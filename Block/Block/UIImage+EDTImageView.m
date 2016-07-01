//
//  UIImageView+EDTImageView.m
//  Block
//
//  Created by lkm on 16/6/27.
//  Copyright © 2016年 mj. All rights reserved.
//

#import "UIImage+EDTImageView.h"
#import <objc/runtime.h>
@implementation UIImage (EDTImage)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method  system_imageName_Method = class_getClassMethod(self, @selector(imageNamed:));
        Method  edt_imageName_Method = class_getClassMethod(self, @selector(edt_imageName:));
        method_exchangeImplementations(edt_imageName_Method, system_imageName_Method);
    });
    
    
}


+ (UIImage *)edt_imageName:(NSString *)imageName {
    //由于方法相互替换，所以下面 = [UIImage imageName:];
    UIImage * image = [UIImage edt_imageName:imageName];
    if (!image) {
        NSLog(@"666666,找不到图片");
    }
    return image;
    
}


@end
