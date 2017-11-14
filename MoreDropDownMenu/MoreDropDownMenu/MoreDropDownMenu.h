//
//  MoreDropDownMenu.h
//  MoreDropDownMenuDemo
//
//  Created by weizhou on 9/26/14.
//  Modify by tanyang on 20/3/15.
//  Copyright (c) 2014 fengweizhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreIndexPath : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger item;
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;
// default item = -1
+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row;
+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row item:(NSInteger)item;
@end

@interface MoreBackgroundCellView : UIView

@end

#pragma mark - data source protocol
@class MoreDropDownMenu;

@protocol MoreDropDownMenuDataSource <NSObject>

@required

/**
 *  返回 menu 第column列有多少行
 */
- (NSInteger)menu:(MoreDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column;

/**
 *  返回 menu 第column列 每行title
 */
- (NSString *)menu:(MoreDropDownMenu *)menu titleForRowAtIndexPath:(MoreIndexPath *)indexPath;
/**
 *  返回 menu 第column列 标题集合
 */
- (NSArray *)menu:(MoreDropDownMenu *)menu arrayForRowAtIndexPath:(MoreIndexPath *)indexPath;

@optional
/**
 *  返回 menu 有多少列 ，默认1列
 */
- (NSInteger)numberOfColumnsInMenu:(MoreDropDownMenu *)menu;

// 新增 返回 menu 第column列 每行image
- (NSString *)menu:(MoreDropDownMenu *)menu imageNameForRowAtIndexPath:(MoreIndexPath *)indexPath;

// 新增 detailText ,right text
- (NSString *)menu:(MoreDropDownMenu *)menu detailTextForRowAtIndexPath:(MoreIndexPath *)indexPath;

/** 新增
 *  当有column列 row 行 返回有多少个item ，如果>0，说明有二级列表 ，=0 没有二级列表
 *  如果都没有可以不实现该协议
 */
- (NSInteger)menu:(MoreDropDownMenu *)menu numberOfItemsInRow:(NSInteger)row column:(NSInteger)column;

/** 新增
 *  当有column列 row 行 item项 title
 *  如果都没有可以不实现该协议
 */
- (NSString *)menu:(MoreDropDownMenu *)menu titleForItemsInRowAtIndexPath:(MoreIndexPath *)indexPath;

@end

#pragma mark - delegate
@protocol MoreDropDownMenuDelegate <NSObject>
@optional
/**
 *  点击代理，点击了第column 第row 或者item项，如果 item >=0
 */
- (void)menu:(MoreDropDownMenu *)menu didSelectRowAtIndexPath:(MoreIndexPath *)indexPath;

/** 新增
 *  return nil if you don't want to user select specified indexpath
 *  optional
 */
- (NSIndexPath *)menu:(MoreDropDownMenu *)menu willSelectRowAtIndexPath:(MoreIndexPath *)indexPath;

- (void)didTapMenu:(MoreDropDownMenu *)menu;

@end

#pragma mark - interface

typedef NS_ENUM(NSInteger, MoreIndicatorAlignType) {
    MoreIndicatorAlignTypeRight = 0,     //指示图标居右
    MoreIndicatorAlignTypeCloseToTitle,  //指示图标挨着文字，有一个默认间距设置为3
};

@interface MoreDropDownMenu : UIView <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, weak) id <MoreDropDownMenuDataSource> dataSource;
@property (nonatomic, weak) id <MoreDropDownMenuDelegate> delegate;

@property (nonatomic, assign) UITableViewCellStyle cellStyle; // default value1
@property (nonatomic, strong) UIColor *indicatorColor;      // 三角指示器颜色
@property (nonatomic, strong) UIColor *textColor;           // 文字title颜色
@property (nonatomic, strong) UIColor *textSelectedColor;   // 文字title选中颜色
@property (nonatomic, strong) UIColor *detailTextColor;     // detailText文字颜色
@property (nonatomic, strong) UIFont *detailTextFont;       // font
@property (nonatomic, strong) UIColor *separatorColor;      // 分割线颜色
@property (nonatomic, assign) NSInteger fontSize;           // 字体大小

//add by xiyang
@property (nonatomic, copy) void(^finishedBlock)(MoreIndexPath *indexPath);//回收回调

// 当有二级列表item时，点击row 是否调用点击代理方法
@property (nonatomic, assign) BOOL isClickHaveItemValid;

@property (nonatomic, getter=isRemainMenuTitle) BOOL remainMenuTitle; // 切换条件时是否更改menu title
@property (nonatomic, strong) NSMutableArray  *currentSelectRowArray; // 恢复默认选项用
@property (nonatomic, strong) NSArray<NSString *> *indicatorImageNames;// 自定义指示器图片(在设置dataSource之前调用才会生效)
@property (nonatomic, strong) NSArray<NSNumber *> *indicatorAnimates;  // 指示器图片是否可以transform(在设置dataSource之前调用才会生效)
@property (nonatomic, assign) MoreIndicatorAlignType indicatorAlignType;

/**
 *  the width of menu will be set to screen width defaultly
 *
 *  @param origin the origin of this view's frame
 *  @param height menu's height
 *
 *  @return menu
 */
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;

- (instancetype)initWithOrigin:(CGPoint)origin width:(CGFloat)width andHeight:(CGFloat)height;
// 获取title
- (NSString *)titleForRowAtIndexPath:(MoreIndexPath *)indexPath;

// 重新加载数据
- (void)reloadData;

// 收回菜单
- (void)hideMenu;

// 创建menu 第一次显示 不会调用点击代理，这个手动调用
- (void)selectDefalutIndexPath;

- (void)selectIndexPath:(MoreIndexPath *)indexPath; // 默认trigger delegate

- (void)selectIndexPath:(MoreIndexPath *)indexPath triggerDelegate:(BOOL)trigger; // 调用代理
@end

