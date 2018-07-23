//
//  TFDropDownMenuView.h
//  TFDropDownMenu
//
//  Created by jiangyunfeng on 2018/6/20.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFIndexPatch.h"
#import <Foundation/Foundation.h>
#import "TFMenuDefinition.h"

@interface TFDropDownMenuView : UIView

/**
 菜单初始化方法
 
 @param frame frame
 @param firstArray 一级菜单
 @param secondArray 二级菜单
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame firstArray:(NSMutableArray *)firstArray secondArray:(NSMutableArray *)secondArray;

/**代理*/
@property (nonatomic, weak) id<TFDropDownMenuViewDelegate> delegate;


//MARK: 数据源
/**一级菜单右侧小title数组*/
@property (strong, nonatomic) NSMutableArray *firstRightArray;
/**二级菜单右侧小title数组*/
@property (strong, nonatomic) NSMutableArray *secondRightArray;
/**一级菜单左侧icon数组*/
@property (strong, nonatomic) NSMutableArray *firstImageArray;
/**二级菜单左侧icon数组*/
@property (strong, nonatomic) NSMutableArray *secondImageArray;
/**各个菜单风格数组, 默认都为TFDropDownMenuStyleTableView*/
@property (strong, nonatomic) NSMutableArray *menuStyleArray;


//MARK: 公开属性
/**menu背景颜色, 默认白色*/
@property (strong, nonatomic) UIColor *menuBackgroundColor;
/**Item选中字体颜色, 默认橙红色*/ //UIColor = UIColor(red: 246/255.0, green: 79/255.0, blue: 0/255.0, alpha: 1)
@property (strong, nonatomic) UIColor *itemTextSelectColor;
/**Item未选中字体颜色, 默认黑色*/
@property (strong, nonatomic) UIColor *itemTextUnSelectColor;
/**cell选中字体颜色, 默认橙红色*/
@property (strong, nonatomic) UIColor *cellTextSelectColor;
/**cell未选中字体颜色, 默认黑色*/
@property (strong, nonatomic) UIColor *cellTextUnSelectColor;
/**分割线颜色, 默认灰色*/
@property (strong, nonatomic) UIColor *separatorColor;
/**cell选中背景颜色, 默认白色*/
@property (strong, nonatomic) UIColor *cellSelectBackgroundColor;
/**cell未选中背景颜色, 默认白色*/
@property (strong, nonatomic) UIColor *cellUnselectBackgroundColor;

/**Item字体大小, 默认14*/
@property (assign, nonatomic) CGFloat itemFontSize;
/**cell字体大小, 默认14*/
@property (assign, nonatomic) CGFloat cellTitleFontSize;
/**cell右侧副字体大小, 默认11*/
@property (assign, nonatomic) CGFloat cellDetailTitleFontSize;
/**下拉表单高度, 默认300*/
@property (assign, nonatomic) CGFloat tableViewHeight;
/**cell高度, 默认44*/
@property (assign, nonatomic) CGFloat cellHeight;
/**左侧表单宽度占屏比 范围0.0~1.0, 默认0.5*/
@property (assign, nonatomic) CGFloat ratioLeftToScreen;//有二级菜单时调整左右所占比例
/**自定义下拉视图*/
@property (strong, nonatomic) NSMutableArray *customViews;
/**动画时间, 默认0.25*/
@property (assign, nonatomic) CGFloat kAnimationDuration;

@end
