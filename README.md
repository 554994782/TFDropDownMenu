## TFDropDownMenu
* A drop-down menu with some view styles

## Contents
* Getting Started
    * [Features【Support Swift Verson】](#Support_Verson)
    * [Installation【How to use TFDropDownMenu】](#How_to_use_TFDropDownMenu)
* Comment API
    ```
    TFDropDownMenuView.h
    TFDropDownMenuView.m
    TFMenuDefinition.h
    TFMenuDefinition.m
    TFIndexPatch.h
    TFIndexPatch.m
    TFDropDownMenuCollectionViewCell.h
    TFDropDownMenuCollectionViewCell.m
    ```
* Examples
    * [The TFDropDownMenu Animate](#The_TFDropDownMenu_Animate)
    * [The TFDropDownMenu Other Fields](#The_TFDropDownMenu_Other_Fields)

## <a id="Support_Verson"></a>Support Verson
* ARC
* iOS>=8.0
* iPhone \ iPad screen anyway

## <a id="How_to_use_TFDropDownMenu"></a>How to use TFDropDownMenu
* Installation with CocoaPods：`pod 'TFDropDownMenu'`
* Manual import：
* Drag All files in the `TFDropDownMenu` folder to project
* Import the main file：`import "TFDropDownMenu.h"`

## <a id="The_TFDropDownMenu_Animate"></a>The TFDropDownMenu Animate
![](https://github.com/554994782/TFDropDownMenu/blob/master/Images/demo.gif?raw=true)

```
NSMutableArray *array1 = [NSMutableArray arrayWithObjects:@"面积最大", @"面积最小", @"价格最高", @"价格最低", nil];
NSMutableArray *array2 = [NSMutableArray arrayWithObjects:@"热门推荐", @"美食", @"影院", @"自助餐", @"景区", @"汽车", @"网吧", @"游戏", nil];
NSMutableArray *array3 = [NSMutableArray arrayWithObjects:@"从大到小", @"从小到大", @"从高到低", @"从低到高", @"从右到左", @"从左到右", @"从前到后", @"从后到前", nil];
NSArray *array21 = @[
@[@"好玩的", @"好吃的", @"好景的", @"好喝的", @"好唱的"],
@[@"美食城1",@"美食城2", @"美食城3", @"美食城5", @"美食城10"],
@[@"金逸影院", @"万达影院", @"兄弟影院", @"新影联影院", @"保利影院", @"大地影院"],
@[@"韩式烤肉", @"日式自助", @"海底捞", @"湘十二楼", @"金百万"],
@[@"长城", @"故宫", @"天安门", @"明十三陵", @"颐和园", @"圆明园"],
@[@"玛莎拉蒂", @"法拉利", @"奔驰", @"宝马", @"奥迪"],
@[@"休闲网咖", @"学子网吧"],
@[@"英雄联盟", @"王者荣耀", @"大吉大利", @"大话西游", @"传奇"]
];

NSMutableArray *data1 = [NSMutableArray arrayWithObjects:array1, array2, array3, @[@"自定义"], nil];
NSMutableArray *data2 = [NSMutableArray arrayWithObjects:@[], array21, @[], @[], nil];
TFDropDownMenuView *menu = [[TFDropDownMenuView alloc] initWithFrame:CGRectMake(0, NAVBAR_HEIGHT, UIScreen.mainScreen.bounds.size.width, 40) firstArray:data1 secondArray:data2];
menu.delegate = self;
menu.cellSelectBackgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
menu.ratioLeftToScreen = 0.35;
[self.view addSubview:menu];

/*副标 detailTitles*/
NSMutableArray *detail1 = [NSMutableArray arrayWithObjects:@"21", @"22", @"23", @"24", nil];
NSMutableArray *detail2 = [NSMutableArray arrayWithObjects:@"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", nil];
NSMutableArray *detail3 = [NSMutableArray arrayWithObjects:@"31", @"32", @"33", @"34", @"35", @"36", @"37", @"38", nil];
NSArray *detail21 = @[
@[@"111", @"112", @"113", @"114", @"115"],
@[@"121",@"122", @"123", @"125", @"125"],
@[@"131", @"132", @"133", @"134", @"135", @"136"],
@[@"141", @"142", @"143", @"144", @"145"],
@[@"151", @"152", @"153", @"154", @"155", @"156"],
@[@"161", @"162", @"163", @"164", @"165"],
@[@"171", @"172"],
@[@"181", @"182", @"183", @"184", @"185"]
];
menu.firstRightArray = [NSMutableArray arrayWithObjects:detail1, detail2, detail3, nil];
menu.secondRightArray = [NSMutableArray arrayWithObjects:@[], detail21, nil];

/*风格 ListStyle*/
menu.menuStyleArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:TFDropDownMenuStyleTableView], [NSNumber numberWithInteger:TFDropDownMenuStyleTableView], [NSNumber numberWithInteger:TFDropDownMenuStyleCollectionView], [NSNumber numberWithInteger:TFDropDownMenuStyleCustom], nil];

/*自定义视图 customView*/
UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 300)];
label.text = @"我是自定义视图\n我是自定义视图\n我是自定义视图\n我是自定义视图\n我是自定义视图\n我是自定义视图\n我是自定义视图\n我是自定义视图";
label.numberOfLines = 0;
label.backgroundColor = [UIColor whiteColor];
label.textAlignment = NSTextAlignmentCenter;
label.textColor = [UIColor orangeColor];
menu.customViews = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], [NSNull null], label, nil];
```

## <a id="The_TFDropDownMenu_Other_Fields"></a>The TFDropDownMenu Other Fields
```swift
/**一级菜单右侧小title数组*/
@property (strong, nonatomic) NSMutableArray *firstRightArray;
/**二级菜单右侧小title数组*/
@property (strong, nonatomic) NSMutableArray *secondRightArray;
/**一级菜单左侧icon数组*/
@property (strong, nonatomic) NSMutableArray *firstImageArray;
/**二级菜单左侧icon数组*/
@property (strong, nonatomic) NSMutableArray *secondImageArray;
/**各个菜单风格数组, 默认都为TFDropDownMenuStyleTableView*/
@property (strong, nonatomic) NSMutableArray *menuStyleArray;


//MARK: 公开属性
/**menu背景颜色, 默认白色*/
@property (strong, nonatomic) UIColor *menuBackgroundColor;
/**Item选中字体颜色, 默认橙红色*/
@property (strong, nonatomic) UIColor *itemTextSelectColor;
/**Item未选中字体颜色, 默认黑色*/
@property (strong, nonatomic) UIColor *itemTextUnSelectColor;
/**cell选中字体颜色, 默认橙红色*/
@property (strong, nonatomic) UIColor *cellTextSelectColor;
/**cell未选中字体颜色, 默认黑色*/
@property (strong, nonatomic) UIColor *cellTextUnSelectColor;
/**分割线颜色, 默认灰色*/
@property (strong, nonatomic) UIColor *separatorColor;
/**cell选中背景颜色, 默认白色*/
@property (strong, nonatomic) UIColor *cellSelectBackgroundColor;
/**cell未选中背景颜色, 默认白色*/
@property (strong, nonatomic) UIColor *cellUnselectBackgroundColor;

/**Item字体大小, 默认14*/
@property (assign, nonatomic) CGFloat itemFontSize;
/**cell字体大小, 默认14*/
@property (assign, nonatomic) CGFloat cellTitleFontSize;
/**cell右侧副字体大小, 默认11*/
@property (assign, nonatomic) CGFloat cellDetailTitleFontSize;
/**下拉表单高度, 默认300*/
@property (assign, nonatomic) CGFloat tableViewHeight;
/**cell高度, 默认44*/
@property (assign, nonatomic) CGFloat cellHeight;
/**左侧表单宽度占屏比 范围0.0~1.0, 默认0.5*/
@property (assign, nonatomic) CGFloat ratioLeftToScreen;//有二级菜单时调整左右所占比例
/**自定义下拉视图*/
@property (strong, nonatomic) NSMutableArray *customViews;
/**动画时间, 默认0.25*/
@property (assign, nonatomic) CGFloat kAnimationDuration;
```

## <a id="Hope"></a>Hope
* If you find bug when used，Hope you can Issues me，Thank you or try to download the latest code of this framework to see the BUG has been fixed or not）
* If you find the function is not enough when used，Hope you can Issues me，I very much to add more useful function to this framework ，Thank you !
* If you want to contribute code for TFDropDownMenut，please Pull Requests me
