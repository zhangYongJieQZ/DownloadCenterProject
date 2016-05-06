//
//  UIButton+Download.m
//  BaseFrameWork
//
//  Created by 张永杰 on 16/5/3.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import "UIButton+Download.h"
#import "FileDownloadManager.h"
#import "FileDownloadOperation.h"
#import <objc/runtime.h>
#import "FMDBObject.h"
static NSString *operationString       = @"operationString";
static NSString *downloadStatusString  = @"downloadStatusString";
static NSString *downloadUrlString     = @"downloadUrl";
static NSString *percentString         = @"percentString";

@interface UIButton ()

@property (nonatomic, assign)float  percent;

@end

@implementation UIButton (Download)

#pragma mark - property

- (void)setPercent:(float)percent{
    objc_setAssociatedObject(self, &percentString, [NSNumber numberWithFloat:percent], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (float)percent{
    NSNumber *percentNumber = objc_getAssociatedObject(self, &percentString);
    return [percentNumber floatValue];
}

- (void)setDownloadStatus:(FileDownloadStatus)downloadStatus{
    mainQueue(^{
        switch (downloadStatus) {
            case FileDownloadNormal:{
                [self setTitle:@"任务" forState:UIControlStateNormal];
                self.percent = 0;
                [self setNeedsDisplay];
            }
                break;
            case FileDownloadWait:{
                [self setTitle:@"等待" forState:UIControlStateNormal];
            }
                break;
            case FileDownloading:{
                [self setTitle:@"下载中" forState:UIControlStateNormal];
            }
                break;
            case FileDownloadPause:{
                [self setTitle:@"暂停" forState:UIControlStateNormal];
            }
                break;
            case FileDownloadFailure:{
                [self setTitle:@"下载失败" forState:UIControlStateNormal];
            }
                break;
            case FileDownloadFinish:{
                [self setTitle:@"下载完成" forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
    });
    objc_setAssociatedObject(self, &downloadStatusString, [NSNumber numberWithInteger:downloadStatus], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (FileDownloadStatus)downloadStatus{
    NSNumber *number = objc_getAssociatedObject(self, &downloadStatusString);
    return [number integerValue];
}

- (void)setDownloadUrl:(NSString *)downloadUrl{
    return objc_setAssociatedObject(self, &downloadUrlString, downloadUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)downloadUrl{
    return objc_getAssociatedObject(self, &downloadUrlString);
}


- (void)calculatePercentWithDownloadSize:(long long)downloadSize fileSize:(long long)fileSize {
    if (downloadSize!= 0 && fileSize != 0) {
        self.percent = (1.0 * downloadSize / fileSize);
         [self setNeedsDisplay];
    }
}

- (void)normalStatusWithURLString:(NSString *)urlString{
    self.downloadUrl = urlString;
    
    [[FMDBObject shareInstance]searchDataWithKeyAttributesDit:@{FMDownloadUrl:urlString} block:^(NSArray *dataArray) {
        if (dataArray.count > 0) {
//            NSLog(@"dataArray = %@",dataArray);
            for (NSDictionary *dit in dataArray) {
                if ([[dit valueForKey:FMDownloadUrl] isEqualToString:urlString]) {
                    self.downloadStatus = [[dit valueForKey:FMDownloadStatus]integerValue];
                    [self calculatePercentWithDownloadSize:[[dit valueForKey:FMDownloadSize]longLongValue] fileSize:[[dit valueForKey:FMFileSize]longLongValue]];
                }
            }
        }
    }];
}

- (void)buttonClick{
    switch (self.downloadStatus) {
        case FileDownloadNormal:{
            [self downloadOperationStart];
        }
            break;
        case FileDownloadWait:{
            
        }
            break;
        case FileDownloading:{
            [self downloadOperationPause];
        }
            break;
        case FileDownloadPause:{
            [self downloadOperationStart];
        }
            break;
        case FileDownloadFailure:{
            [self downloadOperationStart];
        }
            break;
        case FileDownloadFinish:{
            
        }
            break;
        default:
            break;
    }
}

- (void)downloadOperationStart{
    NSLog(@"downloadOperationStart");
    self.downloadStatus = FileDownloadWait;
    backQueue(^{
        [[FileDownloadManager shareInstance]addDownloadOperationWithURLString:self.downloadUrl];
    });
}

- (void)downloadOperationPause{
    [[FileDownloadManager shareInstance]cancelOperationWithUrl:self.downloadUrl];
}

- (void)drawRect:(CGRect)rect{
    if (self.percent != 0) {
        CGRect newRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width * self.percent, rect.size.height);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path,NULL,newRect);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextAddPath(currentContext, path);
        [[UIColor clearColor] setStroke];
        CGContextSetLineWidth(currentContext,0.f);
        [[UIColor redColor]setFill];
        CGContextDrawPath(currentContext, kCGPathFillStroke);
        CGPathRelease(path);
    }
}

@end
