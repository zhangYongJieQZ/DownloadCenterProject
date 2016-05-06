//
//  NSString+CommonMethod.m
//  ZYJMoviePlayer
//
//  Created by 张永杰 on 16/4/14.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import "NSString+CommonMethod.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (CommonMethod)

- (NSString *)md5{
    const char *str = [self UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%@",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                          r[11], r[12], r[13], r[14], r[15], [[self pathExtension] isEqualToString:@""] ? @"" : [NSString stringWithFormat:@".%@", [self pathExtension]]];
    return filename;
}

- (NSString *)pinYin{
//    const char *str = [self cStringUsingEncoding:NSUTF8StringEncoding];
//    
//    CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, CFSTR(self.string));
//    CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, NO);

    return self;
}

@end
