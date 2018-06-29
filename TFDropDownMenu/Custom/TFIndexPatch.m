//
//  TFIndexPatch.m
//  TFDropDownMenu
//
//  Created by jiangyunfeng on 2018/6/21.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

#import "TFIndexPatch.h"

@implementation TFIndexPatch

- (instancetype)initWithColumn:(NSInteger)column section:(NSInteger)section row:(NSInteger)row {
    self = [super init];
    if (self) {
        _column = column;
        _section = section;
        if (row) {
            _row = row;
        } else {
            _row = -1;
        }
        
    }
    return self;
}

- (BOOL)getHasRow {
    return -1 == _row;
}

@end
