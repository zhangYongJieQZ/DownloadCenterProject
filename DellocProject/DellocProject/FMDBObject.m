//
//  FMDBObject.m
//  BaseFrameWork
//
//  Created by 张永杰 on 16/4/7.
//  Copyright © 2016年 张永杰. All rights reserved.
//

#import "FMDBObject.h"
#import <FMDB/FMDB.h>
#import "CommonMethod.h"
@interface FMDBObject ()
@property (nonatomic, strong)FMDatabaseQueue *dbQueue;
@property (nonatomic, strong)NSString        *tableName;
@property (nonatomic, strong)NSDictionary    *attributesDit;

@end
static FMDBObject *fmdbOjc = nil;
@implementation FMDBObject

+ (FMDBObject *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (fmdbOjc == nil) {
            fmdbOjc = [[FMDBObject alloc] initWithTablePath:@"DownloadFile.sqlite" andTableName:@"DownloadFile" andKeyAttributesDit:@{
                                                                                                                                                        FMDownloadUrl:FMText,FMDownloadSize:FMLongLong,FMFileSize:FMLongLong,FMDownloadStatus:FMInteger}];
        }
    });
    return fmdbOjc;
}

- (instancetype)initWithTablePath:(NSString *)path andTableName:(NSString *)tableName andKeyAttributesDit:(NSDictionary *)attributesDit{
    if (self = [super init]) {
        //1.获得数据库文件的路径
        _tableName = tableName;
        _attributesDit = attributesDit;
        NSString *doc=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fileName=[doc stringByAppendingPathComponent:path];
        self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:fileName];
        //创建SQL语句创建表格
        NSString *attributesStr = @"id integer PRIMARY KEY AUTOINCREMENT, ";
        for (NSString *str in attributesDit.allKeys) {
            attributesStr = [attributesStr stringByAppendingFormat:@"%@ %@ NOT NULL,",str,[attributesDit valueForKey:str]];
        }
        if ([attributesStr hasSuffix:@","]) {
            attributesStr = [attributesStr substringToIndex:attributesStr.length - 1];
        }
        NSString *createSQLStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@);",tableName,attributesStr];
        //3.打开数据库
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            if ([db open]) {
                //4.创表
                BOOL result=[db executeUpdate:createSQLStr];
                if (result) {
                    NSLog(@"创表成功");
                }else {
                    NSLog(@"创表失败");
                }
            }
        }];
        
    }
    return self;
}

- (void)insertWithKeyAttributesDit:(NSDictionary *)attributesDit andResultBlock:(sqlQueryResultBlock)block{
    NSString *keyString = @"";
    NSString *valueString = @"";
    for (NSString *keyS in attributesDit.allKeys) {
        keyString = [keyString stringByAppendingFormat:@"%@, ",keyS];
        valueString = [valueString stringByAppendingFormat:@"?, "];
    }
    
    if ([keyString hasSuffix:@", "]) {
        keyString = [keyString substringToIndex:keyString.length - 2];
    }
    
    if ([valueString hasSuffix:@", "]) {
        valueString = [valueString substringToIndex:valueString.length - 2];
    }

    NSString *sqlStr = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@);",self.tableName,keyString,valueString];

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSError *error = nil;
        BOOL isUpDataSuccess = [db executeUpdate:sqlStr values:attributesDit.allValues error:&error];
        block(isUpDataSuccess, error);
        NSLog(@"isUpDataSuccess = %d",isUpDataSuccess);
    }];
}

- (void)deleteWithKeyAttributesDit:(NSDictionary *)attributesDit andResultBlock:(sqlQueryResultBlock)block{
    NSString *sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE ",self.tableName];
    for (NSString *keyS in attributesDit.allKeys) {
        sqlString = [sqlString stringByAppendingFormat:@"%@ = ? and ",keyS];
    }

    if ([sqlString hasSuffix:@"and "]) {
        sqlString = [sqlString substringToIndex:sqlString.length - 4];
    }

    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSError *error = nil;
        BOOL isDeleteSuccess = [db executeUpdate:sqlString values:attributesDit.allValues error:&error];
        block(isDeleteSuccess, error);
        NSLog(@"isDeleteSuccsee = %d",isDeleteSuccess);
    }];
}

- (void)updateDataWithKeyAttributesDit:(NSDictionary *)attributesDit andSearchConditions:(NSDictionary *)conditionsDit resultBlock:(sqlQueryResultBlock)block{
    NSString *sqlString = [NSString stringWithFormat:@"UPDATE %@ SET ",self.tableName];
    //这里的更新只能用,不能用and连接。。。超坑
    for (NSString *key in attributesDit) {
        sqlString = [sqlString stringByAppendingFormat:@"%@ = ? , ",key];
    }
    if ([sqlString hasSuffix:@", "]) {
        sqlString = [sqlString substringToIndex:sqlString.length - 2];
    }
    sqlString = [sqlString stringByAppendingString:@"WHERE"];
    for (NSString *key in conditionsDit) {
        sqlString = [sqlString stringByAppendingFormat:@" %@ = ? and ",key];
    }
    if ([sqlString hasSuffix:@"and "]) {
        sqlString = [sqlString substringToIndex:sqlString.length - 4];
    }
    NSMutableArray *updateArray = [[NSMutableArray alloc] initWithArray:attributesDit.allValues];
    [updateArray addObjectsFromArray:conditionsDit.allValues];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSError *error = nil;
        BOOL isUpdateSuccess = [db executeUpdate:sqlString values:updateArray error:&error];
        block(isUpdateSuccess, error);
    }];
}

- (void)searchDataWithKeyAttributesDit:(NSDictionary *)attributesDit block:(sqlQueryBlock)block{
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE ",self.tableName];
    for (NSString *keyS in attributesDit.allKeys) {
        sqlString = [sqlString stringByAppendingFormat:@"%@ = ? and ",keyS];
    }
    
    if ([sqlString hasSuffix:@"and "]) {
        sqlString = [sqlString substringToIndex:sqlString.length - 4];
    }
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sqlString values:attributesDit.allValues error:nil];
        block([self getSQLDataWith:resultSet]);
    }];
}

- (void)searchAllDataWithblock:(sqlQueryBlock)block{
    NSString *sqlString = [NSString stringWithFormat:@"SELECT * FROM %@",self.tableName];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:sqlString];
        block([self getSQLDataWith:resultSet]);
    }];
}

- (NSArray *)getSQLDataWith:(FMResultSet *)resultSet{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        NSMutableDictionary *dit = [[NSMutableDictionary alloc] init];
        for (NSString *key in _attributesDit.allKeys) {
            NSString *value = [_attributesDit valueForKey:key];
            if ([value isEqualToString:FMInteger]) {
                [dit setValue:[NSNumber numberWithInt:[resultSet intForColumn:key]] forKey:key];
            }else if ([value isEqualToString:FMText]){
                [dit setValue:[resultSet stringForColumn:key] forKey:key];
            }else if([value isEqualToString:FMBool]){
                [dit setValue:[NSNumber numberWithBool:[resultSet boolForColumn:key]] forKey:key];
            }else if ([value isEqualToString:FMDate]){
                [dit setValue:[resultSet dateForColumn:key] forKey:key];
            }else if ([value isEqualToString:FMLong]){
                [dit setValue:[NSNumber numberWithLong:[resultSet longForColumn:key]] forKey:key];
            }else if ([value isEqualToString:FMBlob]){
                [dit setValue:[resultSet dataForColumn:key] forKey:key];
            }else if ([value isEqualToString:FMLongLong]){
                [dit setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:key]] forKey:key];
            }
        }
        [returnArray addObject:dit];
    }
    return returnArray;
}
@end
