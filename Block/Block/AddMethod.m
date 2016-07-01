//
//  AddMethod.m
//  Block
//
//  Created by lkm on 16/6/28.
//  Copyright © 2016年 mj. All rights reserved.
//

#import "AddMethod.h"
#import <objc/runtime.h>
@implementation AddMethod


+ (void)load {
    
    Class clazz = NSClassFromString(@"AddMethod");
    //获取替换前的类方法
    Method instance_eat =
    class_getClassMethod(clazz, @selector(resolveInstanceMethod:));
    //获取替换后的类方法
    Method instance_notEat =
    class_getClassMethod(self, @selector(hy_resolveInstanceMethod:));
    
    //然后交换类方法
    method_exchangeImplementations(instance_eat, instance_notEat);
}


//下面就是一个c 函数，
//Obj-C的方法 （method）就是一个至少需要两个参数（self，_cmd）的C函数
//所以这么定义用来映射
void eat_1(id self,SEL sel)
{
    NSLog(@"到底吃不吃饭了");
    NSLog(@"%@ %@",self,NSStringFromSelector(sel));
}
void eat_2(id self,SEL sel, NSString* str1,NSString* str2)
{
    NSLog(@"到底吃不吃饭了");
    NSLog(@"%@ %@",self,NSStringFromSelector(sel));
    NSLog(@"打印两个参数值：%@ and %@",str1,str2);
}

+ (BOOL)hy_resolveInstanceMethod:(SEL)sel{
    //当sel为实现方法中 有 eat 方法
    if (sel == NSSelectorFromString(@"eat")) {
        //就 动态添加eat方法
        
        // 第一个参数：给哪个类添加方法
        // 第二个参数：添加方法的方法编号
        // 第三个参数：添加方法的函数实现（函数地址）
        // 第四个参数：函数的类型，(返回值+参数类型) v:void @:对象->self :表示SEL->_cmd
        class_addMethod(self, sel, (IMP)eat_1, "v@:");
        
    }
    return YES;
}

@end
