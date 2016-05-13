//
//  FMDBObject.h
//  BaseFrameWork
//
//  Created by 张永杰 on 16/4/7.
//  Copyright © 2016年 张永杰. All rights reserved.
//


#import <Foundation/Foundation.h>
@class FMDatabaseQueue;
typedef void(^sqlQueryBlock)(NSArray *dataArray);
typedef void(^sqlQueryResultBlock)(BOOL result, NSError *error);
//一些常用数据类型
static NSString *FMInteger = @"integer";
static NSString *FMText    = @"text";//文本
static NSString *FMBool    = @"bool";
static NSString *FMDate    = @"date";//日期
static NSString *FMLong    = @"long";
static NSString *FMLongLong= @"long long";
static NSString *FMBlob    = @"blob";//二进制数据(储存图片)
//数据库键值
static NSString *FMDownloadUrl = @"downloadUrl";
static NSString *FMDownloadSize = @"downloadSize";
static NSString *FMFileSize = @"fileSize";
static NSString *FMDownloadStatus = @"downloadStatus";
static NSString *FMDownloadSpeed = @"downloadSpeed";

@interface FMDBObject : NSObject

+ (FMDBObject *)shareInstance;
/**
 *  建立表格
 *  @param path      路径(eg:student.sqlite)->默认在documents文件下
 *  @param tableName 表格名字
 *  @param attributesDit 键值属性{@"name":@"text"} -> name键名  text键属性
 *
 *  @return
 */
- (instancetype)initWithTablePath:(NSString *)path andTableName:(NSString *)tableName andKeyAttributesDit:(NSDictionary *)attributesDit;

/**
 *  插入表格数据(或者更新表格数据)
 *
 *  @param attributesDit @{@"name":@"java"} ->name 键名, java键值
 */
- (void)insertWithKeyAttributesDit:(NSDictionary *)attributesDit andResultBlock:(sqlQueryResultBlock)block;

/**
 *  删除表格数据
 *
 *  @param attributesDit @{@"name":@"java"} ->name 键名, java键值
 */
- (void)deleteWithKeyAttributesDit:(NSDictionary *)attributesDit andResultBlock:(sqlQueryResultBlock)block;

/**
 *  查询表格所有数据
 *
 *  @param attributesDit
 *
 *  @return 数组@(@{@"name":@"java"...}); - >后期在转成model的数据类型即可
 */
- (void)searchAllDataWithblock:(sqlQueryBlock)block;

/**
 *  搜索数据
 *
 *  @param attributesDit @{@"name":@"java"} ->name 键名, java键值
 *
 *  @return @(@{@"name":@"java"...}); - >后期在转成model的数据类型即可
 */
- (void)searchDataWithKeyAttributesDit:(NSDictionary *)attributesDit block:(sqlQueryBlock)block;

/**
 *  更新数据库
 *
 *  @param attributesDit  更新的字段
 *  @param attributesDit  不变的字段
 */
- (void)updateDataWithKeyAttributesDit:(NSDictionary *)attributesDit andSearchConditions:(NSDictionary *)conditionsDit resultBlock:(sqlQueryResultBlock)block;

@end
