//
//  UIButton+Download.h
//  BaseFrameWork
//
//  Created by 张永杰 on 16/5/3.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Download)

@property (nonatomic, strong)NSString               *downloadUrl;
@property (nonatomic, assign)FileDownloadStatus     downloadStatus;

- (void)buttonClick;
- (void)calculatePercentWithDownloadSize:(long long)downloadSize fileSize:(long long)fileSize;

@end
