//
//  NSArray+ZMAdd.m
//  Zomake
//
//  Created by uzhengxiang on 16/6/28.
//  Copyright © 2016年 ZOMAKE. All rights reserved.
//

#import "NSArray+ZMAdd.h"

@implementation NSArray (ZMAdd)

- (id)safeObjectAtIndex:(NSUInteger)index{
    
    if (index >= self.count) {
        return nil;
    }
    
    return [self objectAtIndex:index];
    
}

@end
