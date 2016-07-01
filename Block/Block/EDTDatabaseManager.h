//
//  EDTDatabaseManager.h
//  Block
//
//  Created by lkm on 16/6/22.
//  Copyright © 2016年 jueyin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EDTDatabaseManager : NSObject

//用于任务状态回调
typedef NS_ENUM(NSInteger,Handle_Cade) {
    FAILURE = 0,
    SUCESS = 1,
};

typedef void (^SuccessBlock)(Handle_Cade code);
typedef void (^Success)(Handle_Cade code, NSMutableArray * array);

//typedef  ^Success();
/**
 *  返回一个单例
 *
 *  @return EDTDatabaseManager
 */
+ (EDTDatabaseManager *)shareInstance;



/**
 *  开启数据库
 *
 *  @param dbName db名字，方法将dbName 转成path
 *
 *  @return 开启结果返回
 */
- (BOOL)openDB:(NSString *)dbName;


/**
 *  关闭数据库
 *
 *  @param dbName db名字，方法将dbName 转成path
 *
 *  @return 关闭结果返回
 */
- (BOOL)closeDB:(NSString *)dbName;

/**
 *  获取字段
 *
 *  @param tableName 表名
 *
 *  @return 返回字段数组
 */
- (NSArray *)getColumnsInTable:(NSString *)tableName;

/**
 *  获取字段类型
 *
 *  @param tableName tableName
 *
 *  @return 返回字段类型
 */
- (NSArray *)getColumnsType:(NSString *)tableName;


#pragma mark 增删改查

/**
 *  创建一张表
 *
 *  @param tableName    表名 - 最好用model 类名保持一致
 *  @param dbName       数据库名
 *  @param model        根据model字段进行数据库字段创建
 *  @param successBlock 操作回调
 *
 *  @return 返回创建状态
 */
- (BOOL)createTable:(NSString *)tableName
                 pk:(NSString *)pk
              model:(id)model
            Success:(SuccessBlock)successBlock;




/**
 *  插入模型 （表与字段类型相对应，不要出错，尽量用代码来穿建表）
 *
 *  @param tableName 表名
 *  @param model     model
 *  
 *  @param SuccessBlock 状态回调
 *  @return 插入状态返回
 */
- (BOOL)executeUpdateWithTableName:(NSString *)tableName
                             model:(id)model
                            handle:(SuccessBlock)successBlock;


/**
 *  删除模型数据
 *
 *  @param model 用model的类名 进行查表
 *
 *  @return 返回操作结果
 */
- (BOOL)deleteDataWithModel:(id)model
                         pk:(NSString *)pk
                     handle:(SuccessBlock)successBlock;


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
             handle:(SuccessBlock)successBlock;



/**
 *  查询全部
 *
 *  @param tableName
 *
 *  @param model  映射的模型类
 *  @param success
 *  @return 返回查询结果数组（里面是对象）
 */

- (NSArray *)finalAllWithTableName:(NSString *)tableName
                    modelClassName:(id)model
                           success:(Success)success;


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
                                     success:(Success)success;


@end
