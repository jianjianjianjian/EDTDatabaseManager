//
//  EDTInfoTextFiled.m
//  Block
//
//  Created by lkm on 16/6/20.
//  Copyright © 2016年 mj. All rights reserved.
//

#import "EDTInfoTextFiled.h"
#import <Masonry/Masonry.h>
#import "UIColor+UIColor_Hex.h"
@interface EDTInfoTextFiled ()

@property (nonatomic, strong)UILabel * lineLabel; //底部线
@property (nonatomic, strong)UILabel * remarksLabel; //左侧备注文本
@property (nonatomic, strong)UITextField * contentTextFiled;

@end

@implementation EDTInfoTextFiled

- (instancetype)initWithFrame:(CGRect)frame type:(CustomType)type {
    
    if (self) {
        self = [super initWithFrame:frame];
        self.backgroundColor = [UIColor clearColor];
        [self getBottomLine];
        [self getRemarksLabel];
        if (type == NONAAL_TYPE) {
            [self getContentTextWithNoRightBtnFiled];
        }else if (type == NEED_RIGHT_BTN_TYPE) {
            [self getRightBtn];
            [self getContentTextWithRightBtnFiled];
        }
        
    }
    
    
    return self;
}




- (UILabel *)getBottomLine {
    if (!_lineLabel) {
        _lineLabel = [[UILabel alloc]init];
        [self addSubview:_lineLabel];
        [_lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(0);
            make.right.equalTo(self).offset(0);
            make.height.equalTo(@1);
            make.bottom.equalTo(self);
        }];
        _lineLabel.backgroundColor = [UIColor colorWithHexString:@"d4d4d4"];
    }
    
    return _lineLabel;
}

- (UILabel *)getRemarksLabel {
    if (!_remarksLabel) {
        _remarksLabel = [[UILabel alloc]init];
        [self addSubview:_remarksLabel];
        [_remarksLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
            make.width.equalTo(@60);
        }];
    }
    //    _remarksLabel.backgroundColor = [UIColor redColor];
    self.remarksLabel.font = [UIFont systemFontOfSize:13.0f];
    self.remarksLabel.textAlignment = NSTextAlignmentCenter;
    return _remarksLabel;
}



- (UIButton *)getRightBtn {
    if (!_rightBtn) {
        _rightBtn = [[UIButton alloc]init];
    }
    [self addSubview:_rightBtn];
    [_rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.width.equalTo(@100);
        make.top.equalTo(@5);
        make.bottom.equalTo(@-5);
    }];
    _rightBtn.backgroundColor = [UIColor colorWithHexString:@"#01b4b8"];
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    return _rightBtn;
}

- (UITextField *)getContentTextWithRightBtnFiled {
    if (!_contentTextFiled) {
        _contentTextFiled = [[UITextField alloc]init];
    }
    [self addSubview:_contentTextFiled];
    [_contentTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(_remarksLabel.mas_right).offset(10);
        make.right.equalTo(_rightBtn.mas_left).offset(-10);
    }];
    _contentTextFiled.font = [UIFont systemFontOfSize:13.0f];
    return _contentTextFiled;
}

- (UITextField *)getContentTextWithNoRightBtnFiled {
    if (!_contentTextFiled) {
        _contentTextFiled = [[UITextField alloc]init];
    }
    [self addSubview:_contentTextFiled];
    [_contentTextFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(_remarksLabel.mas_right).offset(10);
        make.right.equalTo(self).offset(-10);
    }];
    _contentTextFiled.font = [UIFont systemFontOfSize:13.0f];
    return _contentTextFiled;
}


#pragma mark setting

- (void)setRemarkString:(NSString *)remarkString {
    self.remarksLabel.text = remarkString;
}

- (void)setRemarkColor:(UIColor *)remarkColor {
    self.remarksLabel.textColor = remarkColor;
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.contentTextFiled.placeholder = placeholder;
}

- (void)setTextFileColor:(UIColor *)textFileColor {
    self.contentTextFiled.textColor = textFileColor;
}

- (void)setRightBtnTitle:(NSString *)rightBtnTitle {
    if (_rightBtn) {
        [self.rightBtn setTitle:rightBtnTitle forState:0];
    }
}

- (void)setRightBtnBackgroudColor:(UIColor *)rightBtnBackgroudColor {
    if (_rightBtn) {
        [self.rightBtn setBackgroundColor:rightBtnBackgroudColor];
    }
}

- (void)setRightBtnTitleColor:(UIColor *)rightBtnTitleColor {
    if (_rightBtn) {
        [self.rightBtn setTitleColor:rightBtnTitleColor forState:0];
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (_rightBtn) {
        self.rightBtn.layer.cornerRadius = cornerRadius;
        self.rightBtn.layer.masksToBounds = YES;
    }
}

- (void)setKeyboardType:(UIKeyboardType *)keyboardType {
    _contentTextFiled.keyboardType = keyboardType;
}

- (NSString *)text {
    return  self.contentTextFiled.text;
    
}






@end
