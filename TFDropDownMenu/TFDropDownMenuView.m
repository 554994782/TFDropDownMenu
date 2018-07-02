//
//  TFDropDownMenuView.m
//  TFDropDownMenu
//
//  Created by jiangyunfeng on 2018/6/20.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

#import "TFDropDownMenuView.h"
#import "Masonry.h"
#import "TFDropDownMenuCollectionViewCell.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define STATUSBAR_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define NAVBAR_HEIGHT (STATUSBAR_HEIGHT+44)
#define SCREEN_SCALE [UIScreen mainScreen].scale

@interface TFDropDownMenuView()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

//MARK: 数据源
/**一级菜单title数组*/
@property (strong, nonatomic) NSMutableArray *firstArray;
/**二级菜单title数组*/
@property (strong, nonatomic) NSMutableArray *secondArray;

@property (assign, nonatomic) NSInteger numberOfColumn;//列数
@property (assign, nonatomic) BOOL isShow;
@property (assign, nonatomic) NSInteger currentSelectColumn;//记录最近选中column
@property (assign, nonatomic) NSInteger lastSelectSection;//记录上一次的section选择，用于回显

@property (strong, nonatomic) NSMutableArray *currentSelectSections;//记录最近选中的sections
@property (strong, nonatomic) NSMutableArray *currentBgLayers;//菜单背景layers
@property (strong, nonatomic) NSMutableArray *currentTitleLayers;//菜单titlelayers
@property (strong, nonatomic) NSMutableArray *currentSeparatorLayers;//菜单分隔竖线separatorlayers
@property (strong, nonatomic) NSMutableArray *currentIndicatorLayers;//菜单箭头layers


@property (strong, nonatomic) UIView *backgroundView;//整体背景
@property (strong, nonatomic) UIView *bottomLineView;//菜单底部横线

@property (strong, nonatomic) UITableView *leftTableView;//
@property (strong, nonatomic) UICollectionView *leftCollectionView;//
@property (strong, nonatomic) UITableView *rightTableView;//
@property (strong, nonatomic) UICollectionView *rightCollectionView;//
@property (strong, nonatomic) UIScrollView *customScrollView;//

@end

@implementation TFDropDownMenuView

/**
 菜单初始化方法
 
 @param frame frame
 @param firstArray 一级菜单
 @param secondArray 二级菜单
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame firstArray:(NSMutableArray *)firstArray secondArray:(NSMutableArray *)secondArray {
    self = [super initWithFrame:frame];
    if (self) {
        [self initAttributes];
        self.backgroundColor = [UIColor whiteColor];
        self.firstArray = firstArray;//[NSMutableArray arrayWithArray:firstArray];
        self.secondArray = [NSMutableArray arrayWithArray:secondArray];
        self.numberOfColumn = firstArray.count;
        [self addAllSubView];
        [self addAction];
    }
    
    return self;
}

- (void)initAttributes {
    self.menuBackgroundColor = [UIColor whiteColor];
    self.itemTextSelectColor = [UIColor colorWithRed:246.0/255.0 green:79.0/255.0 blue:0.0/255.0 alpha:1.0];
    self.itemTextUnSelectColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    self.cellTextSelectColor = [UIColor colorWithRed:246.0/255.0 green:79.0/255.0 blue:0.0/255.0 alpha:1.0];
    self.cellTextUnSelectColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    self.separatorColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
    self.cellSelectBackgroundColor = [UIColor whiteColor];
    self.cellUnselectBackgroundColor = [UIColor whiteColor];
    
    self.itemFontSize = 14.0;
    self.cellTitleFontSize = 14.0;
    self.cellDetailTitleFontSize = 11.0;
    self.tableViewHeight = 300.0;
    self.cellHeight = 44;
    self.ratioLeftToScreen = 0.5;
    self.kAnimationDuration = 0.25;
    self.customViews = [NSMutableArray array];
    self.firstArray = [NSMutableArray array];
    self.secondArray = [NSMutableArray array];
    self.currentSelectSections = [NSMutableArray array];
    self.currentBgLayers = [NSMutableArray array];
    self.currentTitleLayers = [NSMutableArray array];
    self.currentSeparatorLayers = [NSMutableArray array];
    self.currentIndicatorLayers = [NSMutableArray array];
    
}

- (void)addAllSubView {
    CGFloat backgroundLayerWidth = self.frame.size.width / _numberOfColumn;
    
    [self.currentBgLayers removeAllObjects];
    [self.currentTitleLayers removeAllObjects];
    [self.currentSeparatorLayers removeAllObjects];
    [self.currentIndicatorLayers removeAllObjects];
    
    for (NSInteger i = 0; i < self.numberOfColumn; i++) {
        [self.currentSelectSections addObject:[NSNumber numberWithInteger:0]];
        
        // backgroundLayer
        CGPoint backgroundLayerPosition = CGPointMake((i + 0.5) * backgroundLayerWidth, self.bounds.size.height * 0.5);
        CALayer *backgroundLayer = [self creatBackgroundLayer:backgroundLayerPosition backgroundColor:self.menuBackgroundColor];
        
        [self.layer addSublayer:backgroundLayer];
        [self.currentBgLayers addObject:backgroundLayer];
        
        // titleLayer
        NSString *titleStr = [self titleOfMenu:i];
        
        CGPoint titleLayerPosition = CGPointMake((i + 0.5) * backgroundLayerWidth, self.bounds.size.height * 0.5);
        CATextLayer *titleLayer = [self creatTitleLayer:titleStr position:titleLayerPosition textColor:self.itemTextUnSelectColor];
        [self.layer addSublayer:titleLayer];
        [self.currentTitleLayers addObject:titleLayer];
        
        // indicatorLayer
        CGSize textSize = [self calculateStringSize:titleStr];// calculateStringSize(titleStr)
        CGPoint indicatorLayerPosition = CGPointMake(titleLayerPosition.x + (textSize.width / 2) + 10, self.bounds.size.height * 0.5 + 2);
        
        CAShapeLayer *indicatorLayer = [self creatIndicatorLayer:indicatorLayerPosition color:self.itemTextUnSelectColor];
        [self.layer addSublayer:indicatorLayer];
        [self.currentIndicatorLayers addObject:indicatorLayer];
        
        // separatorLayer
        if (i != self.numberOfColumn - 1) {
            CGPoint separatorLayerPosition = CGPointMake(ceil((i + 1) * backgroundLayerWidth) - 1, self.bounds.size.height * 0.5);
            
            CAShapeLayer *separatorLayer = [self creatSeparatorLayer:separatorLayerPosition color:_separatorColor];
            [self.layer addSublayer:separatorLayer];
            [self.currentSeparatorLayers addObject:separatorLayer];
        }
    }
    [self addSubview:self.bottomLineView];
}

//MARK: 各种子视图加载
- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-(1.0/SCREEN_SCALE), self.frame.size.width, (1.0/SCREEN_SCALE))];
        _bottomLineView.backgroundColor = _separatorColor;
    }
    return _bottomLineView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [_backgroundView setOpaque:NO];
        [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backTapped:)]];
    }
    return _backgroundView;
}

- (UITableView *)leftTableView {
    if (!_leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * _ratioLeftToScreen, 0)];
        _leftTableView.dataSource = self;
        _leftTableView.delegate = self;
        _leftTableView.rowHeight = _cellHeight;
        _leftTableView.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1];
        _leftTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _leftTableView.separatorColor = _separatorColor;
    }
    return _leftTableView;
}

- (UITableView *)rightTableView {
    if (!_rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x + self.bounds.size.width * _ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - _ratioLeftToScreen), 0)];
        _rightTableView.dataSource = self;
        _rightTableView.delegate = self;
        _rightTableView.rowHeight = _cellHeight;
        _rightTableView.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1];
        _rightTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _rightTableView.separatorColor = _separatorColor;
    }
    return _rightTableView;
}

- (UICollectionView *)leftCollectionView {
    if (!_leftCollectionView) {
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionViewLayout.itemSize = CGSizeMake((self.bounds.size.width-2)/2, _cellHeight);
        collectionViewLayout.minimumInteritemSpacing = 1;
        collectionViewLayout.minimumLineSpacing = 1;
        
        _leftCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * _ratioLeftToScreen, 0) collectionViewLayout:collectionViewLayout];
        _leftCollectionView.delegate = self;
        _leftCollectionView.dataSource = self;
        _leftCollectionView.backgroundColor = _separatorColor;
        [_leftCollectionView registerClass:[TFDropDownMenuCollectionViewCell class] forCellWithReuseIdentifier:@"TFDropDownMenuCollectionViewCell"];
    }
    return _leftCollectionView;
}

- (UICollectionView *)rightCollectionView {
    if (!_rightCollectionView) {
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        _rightCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.frame.origin.x + self.bounds.size.width * _ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - _ratioLeftToScreen), 0) collectionViewLayout:collectionViewLayout];
        _rightCollectionView.delegate = self;
        _rightCollectionView.dataSource = self;
        _rightCollectionView.backgroundColor = _separatorColor;
        [_rightCollectionView registerClass:[TFDropDownMenuCollectionViewCell class] forCellWithReuseIdentifier:@"TFDropDownMenuCollectionViewCell"];
    }
    return _rightCollectionView;
}

- (UIScrollView *)customScrollView {
    if (!_customScrollView) {
        _customScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.frame.origin.x + self.bounds.size.width * _ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - _ratioLeftToScreen), 0)];
        _customScrollView.backgroundColor = [UIColor whiteColor];
    }
    return _rightCollectionView;
}
/// 背景layer
- (CALayer *)creatBackgroundLayer:(CGPoint)position backgroundColor:(UIColor *)backgroundColor {
    CALayer *layer = [[CALayer alloc] init];
    layer.position = position;
    layer.backgroundColor = [_menuBackgroundColor CGColor];
    layer.bounds = CGRectMake(0, 0, self.bounds.size.width/_numberOfColumn, self.bounds.size.height - 1);
    return layer;
}
/// 标题Layer
- (CATextLayer *)creatTitleLayer:(NSString *)text position:(CGPoint)position textColor:(UIColor *)textColor {
    // size
    CGSize textSize = [self calculateStringSize:text];
    CGFloat maxWidth = self.bounds.size.width / _numberOfColumn - 25;
    CGFloat textLayerWidth = textSize.width < maxWidth ? textSize.width : maxWidth;
    
    //textLayer
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    textLayer.bounds = CGRectMake(0, 0, textLayerWidth, textSize.height);
    textLayer.fontSize = _itemFontSize;
    textLayer.string = text;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.truncationMode = kCATruncationEnd;
    textLayer.foregroundColor = [textColor CGColor];
    textLayer.contentsScale = SCREEN_SCALE;
    textLayer.position = position;
    return textLayer;
}
///箭头指示符indicatorLayer
- (CAShapeLayer *)creatIndicatorLayer:(CGPoint)position color:(UIColor *)color {
    // path
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(0, 0)];
    [bezierPath addLineToPoint:CGPointMake(5, 5)];
    [bezierPath moveToPoint:CGPointMake(5, 5)];
    [bezierPath addLineToPoint:CGPointMake(10, 0)];
    [bezierPath closePath];
    
    // shapeLayer
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.lineWidth = 0.8;
    shapeLayer.strokeColor = [color CGColor];
    shapeLayer.bounds = CGPathGetBoundingBox(shapeLayer.path);
    shapeLayer.position = position;
    return shapeLayer;
}
///竖分隔线separatorLayer
- (CAShapeLayer *)creatSeparatorLayer:(CGPoint)position color:(UIColor *)color {
    // path
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(0, 0)];
    [bezierPath addLineToPoint:CGPointMake(0, self.bounds.size.height - 16)];
    [bezierPath closePath];
    
    // separatorLayer
    CAShapeLayer *separatorLayer = [[CAShapeLayer alloc] init];
    separatorLayer.path = bezierPath.CGPath;
    separatorLayer.lineWidth = 1;
    separatorLayer.strokeColor = [color CGColor];
    separatorLayer.bounds = CGPathGetBoundingBox(separatorLayer.path);
    separatorLayer.position = position;
    return separatorLayer;
}

- (CGSize)calculateStringSize: (NSString *)string {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:_itemFontSize]};
    NSStringDrawingOptions option = NSStringDrawingUsesLineFragmentOrigin;
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:option attributes:attributes context:nil].size;
    return CGSizeMake(ceil(size.width)+2, size.height);
}

//MARK: 数据
/**菜单title*/
- (NSString *)titleOfMenu:(NSInteger)column {
    if (column < _firstArray.count && column < _secondArray.count) {
        NSArray *aArray = [NSArray arrayWithArray:_secondArray[column]];
        if (aArray.count > 0) { //有二级目录
            NSArray *strArray = [NSArray arrayWithArray:aArray.firstObject];
            if (strArray.count > 0) {
                return [NSString stringWithFormat:@"%@", strArray.firstObject];
            }
        } else { //没有二级目录
            NSArray *strArray = [NSArray arrayWithArray:_firstArray[column]];
            if (strArray.count > 0) {
                return [NSString stringWithFormat:@"%@", strArray.firstObject];
            }
        }
    }
    return @"";
}

/**一级目录数*/
- (NSInteger)numberOfSectionsInColumn:(NSInteger)column {
    if (column < _firstArray.count) {
        NSArray *aAarray = [NSArray arrayWithArray:_firstArray[column]];
        return aAarray.count;
    }
    return 0;
}

/**二级目录数*/
- (NSInteger)numberOfRowsInColumn:(NSInteger)column section:(NSInteger)section {
    if (column < _secondArray.count) {
        NSArray *rowArray = [NSArray arrayWithArray:_secondArray[column]];
        if (section < rowArray.count) {
            NSArray *aAarray = [NSArray arrayWithArray:rowArray[section]];
            return aAarray.count;
        }
    }
    return 0;
}

/**一级目录名字*/
- (NSString *)titleForColumn:(NSInteger)column section:(NSInteger)section {
    if (column < _firstArray.count) {
        NSArray *strArray = [NSArray arrayWithArray:_firstArray[column]];
        if (section < strArray.count) {
            return [NSString stringWithFormat:@"%@", strArray[section]];
        }
    }
    return @"";
}

/**二级目录名字*/
- (NSString *)titleForColumn:(NSInteger)column section:(NSInteger)section row:(NSInteger)row {
    if (column < _secondArray.count) {
        NSArray *aArray = [NSArray arrayWithArray:_secondArray[column]];
        if (row < aArray.count) { //有二级目录
            NSArray *strArray = [NSArray arrayWithArray:aArray[section]];
            if (row < strArray.count) {
                return [NSString stringWithFormat:@"%@", strArray[row]];
            }
        }
    }
    return @"";
}

/**一级目录图片*/
- (NSString *)imageNameForColumn:(NSInteger)column section:(NSInteger)section {
    if (column < _firstImageArray.count) {
        NSArray *imgArray = [NSArray arrayWithArray:_firstImageArray[column]];
        if (section < imgArray.count) {
            return [NSString stringWithFormat:@"%@", imgArray[section]];
        }
    }
    return nil;
}

/**二级目录图片*/
- (NSString *)imageNameForColumn:(NSInteger)column section:(NSInteger)section row:(NSInteger)row {
    if (column < _secondImageArray.count) {
        NSArray *aArray = [NSArray arrayWithArray:_secondImageArray[column]];
        if (section < aArray.count) { //有二级目录
            NSArray *imgArray = [NSArray arrayWithArray:aArray[section]];
            if (row < imgArray.count ){
                return [NSString stringWithFormat:@"%@", imgArray[row]];
            }
        }
    }
    return nil;
}

/**一级目录detail*/
-(NSString *) detailTextForColumn:(NSInteger)column section:(NSInteger)section {
    if (column < _firstRightArray.count) {
        NSArray *strArray = [NSArray arrayWithArray:_firstRightArray[column]];
        if (section < strArray.count) {
            return [NSString stringWithFormat:@"%@", strArray[section]];
        }
    }
    return @"";
}

/**二级目录detail*/
- (NSString *)detailTextForColumn:(NSInteger)column section:(NSInteger)section row:(NSInteger)row {
    if (column < _secondRightArray.count) {
        NSArray *aArray = [NSArray arrayWithArray:_secondRightArray[column]];
        if (row < aArray.count) { //有二级目录
            NSArray *strArray = [NSArray arrayWithArray:aArray[section]];
            if (row < strArray.count) {
                return [NSString stringWithFormat:@"%@", strArray[row]];
            }
        }
    }
    return @"";
}

// MARK: - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _leftTableView) {
        return [self numberOfSectionsInColumn:_currentSelectColumn];
    }else {
        NSInteger section = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
        return [self numberOfRowsInColumn:_currentSelectColumn section:section];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.textLabel.textColor = _cellTextUnSelectColor;
        cell.textLabel.highlightedTextColor = _cellTextSelectColor;
        cell.textLabel.font = [UIFont systemFontOfSize:_cellTitleFontSize];
        cell.detailTextLabel.textColor = _cellTextUnSelectColor;
        cell.detailTextLabel.highlightedTextColor = _cellTextSelectColor;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:_cellDetailTitleFontSize];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.selectedBackgroundView.backgroundColor = _cellSelectBackgroundColor;
    }
    
    if (tableView == _leftTableView) {
        // 一级列表
        cell.textLabel.text = [self titleForColumn:_currentSelectColumn section:indexPath.row];
        cell.detailTextLabel.text = [self detailTextForColumn:_currentSelectColumn section:indexPath.row];
        // image
        NSString *imagename = [self imageNameForColumn:_currentSelectColumn section:indexPath.row];
        if (imagename) {
            cell.imageView.image = [UIImage imageNamed:imagename];
        } else {
            cell.imageView.image = nil;
        }
        
        // 选中上次选择的行
        NSInteger select = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
        if (select == indexPath.row) {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            
        }
        if ([self numberOfRowsInColumn:_currentSelectColumn section:indexPath.row] > 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    } else {
        // 二级列表
        NSInteger currentSelectedSection = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
        
        cell.textLabel.text = [self titleForColumn:_currentSelectColumn section:currentSelectedSection row:indexPath.row];
        cell.detailTextLabel.text = [self detailTextForColumn:_currentSelectColumn section:currentSelectedSection row:indexPath.row];
        
        // image
        NSString *imagename = [self imageNameForColumn:_currentSelectColumn section:currentSelectedSection row:indexPath.row];
        if (imagename) {
            cell.imageView.image = [UIImage imageNamed:imagename];
        } else {
            cell.imageView.image = nil;
        }
        
        // 选中上次选择的行
        CATextLayer *titlelayer = _currentTitleLayers[_currentSelectColumn];
        
        if ([cell.textLabel.text isEqualToString:[NSString stringWithFormat:@"%@", titlelayer.string]] && _lastSelectSection == currentSelectedSection) {
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_delegate) {
        CATextLayer *titleLayer = _currentTitleLayers[_currentSelectColumn];
        
        if (tableView == _leftTableView) {
            // 一级列表
            
            _currentSelectSections[_currentSelectColumn] = [NSNumber numberWithInteger:indexPath.row];
            BOOL haveItems = ([self numberOfRowsInColumn:_currentSelectColumn section:indexPath.row] > 0);
            [self animateForTitleLayer:titleLayer indicator:_currentIndicatorLayers[_currentSelectColumn] show:YES complete:^{
            }];
            
            if (haveItems) {
                TFDropDownMenuStyle style = TFDropDownMenuStyleTableView;
                if (_currentSelectColumn < _menuStyleArray.count) {
                    style = [NSString stringWithFormat:@"%@", _menuStyleArray[_currentSelectColumn]].integerValue;
                }
                
                switch (style) {
                    case TFDropDownMenuStyleTableView: {
                        [_rightTableView reloadData];
                        break;
                    }
                    default:
                        break;
                }
            }else {
                // 收回列表
                titleLayer.string = [self titleForColumn:_currentSelectColumn section:indexPath.row];
                _lastSelectSection = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
                [self animateForIndicator:_currentIndicatorLayers[_currentSelectColumn] titlelayer:titleLayer show:NO complete:^{
                    self.isShow = NO;
                }];
                if ([self.delegate respondsToSelector:@selector(menuView:selectIndex:)]) {
                    TFIndexPatch *index = [[TFIndexPatch alloc] initWithColumn:_currentSelectColumn section:indexPath.row row:-1];
                    [self.delegate menuView:self selectIndex:index];
                }
            }
            
            
            
        }else {
            // 二级列表
            _lastSelectSection = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
            
            titleLayer.string = [self titleForColumn:_currentSelectColumn section:_lastSelectSection row:indexPath.row];
            
            [self animateForIndicator:_currentIndicatorLayers[_currentSelectColumn] titlelayer:titleLayer show:NO complete:^{
                self.isShow = NO;
            }];
            
            if ([self.delegate respondsToSelector:@selector(menuView:selectIndex:)]) {
                TFIndexPatch *index = [[TFIndexPatch alloc] initWithColumn:_currentSelectColumn section:_lastSelectSection row:indexPath.row];
                [self.delegate menuView:self selectIndex:index];
            }
        }
    }
}
// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _leftCollectionView) {
        return [self numberOfSectionsInColumn:_currentSelectColumn];
    }else {
        NSInteger section = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
        return [self numberOfRowsInColumn:_currentSelectColumn section:section];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TFDropDownMenuCollectionViewCell *cell = [_leftCollectionView dequeueReusableCellWithReuseIdentifier:@"TFDropDownMenuCollectionViewCell" forIndexPath:indexPath];
    cell.titleLabel.textColor = _cellTextUnSelectColor;
    cell.titleLabel.highlightedTextColor = _cellTextSelectColor;
    cell.titleLabel.font = [UIFont systemFontOfSize:_cellTitleFontSize];
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = _cellUnselectBackgroundColor;
    if (collectionView == _leftCollectionView) {
        // 一级列表
        cell.titleLabel.text = [self titleForColumn:_currentSelectColumn section:indexPath.row];
        // 选中上次选择的行
        NSInteger select = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
        if (select == indexPath.row) {
            cell.titleLabel.textColor = _cellTextSelectColor;
            cell.backgroundColor = _cellSelectBackgroundColor;
            
        }
    } else {
        // 二级列表
        NSInteger currentSelectedSection = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
        
        cell.titleLabel.text = [self titleForColumn:_currentSelectColumn section:currentSelectedSection row:indexPath.row];
        // 选中上次选择的行
        CATextLayer *titlelayer = _currentTitleLayers[_currentSelectColumn];
        
        if ([cell.titleLabel.text isEqualToString:[NSString stringWithFormat:@"%@", titlelayer.string]] && _lastSelectSection == currentSelectedSection) {
            cell.titleLabel.textColor = _cellTextSelectColor;
            cell.backgroundColor = _cellSelectBackgroundColor;
        }
    }
    
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_delegate) {
        CATextLayer *titleLayer = _currentTitleLayers[_currentSelectColumn];
        
        if (collectionView == _leftCollectionView) {
            // 一级列表
            
            _currentSelectSections[_currentSelectColumn] = [NSNumber numberWithInteger:indexPath.row];
            BOOL haveItems = ([self numberOfRowsInColumn:_currentSelectColumn section:indexPath.row] > 0);
            [self animateForTitleLayer:titleLayer indicator:_currentIndicatorLayers[_currentSelectColumn] show:YES complete:^{
            }];
            
            if (haveItems) {
                //                [_rightCollectionView reloadData];
            }else {
                // 收回列表
                titleLayer.string = [self titleForColumn:_currentSelectColumn section:indexPath.row];
                _lastSelectSection = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
                [self animateForIndicator:_currentIndicatorLayers[_currentSelectColumn] titlelayer:titleLayer show:NO complete:^{
                    self.isShow = NO;
                }];
                if ([self.delegate respondsToSelector:@selector(menuView:selectIndex:)]) {
                    TFIndexPatch *index = [[TFIndexPatch alloc] initWithColumn:_currentSelectColumn section:indexPath.row row:-1];
                    [self.delegate menuView:self selectIndex:index];
                }
            }
        } else {
            // 二级列表
            _lastSelectSection = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
            
            titleLayer.string = [self titleForColumn:_currentSelectColumn section:_lastSelectSection row:indexPath.row];
            
            [self animateForIndicator:_currentIndicatorLayers[_currentSelectColumn] titlelayer:titleLayer show:NO complete:^{
                self.isShow = NO;
            }];
            
            if ([self.delegate respondsToSelector:@selector(menuView:selectIndex:)]) {
                TFIndexPatch *index = [[TFIndexPatch alloc] initWithColumn:_currentSelectColumn section:_lastSelectSection row:indexPath.row];
                [self.delegate menuView:self selectIndex:index];
            }
        }
    }
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0.5, 0.5, 0.5, 0.5);
    
}

//MARK: 事件Action
/**菜单添加事件*/
- (void)addAction {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
    [self addGestureRecognizer:tap];
}
/**菜单点击响应*/
- (void)menuTapped:(UITapGestureRecognizer *)sender {
    if (_delegate) {
        CGPoint tapPoint = [sender locationInView:self];
        NSInteger tapIndex = tapPoint.x / (self.frame.size.width / _numberOfColumn);
        for (NSInteger i = 0; i < self.numberOfColumn; i++) {
            if (i != tapIndex) {
                [self animateForIndicator:_currentIndicatorLayers[i] show:NO complete:^{
                    [self animateForTitleLayer:self.currentTitleLayers[i] indicator:nil show:NO complete:^{
                    }];
                }];
            }
        }
        // 收回或弹出当前的menu
        if (_currentSelectColumn == tapIndex && _isShow) {// 收回menu
            [self animateForIndicator:_currentIndicatorLayers[tapIndex] titlelayer:_currentTitleLayers[tapIndex] show:NO complete:^{
                self.currentSelectColumn = tapIndex;
                self.isShow = false;
            }];
            _currentSelectSections[_currentSelectColumn] = [NSNumber numberWithInteger:_lastSelectSection];
        } else {// 弹出menu
            if ([self.delegate respondsToSelector:@selector(menuView:tfColumn:)]) {
                [self.delegate menuView:self tfColumn:tapIndex];
            }
            _currentSelectColumn = tapIndex;
            _lastSelectSection = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
            // 载入数据
            [_leftTableView reloadData];
            if ([self numberOfRowsInColumn:_currentSelectColumn section:_lastSelectSection]) {
                [_rightTableView reloadData];
            }
            [self animateForIndicator:_currentIndicatorLayers[tapIndex] titlelayer:_currentTitleLayers[tapIndex] show:YES complete:^{
                self.isShow = YES;
            }];
        }
    }
    
}

/**背景点击*/
- (void)backTapped:(UITapGestureRecognizer *)sender {
    [self animateForIndicator:_currentIndicatorLayers[_currentSelectColumn] titlelayer:_currentTitleLayers[_currentSelectColumn] show:NO complete:^{
        self.isShow = NO;
    }];
}

/**使用代码选中列表中选项*/
- (void)selectedAtIndex:(TFIndexPatch *)indexPath {
    // 判断传入Index是否合法
    
    if (indexPath.column >= 0 && indexPath.section >= 0 && indexPath.column < _firstArray.count && indexPath.section < [self numberOfSectionsInColumn:indexPath.column]) {
    } else {
        NSLog(@"传入的indexPath不合法");
    }
    if (indexPath.row < [self numberOfRowsInColumn:indexPath.column section:indexPath.section] && indexPath.row >= 0) {
    } else {
        NSLog(@"传入的indexPath不合法");
    }
    // 选择
    CATextLayer *titleLayer = _currentTitleLayers[indexPath.column];
    _currentSelectColumn = indexPath.column;
    _currentSelectSections[indexPath.column] = [NSNumber numberWithInteger:indexPath.section];
    if (indexPath.hasRow) {
        titleLayer.string = [self titleForColumn:indexPath.column section:indexPath.section];
        [self animateForTitleLayer:titleLayer indicator: _currentIndicatorLayers[_currentSelectColumn] show: _isShow complete:^{
        }];
    }else {
        titleLayer.string = [self titleForColumn:indexPath.column section:indexPath.section row:indexPath.row];
        [self animateForTitleLayer:titleLayer indicator: _currentIndicatorLayers[_currentSelectColumn] show: _isShow complete:^{
        }];
    }
    if ([self.delegate respondsToSelector:@selector(menuView:selectIndex:)]) {
        [self.delegate menuView:self selectIndex:indexPath];
    }
}
/// 默认选中
- (void)selectDeafult {
    for (NSInteger i = 0; i < _firstArray.count; i++) {
        if ([self numberOfRowsInColumn:i section:0] > 0) {
            TFIndexPatch *index = [[TFIndexPatch alloc] initWithColumn:i section:0 row:0];
            [self selectedAtIndex:index];
        } else {
            TFIndexPatch *index = [[TFIndexPatch alloc] initWithColumn:i section:0 row:-1];
            [self selectedAtIndex:index];
        }
    }
}



//MARK: 动画
/**动画串联*/
- (void)animateForIndicator:(CAShapeLayer *)indicator titlelayer:(CATextLayer *)titlelayer show:(BOOL)show complete:(void(^)(void))complete {
    [self animateForIndicator:indicator show:show complete:^{
        [self animateForTitleLayer:titlelayer indicator:indicator show:show complete:^{
            [self animateForBackgroundView:show complete:^{
                [self animateTableViewWithShow:show complete:^{
                }];
            }];
        }];
    }];
    if (complete) {
        complete();
    }
}

/**箭头指示符动画*/
- (void)animateForIndicator:(CAShapeLayer *)indicator show:(BOOL)show complete:(void(^)(void))complete {
    if (show) {
        indicator.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        indicator.strokeColor = [_itemTextSelectColor CGColor];
    }else {
        indicator.transform = CATransform3DIdentity;
        indicator.strokeColor = [_itemTextUnSelectColor CGColor];
    }
    if (complete) {
        complete();
    }
}

/**backgroundView动画*/
- (void)animateForBackgroundView:(BOOL)show complete:(void(^)(void))complete {
    
    if (show) {
        [self.superview addSubview:self.backgroundView];
        [self.superview addSubview:self];
        [UIView animateWithDuration:_kAnimationDuration animations:^{
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        }];
    } else {
        _currentSelectSections[_currentSelectColumn] = [NSNumber numberWithInteger:_lastSelectSection];
        [UIView animateWithDuration:_kAnimationDuration animations:^{
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        } completion:^(BOOL finished) {
            [self.backgroundView removeFromSuperview];
        }];
    }
    if (complete) {
        complete();
    }
}

/**tableView动画*/
- (void)animateTableViewWithShow:(BOOL)show complete:(void(^)(void))complete {
    
    BOOL haveItems = NO;
    NSInteger numberOfSection = [self numberOfSectionsInColumn:_currentSelectColumn];
    for (NSInteger i = 0; i < numberOfSection; i++) {
        if ([self numberOfRowsInColumn:_currentSelectColumn section:i] > 0) {
            haveItems = YES;
            break;
        }
    }
    
    
    if (show) {
        [self showListViewWithHaveItems:haveItems];
    } else {
        [self hiddenListViewWithHaveItems:haveItems];
    }
    if (complete) {
        complete();
    }
}

- (void)showListViewWithHaveItems:(BOOL)haveItems {
    TFDropDownMenuStyle style = TFDropDownMenuStyleTableView;
    if (_currentSelectColumn < _menuStyleArray.count) {
        style = [NSString stringWithFormat:@"%@", _menuStyleArray[_currentSelectColumn]].integerValue;
    }
    NSInteger numberOfSection = [self numberOfSectionsInColumn:_currentSelectColumn];
    CGFloat tempHeight = numberOfSection * _cellHeight;
    CGFloat heightForTableView = (tempHeight > _tableViewHeight) ? _tableViewHeight : tempHeight;
    if (haveItems) {
        switch (style) {
            case TFDropDownMenuStyleTableView: {
                [self.leftCollectionView removeFromSuperview];
                [self.rightCollectionView removeFromSuperview];
                [self.customScrollView removeFromSuperview];
                self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * _ratioLeftToScreen, 0);
                self.rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * _ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - _ratioLeftToScreen), 0);
                [self.superview addSubview:self.leftTableView];
                [self.superview addSubview:self.rightTableView];
                [UIView animateWithDuration:_kAnimationDuration animations:^{
                    self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * self.ratioLeftToScreen, heightForTableView);
                    self.rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * self.ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - self.ratioLeftToScreen), heightForTableView);
                }];
                break;
            }
            case TFDropDownMenuStyleCollectionView: {
                tempHeight = ((numberOfSection+1)/2) * _cellHeight;
                heightForTableView = (tempHeight > _tableViewHeight) ? _tableViewHeight : tempHeight;
                [self.rightCollectionView removeFromSuperview];
                [self.leftTableView removeFromSuperview];
                [self.rightTableView removeFromSuperview];
                [self.customScrollView removeFromSuperview];
                [self.superview addSubview:self.leftCollectionView];
                //                [self.leftCollectionView reloadData];
                self.leftCollectionView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                
                [UIView animateWithDuration:_kAnimationDuration animations:^{
                    self.leftCollectionView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, heightForTableView);
                }];
                break;
            }
            case TFDropDownMenuStyleCustom: {
                [self.leftCollectionView removeFromSuperview];
                [self.rightCollectionView removeFromSuperview];
                [self.leftTableView removeFromSuperview];
                [self.rightTableView removeFromSuperview];
                [self.customScrollView removeFromSuperview];
                if (_currentSelectColumn < _customViews.count) {
                    UIView *view = _customViews[_currentSelectColumn];
                    if (view != nil) {
                        CGFloat viewHeight = view.frame.size.height > 0 ? view.frame.size.height : _cellHeight;
                        viewHeight = viewHeight > _tableViewHeight ? _tableViewHeight : viewHeight;
                        view.frame = CGRectMake(0, 0, self.bounds.size.width, viewHeight);
                        self.customScrollView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                        [self.customScrollView addSubview:view];
                        [self.superview addSubview:self.customScrollView];
                        [UIView animateWithDuration:_kAnimationDuration animations:^{
                            self.customScrollView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, viewHeight);
                        }];
                    } else {
                        self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * _ratioLeftToScreen, 0);
                        self.rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * _ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - _ratioLeftToScreen), 0);
                        [self.superview addSubview:self.leftTableView];
                        [self.superview addSubview:self.rightTableView];
                        [UIView animateWithDuration:_kAnimationDuration animations:^{
                            self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * self.ratioLeftToScreen, heightForTableView);
                            self.rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * self.ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - self.ratioLeftToScreen), heightForTableView);
                        }];
                    }
                } else {
                    self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * _ratioLeftToScreen, 0);
                    self.rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * _ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - _ratioLeftToScreen), 0);
                    [self.superview addSubview:self.leftTableView];
                    [self.superview addSubview:self.rightTableView];
                    [UIView animateWithDuration:_kAnimationDuration animations:^{
                        self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * self.ratioLeftToScreen, heightForTableView);
                        self.rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * self.ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - self.ratioLeftToScreen), heightForTableView);
                    }];
                }
                break;
            }
            default:
                break;
        }
        
    } else {
        switch (style) {
            case TFDropDownMenuStyleTableView: {
                [self.leftCollectionView removeFromSuperview];
                [self.rightCollectionView removeFromSuperview];
                [self.rightTableView removeFromSuperview];
                [self.customScrollView removeFromSuperview];
                self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                [self.superview addSubview:self.leftTableView];
                [UIView animateWithDuration:_kAnimationDuration animations:^{
                    self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, heightForTableView);
                }];
                break;
            }
            case TFDropDownMenuStyleCollectionView: {
                tempHeight = ((numberOfSection+1)/2) * _cellHeight;
                heightForTableView = (tempHeight > _tableViewHeight) ? _tableViewHeight : tempHeight;
                [self.rightCollectionView removeFromSuperview];
                [self.leftTableView removeFromSuperview];
                [self.rightTableView removeFromSuperview];
                [self.customScrollView removeFromSuperview];
                self.leftCollectionView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                [self.superview addSubview:self.leftCollectionView];
                [UIView animateWithDuration:_kAnimationDuration animations:^{
                    self.leftCollectionView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, heightForTableView);
                }];
                break;
            }
            case TFDropDownMenuStyleCustom: {
                [self.leftCollectionView removeFromSuperview];
                [self.rightCollectionView removeFromSuperview];
                [self.leftTableView removeFromSuperview];
                [self.rightTableView removeFromSuperview];
                [self.customScrollView removeFromSuperview];
                if (_currentSelectColumn < _customViews.count) {
                    UIView *view = _customViews[_currentSelectColumn];
                    if (view != nil) {
                        CGFloat viewHeight = view.frame.size.height > 0 ? view.frame.size.height : _cellHeight;
                        viewHeight = viewHeight > _tableViewHeight ? _tableViewHeight : viewHeight;
                        view.frame = CGRectMake(0, 0, self.bounds.size.width, viewHeight);
                        self.customScrollView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                        [self.customScrollView addSubview:view];
                        [self.superview addSubview:self.customScrollView];
                        [UIView animateWithDuration:_kAnimationDuration animations:^{
                            self.customScrollView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, viewHeight);
                        }];
                    } else {
                        self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                        [self.superview addSubview:self.leftTableView];
                        [UIView animateWithDuration:_kAnimationDuration animations:^{
                            self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, heightForTableView);
                        }];
                    }
                } else {
                    self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                    [self.superview addSubview:self.leftTableView];
                    [UIView animateWithDuration:_kAnimationDuration animations:^{
                        self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, heightForTableView);
                    }];
                }
                break;
            }
            default:
                break;
        }
    }
}

- (void)hiddenListViewWithHaveItems:(BOOL)haveItems {
    TFDropDownMenuStyle style = TFDropDownMenuStyleTableView;
    if (_currentSelectColumn < _menuStyleArray.count) {
        style = [NSString stringWithFormat:@"%@", _menuStyleArray[_currentSelectColumn]].integerValue;
    }
    if (haveItems) {
        
        switch (style) {
            case TFDropDownMenuStyleTableView: {
                [UIView animateWithDuration:_kAnimationDuration animations:^{
                    self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * self.ratioLeftToScreen, 0);
                    self.rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * self.ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - self.ratioLeftToScreen), 0);
                } completion:^(BOOL finished) {
                    [self.leftTableView removeFromSuperview];
                    [self.rightTableView removeFromSuperview];
                }];
                break;
            }
            case TFDropDownMenuStyleCollectionView: {
                [UIView animateWithDuration:_kAnimationDuration animations:^{
                    self.leftCollectionView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                } completion:^(BOOL finished) {
                    [self.leftCollectionView removeFromSuperview];
                }];
                break;
            }
            case TFDropDownMenuStyleCustom: {
                [self.leftCollectionView removeFromSuperview];
                [self.rightCollectionView removeFromSuperview];
                [self.leftTableView removeFromSuperview];
                [self.rightTableView removeFromSuperview];
                [self.customScrollView removeFromSuperview];
                if (_currentSelectColumn < _customViews.count) {
                    UIView *view = _customViews[_currentSelectColumn];
                    if (view != nil) {
                        [UIView animateWithDuration:_kAnimationDuration animations:^{
                            self.customScrollView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                        } completion:^(BOOL finished) {
                            [self.customScrollView removeFromSuperview];
                            for (UIView *subView in [self.customScrollView subviews]) {
                                [subView removeFromSuperview];
                            }
                        }];
                    } else {
                        [UIView animateWithDuration:_kAnimationDuration animations:^{
                            self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * self.ratioLeftToScreen, 0);
                            self.rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * self.ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - self.ratioLeftToScreen), 0);
                        } completion:^(BOOL finished) {
                            [self.leftTableView removeFromSuperview];
                            [self.rightTableView removeFromSuperview];
                        }];
                    }
                } else {
                    [UIView animateWithDuration:_kAnimationDuration animations:^{
                        self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * self.ratioLeftToScreen, 0);
                        self.rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * self.ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - self.ratioLeftToScreen), 0);
                    } completion:^(BOOL finished) {
                        [self.leftTableView removeFromSuperview];
                        [self.rightTableView removeFromSuperview];
                    }];
                }
                break;
            }
            default:
                break;
        }
        
        
    } else {
        switch (style) {
            case TFDropDownMenuStyleTableView: {
                [UIView animateWithDuration:_kAnimationDuration animations:^{
                    self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                } completion:^(BOOL finished) {
                    [self.leftTableView removeFromSuperview];
                }];
                break;
            }
            case TFDropDownMenuStyleCollectionView: {
                [UIView animateWithDuration:_kAnimationDuration animations:^{
                    self.leftCollectionView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                } completion:^(BOOL finished) {
                    [self.leftCollectionView removeFromSuperview];
                }];
                break;
            }
            case TFDropDownMenuStyleCustom: {
                if (_currentSelectColumn < _customViews.count) {
                    UIView *view = _customViews[_currentSelectColumn];
                    if (view != nil) {
                        [UIView animateWithDuration:_kAnimationDuration animations:^{
                            self.customScrollView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                        } completion:^(BOOL finished) {
                            [self.customScrollView removeFromSuperview];
                            for (UIView *subView in [self.customScrollView subviews]) {
                                [subView removeFromSuperview];
                            }
                        }];
                    } else {
                        [UIView animateWithDuration:_kAnimationDuration animations:^{
                            self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                        } completion:^(BOOL finished) {
                            [self.leftTableView removeFromSuperview];
                        }];
                    }
                } else {
                    [UIView animateWithDuration:_kAnimationDuration animations:^{
                        self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
                    } completion:^(BOOL finished) {
                        [self.leftTableView removeFromSuperview];
                    }];
                }
                break;
            }
            default:
                break;
        }
    }
}

/**titleLayer动画*/
- (void)animateForTitleLayer:(CATextLayer *)textLayer indicator:(CAShapeLayer *)indicator show:(BOOL)show complete:(void(^)(void))complete {
    
    CGSize textSize = [self calculateStringSize:[NSString stringWithFormat:@"%@", textLayer.string]];
    
    CGFloat maxWidth = self.bounds.size.width / _numberOfColumn - 25;
    CGFloat textLayerWidth = (textSize.width < maxWidth) ? textSize.width : maxWidth;
    CGFloat textLayerHeight = textSize.height;
    textLayer.bounds = CGRectMake(0, 0, textLayerWidth, textLayerHeight);
    if (indicator) {
        indicator.position = CGPointMake(textLayer.position.x + textLayerWidth / 2 + 10, indicator.position.y) ;
    }
    if (show) {
        textLayer.foregroundColor = [_itemTextSelectColor CGColor];
    }else {
        textLayer.foregroundColor = [_itemTextUnSelectColor CGColor];
    }
    if (complete) {
        complete();
    }
}

/**设置属性*/
- (void)setMenuBackgroundColor:(UIColor *)menuBackgroundColor {
    _menuBackgroundColor = menuBackgroundColor;
    for (CALayer *backLayer in self.currentBgLayers) {
        backLayer.backgroundColor = [_menuBackgroundColor CGColor];
        self.backgroundColor = _menuBackgroundColor;
    }
}
- (void)setItemTextUnSelectColor:(UIColor *)itemTextUnSelectColor {
    _itemTextUnSelectColor = itemTextUnSelectColor;
    for (CATextLayer *titleLayer in self.currentTitleLayers) {
        titleLayer.foregroundColor = [_itemTextUnSelectColor CGColor];
    }
    for (CAShapeLayer *indicatorLayer in self.currentIndicatorLayers) {
        indicatorLayer.strokeColor = [_itemTextUnSelectColor CGColor];
    }
}
- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    for (CAShapeLayer *separatorLayer in self.currentSeparatorLayers) {
        separatorLayer.strokeColor = [_separatorColor CGColor];
    }
}

- (void)setItemFontSize:(CGFloat)itemFontSize {
    _itemFontSize = itemFontSize;
    for (CATextLayer *titleLayer in self.currentTitleLayers) {
        titleLayer.fontSize = _itemFontSize;
    }
}
@end
