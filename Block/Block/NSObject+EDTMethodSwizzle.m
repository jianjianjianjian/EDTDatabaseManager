//
//  NSObject+EDTMethodSwizzle.m
//  Block
//
//  Created by lkm on 16/6/27.
//  Copyright © 2016年 mj. All rights reserved.
//

#import "NSObject+EDTMethodSwizzle.h"
#import <objc/runtime.h>
@implementation NSObject (EDTMethodSwizzle)

+ (BOOL)method_Swizzle:(SEL)origSel swizzleMethod:(SEL)swizzleSel {
    
    //原始方法
    Method origalMethod = class_getInstanceMethod(self, origSel);
    //替换方法
    Method swizzleMethod = class_getInstanceMethod(self, swizzleSel);
    
    if (origalMethod && swizzleMethod) {
        //添加方法
        if (class_addMethod(self, origSel,
                            method_getImplementation(swizzleMethod),
                            method_getTypeEncoding(swizzleMethod))) {
            class_replaceMethod(self, swizzleSel,
                                method_getImplementation(origalMethod),
                                method_getTypeEncoding(origalMethod));
        }
        
        return YES;
    }
    
    return NO;
}


+ (BOOL)exchangeInstanceMethod:(SEL)origSel exchangeMethod:(SEL)exchangeSel {
    
    
    //原始方法
    Method origalMethod = class_getInstanceMethod([self class], origSel);
    //替换方法
    Method swizzleMethod = class_getInstanceMethod([self class], exchangeSel);
    
    if (origalMethod && swizzleMethod) {
        //交换
        method_exchangeImplementations(origalMethod, swizzleMethod);
        return YES;
    }
    
    return NO;
}


@end
