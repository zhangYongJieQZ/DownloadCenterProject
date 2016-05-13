//
//  FileDownloadManager.m
//  BaseFrameWork
//
//  Created by 张永杰 on 16/4/29.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import "FileDownloadManager.h"
#import "CommonMethod.h"
#import "FMDBObject.h"

static FileDownloadManager *fileDownloadManager = nil;

@interface FileDownloadManager ()

@property (nonatomic, strong)NSMutableDictionary    *downloadDit;//存放operation,防止重复创建
@property (nonatomic, strong)NSOperationQueue       *downloadQueue;//队列管理
@property (nonatomic, strong)dispatch_queue_t       barrierQueue;
@property (nonatomic, strong)FMDBObject             *downloadSqlite;

@end

@implementation FileDownloadManager

+ (FileDownloadManager *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (fileDownloadManager == nil) {
            fileDownloadManager = [[FileDownloadManager alloc] init];
        }
    });
    return fileDownloadManager;
}

- (instancetype)init{
    if (self = [super init]) {
        _downloadDit = [NSMutableDictionary new];
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 3;
        _barrierQueue = dispatch_queue_create("my.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
        _downloadSqlite = [FMDBObject shareInstance];
    }
    return self;
}

- (NSArray *)allTheOperation{
    return self.downloadQueue.operations;
}

- (void)addDownloadOperationWithURLString:(NSString *)urlString{
    if (self.downloadDit[urlString]) {
        
    }else{
        //发送开始通知(防止多个界面有相同的下载显示)
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@%@",FileDownloadStartNotification,urlString] object:nil];
        
        [self insertSqlWithUrlString:urlString];
        
        FileDownloadOperation *operation = [[FileDownloadOperation alloc] initWithRequest:urlString progerssBlock:^(long long receivedSize, long long expectedSize,long long originSize) {
            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@%@",FileDownloadingChangeNotification,urlString] object:@{dataSizeKey:[NSNumber numberWithLongLong:receivedSize],fileSizeKey:[NSNumber numberWithLongLong:expectedSize],originSizeKey:[NSNumber numberWithLongLong:originSize]}];
            [self updateDataWithKeyAttributesDit:@{
                                                  FMDownloadSize:[NSNumber numberWithLongLong:receivedSize],
                                                  FMFileSize:[NSNumber numberWithLongLong:expectedSize],
                                                  FMDownloadStatus:[NSNumber numberWithInteger:FileDownloading]} andSearchConditions:@{
                                                                                                                                        FMDownloadUrl:urlString                                                                                }];
            
        } completeBlock:^(NSString *filePath, NSData *data, NSError *error) {
            if (error == nil) {
                [[NSNotificationCenter defaultCenter]postNotificationName:[NSString stringWithFormat:@"%@%@",FileDownloadFinishNotification,urlString] object:@{@"filePath":filePath,@"data":data}];
            }else{
                [[NSNotificationCenter defaultCenter]postNotificationName:[NSString stringWithFormat:@"%@%@",FileDownloadFailureNotification,urlString] object:@{@"error":error}];
            }
            
            
            [self updateDataWithKeyAttributesDit:@{FMDownloadStatus:[NSNumber numberWithInteger:FileDownloadFinish]} andSearchConditions:@{FMDownloadUrl:urlString}];
            
        } cancelBlock:^{
            
            [[NSNotificationCenter defaultCenter]postNotificationName:[NSString stringWithFormat:@"%@%@",FileDownloadCancelNotification,urlString] object:nil];
            
            [self updateDataWithKeyAttributesDit:@{FMDownloadStatus:[NSNumber numberWithInteger:FileDownloadPause]} andSearchConditions:@{FMDownloadUrl:urlString}];
            
            [self.downloadDit removeObjectForKey:urlString];
        }];
        
        dispatch_barrier_sync(self.barrierQueue, ^{
            [self.downloadQueue addOperation:operation];
            self.downloadDit[urlString] = operation;
        });
    }
}

- (FileDownloadOperation *)downloadOperationExistWithUrl:(NSString *)urlString{
    FileDownloadOperation *operation = nil;
    if (self.downloadDit[urlString]) {
        operation = self.downloadDit[urlString];
        return operation;
    }else{
        return nil;
    }
}

- (void)cancelOperationWithUrl:(NSString *)urlString{
    [[self downloadOperationExistWithUrl:urlString]cancel];
}

- (void)dealloc{
    [_downloadQueue cancelAllOperations];
}

#pragma mark - sql

- (void)insertSqlWithUrlString:(NSString *)urlString{
    [self.downloadSqlite searchDataWithKeyAttributesDit:@{FMDownloadUrl:urlString} block:^(NSArray *dataArray) {
        if (dataArray.count == 0) {
            //需要延时,不然会造成同时访问FMDatabaseQueue报错
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.downloadSqlite insertWithKeyAttributesDit:@{FMDownloadUrl:urlString,FMDownloadSize:[NSNumber numberWithLongLong:0],FMFileSize:[NSNumber numberWithLongLong:0],FMDownloadStatus:[NSNumber numberWithInteger:1],FMDownloadSpeed:@"0KB/S"} andResultBlock:^(BOOL result, NSError *error) {
                    
                }];
            });
        }
    }];
}

- (void)updateDataWithKeyAttributesDit:(NSDictionary *)attributesDit andSearchConditions:(NSDictionary *)conditionsDit{
    [self.downloadSqlite updateDataWithKeyAttributesDit:attributesDit andSearchConditions:conditionsDit resultBlock:^(BOOL result, NSError *error) {
        
    }];
}

@end
