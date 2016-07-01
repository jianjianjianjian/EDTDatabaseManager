//
//  EDTSearchView.h
//  BaoSengYuanXocde6
//
//  Created by lkm on 16/6/12.
//  Copyright © 2016年 谭宗坚. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EDTAddressNoticeDelegate <NSObject>

@optional
//开始操作searchbar
- (void)customSearchBarBeginEditting;
//开始搜索
- (void)startSaearchAction;
//textFiled 没有值的时候，需要移除tableview notice
- (void)removeTableViewAction;

@end

@interface EDTSearchView : UIView

@property (nonatomic, weak) id <EDTAddressNoticeDelegate> noticeDelegate;

/**
 *  边框颜色
 */
@property (nonatomic)CGColorRef  boardColor;

/**
 *  搜索背景颜色
 */
@property (nonatomic, strong)UIColor* searchBtnBackgroundColor;

/**
 *  placeholder
 */
@property (nonatomic, copy)NSString * placeholder;

@end
