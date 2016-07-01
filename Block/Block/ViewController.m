//
//  ViewController.m
//  Block
//
//  Created by lkm on 16/4/11.
//  Copyright © 2016年 mj. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+HEX.h"
#import "UIColor+UIColor_Hex.h"
#import "EDTSearchView.h"
#import "EDTInfoTextFiled.h"
#import "EDTDatabaseManager.h"
#import "InfoModel.h"
#import "test.h"
#import "UIImage+EDTImageView.h"
//#import "AddMethod.h"
#import "TableModel.h"
@interface ViewController ()

@end

@interface ViewController ()<EDTAddressNoticeDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f8f8f8"];
    EDTSearchView * searchView = [[EDTSearchView alloc]initWithFrame:CGRectMake(15.0f, 100.0f, [UIScreen mainScreen].bounds.size.width-30, 45.0f)];
    searchView.boardColor =  [UIColor colorWithHexString:@"ff9a08"].CGColor;
    searchView.searchBtnBackgroundColor =  [UIColor colorWithHexString:@"ff9a08"];
    searchView.placeholder = @"placeholder";
    searchView.noticeDelegate = self;
    [self.view addSubview:searchView];
    
    
    EDTInfoTextFiled * infoTextFiled = [[EDTInfoTextFiled alloc]initWithFrame:
                                        CGRectMake(15.0f, 200.0f,
                                                   [UIScreen mainScreen].bounds.size.width-30 ,
                                                   45.0f) type:1];
    infoTextFiled.remarkString = @"姓名";
    infoTextFiled.remarkColor = [UIColor colorWithHexString:@"#3c3c3c"];
    infoTextFiled.placeholder = @"请输入姓名";
    infoTextFiled.textFileColor = [UIColor redColor];
    infoTextFiled.rightBtnBackgroudColor = [UIColor colorWithHexString:@"#01b4b8"];
    infoTextFiled.rightBtnTitle = @"获取验证码";
    infoTextFiled.rightBtnTitleColor = [UIColor grayColor];
    infoTextFiled.cornerRadius = 5.0f;
    infoTextFiled.keyboardType = (UIKeyboardType *)UIKeyboardTypeNumberPad;
    [self.view addSubview:infoTextFiled];
    NSLog(@"%@",infoTextFiled.text);
    
    
#pragma mark database operation
    EDTDatabaseManager * databaseManager = [EDTDatabaseManager shareInstance];
    NSLog(@"%d",[databaseManager openDB:@"jueyin"]);
    
    InfoModel * infoModel = [[InfoModel alloc]init];
    infoModel.id_card = @"56461341645445";
    infoModel.sex = @"men";
    infoModel.tall = 170;
    infoModel.work = @"coder";
    NSLog(@"%@",[databaseManager getColumnsInTable:@"info"]);
    [databaseManager executeUpdateWithTableName:@"info"
                                          model:infoModel
                                         handle:^(Handle_Cade code) {
                                             NSLog(code? @"插入成功":@"插入失败");
                                         }];
    
    
    
    
    
    TableModel * tableModel = [[TableModel alloc]init];
    tableModel.id_card = 12238;
    tableModel.sex = @"男";
    tableModel.tall = 170;
    tableModel.work = @"程序员";
    tableModel.school = @"北京工业大学";
    tableModel.isTure = YES;
    tableModel.number = [NSNumber numberWithInt:253];
    tableModel.array = @[@"1",@"2",@"3"];
    //    @property (nonatomic, copy)NSString * school;
    //    @property (nonatomic, assign)BOOL  isTure;
    //    @property (nonatomic, assign)NSNumber * number;
    //    @property (nonatomic, strong)NSArray * array;
    
    [databaseManager createTable:@"TableModel"
                              pk:@"id_card"
                           model:tableModel
                         Success:^(Handle_Cade code) {
                             NSLog(code? @"创建成功":@"创建失败");
                         }];
    [databaseManager executeUpdateWithTableName:@"TableModel"
                                          model:tableModel
                                         handle:^(Handle_Cade code) {
                                             NSLog(code? @"插入成功":@"插入失败");
                                         }];
    
    //    
    //    [databaseManager deleteDataWithModel:tableModel pk:@"id_card"
    //                                  handle:^(Handle_Cade code) {
    //                                      NSLog(code? @"删除成功":@"删除失败");
    //                                  }];
    
    
    
    TableModel * tableModelss = [[TableModel alloc]init];
    tableModelss.id_card = 2;
    tableModelss.sex = @"男";
    tableModelss.tall = 170;
    tableModelss.work = @"程序员";
    tableModelss.school = @"北京工业大学";
    tableModelss.isTure = YES;
    tableModelss.number = [NSNumber numberWithInt:253];
    tableModelss.array = @[@"1",@"2",@"3"];
    
    [databaseManager updateModel:tableModelss pk:@"id_card"
                          handle:^(Handle_Cade code) {
                              NSLog(code? @"model更新成功":@"model 更新失败");
                          }];
    
    
    
    
    //    先插入一百条数据
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        for (int i = 0; i < 100; i++) {
    //            
    //            TableModel * tableModelss = [[TableModel alloc]init];
    //            tableModelss.id_card = i;
    //            tableModelss.sex = @"男";
    //            tableModelss.tall = 169;
    //            tableModelss.work = @"程序员";
    //            tableModelss.school = @"北京工业大学";
    //            tableModelss.isTure = YES;
    //            tableModelss.number = [NSNumber numberWithInt:253];
    //            tableModelss.array = @[@"1",@"2",@"3"];
    //            
    //            [databaseManager executeUpdateWithTableName:@"TableModel"
    //                                                  model:tableModelss
    //                                                 handle:^(Handle_Cade code) {
    //                                                     NSLog(code? @"插入成功":@"插入失败");
    //                                                 }];
    //        }
    //    });
    
    
    [databaseManager finalAllWithTableName:@"TableModel"
                            modelClassName:@"TableModel"
                                   success:^(Handle_Cade code,
                                             NSMutableArray *array) {
                                       NSLog(@"%d",array.count);
                                       TableModel * model = (TableModel *)array[0];
                                       NSLog(@"%@",model);
                                       NSLog(code? @"查询成功":@"查询失败");
                                       
                                       for (int i = 0; i< array.count; i++) {
                                           TableModel * model = (TableModel *)array[i];
                                           NSLog(@"%d",model.tall);
                                       }
                                       
                                   }];
    
    
    [databaseManager closeDB:@"jueyin"];
    
    
    //然后按条件查询
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        
    //        [databaseManager finalWithConditionWithTableName:@"TableModel"
    //                                          modelClassName:@"TableModel"
    //                                         conditionString:@"WHERE id_card > 20"
    //                                                 success:^(Handle_Cade code, NSMutableArray *array) {
    //                                                     NSLog(@"%d",array.count);
    //                                                     for (int i = 0; i< array.count; i++) {
    //                                                         TableModel * model = (TableModel *)array[i];
    //                                                         NSLog(@"%d",model.id_card);
    //                                                     }
    //                                                 }];
    //        
    //    });
    //    
    
    
    [UIImage imageNamed:@"xxx"];
    //    [UIImage edt_imageName:@"11111"];
    
    
    //
    Class clazz = NSClassFromString(@"AddMethod");
    id object = [[clazz alloc]init];
    
    [object performSelector:@selector(eat) withObject:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//开始操作searchbar
- (void)customSearchBarBeginEditting {
    
}
//开始搜索
- (void)startSaearchAction {
    
}
//textFiled 没有值的时候，需要移除tableview notice
- (void)removeTableViewAction {
    
}


@end
