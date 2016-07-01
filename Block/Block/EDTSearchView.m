//
//  EDTSearchView.m
//  BaoSengYuanXocde6
//
//  Created by lkm on 16/6/12.
//  Copyright © 2016年 谭宗坚. All rights reserved.
//

#import "EDTSearchView.h"
#import "UIColor+HEX.h"
#import "UIColor+UIColor_Hex.h"
#import <Masonry/Masonry.h>
@interface EDTSearchView ()
@property (nonatomic, strong)UIImageView * searchImageView;
@property (nonatomic, strong)UITextField * searchTextField;
@property (nonatomic, strong)UIButton * searchBtn;

@end

@interface EDTSearchView ()<UITextFieldDelegate>

@end

@implementation EDTSearchView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self) {
        self = [super initWithFrame:frame];
        self.backgroundColor = [UIColor whiteColor];
        [self getSearchImageView];
        [self getSearchBtn];
        [self getSearchTF];
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    
}

- (void)getSearchImageView {
    
    _searchImageView = [[UIImageView alloc]init];
    [self addSubview:_searchImageView];
    [_searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.left.equalTo(self).offset(15);
        make.width.height.equalTo(@20);
        make.centerY.equalTo(self);
    }];
    //    [_searchImageView setImage:[UIImage imageNamed:@"btn_nav_search---Assistor.png"]];
}

- (void)getSearchTF {
    
    _searchTextField = [[UITextField alloc]init];
    [self addSubview:_searchTextField];
    _searchTextField.placeholder = @"搜索地址";
    _searchTextField.delegate = self;
    _searchTextField.font = [UIFont systemFontOfSize:13.0f];
    [_searchTextField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [_searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self).offset(0);
        make.left.equalTo(_searchImageView.mas_right).offset(5);
        make.right.equalTo(self.searchBtn.mas_left).offset(0);
    }];
    
}

- (void)getSearchBtn {
    
    self.searchBtn = [[UIButton alloc]init];
    self.searchBtn.backgroundColor = [UIColor colorWithHexString:@"ff9a08"];
    [self.searchBtn setTitle:@"搜索" forState:0];
    [self addSubview:self.searchBtn];
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(0);
        make.height.equalTo(self.mas_height);
        make.top.equalTo(@0);
        make.width.equalTo(@55);
    }];
    [self.searchBtn addTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchDown];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.noticeDelegate customSearchBarBeginEditting];
    return YES;
}

- (BOOL)textFieldChanged:(UITextField *)textField {
    // 注意如果有多个UITextFiled，需要加个判断
    if (textField.text.length == 0) {
        [self.noticeDelegate removeTableViewAction];
    }
    return YES;
}

- (void)searchAction:(UIButton *)btn {
    [self.noticeDelegate startSaearchAction];
}

- (void)setBoardColor:(CGColorRef)boardColor {
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = boardColor;
}

- (void)setSearchBtnBackgroundColor:(UIColor *)searchBtnBackgroundColor {
    [self.searchBtn setBackgroundColor:searchBtnBackgroundColor];
}

- (void)setPlaceholder:(NSString *)placeholder {
    self.searchTextField.placeholder = placeholder;
}

@end
