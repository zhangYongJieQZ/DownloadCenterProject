//
//  CommonMethod.h
//  BaseFrameWork
//
//  Created by 张永杰 on 16/4/28.
//  Copyright © 2016年 张永杰. All rights reserved.
//  常用方法集合

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CommonMethod : NSObject
/**
 *  复制
 *
 *  @param string
 */
+ (void)pastedboardCopyWithStr:(NSString *)string;
/**
 *  粘贴
 *
 *  @return
 */
+ (NSString *)pastedboardPaste;
/**
 *  打电话
 *
 *  @param phoneNumber
 */
+ (void)callPhoneNumber:(NSString *)phoneNumber;
/**
 *  发短信
 *
 *  @param phoneNumber
 */
+ (void)sendMessage:(NSString *)phoneNumber;
/**
 *  发邮件
 *
 *  @param email
 */
+ (void)sendEmail:(NSString *)email;
/**
 *  打开网页
 *
 *  @param webUrl 
 */
+ (void)browserWeb:(NSString *)webUrl;
/**
 *  沙盒路径
 *
 *  @return
 */
+ (NSString *)getSandboxPath;
/**
 *  document路径
 *
 *  @return
 */
+ (NSString *)getDocumentPath;
/**
 *  library路径
 *
 *  @return
 */
+ (NSString *)getLibraryPath;
/**
 *  cache路径
 *
 *  @return
 */
+ (NSString *)getCachePath;
/**
 *  tep路径
 *
 *  @return 
 */
+ (NSString *)getTmpPath;
/**
 *  创建文件夹
 *
 *  @param name 文件夹名
 *
 *  @return 
 */
+ (NSString *)createFileName:(NSString *)name;


@end
