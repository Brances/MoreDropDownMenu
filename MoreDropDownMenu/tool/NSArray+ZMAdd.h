//
//  NSArray+ZMAdd.h
//  Zomake
//
//  Created by uzhengxiang on 16/6/28.
//  Copyright © 2016年 ZOMAKE. All rights reserved.
//  安全获取索引中的对象

#import <Foundation/Foundation.h>

@interface NSArray (ZMAdd)

- (id)safeObjectAtIndex:(NSUInteger)index;

@end
