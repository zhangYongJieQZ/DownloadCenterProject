//
//  DownLoadTableViewCell.h
//  DellocProject
//
//  Created by 张永杰 on 16/5/5.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownLoadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *themeLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UILabel *sppedLaebl;

- (void)registerNotificationCenter:(NSString *)urlString inIndexPath:(NSInteger)path;

@end
