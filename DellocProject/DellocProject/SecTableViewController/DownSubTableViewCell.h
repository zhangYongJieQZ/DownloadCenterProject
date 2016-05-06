//
//  DownSubTableViewCell.h
//  DellocProject
//
//  Created by 张永杰 on 16/5/6.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import "DownLoadTableViewCell.h"

@interface DownSubTableViewCell : DownLoadTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *themeLabel;

@property (weak, nonatomic) IBOutlet UILabel *sppedLaebl;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@end
