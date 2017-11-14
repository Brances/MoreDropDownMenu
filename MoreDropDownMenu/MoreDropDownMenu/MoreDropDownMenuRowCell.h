//
//  MoreDropDownMenuRowCell.h
//
//
//  Created by ZOMAKE on 2017/10/9.
//  Copyright © 2017年 Brancs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreDropDownMenuRowCell : UITableViewCell

/** <#注释#> */
@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) void(^clickTagBlock)(NSString *);
/** 选中的按钮 */
@property (nonatomic, strong) UIButton *selectButton;

- (void)setUI:(NSArray *)dataArray;

@end

@interface MoreDropDownMenuRowCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIButton  *button;
@property (nonatomic, assign) BOOL      selectCell;
- (void)setupUI:(NSString *)text;



@end

