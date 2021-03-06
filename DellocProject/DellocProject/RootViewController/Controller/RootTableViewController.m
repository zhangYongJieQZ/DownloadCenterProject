//
//  RootTableViewController.m
//  DellocProject
//
//  Created by 张永杰 on 16/5/5.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import "RootTableViewController.h"
#import "DownLoadTableViewCell.h"
#import "GetVideoDataTools.h"
#import "UIButton+Download.h"
#import "CommonMethod.h"
#import "NSString+CommonMethod.h"
#import "SecTableViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#define listURL @"http://c.m.163.com/nc/video/home/0-10.html"

@interface RootTableViewController ()

@property (nonatomic, strong)NSArray  *listArray;

@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下载列表";
    [self getData];
    [self createButtonInNavigationBar];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)createButtonInNavigationBar{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    CGSize buttonSize = CGSizeMake(80, 44);
    rightButton.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    [rightButton setTitle:@"下载中心" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
}

- (void)rightButtonClick{
    UIStoryboard *sty = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:[sty instantiateViewControllerWithIdentifier:@"SecTableViewController"] animated:YES];;
}

- (void)getData{
    self.listArray = [NSMutableArray array];
    [[GetVideoDataTools shareDataTools] getHeardDataWithURL:listURL HeardValue:^(NSArray *heardArray, NSArray *videoArray) {
        self.listArray = videoArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentify = @"DownLoadTableViewCell";
    DownLoadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify forIndexPath:indexPath];
    Video *video = self.listArray[indexPath.row];
    [cell registerNotificationCenter:video.mp4_url];
    cell.themeLabel.text = video.title;
    cell.sppedLaebl.text = @"";
    [cell.downloadButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)clickButton:(UIButton *)sender{
    [sender buttonClick];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Video *video = self.listArray[indexPath.row];
    NSString *path = [[CommonMethod createFileName:ZYJDownloadFile] stringByAppendingString:[NSString stringWithFormat:@"/%@",[video.mp4_url md5]]];
    AVPlayerViewController *AVPlayerVC = [[AVPlayerViewController alloc] init];
    AVPlayerVC.player = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:path]];
    [self presentViewController:AVPlayerVC animated:YES completion:^{
        [AVPlayerVC.player play];
    }];
}

@end
