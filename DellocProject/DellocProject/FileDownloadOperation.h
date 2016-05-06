//
//  FileDownloadOperation.h
//  BaseFrameWork
//
//  Created by 张永杰 on 16/4/29.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#define KB(size) [NSString stringWithFormat:@"%.2lld/KB",size / 1024];
#define MB(size) [NSString stringWithFormat:@"%.2lld/MB",size / 1024 / 1024];
#define GB(size) [NSString stringWithFormat:@"%.2lld/GB",size / 1024 / 1024 / 1024];

#define NetSpeed(size) if(size / 1024 < 1024) {KB(size)} else {MB(size)}
#import <Foundation/Foundation.h>

typedef void(^FileDownloadProgressBlock)(long long receivedSize, long long expectedSize, long long originSize);
typedef void(^FileDownloadCompleteBlock)(NSString *filePath, NSData *data, NSError *error);
typedef void(^FileDownloadNoParamsBlock)();

@interface FileDownloadOperation : NSOperation

@property (nonatomic, assign)BOOL  isDownload;
@property (nonatomic, assign)BOOL  isCancel;


- (instancetype)initWithRequest:(NSString *)requestUrl
                  progerssBlock:(FileDownloadProgressBlock)progressBlock
                  completeBlock:(FileDownloadCompleteBlock)completeBlock
                    cancelBlock:(FileDownloadNoParamsBlock)cancelBlock;

@end
