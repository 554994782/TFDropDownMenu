//
//  TFDropDownMenuCollectionViewCell.m
//  TFDropDownMenu
//
//  Created by jiangyunfeng on 2018/6/30.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

#import "TFDropDownMenuCollectionViewCell.h"
#import "Masonry.h"

@implementation TFDropDownMenuCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}
@end
