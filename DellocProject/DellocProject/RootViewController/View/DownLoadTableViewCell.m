//
//  DownLoadTableViewCell.m
//  DellocProject
//
//  Created by 张永杰 on 16/5/5.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import "DownLoadTableViewCell.h"
#import "UIButton+Download.h"
#import "FMDBObject.h"
@implementation DownLoadTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

//注册通知
- (void)registerNotificationCenter:(NSString *)urlString inIndexPath:(NSInteger)path{
    [[NSNotificationCenter defaultCenter]removeObserver:self];//免得重用了。。会通知错乱
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startDownload:) name:[NSString stringWithFormat:@"%@%@",FileDownloadStartNotification,urlString] object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pauseDownload:) name:[NSString stringWithFormat:@"%@%@",FileDownloadCancelNotification,urlString] object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(finishedDownload:) name:[NSString stringWithFormat:@"%@%@",FileDownloadFinishNotification,urlString] object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloading:) name:[NSString stringWithFormat:@"%@%@",FileDownloadingChangeNotification,urlString] object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(downloadFailure:) name:[NSString stringWithFormat:@"%@%@",FileDownloadFailureNotification,urlString] object:nil];
    self.downloadButton.downloadUrl = urlString;
    self.downloadButton.tag = path;
    self.downloadButton.percent = 0;
    //初始化,从数据库中读取
    
    [[FMDBObject shareInstance]searchDataWithKeyAttributesDit:@{FMDownloadUrl:urlString} block:^(NSArray *dataArray) {
        if (dataArray.count > 0) {
            for (NSDictionary *dit in dataArray) {
                if ([[dit valueForKey:FMDownloadUrl] isEqualToString:urlString]) {
                    mainQueue(^{
                        self.downloadButton.downloadStatus = [[dit valueForKey:FMDownloadStatus]integerValue];
                        [self.downloadButton calculatePercentWithDownloadSize:[[dit valueForKey:FMDownloadSize]longLongValue] fileSize:[[dit valueForKey:FMFileSize]longLongValue]];
                    });
                }
            }
        }else{
            mainQueue(^{
                self.downloadButton.downloadStatus = FileDownloadNormal;
                [self.downloadButton calculatePercentWithDownloadSize:0 fileSize:0];
            });
        }
    }];
    
}

- (void)downloadFailure:(NSNotification *)notification{
    self.downloadButton.downloadStatus = FileDownloadFailure;
}

- (void)startDownload:(NSNotification *)notification{
    self.downloadButton.downloadStatus = FileDownloadWait;
}

- (void)pauseDownload:(NSNotification *)notification{
    self.downloadButton.downloadStatus = FileDownloadPause;
    self.sppedLaebl.text = @"0KB/S";
}

- (void)finishedDownload:(NSNotification *)notification{
    if ([notification.object valueForKey:@"error"] == nil) {
        self.downloadButton.downloadStatus = FileDownloadFinish;
    }else{
        self.downloadButton.downloadStatus = FileDownloadFailure;
    }
    self.sppedLaebl.text = @"0KB/S";
}

- (void)downloading:(NSNotification *)notification{
    long long orignSize = [[notification.object valueForKey:originSizeKey]longLongValue];
    long long dataSize = [[notification.object valueForKey:dataSizeKey]longLongValue];
    long long fileSize = [[notification.object valueForKey:fileSizeKey]longLongValue];
    NSInteger value = dataSize - orignSize;
    NSString *speedString = @"";
    if (value > 1024 * 1024) {
        speedString = [NSString stringWithFormat:@"%.2fMB/S",value / 1024.0 / 1024];
    }else if (value > 1024){
        speedString = [NSString stringWithFormat:@"%.2fKB/S",value / 1024.0];
    }else{
        if (value == 0) {
            speedString = @"0KB/S";
        }else{
            speedString = [NSString stringWithFormat:@"%dB/S",value];
        }
    }
    mainQueue(^{
        [self.downloadButton calculatePercentWithDownloadSize:dataSize fileSize:fileSize];
        self.sppedLaebl.text = speedString;
        self.downloadButton.downloadStatus = FileDownloading;
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
