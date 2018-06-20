//
//  TFColorRGB.swift
//  TFSegment
//
//  Created by jiangyunfeng on 2018/6/12.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

import UIKit
import CoreGraphics

public struct TFColorRGB {
    public var r : CGFloat = 0.0
    public var g : CGFloat = 0.0
    public var b : CGFloat = 0.0
    public init(color: UIColor) {
        var rr : CGFloat = 0.0
        var gg : CGFloat = 0.0
        var bb : CGFloat = 0.0
        if color.getRed(&rr, green: &gg, blue: &bb, alpha: nil) {
            r = rr
            g = gg
            b = bb
        }

    }
}
