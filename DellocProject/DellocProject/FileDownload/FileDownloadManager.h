//
//  FileDownloadManager.h
//  BaseFrameWork
//
//  Created by 张永杰 on 16/4/29.
//  Copyright © 2016年 张永杰. All rights reserved.
//  下载队列管理

#import <Foundation/Foundation.h>
#import "FileDownloadOperation.h"
@interface FileDownloadManager : NSObject

+ (FileDownloadManager *)shareInstance;

//添加下载队列,使用URLString作为唯一标识
- (void)addDownloadOperationWithURLString:(NSString *)urlString;

//取消队列下载
- (void)cancelOperationWithUrl:(NSString *)urlString;

//此方法查看队列的情况
- (NSArray *)allTheOperation;
@end
