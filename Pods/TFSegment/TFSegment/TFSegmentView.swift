//
//  TFSegmentView.swift
//  TFSegment
//
//  Created by jiangyunfeng on 2018/6/12.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

import UIKit

public protocol TFSegmentViewDelegate : NSObjectProtocol {
    /// 点击item回调
    func select(_ index: NSInteger, animated: Bool)
}

open class TFSegmentView: UIView {
    
    //MARK: 公开属性
    
    /**背景颜色, 默认白色*/
    public var backColor: UIColor = UIColor.white
    /**Item最大显示数, 默认8*/
    public var maxItemCount: NSInteger = 8
    /**Item宽度, 不设置则平分*/
    public var tabItemWidth: CGFloat = 0.0
    /**Item的title效果*/
    public var titleStyle: TFTitleTransformStyle = .default
    /**选中字体颜色*/
    public var selectedColor: UIColor = UIColor.red {
        didSet {
            selectColorRGB = TFColorRGB.init(color: selectedColor) //
        }
    }
    /**未选中字体颜色*/
    public var unSelectedColor: UIColor = UIColor.black {
        didSet {
            unSelectColorRGB = TFColorRGB.init(color: unSelectedColor) //
        }
    }
    /**默认字体大小*/
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 18)
    /**未选中字体缩小比例，默认是0.8（0~1）*/
    public var selectFontScale: CGFloat = 0.8 {
        didSet {
            layoutSubviews()
        }
        
    }
    /**下标效果*/
    public var indicatorStyle: TFIndicatorWidthStyle = .default
    /**下标高度，默认是2.0*/
    public var indicatorHeight: CGFloat = 2.0
    /**下标宽度，默认是30*/
    public var indicatorWidth: CGFloat = 30.0
    /**底部分割线颜色*/
    public var separatorColor: UIColor = UIColor.clear

    /**代理*/
    public weak var delegate: TFSegmentViewDelegate?//代理回调
    public weak var delegateScrollView: UIScrollView?//设置要跟踪的scrollView
    
    //MARK: 过程记录
    private var tabItems = [TFItemLabel]() //Item数组
    private var selectedTabIndex: NSInteger = 0 {//当前选择项
        willSet {
            lastSelectedTabIndex = selectedTabIndex
        }
    }
    private var lastSelectedTabIndex: NSInteger = 0 //记录上一次选择项
    private var isNeedRefreshLayout = true //滑动过程中不允许layoutSubviews
    private var isChangeByClick = false //是否是通过点击改变的
    private var leftItemIndex: NSInteger = 0 //记录滑动时左边的itemIndex
    private var rightItemIndex: NSInteger = 0 //记录滑动时右边的itemIndex
    private var leftToRight: Bool = true //从左到右
    private var numOfItemCount: NSInteger = 0 //最终显示Item个数
    private var shiftOffset: CGFloat = 0.0 { //偏移量在一页中的占比(0.0~1.0)
        didSet {
            if isChangeByClick {
                changeIndexWithAnimation()
            }
            #if DEBUG
            print("shiftOffset : \(shiftOffset)")
            #endif
            
        }
    }
    
    private var selectColorRGB: TFColorRGB = TFColorRGB.init(color: UIColor.red) //
    private var unSelectColorRGB: TFColorRGB = TFColorRGB.init(color: UIColor.black) //
    //MARK: 数据源
    var titleDatas = [String]() //title数组
    
    //MARK: 初始化
    public init(frame: CGRect, titles: [String]) {
        super.init(frame: frame)
        titleDatas = titles
        numOfItemCount = titles.count < maxItemCount ?titles.count : maxItemCount
        addAllSubViews()
        
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 懒加载子视图
    ///背景
    lazy var backView: UIView = {
        let bv = UIView()
        bv.backgroundColor = backColor
        return bv
    }()
    
    ///第一层子视图
    lazy var contentView: UIScrollView = {
        let cv = UIScrollView()
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.clipsToBounds = true
        cv.backgroundColor = backColor
        return cv
    }()
    
    ///底部分割线
    lazy var separatorView: UIView = {
        let sv = UIView()
        sv.backgroundColor = separatorColor
        return sv
    }()
    
    ///下标
    lazy var indicatorView: UIView = {
        let iv = UIView()
        iv.backgroundColor = selectedColor
        return iv
    }()
    
    ///添加子视图
    func addAllSubViews() {
        self.addSubview(backView)
        self.addSubview(contentView)
        var i = 0
        for title in titleDatas {
            let titleItem = TFItemLabel()
            titleItem.font = titleFont
            titleItem.text = title
            titleItem.textColor = ((i == selectedTabIndex) ? selectedColor : unSelectedColor)
            titleItem.textAlignment = .center
            titleItem.isUserInteractionEnabled = true
            
            let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(changeIndexWithClick(tap:)))
            titleItem.addGestureRecognizer(tapRecognizer)
            tabItems.append(titleItem)
            self.contentView.addSubview(titleItem)
            i = i + 1
        }
        self.addSubview(separatorView)
        self.addSubview(indicatorView)
        layoutIfNeeded()
    }
    
    override open func layoutSubviews() {
        if(isNeedRefreshLayout && tabItems.count > 0) {
            //tab layout
            if 0 == tabItemWidth {
                tabItemWidth = self.bounds.width/CGFloat(numOfItemCount)
            }
            
            self.contentView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
            self.contentView.contentSize = CGSize.init(width: tabItemWidth * CGFloat(numOfItemCount), height: 0)
            
            var i = 0
            for item in tabItems {
                item.frame = CGRect(x: tabItemWidth * CGFloat(i), y: 0, width: tabItemWidth, height: self.bounds.height)
                item.process = 0.0
                if(i != selectedTabIndex) {
                    item.transform = CGAffineTransform(scaleX: selectFontScale, y: selectFontScale)
                } else {
                    item.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
                i = i + 1
            }
            
            separatorView.frame = CGRect(x: 0, y: self.bounds.height-0.5, width: tabItemWidth * CGFloat(numOfItemCount), height: 0.5)
            self.layoutIndicatorViewWithStyle()
        }
    }
}

//MARK: 视图变化
extension TFSegmentView {
    /**根据不同风格对下标layout*/
    func layoutIndicatorViewWithStyle() {
        switch indicatorStyle {
        case .default:
            self.layoutIndicatorView()
        case .followText:
            self.layoutIndicatorView()
        case .stretch:
            self.layoutIndicatorView()
        case .followTextStretch:
            self.layoutIndicatorView()
        }

    }
    
    func layoutIndicatorView() {
        let indicatorWidth: CGFloat = self.getIndicatorWidth(title: titleDatas[selectedTabIndex])
        let selecedTabItem = tabItems[selectedTabIndex]
        self.indicatorView.frame = CGRect.init(x: selecedTabItem.center.x - indicatorWidth / 2.0, y: self.bounds.height-indicatorHeight, width: indicatorWidth, height: indicatorHeight)
    }
    
    func changeIndexWithAnimation() {
        //调整title
        changeTitleIndexWithAnimation()
        
        //调整indicator
        changeIndicatorIndexWithAnimation()
    }
    
    //调整title
    func changeTitleIndexWithAnimation() {
        
        switch (titleStyle) {
        case .default:
            self.changeTitleWithDefault()
        case .gradual:
            self.changeTitleWithGradual()
        case .fill:
            self.changeTitleWithFill()
        }
    }
    //调整indicator
    func changeIndicatorIndexWithAnimation() {
        switch (indicatorStyle) {
        case .default:
            self.changeIndicatorWithDefault()
        case .followText:
            self.changeIndicatorWithFollowText()
        case .stretch:
            self.changeIndicatorWithStretch()
        case .followTextStretch:
            self.changeIndicatorWithFollowTextStretch()
        }
    }
    
    //MARK: Item字体动画
    func changeTitleWithDefault() {
        if(shiftOffset > 0.5) {
            let selctTabItem = tabItems[rightItemIndex]
            let currentTabItem = tabItems[leftItemIndex]
            currentTabItem.textColor = unSelectedColor
            selctTabItem.textColor = selectedColor
        } else {
            let selctTabItem = tabItems[leftItemIndex]
            let currentTabItem = tabItems[rightItemIndex]
            currentTabItem.textColor = unSelectedColor
            selctTabItem.textColor = selectedColor
        }
        fontAnimate()
    }
    func changeTitleWithGradual() {
        if leftItemIndex != rightItemIndex {
            
            let leftScale: CGFloat = shiftOffset
            let rightScale: CGFloat = 1.0 - leftScale
            
            //颜色渐变
            let difR = selectColorRGB.r-unSelectColorRGB.r
            let difG = selectColorRGB.g-unSelectColorRGB.g
            let difB = selectColorRGB.b-unSelectColorRGB.b
            
            let leftItemColor = UIColor.init(red: unSelectColorRGB.r+rightScale*difR, green: unSelectColorRGB.g+rightScale*difG, blue: unSelectColorRGB.b+rightScale*difB, alpha: 1.0)

            let rightItemColor = UIColor.init(red: unSelectColorRGB.r+leftScale*difR, green: unSelectColorRGB.g+leftScale*difG, blue: unSelectColorRGB.b+leftScale*difB, alpha: 1.0)
            
            let leftTabItem = tabItems[leftItemIndex]
            let rightTabItem = tabItems[rightItemIndex]
            leftTabItem.textColor = leftItemColor
            rightTabItem.textColor = rightItemColor
            fontAnimate()
        }
    }
    func changeTitleWithFill() {
        if 0 == shiftOffset {
            return //起点和终点不处理，终点时左右index已更新，会绘画错误（你可以注释看看）
        }
        
        let leftTabItem = tabItems[leftItemIndex]
        let rightTabItem = tabItems[rightItemIndex]
        
        leftTabItem.textColor = selectedColor
        rightTabItem.textColor = unSelectedColor
        leftTabItem.fillColor = unSelectedColor
        rightTabItem.fillColor = selectedColor
        leftTabItem.process = shiftOffset
        rightTabItem.process = shiftOffset
        fontAnimate()
    }
    //字体渐变
    func fontAnimate() {
        let leftScale: CGFloat = shiftOffset
        let rightScale: CGFloat = 1.0 - leftScale
        let leftTabItem = tabItems[leftItemIndex]
        let rightTabItem = tabItems[rightItemIndex]
        leftTabItem.transform = CGAffineTransform(scaleX: selectFontScale+(1-selectFontScale)*rightScale, y: selectFontScale+(1-selectFontScale)*rightScale)
        rightTabItem.transform = CGAffineTransform(scaleX: selectFontScale+(1-selectFontScale)*leftScale, y: selectFontScale+(1-selectFontScale)*leftScale)
    }
    
    //MARK: 下标动画
    func changeIndicatorWithDefault() {

        let leftTabItem = tabItems[leftItemIndex]
        let rightTabItem = tabItems[rightItemIndex]
        
        let diffOfCenterX = rightTabItem.center.x - leftTabItem.center.x
        let nowIndicatorCenterX = leftTabItem.center.x + shiftOffset * diffOfCenterX
        self.indicatorView.frame = CGRect.init(x: nowIndicatorCenterX - indicatorWidth/2.0, y: self.indicatorView.frame.origin.y, width: indicatorWidth, height: indicatorHeight)
        
//        let selectTabItem = tabItems[selectedTabIndex]
//        let currentTabItem = tabItems[lastSelectedTabIndex]
//
//        var shift = shiftOffset
//        let diffOfCenterX = selectTabItem.center.x - currentTabItem.center.x
//        if diffOfCenterX < 0 {
//            shift = 1 - shiftOffset
//        }
////        //计算indicator此时的centerx
//        var nowIndicatorCenterX = currentTabItem.center.x + shift * diffOfCenterX
//        if 0 == shiftOffset {
//            nowIndicatorCenterX = selectTabItem.center.x
//        }
//        self.indicatorView.frame = CGRect.init(x: nowIndicatorCenterX - indicatorWidth/2.0, y: self.indicatorView.frame.origin.y, width: indicatorWidth, height: indicatorHeight)

    }
    func changeIndicatorWithFollowText() {
        
        let leftTabItem = tabItems[leftItemIndex]
        let rightTabItem = tabItems[rightItemIndex]
        
        //计算此时body的偏移量在一页中的占比
        var relativeLocation = shiftOffset
        //记录左右对应的indicator宽度
        let leftIndicatorWidth = getIndicatorWidth(title: titleDatas[leftItemIndex])
        let rightIndicatorWidth = getIndicatorWidth(title: titleDatas[rightItemIndex])
        
        
        //左右边界的时候，占比清0
        if(leftItemIndex == rightItemIndex) {
            relativeLocation = 0
        }
        //基于从左到右方向（无需考虑滑动方向），计算当前中心轴所处位置的长度
        let nowIndicatorWidth: CGFloat = leftIndicatorWidth + (rightIndicatorWidth - leftIndicatorWidth) * relativeLocation
        
        let diffOfCenterX = rightTabItem.center.x - leftTabItem.center.x
        let nowIndicatorCenterX = leftTabItem.center.x + shiftOffset * diffOfCenterX
        
        self.indicatorView.frame = CGRect(x: nowIndicatorCenterX - nowIndicatorWidth/2.0, y: self.indicatorView.frame.origin.y, width: nowIndicatorWidth, height: indicatorHeight)
    }
    func changeIndicatorWithStretch() {
        if(indicatorWidth <= 0) {
            return
        }
        //计算此时body的偏移量在一页中的占比
        var relativeLocation = shiftOffset
        //左右边界的时候，占比清0
        if(leftItemIndex == rightItemIndex) {
            relativeLocation = 0
        }
        
        let leftTabItem = tabItems[leftItemIndex]
        let rightTabItem = tabItems[rightItemIndex]
        
        //当前的frame
        var nowFrame = self.indicatorView.frame

        let dif = CGFloat(abs(leftItemIndex-rightItemIndex))
        //重新计算frame
        if(relativeLocation <= 0.5) {
            let width = indicatorWidth + tabItemWidth * dif * (relativeLocation / 0.5)
            nowFrame.size.width = width
            
            if leftToRight {
                nowFrame.origin.x = leftTabItem.center.x - indicatorWidth/2
            } else {
                nowFrame.origin.x = rightTabItem.center.x + indicatorWidth/2 - (indicatorWidth + tabItemWidth*dif)
            }
        } else {
            let width = indicatorWidth + tabItemWidth * dif * ((1 - relativeLocation) / 0.5)
            nowFrame.size.width = width
            if leftToRight {
                 nowFrame.origin.x = leftTabItem.center.x - indicatorWidth/2 + (indicatorWidth + tabItemWidth*dif) - width
            } else {
                nowFrame.origin.x = rightTabItem.center.x + indicatorWidth/2 - width
            }
        }
        
        self.indicatorView.frame = nowFrame
    }
    
    func changeIndicatorWithFollowTextStretch() {
        if(indicatorWidth <= 0) {
            return
        }
        //计算此时body的偏移量在一页中的占比
        var relativeLocation = shiftOffset
        //左右边界的时候，占比清0
        if(leftItemIndex == rightItemIndex) {
            relativeLocation = 0
        }
        
        let leftTabItem = tabItems[leftItemIndex]
        let rightTabItem = tabItems[rightItemIndex]
        
        //记录左右对应的indicator宽度
        let leftIndicatorWidth = getIndicatorWidth(title: titleDatas[leftItemIndex])
        let rightIndicatorWidth = getIndicatorWidth(title: titleDatas[rightItemIndex])
        
        //基于从左到右方向（无需考虑滑动方向），计算当前中心轴所处位置的长度
        let nowIndicatorWidth: CGFloat = leftIndicatorWidth + (rightIndicatorWidth - leftIndicatorWidth) * relativeLocation
        
        //当前的frame
        var nowFrame = self.indicatorView.frame
        
        let dif = CGFloat(abs(leftItemIndex-rightItemIndex))
        //重新计算frame
        if(relativeLocation <= 0.5) {
            let width = nowIndicatorWidth + tabItemWidth * dif * (relativeLocation / 0.5)
            nowFrame.size.width = width
            
            if leftToRight {
                nowFrame.origin.x = leftTabItem.center.x - nowIndicatorWidth/2
            } else {
                nowFrame.origin.x = rightTabItem.center.x + nowIndicatorWidth/2 - (nowIndicatorWidth + tabItemWidth*dif)
            }
        } else {
            let width = nowIndicatorWidth + tabItemWidth * dif * ((1 - relativeLocation) / 0.5)
            nowFrame.size.width = width
            if leftToRight {
                nowFrame.origin.x = leftTabItem.center.x - nowIndicatorWidth/2 + (nowIndicatorWidth + tabItemWidth*dif) - width
            } else {
                nowFrame.origin.x = rightTabItem.center.x + nowIndicatorWidth/2 - width
            }
        }
        
        self.indicatorView.frame = nowFrame
    }
}

//MARK: 响应事件
extension TFSegmentView {
    /**Item点击*/
    @objc func changeIndexWithClick(tap: UITapGestureRecognizer) {
        let nextIndex: NSInteger = tabItems.index(of: tap.view as! TFItemLabel) ?? 0
        if(nextIndex != selectedTabIndex) {
            isChangeByClick = true
            let dif = abs(nextIndex - selectedTabIndex)
            let animate = !(dif > 1)
            changeSelectedItemToNextItem(nextIndex: nextIndex)
            contentView.isUserInteractionEnabled = false //防止快速切换
            delegateScrollView?.isUserInteractionEnabled = false
            if let del = delegate {
                del.select(nextIndex, animated: animate)
                if let scroll = delegateScrollView {
                    if animate {
                        scroll.setContentOffset(CGPoint(x: scroll.bounds.width * CGFloat(nextIndex), y: 0), animated: animate)
                    } else {
                        scroll.setContentOffset(CGPoint(x: scroll.bounds.width * CGFloat(nextIndex)-1, y: 0), animated: animate)
                        scroll.setContentOffset(CGPoint(x: scroll.bounds.width * CGFloat(nextIndex), y: 0), animated: true)
                    }
                }
                
            }
        }
    }
    
    func changeSelectedItemToNextItem(nextIndex: NSInteger) {
//        if abs(selectedTabIndex-nextIndex) > 1 {//间隔超过一格时，无动画效果
//            let currentTabItem = tabItems[selectedTabIndex]
//            let nextTabItem = tabItems[nextIndex]
//            currentTabItem.textColor = unSelectedColor
//            nextTabItem.textColor = selectedColor
//            changeIndex(nextIndex: nextIndex)
//            switch (indicatorStyle) {
//            case .default, .stretch:
//                self.changeIndicatorWithDefault()
//            case .followText:
//                self.changeIndicatorWithFollowText()
//            }
//            finishChangeAnimate()
//        } else {//动画效果
            leftToRight = nextIndex > selectedTabIndex
            leftItemIndex = leftToRight ? selectedTabIndex : nextIndex
            rightItemIndex = leftToRight ? nextIndex : selectedTabIndex
            shiftOffset = leftToRight ? 0.0 : 1.0
            var toFloat: CGFloat = 0.0
            selectedTabIndex = nextIndex
            
        _ = Timer.block_scheduledTimer(timeInterval: 0.01, repeats: true) {[weak self] (ttimer) in
                guard let `self` = self else { return }
                toFloat  = toFloat + 1.0
                if self.leftToRight {
                    var num = toFloat/25.0
                    if num > 1 {
                        num = 1
                    }
                    self.shiftOffset = num
                } else {
                    var num = 1.0 - toFloat/25.0
                    if num < 0 {
                        num = 0
                    }
                    self.shiftOffset = num
                    
                }
                if toFloat > 30 {
                    ttimer.invalidate()
//                    self.finishChangeAnimate()
                }
            }
            
//            UIView.animate(withDuration: 0.25, animations: {
//                self.shiftOffset = toFloat
//            }) { (finish) in
//                //重置
//                self.finishChangeAnimate()
//            }

            
//        }
        
    }
    
    func changeIndex(nextIndex: NSInteger) {
        leftItemIndex = nextIndex > selectedTabIndex ? selectedTabIndex : nextIndex
        rightItemIndex = nextIndex > selectedTabIndex ? nextIndex : selectedTabIndex
        selectedTabIndex = nextIndex
    }
    
}

//MARK: 工具
extension TFSegmentView {
    /**根据对应文本计算下标线宽度*/
    func getIndicatorWidth(title: String) -> CGFloat {
        if(indicatorStyle == .default || indicatorStyle == .stretch) {
            return indicatorWidth
        } else {
            if(title.count <= 2) {
                return 30.0
            } else {
                let width = CGFloat(title.count) * titleFont.pointSize + 12.0
                return width
            }
        }
    }
    
    func finishChangeAnimate() {
        isNeedRefreshLayout = true
        isChangeByClick = false
        contentView.isUserInteractionEnabled = true
    }
}

extension TFSegmentView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //滚动过程中不允许layout
        isNeedRefreshLayout = false
        if scrollView == contentView {
        } else {
            contentView.isUserInteractionEnabled = false
//            scrollView.isUserInteractionEnabled = false
            //未初始化时不处理
            if scrollView.contentSize.width <= 0 {
                return
            }

            //获取当前左右item index(点击方式已获知左右index，无需根据contentoffset计算)
            if(!isChangeByClick) {
                if(scrollView.contentOffset.x <= 0) { //左边界
                    leftItemIndex = 0
                    rightItemIndex = 0
                    
                } else if(scrollView.contentOffset.x >= (scrollView.contentSize.width-scrollView.bounds.width)) { //右边界
                    leftItemIndex = numOfItemCount-1
                    rightItemIndex = numOfItemCount-1
                    
                } else {
                    leftItemIndex = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.width)
                    rightItemIndex = leftItemIndex + 1
                    if rightItemIndex > selectedTabIndex {
                        leftToRight = true
                    }
                    if leftItemIndex < selectedTabIndex {
                        leftToRight = false
                    }
                    let conX = scrollView.contentOffset.x
                    let rem = conX.truncatingRemainder(dividingBy: scrollView.bounds.width)
                    #if DEBUG
                    print("rem \(rem)")
                    #endif
                    
                    if 0 == rem {
                        selectedTabIndex = NSInteger(scrollView.contentOffset.x / scrollView.bounds.width)
                    }
                    shiftOffset = rem / scrollView.bounds.width
                    changeIndexWithAnimation()
                }
                
                
            }
        }
        
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == contentView {
        } else {
            selectedTabIndex = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.width + CGFloat(0.5))
            adjustItems()
            isChangeByClick = false
            contentView.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == contentView {
        } else {
            selectedTabIndex = (NSInteger)(scrollView.contentOffset.x / scrollView.bounds.width + CGFloat(0.5))
            adjustItems()
            isChangeByClick = false
            contentView.isUserInteractionEnabled = true
            scrollView.isUserInteractionEnabled = true
//            finishChangeAnimate()
        }
    }
    
    func adjustItems() {
        var i = 0
        for item in tabItems {
            item.frame = CGRect(x: tabItemWidth * CGFloat(i), y: 0, width: tabItemWidth, height: self.bounds.height)
            item.process = 0.0
            if(i == selectedTabIndex) {
                item.textColor = selectedColor
            } else {
                item.textColor = unSelectedColor
            }
            i = i + 1
        }
    }
}

