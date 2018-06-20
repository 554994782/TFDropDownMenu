//
//  TFItemLabel.swift
//  TFSegment
//
//  Created by jiangyunfeng on 2018/6/12.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

import UIKit

open class TFItemLabel: UILabel {
    open var fillColor : UIColor = UIColor.red //填充色
    open var defaultColor : UIColor = UIColor.black { //填充色
        didSet {
            self.textColor = defaultColor
        }
    }
    open var process : CGFloat = 0.2 {//填充占比
        didSet {
            self.setNeedsDisplay()
        }
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override open func draw(_ rect: CGRect) {
        // Drawing code
        super.drawText(in: rect)
        if fillColor.isKind(of: UIColor.classForCoder()) {
            fillColor.setFill()
            UIRectFillUsingBlendMode(CGRect.init(x: rect.origin.x, y: rect.origin.y, width: rect.size.width*process, height: rect.size.height), CGBlendMode.sourceIn)
        }
    }
}
