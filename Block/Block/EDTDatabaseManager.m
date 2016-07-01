//
//  EDTDatabaseManager.m
//  Block
//
//  Created by lkm on 16/6/22.
//  Copyright © 2016年 jueyin. All rights reserved.
//

#import "EDTDatabaseManager.h"
#import <FMDB/FMDB.h>
#import <objc/runtime.h>

/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT" //字符串文本
#define SQLINTEGER  @"INTEGER" //带符号的整型，具体取决有存入数字的范围大小
#define SQLREAL     @"REAL" //浮点数字，存储为8-byte IEEE浮点数
#define SQLBLOB     @"BLOB" //二进制对象
#define SQLNULL     @"NULL" //空值


#define PrimaryKey  @"primary key"

#define primaryId   @"pk"

static EDTDatabaseManager * dataManager;
static FMDatabase * db = nil;

@interface EDTDatabaseManager ()


//数据库串行队列
@property (nonatomic, strong)dispatch_queue_t  databaseSerialQueue;

@end

@implementation EDTDatabaseManager


+ (EDTDatabaseManager *)shareInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[EDTDatabaseManager alloc]init];
    });
    
    return dataManager;
}

- (dispatch_queue_t)databaseSerialQueue {
    if (!_databaseSerialQueue) {
        
        _databaseSerialQueue =
        dispatch_queue_create("com.ConcurrentQueue",
                              DISPATCH_QUEUE_CONCURRENT);
    }
    return _databaseSerialQueue;
}


#pragma mark private method

/**
 *  把资源文件中的db copy 到 document 目录下
 *
 *  @param dbName  表名
 *
 *  @return 是否成功操作
 */

- (BOOL)copySourceDBToDocument:(NSString *)dbName {
    
    NSString * documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) [0];
    NSLog(@"%@",documentPath);
    NSString * dbDirectoryPath = [NSString stringWithFormat:@"%@%@",
                                  documentPath,
                                  @"/db"];
    //检查沙盒根目录下有没有指定的 专门的数据库文件夹 （该文件夹命名为 db）
    if ([[NSFileManager defaultManager]fileExistsAtPath:dbDirectoryPath]) {
        NSLog(@"沙盒目录存在db文件夹");
        //获取资源文件路径
        NSString * dbSourcePath = [[NSBundle mainBundle] pathForResource:dbName
                                                                  ofType:@"sqlite"];
        //检查沙盒文件目录有没有该数据库
        NSString * dbFilePath = [NSString stringWithFormat:@"%@/%@",
                                 dbDirectoryPath,dbName];
        if ([[NSFileManager defaultManager]
             fileExistsAtPath:dbFilePath]) {
            return YES;
        }else {
            BOOL  copySatus = [[NSFileManager defaultManager]
                               copyItemAtPath:dbSourcePath
                               toPath:[NSString stringWithFormat:@"%@%@",
                                       dbFilePath,@".sqlite"]
                               error:nil];
            return copySatus;
        }
        
        
    }else {
        NSLog(@"沙盒目录不存在db文件夹，立即创建db目录");
        BOOL createDirStatus = [[NSFileManager defaultManager]
                                createDirectoryAtPath:dbDirectoryPath
                                withIntermediateDirectories:YES
                                attributes:nil
                                error:nil];
        if (createDirStatus) {
            //获取资源文件路径
            NSString * dbSourcePath = [[NSBundle mainBundle]
                                       pathForResource:dbName ofType:@"sqlite"];
            NSLog(@"%@",dbSourcePath);
            //检查沙盒文件目录有没有该数据库
            NSString * dbFilePath = [NSString stringWithFormat:@"%@/%@",
                                     dbDirectoryPath,dbName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:dbFilePath]) {
                return YES;
            }else {
                BOOL  copySatus = [[NSFileManager defaultManager]
                                   copyItemAtPath:dbSourcePath
                                   toPath:[NSString stringWithFormat:@"%@%@",
                                           dbFilePath,@".sqlite"]
                                   error:nil];
                return copySatus;
            }
            
        }else {
            
            return NO;
        }
        
        
        
    }
    
    return NO;
}


/**
 *  通过runtime 便利model 属性，类型来创建table
 *
 *  @param model 数据源
 *
 *  @return 拼接好的字符
 */
- (NSString *)getColumeAndTypeString:(id)model pk:(NSString *)pk {
    
    NSMutableString * columeAndTypeString = [NSMutableString string];
    NSMutableArray * propertyNameArray = [NSMutableArray array];
    NSMutableArray * propertyTypeArray = [NSMutableArray array];
    unsigned int outCount = 0;
    objc_property_t * propertyList = class_copyPropertyList([model class],&outCount);
    for (int i = 0; i < outCount; i++) {
        //属性名
        NSString * propertyName = @(property_getName(propertyList[i]));
        NSLog(@"%@",propertyName);
        [propertyNameArray addObject:propertyName];
        //属性类型
        NSString * propertyType = @(property_getAttributes(propertyList[i]));
        NSLog(@"%@",propertyType);
        if ([propertyType hasPrefix:@"T@"]) {
            [propertyTypeArray addObject:SQLTEXT];
        } else if ([propertyType hasPrefix:@"Ti"]||
                   [propertyType hasPrefix:@"TI"]||
                   [propertyType hasPrefix:@"Ts"]||
                   [propertyType hasPrefix:@"TS"]||
                   [propertyType hasPrefix:@"TB"]||
                   [propertyType hasPrefix:@"Tq"]||
                   [propertyType hasPrefix:@"TQ"]) {
            [propertyTypeArray addObject:SQLINTEGER];
        } else {
            [propertyTypeArray addObject:SQLREAL];
        }
        
    }
    
    for (int i = 0; i < outCount; i++) {
        //
        [columeAndTypeString appendFormat:@"%@ %@",propertyNameArray[i],
         propertyTypeArray[i]];
        
        if ([pk isEqualToString:propertyNameArray[i]]) {
            [columeAndTypeString appendString:@" primary key"];
        }
        
        if(i+1 != outCount)
        {
            [columeAndTypeString appendString:@","];
        }
    }
    
    free(propertyList);
    NSLog(@"%@",columeAndTypeString);
    return columeAndTypeString;
}



#pragma mark public method

/**
 *  开启数据库
 *
 *  @param dbName db名字，方法将dbName 转成path
 *
 *  @return 开启结果返回
 */
- (BOOL)openDB:(NSString *)dbName {
    
    [self copySourceDBToDocument:dbName];
    NSString * documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) [0];
    NSString * dbDirectoryPath = [NSString stringWithFormat:@"%@%@",
                                  documentPath,
                                  @"/db"];
    NSString * dbPath = [NSString stringWithFormat:@"%@/%@.sqlite",
                         dbDirectoryPath,
                         dbName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath]) {
        db = [FMDatabase databaseWithPath:dbPath];
        if (db) {
            return  [db open];
        }
    }
    
    NSAssert([db open], @"db不能open");
    return NO;
}




/**
 *  关闭数据库
 *
 *  @param dbName db名字，方法将dbName 转成path
 *
 *  @return 关闭结果返回
 */

- (BOOL)closeDB:(NSString *)dbName {
    if (db) {
        return  [db close];
    }
    NSLog(@"db关闭异常，请检查db是否为nil");
    return NO;
}

/**
 *  获取字段
 *
 *  @param tableName 表名
 *
 *  @return 返回字段数组
 */
- (NSArray *)getColumnsInTable:(NSString *)tableName {
    
    NSMutableArray * columnsArray = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        NSString *column = [resultSet stringForColumn:@"name"];
        [columnsArray addObject:column];
    }
    
    return [columnsArray copy];
}



/**
 *  获取字段类型
 *
 *  @param tableName tableName
 *
 *  @return 返回字段类型
 */
- (NSArray *)getColumnsType:(NSString *)tableName {
    const char * className = [tableName UTF8String];
    Class kclass = objc_getClass(className);
    if (!kclass)
    {
        Class superClass = [NSObject class];
        kclass = objc_allocateClassPair(superClass, className, 0);
    }
    
    objc_registerClassPair(kclass);
    id instance = [[kclass alloc] init];
    unsigned int outCount = 0;
    objc_property_t * propertyList = class_copyPropertyList([instance class],&outCount);
    NSMutableArray * propertyTypeArray = [NSMutableArray array];
    for (int i = 0; i < [self getColumnsInTable:tableName].count; i++) {
        //属性名
        //属性类型
        NSString * propertyType = @(property_getAttributes(propertyList[i]));
        NSLog(@"%@",propertyType);
        if ([propertyType hasPrefix:@"T@"]) {
            [propertyTypeArray addObject:SQLTEXT];
        } else if ([propertyType hasPrefix:@"Ti"]||
                   [propertyType hasPrefix:@"TI"]||
                   [propertyType hasPrefix:@"Ts"]||
                   [propertyType hasPrefix:@"TS"]||
                   [propertyType hasPrefix:@"TB"]||
                   [propertyType hasPrefix:@"Tq"]||
                   [propertyType hasPrefix:@"TQ"]) {
            [propertyTypeArray addObject:SQLINTEGER];
        } else {
            [propertyTypeArray addObject:SQLREAL];
        }
        
    }
    
    return propertyTypeArray;
}





#pragma mark 增删改查

/**
 *  创建一张表
 *
 *  @param tableName    表名
 *  @param dbName       数据库名
 *  @param model        根据model字段进行数据库字段创建
 *  @param successBlock 操作回调
 *
 *  @return 返回创建状态
 */
- (BOOL)createTable:(NSString *)tableName
                 pk:(NSString *)pk
              model:(id)model
            Success:(SuccessBlock)successBlock {
    
    BOOL res = YES;
    NSString * columeAndTypeString = [self getColumeAndTypeString:model pk:pk];
    NSString * sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);",
                      tableName,columeAndTypeString];
    NSLog(@"%@",sql);
    
    if (![db executeUpdate:sql]) {
        res = NO;
    }
    
    successBlock(res);
    return res;
    
}


/**
 *  插入模型
 *
 *  @param tableName 表名
 *  @param model     model
 * 
 *  @param SuccessBlock 操作回调
 *  @return 插入状态返回
 */

- (BOOL)executeUpdateWithTableName:(NSString *)tableName
                             model:(id)model
                            handle:(SuccessBlock)successBlock {
    
    BOOL sdf = [db tableExists:tableName];
    NSLog(@"%d",sdf);
    if ([db tableExists:tableName]) {
        unsigned int outCount = 0;
        objc_property_t * propertyList = class_copyPropertyList([model class],&outCount);
        //借鉴
        NSMutableString * keyString = [NSMutableString string];
        NSMutableString * valueString = [NSMutableString string];
        NSMutableArray * insertValues = [NSMutableArray array];
        for (int i = 0; i <outCount; i++) {
            NSString *proname = [[dataManager getColumnsInTable:tableName] objectAtIndex:i];
            if ([proname isEqualToString:primaryId]) {
                continue;
            }
            [keyString appendFormat:@"%@,", proname];
            [valueString appendString:@"?,"];
            id value = [model valueForKey:proname];
            if (!value) {
                value = @"";
            }
            [insertValues addObject:value];
            
        }
        [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
        [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
        NSLog(@"%@",keyString);
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);",
                         tableName, keyString, valueString];
        NSLog(@"%@",sql);
        BOOL flag = [db executeUpdate:sql withArgumentsInArray:insertValues];
        successBlock(flag);
        return flag;
    }else {
        NSAssert([db tableExists:tableName],@"不存在表");
    }
    
    return NO;
}


/**
 *  删除模型
 *
 *  @param model 用model的类名 进行查表
 *
 *  @return 返回操作结果
 */
- (BOOL)deleteDataWithModel:(id)model
                         pk:(NSString *)pk
                     handle:(SuccessBlock)successBlock {
    
    BOOL hasPkInTable = NO;
    id valueWithPK;
    BOOL res = NO;
    if ([db tableExists:[NSString stringWithUTF8String:object_getClassName(model)]]) {
        unsigned int outCount = 0;
        objc_property_t * propertyList = class_copyPropertyList([model class],&outCount);
        for (int i = 0; i < outCount; i++) {
            if ([pk isEqualToString:@(property_getName(propertyList[i]))]) {
                hasPkInTable = YES;
                valueWithPK = [model valueForKey:pk];
                if (!valueWithPK || valueWithPK <= 0) {
                    NSLog(@"pk有问题,!valueWithPK || valueWithPK <= 0");
                }
            }
        }
        
        if (!hasPkInTable) {
            NSLog(@"pk 在表中不存在！");
        }else {
            NSString * sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",
                              [NSString stringWithUTF8String:object_getClassName(model)],
                              pk];
            
            if ([db executeUpdate:sql withArgumentsInArray:@[valueWithPK]]) {
                res = YES;
            }
            successBlock(res);
            
        }
        
    }else {
        NSLog(@"表不存在");
        NSLog(@"%@",[NSString stringWithUTF8String:object_getClassName(model)]);
    }
    
    
    return res;
    
}


/**
 *  更改模型数据
 *
 *  @param model        model
 *  @param pk           pk
 *  @param successBlock
 *
 *  @return 返回操作结果
 */
- (BOOL)updateModel:(id)model
                 pk:(NSString *)pk
             handle:(SuccessBlock)successBlock {
    
    BOOL res;
    if ([db tableExists:[NSString stringWithUTF8String:object_getClassName(model)]]) {
        
        BOOL hasPkInTable = NO;
        id valueWithPK;
        unsigned int outCount = 0;
        NSMutableArray *propertyNameArray = [NSMutableArray array];
        objc_property_t * propertyList = class_copyPropertyList([model class],&outCount);
        for (int i = 0; i < outCount; i++) {
            if ([pk isEqualToString:@(property_getName(propertyList[i]))]) {
                hasPkInTable = YES;
                valueWithPK = [model valueForKey:pk];
                if (!valueWithPK || valueWithPK <= 0) {
                    NSLog(@"pk有问题,!valueWithPK || valueWithPK <= 0");
                }
            }
            
            NSString *propertyName = @(property_getName(propertyList[i]));
            [propertyNameArray addObject:propertyName];
        }
        
        if (!hasPkInTable) {
            NSLog(@"pk 在表中不存在！");
        }else {
            
            NSMutableString *keyString = [NSMutableString string];
            NSMutableArray *updateValues = [NSMutableArray  array];
            for (int i = 0; i <outCount; i++) {
                NSString *proname = [self getColumnsInTable:
                                     [NSString stringWithUTF8String:object_getClassName(model)]][i];
                
                [keyString appendFormat:@" %@=?,", proname];
                id value = [model valueForKey:proname];
                if (!value) {
                    value = @"";
                }
                [updateValues addObject:value];
                
            }
            
            //删除最后那个逗号
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;",
                             [NSString stringWithUTF8String:object_getClassName(model)],
                             keyString, pk];
            NSLog(@"%@",sql);
            [updateValues addObject:valueWithPK];
            NSLog(@"%@",updateValues);
            res = [db executeUpdate:sql withArgumentsInArray:updateValues];
            NSLog(res?@"更新成功":@"更新失败");
            successBlock(res);
        }
        
    }else {
        NSLog(@"不存在该表");
    }
    
    return res;
    
}



/**
 *  查询全部
 *
 *  @param tableName
 *
 *  @param model  映射的模型类
 *  @param success
 *  @return 返回查询结果数组
 */

- (NSArray *)finalAllWithTableName:(NSString *)tableName
                    modelClassName:(id)model
                           success:(Success)success {
    BOOL res = NO;
    NSMutableArray * objectArray = [NSMutableArray array];
    //    NSDictionary * modelDic = [NSMutableDictionary dictionary];
    NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
    
    unsigned int outCount = 0;
    //    NSMutableArray *propertyNameArray = [NSMutableArray array];
    //    objc_property_t * propertyList = class_copyPropertyList([model class],&outCount);
    
    FMResultSet * resultSet = [db executeQuery:sql];
    while ([resultSet next]) {
        res = YES;
        const char * className = [model UTF8String];
        Class kclass = objc_getClass(className);
        if (!kclass)
        {
            Class superClass = [NSObject class];
            kclass = objc_allocateClassPair(superClass, className, 0);
        }
        
        objc_registerClassPair(kclass);
        id instance = [[kclass alloc] init];
        
        NSMutableArray * propertyTypeArray = [NSMutableArray array];
        propertyTypeArray = [[self getColumnsType:tableName] mutableCopy];
        
        for (int i = 0; i < [self getColumnsInTable:tableName].count; i++) {
            if ([propertyTypeArray[i] isEqualToString:SQLTEXT]) {
                [instance setValue:[resultSet stringForColumn:[self getColumnsInTable:tableName][i]]
                            forKey:[self getColumnsInTable:tableName][i]];
            }else {
                NSLog(@"%@",[self getColumnsInTable:tableName][i]);
                [instance setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:
                                                                 [self getColumnsInTable:tableName][i]]]
                            forKey:[self getColumnsInTable:tableName][i]];
                
                
            }
            
        }
        
        [objectArray addObject:instance];
    }
    
    success (res,objectArray);
    return objectArray;
}


/**
 *  按照条件查询
 *
 *  @param tableName tableName
 *  @param success   success
 *
 *  @param modelClassName 返回数据里面对象需要转成
 *  @param conditionString 条件语句
 *
 *  @return 返回查询的结果数组（里面是对象）
 */
- (NSArray *)finalWithConditionWithTableName:(NSString *)tableName
                              modelClassName:(NSString *)modelClassName
                             conditionString:(NSString *)conditionString
                                     success:(Success)success {
    
    BOOL res = NO;
    NSMutableArray * objectArray = [NSMutableArray array];
    NSString * sql = [NSString stringWithFormat:@"SELECT * FROM %@ %@",
                      tableName,conditionString];
    NSLog(@"%@",sql);
    FMResultSet * resultSet = [db executeQuery:sql];
    while ([resultSet next]) {
        res = YES;
        //用runtime 生成模型类
        const char * className = [modelClassName UTF8String];
        Class kclass = objc_getClass(className);
        if (!kclass) {
            Class superClass = [NSObject class];
            kclass = objc_allocateClassPair(superClass, className, 0);
        }
        objc_registerClassPair(kclass);
        id instance = [[kclass alloc] init];
        NSMutableArray * propertTypeArray = [[self getColumnsType:tableName] mutableCopy];
        NSLog(@"%@", [self getColumnsType:tableName]);
        for (int i = 0; i < [self getColumnsInTable:tableName].count; i++) {
            if ([propertTypeArray[i] isEqualToString:SQLTEXT]) {
                [instance setValue:[resultSet stringForColumn:[self getColumnsInTable:tableName][i]]
                            forKey:[self getColumnsInTable:tableName][i]];
            }else {
                [instance setValue:[NSNumber numberWithLongLong:[self getColumnsInTable:tableName][i]]
                            forKey:[self getColumnsInTable:tableName][i]];
            }
            
            
        }
        
        
        [objectArray addObject:instance];
    }
    
    success(res, objectArray);
    return objectArray;
}

@end
