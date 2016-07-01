//
//  test.m
//  Block
//
//  Created by lkm on 16/6/27.
//  Copyright © 2016年 mj. All rights reserved.
//

#import "test.h"
#import "NSObject+EDTMethodSwizzle.h"
#import <objc/runtime.h>
@implementation test

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class clazz = object_getClass((id)self);
        //        [clazz method_Swizzle:@selector(origalMethod)
        //                swizzleMethod:@selector(swizzleMethod)];
        [clazz exchangeInstanceMethod:@selector(origalMethod)
                       exchangeMethod:@selector(swizzleMethod)];
    });
    
    //    [self origalMethod];
    //    [self swizzleMethod];
    
}



+ (void) origalMethod {
    
    NSLog(@"1111");
}


- (void) swizzleMethod {
    
    NSLog(@"2222");
}

@end
