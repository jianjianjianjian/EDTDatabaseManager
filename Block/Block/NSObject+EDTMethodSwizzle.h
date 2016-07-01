//
//  NSObject+EDTMethodSwizzle.h
//  Block
//
//  Created by lkm on 16/6/27.
//  Copyright © 2016年 mj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (EDTMethodSwizzle)

+ (BOOL)method_Swizzle:(SEL)origSel swizzleMethod:(SEL)swizzleSel;


+ (BOOL)exchangeInstanceMethod:(SEL)origSel exchangeMethod:(SEL)exchangeSel;

@end
