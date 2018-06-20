//
//  TFSegmentStyle.swift
//  TFSegment
//
//  Created by jiangyunfeng on 2018/6/13.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

import UIKit

/**title转化样式*/
public enum TFTitleTransformStyle: Int {
    case `default` = 0 //正常
    case gradual //颜色渐变
    case fill //颜色填充
}

/**下标样式*/
public enum TFIndicatorWidthStyle: Int {
    case `default` = 0 //自定义宽度
    case followText //随文本长度变化
    case stretch //自定义宽度且拉伸
    case followTextStretch //随文本长度变化且拉伸
}
