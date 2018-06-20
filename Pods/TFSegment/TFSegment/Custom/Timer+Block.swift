//
//  Timer+Block.swift
//  TaxiDriver
//
//  Created by jiangyunfeng on 2018/5/31.
//  Copyright © 2018年 didapinche. All rights reserved.
//

/*    举个例子
     let myTimer = Timer.block_scheduledTimer(timeInterval: 1.0, repeats: true, timerBlock: { (timer) in
         log.debug("timer回调")
     })
     RunLoop.current.add(myTimer, forMode: RunLoopMode.commonModes)
 */

import Foundation
import UIKit

extension Timer {
    /**
     将来从iOS 10.0开始支持后可以用系统提供的方法：
     open class func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Swift.Void) -> Timer
     
     由于系统提供的block方法是从iOS 10.0，所以下方是自己写的带block的Timer
     由此方法创建的Timer可以在deinit方法中调用invalidate注销
     deinit {
         myTimer.invalidate()
     }
     
     */
    open class func block_scheduledTimer(timeInterval ti: TimeInterval, repeats yesOrNo: Bool, timerBlock: @escaping (Timer) -> Swift.Void) -> Timer {
        
        let timer = Timer.scheduledTimer(timeInterval: ti, target: self, selector: #selector(block_timerSelector), userInfo: timerBlock, repeats: yesOrNo)
        return timer
    }
    
    @objc private class func block_timerSelector(timer : Timer) -> Void {
        guard let tBlock = timer.userInfo as? (Timer) -> Swift.Void else { return }
        tBlock(timer);
    }
    
}
