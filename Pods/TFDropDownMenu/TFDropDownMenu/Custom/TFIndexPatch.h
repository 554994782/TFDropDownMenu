//
//  TFIndexPatch.h
//  TFDropDownMenu
//
//  Created by jiangyunfeng on 2018/6/21.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFIndexPatch : NSObject

@property (assign, nonatomic)NSInteger column;//菜单index
@property (assign, nonatomic)NSInteger section;//一级菜单index
@property (assign, nonatomic)NSInteger row;//二级菜单index，默认-1

@property (assign, nonatomic)BOOL hasRow;
//row不存在传nil
- (instancetype)initWithColumn:(NSInteger)column section:(NSInteger)section row:(NSInteger)row;

@end
