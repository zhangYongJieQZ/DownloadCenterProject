//
//  FileDownloadOperation.m
//  BaseFrameWork
//
//  Created by 张永杰 on 16/4/29.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import "FileDownloadOperation.h"
#import "CommonMethod.h"
#import "NSString+CommonMethod.h"
@interface FileDownloadOperation ()<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (nonatomic, strong)FileDownloadProgressBlock  progressBlock;
@property (nonatomic, strong)FileDownloadCompleteBlock  completeBlock;
@property (nonatomic, strong)FileDownloadNoParamsBlock  cancelBlock;
@property (nonatomic, strong)NSString                   *urlString;
@property (nonatomic, strong)NSURLConnection            *connect;
@property (nonatomic, strong)NSMutableData              *data;
@property (nonatomic, assign)long long                  fileSize;
@property (nonatomic, assign)long long                  originSize;//上一秒的大小,用来计算下载速度
@property (nonatomic, assign)BOOL                       hasCancel;

@property (nonatomic, strong)NSTimer                    *timer;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@end

@implementation FileDownloadOperation
@synthesize executing = _executing;
@synthesize finished = _finished;
- (instancetype)initWithRequest:(NSString *)requestUrl
                  progerssBlock:(FileDownloadProgressBlock)progressBlock
                  completeBlock:(FileDownloadCompleteBlock)completeBlock
                    cancelBlock:(FileDownloadNoParamsBlock)cancelBlock{
    if (self = [super init]) {
        _progressBlock = [progressBlock copy];
        _completeBlock = [completeBlock copy];
        _cancelBlock = [cancelBlock copy];
        _executing = NO;
        _finished = NO;
        _urlString = requestUrl;
        NSData *fileData = [NSData dataWithContentsOfFile:[self downloadFilePath]];
        if (fileData.length && fileData) {
            _data = [[NSMutableData alloc] initWithData:fileData];
            _hasCancel = YES;
        }else{
            _data = [[NSMutableData alloc] init];
        }
        
    }
    return self;
}

- (void)start{
    _executing = YES;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    NSString *rangeValue = [NSString stringWithFormat:@"bytes=%lu-", (unsigned long)_data.length];
    [request addValue:rangeValue forHTTPHeaderField:@"Range"];
    if (!self.connect) {
        self.connect = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    }
    [self.connect start];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(repeatDownloadSpeed) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
    
    CFRunLoopRun();//不启用这个的话。。线程无法开始执行
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:FileDownloadStartNotification object:self];
    });
}

- (void)cancel {
    @synchronized (self) {
        [self performSelector:@selector(cancelInternalAndStop) withObject:nil];
    }
}

- (void)cancelInternalAndStop {
    if (self.isFinished) return;
    [self cancelInternal];
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)cancelInternal {
    if (self.isFinished) return;
    [super cancel];
    if (self.cancelBlock) self.cancelBlock();
    
    if (self.connect) {
        [self.connect cancel];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:FileDownloadCancelNotification object:self];
        });
        if (!self.isFinished) self.finished = YES;
        if (self.isExecuting)self.executing = NO;
    }
    [self reset];
}

- (void)repeatDownloadSpeed{
    if (_progressBlock) {
        if (_hasCancel) {//暂停下载会造成网速错误
            _originSize = _data.length;
            _hasCancel = NO;
        }
        _progressBlock(_data.length, _fileSize,_originSize);
    }
    _originSize = _data.length;
}

- (void)reset {
    self.cancelBlock = nil;
    self.completeBlock = nil;
    self.progressBlock = nil;
    self.connect = nil;
    self.data = nil;
    [self.timer invalidate];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    @synchronized(self) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.connect = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:FileDownloadCancelNotification object:self];
        });
    }
    
    if (self.completeBlock) {
        self.completeBlock(nil, nil, error);
    }
    self.completeBlock = nil;
    
    [self done];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    //开启定时器
    [self.timer fire];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]){
        NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
        _fileSize = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue] + _data.length;
//        NSLog(@"%lld",_fileSize);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //写入文件
    [_data appendData:data];
    [_data writeToFile:[self downloadFilePath] atomically:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"%@",[self downloadFilePath]);
    [_data writeToFile:[self downloadFilePath] atomically:YES];
    //防止最后一次传输proBlock没传输成功。(网速是根据前一秒和后一秒的数据差值来计算,这里是为了防止最后一次没传输过去)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (_completeBlock) {
            _completeBlock([self downloadFilePath], _data, nil);
        }
        [self done];
    });
}

- (NSString *)downloadFilePath{
    return [[CommonMethod createFileName:ZYJDownloadFile] stringByAppendingString:[NSString stringWithFormat:@"/%@",[_urlString md5]]];
}

@end
