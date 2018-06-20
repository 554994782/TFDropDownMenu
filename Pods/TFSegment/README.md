![(logo)](https://github.com/554994782/TFSegment/blob/master/Images/logo.png)
## TFSegment
* A selector view who contains some simple animation effects

## Contents
* Getting Started
    * [Features【Support Swift Verson】](#Support_Swift_Verson)
    * [Installation【How to use TFSegment】](#How_to_use_TFSegment)
    * [Structure【The Structure Chart of TFSegment】](#The_Structure_Chart_of_TFSegment)
* Comment API
    ```swift
    TFSegmentView.swift
    TFItemLabel.swift
    TFSegmentStyle.swift
    TFColorRGB.swift
    Timer+Block.swift
    ```
* Examples
    * [The TFSegment change 01_Default](#The_TFSegment_change_01_Default)
    * [The TFSegment change 02_Animate](#The_TFSegment_change_02_Animate)
    * [The TFSegment change 03_Animate](#The_TFSegment_change_03_Animate)
    * [The TFSegment change 04_Animate](#The_TFSegment_change_04_Animate)
    * [The TFSegment change 05_Other_Fields](#The_TFSegment_change_05_Other_Fields)
    
* [<font color=#ff2600 size=3>Warning Must Do</font>](#Warning_Must_Do)
    
* [Hope](#Hope)

## <a id="Support_Swift_Verson"></a>Support Swift Verson
* Support from `Swift 4.1`
* ARC
* iOS>=8.0
* iPhone \ iPad screen anyway

## <a id="How_to_use_TFSegment"></a>How to use TFSegment
* Installation with CocoaPods：`pod 'TFSegment'`
* Manual import：
    * Drag All files in the `TFSegment` folder to project
    * Import the main file：`import TFSegment`

## <a id="The_Structure_Chart_of_TFSegment"></a>The Structure Chart of TFSegment
![](https://github.com/554994782/TFSegment/blob/master/Images/structure.png)


## <a id="The_TFSegment_change_01_Default"></a>The TFSegment change 01_Default
```swift
lazy var segmentView: TFSegmentView = {
    let sv = TFSegmentView(frame: CGRect.init(x: 0, y: 60, width: UIScreen.main.bounds.width, height: 60), titles: titleArray)
    sv.delegate = self
    sv.delegateScrollView = scrollView
    sv.titleStyle = .default //The text color of item change without animate 文字颜色直接变
    sv.indicatorStyle = .default //Subscript without tensile change 下标无拉伸变化
    sv.selectFontScale = 1.0 //Text scaling ratio 文字缩放比例（0.0~1.0）
    return sv
}()
```
![(文字颜色直接变，下标无拉伸变化)](https://github.com/554994782/TFSegment/blob/master/Images/animate01.gif)

## <a id="The_TFSegment_change_02_Animate"></a>The TFSegment change 02_Animate
```swift
lazy var segmentView: TFSegmentView = {
    let sv = TFSegmentView(frame: CGRect.init(x: 0, y: segmentView1.frame.maxY+2, width: UIScreen.main.bounds.width, height: 60), titles: titleArray)
    sv.delegate = self
    sv.delegateScrollView = scrollView
    sv.titleStyle = .gradual //Text color gradient 文字颜色渐变
    sv.indicatorStyle = .followText //Subscript varies with text length 下标随文本长度变化
    return sv
}()
```
![(文字颜色渐变，下标随文本长度变化)](https://github.com/554994782/TFSegment/blob/master/Images/animate02.gif)

## <a id="The_TFSegment_change_03_Animate"></a>The TFSegment change 03_Animate
```swift
lazy var segmentView: TFSegmentView = {
    let sv = TFSegmentView(frame: CGRect.init(x: 0, y: segmentView2.frame.maxY+2, width: UIScreen.main.bounds.width, height: 60), titles: titleArray)
    sv.delegate = self
    sv.delegateScrollView = scrollView
    sv.titleStyle = .fill //Text color progress fill 文字颜色进度填充
    sv.indicatorStyle = .stretch //Subscript varies with stretch下标拉伸变化
    return sv
}()
```
![(文字颜色进度填充，下标拉伸变化)](https://github.com/554994782/TFSegment/blob/master/Images/animate03.gif)

## <a id="The_TFSegment_change_04_Animate"></a>The TFSegment change 04_Animate
```swift
lazy var segmentView: TFSegmentView = {
    let sv = TFSegmentView(frame: CGRect.init(x: 0, y: segmentView3.frame.maxY+2, width: UIScreen.main.bounds.width, height: 60), titles: titleArray)
    sv.delegate = self
    sv.delegateScrollView = scrollView
    sv.titleStyle = .fill //Text color progress fill 文字颜色进度填充
    sv.indicatorStyle = .followTextStretch // Subscript varies with text length and stretch下标随文本长度变化 且 拉伸变化
    return sv
}()
```
![(文字颜色进度填充，下标随文本长度变化且拉伸变化)](https://github.com/554994782/TFSegment/blob/master/Images/animate04.gif)

## <a id="The_TFSegment_change_05_Other_Fields"></a>The TFSegment change 05_Other_Fields
```swift
/**Background color, default white / 背景颜色, 默认白色*/
public var backColor: UIColor = UIColor.white
/**Item maximum display, default 8 / Item最大显示数, 默认8*/
public var maxItemCount: NSInteger = 8
/**Item width, split without setting / Item宽度, 不设置则平分*/
public var tabItemWidth: CGFloat = 0.0
/**Text effect of item / Item的文字效果*/
public var titleStyle: TFTitleTransformStyle = .default
/**Selected font color / 选中字体颜色*/
public var selectedColor: UIColor = UIColor.red
/**UnSelected font color / 未选中字体颜色*/
public var unSelectedColor: UIColor = UIColor.black
/**Text font size, default 18 / 默认字体大小, 默认18*/
public var titleFont: UIFont = UIFont.systemFont(ofSize: 18)
/**UnSelected font reduction, default is 0.8(0~1) / 未选中字体缩小比例，默认是0.8（0~1）*/
public var selectFontScale: CGFloat = 0.8
/**Subscript effect / 下标效果*/
public var indicatorStyle: TFIndicatorWidthStyle = .default
/**Subscript height, default 2.0 / 下标高度，默认是2.0*/
public var indicatorHeight: CGFloat = 2.0
/**Subscript width, default is 30 / 下标宽度，默认是30*/
public var indicatorWidth: CGFloat = 30.0
/**Bottom Secant Color, default clear / 底部分割线颜色, 默认透明*/
public var separatorColor: UIColor = UIColor.clear
```

## <a id="Warning_Must_Do"></a><font color=#ff2600 size=3>Warning Must Do</font>
```swift
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        segmentView.scrollViewDidScroll(scrollView)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        segmentView.scrollViewDidEndDecelerating(scrollView)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        segmentView.scrollViewDidEndScrollingAnimation(scrollView)
    }
}
```

## <a id="Hope"></a>Hope
* If you find bug when used，Hope you can Issues me，Thank you or try to download the latest code of this framework to see the BUG has been fixed or not）
* If you find the function is not enough when used，Hope you can Issues me，I very much to add more useful function to this framework ，Thank you !
* If you want to contribute code for TFSegment，please Pull Requests me
*  If you use TFSegment in your develop app，Hope you can go to [CocoaControls](https://www.cocoacontrols.com/controls/tfsegment) to add the iTunes path of you app，I Will install your app，and according to the usage of many app，to be a better design and improve to TFSegment，Thank you !
* Step01（WeChat is just an Example，Explore“Your app name itunes”）
![(step01)](https://github.com/554994782/TFSegment/blob/master/Images/hope01.jpg)
* Step02
![(step02)](https://github.com/554994782/TFSegment/blob/master/Images/hope02.jpg)
* Step03
![(step03)](https://github.com/554994782/TFSegment/blob/master/Images/hope03.jpg)
* Step04
![(step04)](https://github.com/554994782/TFSegment/blob/master/Images/hope04.jpg)
