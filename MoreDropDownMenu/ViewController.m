//
//  ViewController.m
//  MoreDropDownMenu
//
//  Created by ZOMAKE on 2017/11/14.
//  Copyright © 2017年 Brances. All rights reserved.
//

#import "ViewController.h"
#import "MoreDropDownMenu.h"

@interface ViewController ()<MoreDropDownMenuDataSource,MoreDropDownMenuDelegate>

@property (nonatomic, strong) NSArray               *cates;
@property (nonatomic, strong) NSArray               *states;
@property (nonatomic, strong) NSArray               *sorts;
@property (nonatomic, strong) MoreDropDownMenu       *menu;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MoreDropDownMenu";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"dismiss" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    
    self.cates = @[@"全部",@"服饰",@"搭配",@"数码",@"餐厨",@"出行",@"文具",@"居家",@"品牌"];
    self.states = @[@"预热中",@"预售中",@"预售失败",@"成功结束"];
    self.sorts = @[@"最热",@"最新",@"价格"];
    
    _menu = [[MoreDropDownMenu alloc] initWithOrigin:CGPointMake(0, 64) andHeight:49.5];
    _menu.delegate = self;
    _menu.dataSource = self;
    //当下拉菜单收回时的回调，用于网络请求新的数据
    [self.view addSubview:_menu];
    _menu.finishedBlock=^(MoreIndexPath *indexPath){
        if (indexPath.item >= 0) {
            NSLog(@"收起:点击了 %ld - %ld - %ld 项目",indexPath.column,indexPath.row,indexPath.item);
        }else {
            NSLog(@"收起:点击了 %ld - %ld 项目",indexPath.column,indexPath.row);
        }
    };
    [_menu selectIndexPath:[MoreIndexPath indexPathWithCol:1 row:1]];
}

- (void)dismiss{
    //self.classifys = @[@"美食",@"今日新单",@"电影"];
    [_menu hideMenu];
}

#pragma mark - MoreDropDownMenuDataSource and MoreDropDownMenuDelegate
- (NSInteger)numberOfColumnsInMenu:(MoreDropDownMenu *)menu{
    return 3;
}

- (NSInteger)menu:(MoreDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column{
    if (column == 0) {
        return self.cates.count;
    }else if (column == 1){
        return self.states.count;
    }else {
        return self.sorts.count;
    }
}

- (NSString *)menu:(MoreDropDownMenu *)menu titleForRowAtIndexPath:(MoreIndexPath *)indexPath{
    if (indexPath.column == 0) {
        return self.cates[indexPath.row];
    } else if (indexPath.column == 1){
        return self.states[indexPath.row];
    } else {
        return self.sorts[indexPath.row];
    }
}
- (NSArray *)menu:(MoreDropDownMenu *)menu arrayForRowAtIndexPath:(MoreIndexPath *)indexPath{
    if (indexPath.column == 0) {
        return self.cates;
    } else if (indexPath.column == 1){
        return self.states;
    } else {
        return self.sorts;
    }
}

- (void)menu:(MoreDropDownMenu *)menu didSelectRowAtIndexPath:(MoreIndexPath *)indexPath{
        if (indexPath.item >= 0) {
            NSLog(@"点击了 %ld - %ld - %ld 项目",indexPath.column,indexPath.row,indexPath.item);
        }else {
            NSLog(@"点击了 %ld - %ld 项目",indexPath.column,indexPath.row);
        }
}

- (void)didTapMenu:(MoreDropDownMenu *)menu{
    //    if (self.moveScroll) {
    //        self.moveScroll(self.tableView);
    //    }
    
    NSLog(@"点击了菜单");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
