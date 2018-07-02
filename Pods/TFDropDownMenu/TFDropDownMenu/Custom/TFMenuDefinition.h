//
//  TFMenuDefinition.h
//  TFDropDownMenu
//
//  Created by jiangyunfeng on 2018/6/23.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

#ifndef TFMenuDefinition_h
#define TFMenuDefinition_h


#endif /* TFMenuDefinition_h */

/**下拉菜单风格*/
typedef NS_ENUM(NSUInteger, TFDropDownMenuStyle) {
    TFDropDownMenuStyleTableView,//普通tableview，一行一个，可支持二级菜单
    TFDropDownMenuStyleCollectionView,//collectionView，仅支持一级菜单
    TFDropDownMenuStyleCustom//自定义视图，需设置，仅支持一级菜单
};

//代理点击回调
@class TFDropDownMenuView;
@protocol TFDropDownMenuViewDelegate <NSObject>
- (void)menuView:(TFDropDownMenuView *)menu tfColumn:(NSInteger)column;//菜单被点击
- (void)menuView:(TFDropDownMenuView *)menu selectIndex:(TFIndexPatch *)index;//下拉菜单被点击
@end

