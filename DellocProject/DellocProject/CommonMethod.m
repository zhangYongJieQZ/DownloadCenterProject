//
//  CommonMethod.m
//  BaseFrameWork
//
//  Created by 张永杰 on 16/4/28.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import "CommonMethod.h"

@implementation CommonMethod

+ (void)pastedboardCopyWithStr:(NSString *)string{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:string];
}

+ (NSString *)pastedboardPaste{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    return pasteboard.string;
}

+ (void)callPhoneNumber:(NSString *)phoneNumber{

    NSString *url=[NSString stringWithFormat:@"telprompt://%@",phoneNumber];//这种方式会提示用户确认是否拨打电话
    [self openUrl:url];
}

+ (void)sendMessage:(NSString *)phoneNumber{
    NSString *url=[NSString stringWithFormat:@"sms://%@",phoneNumber];
    [self openUrl:url];
}

+ (void)sendEmail:(NSString *)email{
    NSString *url=[NSString stringWithFormat:@"mailto://%@",email];
    [self openUrl:url];
}

+ (void)browserWeb:(NSString *)webUrl{
    [self openUrl:webUrl];
}

+ (NSString *)getSandboxPath{
    NSString *dirHome=NSHomeDirectory();//沙盒路径
    return dirHome;
}

+ (NSString *)getDocumentPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//Documents目录路径
    return documentsDirectory;
}

+ (NSString *)getLibraryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0]; //Library目录路径
    return libraryDirectory;
}

+ (NSString *)getCachePath{
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cacPath objectAtIndex:0]; //Cache目录路径
    return cachePath;
}

+ (NSString *)getTmpPath{
    NSString *tmpDirectory = NSTemporaryDirectory();//Tmp目录路径
    return tmpDirectory;
}

+ (NSString *)createFileName:(NSString *)name{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *testDirectory = [[self getDocumentPath] stringByAppendingPathComponent:name];     // 创建目录
    if (![fileManager fileExistsAtPath:testDirectory]) {
        BOOL res=[fileManager createDirectoryAtPath:testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        if (res) {
            NSLog(@"文件夹创建成功");
        }else{
            NSLog(@"文件夹创建失败");
        }
    }
    return testDirectory;
}


#pragma - mark private

+ (void)openUrl:(NSString *)urlStr{
    NSURL *url=[NSURL URLWithString:urlStr];
    UIApplication *application=[UIApplication sharedApplication];
    if(![application canOpenURL:url]){
        NSLog(@"无法打开\"%@\"，请确保此应用已经正确安装.",url);
        return;
    }
    [[UIApplication sharedApplication] openURL:url];
}
@end
