//
//  SecTableViewController.m
//  DellocProject
//
//  Created by 张永杰 on 16/5/6.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import "SecTableViewController.h"
#import "DownSubTableViewCell.h"
#import "GetVideoDataTools.h"
#import "UIButton+Download.h"
#import "CommonMethod.h"
#import <MediaPlayer/MediaPlayer.h>
#import "NSString+CommonMethod.h"
#define listURL @"http://c.m.163.com/nc/video/home/0-10.html"

@interface SecTableViewController ()
@property (nonatomic, strong)NSArray   *listArray;
@end

@implementation SecTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"下载中心";
    [self getData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    static NSString *cellIdentify = @"DownSubTableViewCell";
    DownSubTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify forIndexPath:indexPath];
    Video *video = self.listArray[indexPath.row];
    [cell registerNotificationCenter:video.mp4_url];
    cell.themeLabel.text = video.title;
    //    [cell.downloadButton normalStatusWithURLString: video.mp4_url];
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
    
    MPMoviePlayerViewController *moviePlayer = [ [ MPMoviePlayerViewController alloc]initWithContentURL:[NSURL fileURLWithPath:path]];
    [self presentMoviePlayerViewControllerAnimated:moviePlayer];
    //    [self.view addSubview:moviePlayer.view];
    //    [self presentViewController:moviePlayer animated:YES completion:nil];
}

@end
