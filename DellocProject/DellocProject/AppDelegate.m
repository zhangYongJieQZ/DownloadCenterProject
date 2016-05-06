//
//  AppDelegate.m
//  DellocProject
//
//  Created by 张永杰 on 16/5/4.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import "AppDelegate.h"
#import "FMDBObject.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //初始化时遍历数据库。。修正因退出程序而造成的状态不正确问题
    [[FMDBObject shareInstance]searchAllDataWithblock:^(NSArray *dataArray) {
        if (dataArray.count > 0) {
            for (NSDictionary *dit in dataArray) {
                if ([[dit valueForKey:FMDownloadStatus]integerValue] == 2 || [[dit valueForKey:FMDownloadStatus]integerValue] == 1) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[FMDBObject shareInstance]updateDataWithKeyAttributesDit:@{FMDownloadStatus:[NSNumber numberWithInteger:5]} andSearchConditions:@{FMDownloadUrl:[dit valueForKey:FMDownloadUrl]} resultBlock:^(BOOL result, NSError *error) {
                            
                        }];
                    });
                }
            }
        }
    }];
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
