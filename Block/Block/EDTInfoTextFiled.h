//
//  EDTInfoTextFiled.h
//  Block
//
//  Created by lkm on 16/6/20.
//  Copyright © 2016年 mj. All rights reserved.
//

#import <UIKit/UIKit.h>

//定义类型
typedef NS_ENUM(NSInteger, CustomType) {
    
    NONAAL_TYPE = 1, // 默认格式 （ 姓名_placeholder____________  ）
    NEED_RIGHT_BTN_TYPE =2 //右侧含有按钮  （ 姓名_placeholder____________btn  ）
};

@interface EDTInfoTextFiled : UIView

/**
 *  初始化方法
 *
 *  @param frame frame
 *  @param type  创建类型
 *
 *  @return      instancetype
 */
- (instancetype)initWithFrame:(CGRect)frame type:(CustomType)type;

/**
 *  placeholder
 */
@property (nonatomic, copy)NSString * placeholder;

/**
 *  备注名称
 */
@property (nonatomic, copy)NSString * remarkString;
/**
 *  备注提示字体颜色
 */
@property (nonatomic, strong)UIColor * remarkColor;

/**
 *  textFiled 字体颜色
 */
@property (nonatomic, strong)UIColor * textFileColor;

/**
 *  右侧按钮title
 */
@property (nonatomic, strong)NSString * rightBtnTitle;

/**
 *  右侧按钮的背景色
 */
@property (nonatomic, strong)UIColor * rightBtnBackgroudColor;

/**
 *  右侧按钮的字体颜色
 */
@property (nonatomic, strong)UIColor * rightBtnTitleColor;


/**
 *  右侧按钮的圆角值
 */
@property (nonatomic, assign)CGFloat cornerRadius;

/**
 *  键盘样式
 */
@property (nonatomic)UIKeyboardType * keyboardType;

/**
 *  获取输入框文字信息
 */
@property (nonatomic, copy)NSString * text;


/**
 *  右侧button，开放出来，方便扩展
 */
@property (nonatomic, strong)UIButton * rightBtn;

@end
