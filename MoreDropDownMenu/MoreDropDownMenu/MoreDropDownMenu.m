//
//  DOPDropDownMenu.m
//  DOPDropDownMenuDemo
//
//  Created by weizhou on 9/26/14.
//  Modify by tanyang on 20/3/15.
//  Copyright (c) 2014 fengweizhou. All rights reserved.
//

#import "MoreDropDownMenu.h"
#import "MoreDropDownMenuRowCell.h"

#define kMarginBetweenImageAndLabel 3

#define KImageHeight 40.f
#define KImageMargin 20.f
#define KImageCount  3.f

@implementation MoreIndexPath
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        _column = column;
        _row = row;
        _item = -1;
    }
    return self;
}

- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row tem:(NSInteger)item {
    self = [self initWithColumn:column row:row];
    if (self) {
        _item = item;
    }
    return self;
}

+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row {
    MoreIndexPath *indexPath = [[self alloc] initWithColumn:col row:row];
    return indexPath;
}

+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row item:(NSInteger)item
{
    return [[self alloc]initWithColumn:col row:row tem:item];
}

@end

@implementation MoreBackgroundCellView

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画一条底部线
    
    CGContextSetRGBStrokeColor(context, 219.0/255, 224.0/255, 228.0/255, 1);//线条颜色
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width,0);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width,rect.size.height);
    CGContextStrokePath(context);
}

@end

#pragma mark - menu implementation

@interface MoreDropDownMenu (){
    struct {
        unsigned int numberOfRowsInColumn :1;
        unsigned int numberOfItemsInRow :1;
        unsigned int titleForRowAtIndexPath :1;
        unsigned int titleForItemsInRowAtIndexPath :1;
        unsigned int imageNameForRowAtIndexPath :1;
        unsigned int imageNameForItemsInRowAtIndexPath :1;
        unsigned int detailTextForRowAtIndexPath: 1;
        unsigned int detailTextForItemsInRowAtIndexPath: 1;
        
    }_dataSourceFlags;
}

@property (nonatomic, assign) NSInteger currentSelectedMenudIndex;  // 当前选中列

@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) NSInteger numOfMenu;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UICollectionView  *leftCollectionView;
@property (nonatomic, strong) UIImageView *buttomImageView; // 底部imageView
@property (nonatomic, weak) UIView *bottomShadow;

//data source
@property (nonatomic, copy) NSArray *array;
//layers array
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *indicators;
@property (nonatomic, copy) NSArray *bgLayers;
@property (nonatomic, assign) BOOL indicatorIsImageView;
@property (nonatomic, assign) CGFloat dropDownViewWidth;    // 以属性的形式，方便以后修改

//add by xiyang
@property (nonatomic, retain) MoreIndexPath *currentIndexPath; //当前选中的index

@end

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define kTableViewCellHeight 43
#define kTableViewHeight 300
#define kButtomImageViewHeight 21

#define kTextColor [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1]
#define kDetailTextColor [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1]
#define kSeparatorColor [UIColor colorWithRed:219/255.0 green:219/255.0 blue:219/255.0 alpha:1]
#define kCellBgColor [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1]
#define kTextSelectColor [UIColor colorWithRed:246/255.0 green:79/255.0 blue:0/255.0 alpha:1]

@implementation MoreDropDownMenu {
    CGFloat _tableViewHeight;
}

#pragma mark - getter
- (UIColor *)indicatorColor {
    if (!_indicatorColor) {
        _indicatorColor = [UIColor blackColor];
    }
    return _indicatorColor;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

- (UIColor *)separatorColor {
    if (!_separatorColor) {
        _separatorColor = [UIColor blackColor];
    }
    return _separatorColor;
}

- (NSString *)titleForRowAtIndexPath:(MoreIndexPath *)indexPath {
    return [self.dataSource menu:self titleForRowAtIndexPath:indexPath];
}

- (void)reloadData
{
    [self animateBackGroundView:_backGroundView show:NO complete:^{
        [self animateTableView:nil show:NO complete:^{
            self.show = NO;
            id VC = self.dataSource;
            //self.dataSource = nil;
            self.dataSource = VC;
        }];
    }];
    
}

- (void)selectDefalutIndexPath
{
    [self selectIndexPath:[MoreIndexPath indexPathWithCol:0 row:0]];
}

- (void)selectIndexPath:(MoreIndexPath *)indexPath triggerDelegate:(BOOL)trigger {
    if (!_dataSource || !_delegate
        || ![_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
        return;
    }
    
    if ([_dataSource numberOfColumnsInMenu:self] <= indexPath.column || [_dataSource menu:self numberOfRowsInColumn:indexPath.column] <= indexPath.row) {
        return;
    }
    
    CATextLayer *title = (CATextLayer *)_titles[indexPath.column];
    
    if (indexPath.item < 0 ) {
        if (!_isClickHaveItemValid && _dataSourceFlags.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:indexPath.row column:indexPath.column] > 0){
            title.string = [_dataSource menu:self titleForItemsInRowAtIndexPath:[MoreIndexPath indexPathWithCol:indexPath.column row:self.isRemainMenuTitle ? 0 : indexPath.row item:0]];
            if (trigger) {
                [_delegate menu:self didSelectRowAtIndexPath:[MoreIndexPath indexPathWithCol:indexPath.column row:indexPath.row item:0]];
            }
        }else {
            title.string = [_dataSource menu:self titleForRowAtIndexPath:
                            [MoreIndexPath indexPathWithCol:indexPath.column row:self.isRemainMenuTitle ? 0 : indexPath.row]];
            if (trigger) {
                [_delegate menu:self didSelectRowAtIndexPath:indexPath];
            }
        }
        if (_currentSelectRowArray.count > indexPath.column) {
            _currentSelectRowArray[indexPath.column] = @(indexPath.row);
        }
        id indicator = _indicators[indexPath.column];
        [self layoutIndicator:indicator withTitle:title];
        self.currentIndexPath = indexPath;
    }else if (_dataSourceFlags.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:indexPath.row column:indexPath.column] > 0) { //changed by xiyang 解决当column不为0时默认选中为column=1，row=0，item=0导致无法选中的bug
        title.string = [_dataSource menu:self titleForItemsInRowAtIndexPath:indexPath];
        if (trigger) {
            [_delegate menu:self didSelectRowAtIndexPath:indexPath];
        }
        if (_currentSelectRowArray.count > indexPath.column) {
            _currentSelectRowArray[indexPath.column] = @(indexPath.row);
        }
        id indicator = _indicators[indexPath.column];
        [self layoutIndicator:indicator withTitle:title];
        self.currentIndexPath = indexPath;
    }

}

- (void)selectIndexPath:(MoreIndexPath *)indexPath {
    [self selectIndexPath:indexPath triggerDelegate:YES];
}

#pragma mark - setter
- (void)setDataSource:(id<MoreDropDownMenuDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    _dataSource = dataSource;
    
    // remove old layer
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    //configure view
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)]) {
        _numOfMenu = [_dataSource numberOfColumnsInMenu:self];
    } else {
        _numOfMenu = 1;
    }
    
    if (self.indicatorImageNames && self.indicatorImageNames.count) {
        self.indicatorIsImageView = YES;
    }else {
        self.indicatorIsImageView = NO;
    }
    
    _currentSelectRowArray = [NSMutableArray arrayWithCapacity:_numOfMenu];
    
    for (NSInteger index = 0; index < _numOfMenu; ++index) {
        [_currentSelectRowArray addObject:@(0)];
    }
    
    _dataSourceFlags.numberOfRowsInColumn = [_dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)];
    _dataSourceFlags.numberOfItemsInRow = [_dataSource respondsToSelector:@selector(menu:numberOfItemsInRow:column:)];
    _dataSourceFlags.titleForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)];
    _dataSourceFlags.titleForItemsInRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:titleForItemsInRowAtIndexPath:)];
    _dataSourceFlags.imageNameForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:imageNameForRowAtIndexPath:)];
    
    _dataSourceFlags.detailTextForRowAtIndexPath = [_dataSource respondsToSelector:@selector(menu:detailTextForRowAtIndexPath:)];
    
    _bottomShadow.hidden = NO;
    CGFloat textLayerInterval = self.frame.size.width / ( _numOfMenu * 2);
    CGFloat separatorLineInterval = self.frame.size.width / _numOfMenu;
    CGFloat bgLayerInterval = self.frame.size.width / _numOfMenu;
    
    NSMutableArray *tempTitles = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempIndicators = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempBgLayers = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    
    for (int i = 0; i < _numOfMenu; i++) {
        //bgLayer
        CGPoint bgLayerPosition = CGPointMake((i+0.5)*bgLayerInterval, self.frame.size.height/2);
        CALayer *bgLayer = [self createBgLayerWithColor:[UIColor whiteColor] andPosition:bgLayerPosition];
        [self.layer addSublayer:bgLayer];
        [tempBgLayers addObject:bgLayer];
        //title
        CGPoint titlePosition = CGPointMake( (i * 2 + 1) * textLayerInterval , self.frame.size.height / 2);
        
        NSString *titleString;
        if (!self.isClickHaveItemValid && _dataSourceFlags.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:0 column:i]>0) {
            titleString = [_dataSource menu:self titleForItemsInRowAtIndexPath:[MoreIndexPath indexPathWithCol:i row:0]];
        }else {
            titleString =[_dataSource menu:self titleForRowAtIndexPath:[MoreIndexPath indexPathWithCol:i row:0]];
        }
        
        CATextLayer *title = [self createTextLayerWithNSString:titleString withColor:self.textColor andPosition:titlePosition];
        [self.layer addSublayer:title];
        [tempTitles addObject:title];
        //indicator
        if (self.indicatorIsImageView) {
            CGFloat textMaxX = CGRectGetMaxX(title.frame);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(textMaxX + 1, self.frame.size.height / 2, 8, 4)];
            
            if (self.indicatorImageNames && self.indicatorImageNames.count > i)
            {
                UIImage *indicatarImage = [UIImage imageNamed:self.indicatorImageNames[i]];
                //更具图片的尺寸来设置frame
                CGSize imageViewSize = indicatarImage.size;
                CGRect frame = imageView.frame;
                frame.size = imageViewSize;
                frame.origin.y = (self.frame.size.height - imageViewSize.height)/2;//居中
                imageView.frame = frame;
                imageView.image = indicatarImage;
            }else
            {
                imageView.image = [UIImage imageNamed:@"dop_icon_default_indicator"];
            }
            
            [self addSubview:imageView];
            imageView.tag = i;
            [tempIndicators addObject:imageView];
        }else {
            CAShapeLayer *indicator = [self createIndicatorWithColor:self.indicatorColor andPosition:CGPointMake((i + 1)*separatorLineInterval - 10, self.frame.size.height / 2)];
            [self.layer addSublayer:indicator];
            [tempIndicators addObject:indicator];
        }
        //separator
        if (i != _numOfMenu - 1) {
            CGPoint separatorPosition = CGPointMake(ceilf((i + 1) * separatorLineInterval-1), self.frame.size.height / 2);
            CAShapeLayer *separator = [self createSeparatorLineWithColor:self.separatorColor andPosition:separatorPosition];
            [self.layer addSublayer:separator];
        }
        
        [self layoutIndicator:tempIndicators[i] withTitle:tempTitles[i]];
    }
    _titles = [tempTitles copy];
    _indicators = [tempIndicators copy];
    _bgLayers = [tempBgLayers copy];
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.backgroundColor = KUnSelectBorderColor.CGColor;
    lineLayer.frame = CGRectMake(0, self.frame.size.height, kScreenWidth, 0.5);
    [self.layer addSublayer:lineLayer];
    
    
}

//add by xiyang
-(void)setShow:(BOOL)show{
    _show = show;
    if (!show) {
        if (self.currentIndexPath!=nil) {
            if (self.finishedBlock) {
                self.finishedBlock(self.currentIndexPath);
            }
        }
        NSLog(@"收回");
    }
}
#pragma mark - init method
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {
    return [self initWithOrigin:origin width:[UIScreen mainScreen].bounds.size.width andHeight:height];
}

- (instancetype)initWithOrigin:(CGPoint)origin width:(CGFloat)width andHeight:(CGFloat)height {
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, width, height)];
    if (self) {
        self.backgroundColor = KButtonColor;
        _origin = origin;
        _currentSelectedMenudIndex = -1;
        self.show = NO;
        _fontSize = 14;
        _cellStyle = UITableViewCellStyleValue1;
        _separatorColor = [UIColor whiteColor];
        _textColor = KButtonColor;
        _textSelectedColor = KSelectBorderColor;
        _detailTextFont = [UIFont systemFontOfSize:11];
        _detailTextColor = kDetailTextColor;
        _indicatorColor = KButtonColor;
        _tableViewHeight = IS_IPHONE_4_OR_LESS ? 200 : kTableViewHeight;
        _dropDownViewWidth = [UIScreen mainScreen].bounds.size.width;
        _isClickHaveItemValid = YES;
        _indicatorAlignType = MoreIndicatorAlignTypeCloseToTitle;
        CGSize dropDownViewSize = CGSizeMake(_dropDownViewWidth, [UIScreen mainScreen].bounds.size.height);
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _leftCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _leftCollectionView.delegate = self;
        _leftCollectionView.dataSource = self;
        _leftCollectionView.backgroundColor = [UIColor whiteColor];
        _leftCollectionView.showsHorizontalScrollIndicator = NO;
        _leftCollectionView.showsVerticalScrollIndicator = NO;
        //注册CELL
        [_leftCollectionView registerClass:[MoreDropDownMenuRowCollectionCell class] forCellWithReuseIdentifier:@"MoreDropDownMenuRowCollectionCell"];
        
        _buttomImageView = [[UIImageView alloc]initWithFrame:CGRectMake(origin.x, self.frame.origin.y + self.frame.size.height, dropDownViewSize.width, 0.5)];
        _buttomImageView.image = [self imageWithColor:KUnSelectBorderColor size:CGSizeMake(1, 1)];
        
        //self tapped
        self.backgroundColor = [UIColor whiteColor];
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
        [self addGestureRecognizer:tapGesture];
        
        //background init and tapped
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(origin.x, origin.y + 0, dropDownViewSize.width, dropDownViewSize.height)];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backGroundView addGestureRecognizer:gesture];
        
        //add bottom shadow
//        UIView *bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, width, 0.5)];
//        //bottomShadow.backgroundColor = kSeparatorColor;
//        bottomShadow.backgroundColor = [UIColor whiteColor];
//        bottomShadow.hidden = NO;
//        [self addSubview:bottomShadow];
//        _bottomShadow = bottomShadow;
        
        
    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - CollectionDataSource Delegate
//行数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (_dataSourceFlags.numberOfRowsInColumn) {
        return [_dataSource menu:self
            numberOfRowsInColumn:_currentSelectedMenudIndex];
    } else {
        //NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
        return 0;
    }
}
//大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((kScreenWidth - 2 * KImageMargin - 2 * KImageMargin)/KImageCount,KImageHeight * FIT_WIDTH);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return KImageMargin;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return KImageMargin;
}
//分区缩进
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(KImageMargin, KImageMargin, 0, KImageMargin);
}

//数据源
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MoreDropDownMenuRowCollectionCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:@"MoreDropDownMenuRowCollectionCell" forIndexPath:indexPath];
    if ([_dataSource menu:self titleForRowAtIndexPath:[MoreIndexPath indexPathWithCol:_currentSelectedMenudIndex row:indexPath.row]]) {
        [cell setupUI:[_dataSource menu:self titleForRowAtIndexPath:[MoreIndexPath indexPathWithCol:_currentSelectedMenudIndex row:indexPath.row]]];
    }
    
    NSInteger currentSelectedMenudRow = [_currentSelectRowArray[_currentSelectedMenudIndex] integerValue];
    if (indexPath.row == currentSelectedMenudRow){
        cell.selectCell = YES;
    }else{
        cell.selectCell = NO;
    }
    
    if (_dataSourceFlags.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:indexPath.row column:_currentSelectedMenudIndex]> 0){
        NSLog(@"选中");
    } else {
        NSLog(@"未选中");
    }
    
    return cell;
}

#pragma mark - init support
- (CALayer *)createBgLayerWithColor:(UIColor *)color andPosition:(CGPoint)position {
    CALayer *layer = [CALayer layer];
    
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, self.frame.size.width/self.numOfMenu, self.frame.size.height-1);
    layer.backgroundColor = color.CGColor;
    
    return layer;
}

- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(4, 5)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 0.8;
    layer.fillColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;
    
    return layer;
}

- (CAShapeLayer *)createSeparatorLineWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(160,0)];
    [path addLineToPoint:CGPointMake(160, 20)];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1;
    layer.strokeColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = point;
    return layer;
}

- (CATextLayer *)createTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point {
    
    CGSize size = [self calculateTitleSizeWithString:string];
    
    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    layer.string = string;
    layer.fontSize = _fontSize;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.truncationMode = kCATruncationEnd;
    layer.foregroundColor = color.CGColor;
    
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    layer.position = point;
    
    return layer;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string{
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:_fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return CGSizeMake(ceilf(size.width)+2, size.height);
}

#pragma mark - gesture handle
- (void)menuTapped:(UITapGestureRecognizer *)paramSender {
    if (_dataSource == nil) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(didTapMenu:)]) {
        [self.delegate didTapMenu:self];
    }
    
    CGPoint touchPoint = [paramSender locationInView:self];
    //calculate index
    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / _numOfMenu);
    
    for (int i = 0; i < _numOfMenu; i++) {
        if (i != tapIndex) {
            [self animateIndicator:_indicators[i] Forward:NO complete:^{
                [self animateTitle:_titles[i] show:NO complete:^{
                    
                }];
            }];
        }
    }
    
    if (tapIndex == _currentSelectedMenudIndex && _show) {
        [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_leftCollectionView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
            _currentSelectedMenudIndex = tapIndex;
            self.show = NO;
        }];
    } else {
        _currentSelectedMenudIndex = tapIndex;
        [_leftCollectionView reloadData];
        
        [self animateIdicator:_indicators[tapIndex] background:_backGroundView tableView:_leftCollectionView title:_titles[tapIndex] forward:YES complecte:^{
            self.show = YES;
        }];
    }
}

- (void)backgroundTapped:(UITapGestureRecognizer *)paramSende{
    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_leftCollectionView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
        self.show = NO;
    }];
}

- (void)hideMenu{
    if (_show) {
        [self backgroundTapped:nil];
    }
}

#pragma mark - Private Method

- (void)layoutIndicator:(id)indicator withTitle:(CATextLayer *)title {
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25 -kMarginBetweenImageAndLabel) ? size.width : self.frame.size.width / _numOfMenu - 25 - kMarginBetweenImageAndLabel;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    if (self.indicatorAlignType == MoreIndicatorAlignTypeCloseToTitle) {
        if (self.indicatorIsImageView) {
            CGRect indicatorFrame = ((UIImageView *)indicator).frame;
            indicatorFrame.origin.x = CGRectGetMaxX(title.frame) + kMarginBetweenImageAndLabel;
            ((UIImageView *)indicator).frame = indicatorFrame;
        }else {
            CGRect indicatorFrame = ((CAShapeLayer *)indicator).frame;
            indicatorFrame.origin.x = CGRectGetMaxX(title.frame) + kMarginBetweenImageAndLabel;
            ((CAShapeLayer *)indicator).frame = indicatorFrame;
        }
    }
}

#pragma mark - animation method
- (void)animateIndicator:(id)indicator Forward:(BOOL)forward complete:(void(^)())complete {
    if (self.indicatorIsImageView) {
        [self animateIndicatorImageView:(UIImageView *)indicator Forward:forward complete:complete];
    }else {
        [self animateIndicatorShapeLayer:(CAShapeLayer *)indicator Forward:forward complete:complete];
    }
}

- (void)animateIndicatorShapeLayer:(CAShapeLayer *)indicator Forward:(BOOL)forward complete:(void(^)())complete{
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim forKey:anim.keyPath];
        [indicator setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    if (forward) {
        // 展开
        indicator.fillColor = _textSelectedColor.CGColor;
    } else {
        // 收缩
        indicator.fillColor = _textColor.CGColor;
    }
    
    complete();
}

- (void)animateIndicatorImageView:(UIImageView *)indicator Forward:(BOOL)forward complete:(void(^)())complete {
    NSInteger tapedIndex = indicator.tag;
    BOOL canTransform = YES;
    if (self.indicatorAnimates && self.indicatorAnimates.count > tapedIndex) {
        canTransform = [self.indicatorAnimates[tapedIndex] boolValue];
    }
    if (forward && canTransform) {
        indicator.transform =  CGAffineTransformMakeRotation(M_PI);
    }else{
        indicator.transform = CGAffineTransformIdentity;
    }
    
    complete();
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    complete();
}

- (void)animateTableView:(UICollectionView *)tableView show:(BOOL)show complete:(void(^)())complete {
    
    BOOL haveItems = NO;
    
    if (_dataSource) {
        NSInteger num = [_leftCollectionView numberOfItemsInSection:0];
        
        for (NSInteger i = 0; i<num;++i) {
            if (_dataSourceFlags.numberOfItemsInRow
                && [_dataSource menu:self numberOfItemsInRow:i column:_currentSelectedMenudIndex] > 0) {
                haveItems = YES;
                break;
            }
        }
    }
    
    if (show) {
        if (haveItems) {
            _leftCollectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth/2, 0);
            [self.superview addSubview:_leftCollectionView];
        } else {
            _leftCollectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth, 0);
            [self.superview addSubview:_leftCollectionView];
            
        }
        _buttomImageView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth, 1);
        [self.superview addSubview:_buttomImageView];
        
        CGFloat count = [_dataSource menu:self arrayForRowAtIndexPath:[MoreIndexPath indexPathWithCol:_currentSelectedMenudIndex row:_currentSelectedMenudIndex]].count;
        
        CGFloat tableViewHeight = KImageHeight * FIT_WIDTH * ceil(count / KImageCount) + ceil(count / KImageCount) * KImageMargin + KImageMargin;
        
        [UIView animateWithDuration:0.2 animations:^{
            if (haveItems) {
                _leftCollectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth/2, tableViewHeight);
            } else {
                _leftCollectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth, tableViewHeight);
            }
            _buttomImageView.frame = CGRectMake(self.origin.x, CGRectGetMaxY(_leftCollectionView.frame), _dropDownViewWidth, 0.5);
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            if (haveItems) {
                _leftCollectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth/2, 0);
            } else {
                _leftCollectionView.frame = CGRectMake(self.origin.x, self.frame.origin.y + self.frame.size.height, _dropDownViewWidth, 0);
            }
            _buttomImageView.frame = CGRectMake(self.origin.x, CGRectGetMaxY(_leftCollectionView.frame), _dropDownViewWidth, 0.5);
        } completion:^(BOOL finished) {
            [_leftCollectionView removeFromSuperview];
            [_buttomImageView removeFromSuperview];
        }];
    }
    complete();
}

- (void)animateTitle:(CATextLayer *)title show:(BOOL)show complete:(void(^)())complete {
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    if (!show) {
        title.foregroundColor = _textColor.CGColor;
    } else {
        title.foregroundColor = _textSelectedColor.CGColor;
    }
    complete();
}

- (void)animateIdicator:(id)indicator background:(UIView *)background tableView:(UICollectionView *)tableView title:(CATextLayer *)title forward:(BOOL)forward complecte:(void(^)())complete{
    if (self.indicatorAlignType == MoreIndicatorAlignTypeCloseToTitle) {
        [self layoutIndicator:indicator withTitle:title];
    }
    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                [self animateTableView:tableView show:forward complete:^{
                }];
            }];
        }];
    }];
    
    complete();
}

#pragma mark - tableview delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (_leftCollectionView == collectionView) {
        self.currentIndexPath = [MoreIndexPath indexPathWithCol:_currentSelectedMenudIndex row:indexPath.row];
        BOOL haveItem = [self confiMenuWithSelectRow:indexPath.row];
        BOOL isClickHaveItemValid = self.isClickHaveItemValid ? YES : haveItem;
        
        if (isClickHaveItemValid && _delegate && [_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
            [self.delegate menu:self didSelectRowAtIndexPath:self.currentIndexPath];
            
        }
    }
}

- (BOOL )confiMenuWithSelectRow:(NSInteger)row {
    
    _currentSelectRowArray[_currentSelectedMenudIndex] = @(row);
    
    
    CATextLayer *title = (CATextLayer *)_titles[_currentSelectedMenudIndex];
    
    if (_dataSourceFlags.numberOfItemsInRow && [_dataSource menu:self numberOfItemsInRow:row column:_currentSelectedMenudIndex]> 0) {
        
        // 有双列表 有item数据
        if (self.isClickHaveItemValid) {
            title.string = [_dataSource menu:self titleForRowAtIndexPath:[MoreIndexPath indexPathWithCol:_currentSelectedMenudIndex row:row]];
            [self animateTitle:title show:YES complete:^{
                
            }];
        } else {
            
        }
        return NO;
        
    } else {
        
        title.string = [_dataSource menu:self titleForRowAtIndexPath:
                        [MoreIndexPath indexPathWithCol:_currentSelectedMenudIndex row:self.isRemainMenuTitle ? 0 : row]];
        [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_leftCollectionView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
            self.show = NO;
        }];
        return YES;
    }
}


@end

