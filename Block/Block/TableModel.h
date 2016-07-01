//
//  TableModel.h
//  Block
//
//  Created by lkm on 16/6/28.
//  Copyright © 2016年 mj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableModel : NSObject

@property (nonatomic, assign)NSInteger  id_card;
@property (nonatomic, copy)NSString * sex;
@property (nonatomic, assign)NSInteger  tall;
@property (nonatomic, copy)NSString * work;
@property (nonatomic, copy)NSString * school;
@property (nonatomic, assign)BOOL  isTure;
@property (nonatomic, assign)NSNumber * number;
@property (nonatomic, strong)NSArray * array;



@end
