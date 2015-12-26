//
//  Card.h
//  ServerPoint
//
//  Created by qianfeng on 15-12-3.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Card : NSObject
@property (nonatomic, copy) NSString *cardColor;//牌花色
@property (nonatomic, copy) NSString *cardSize;//牌面大小
@property (nonatomic, assign) int cardPoint;//牌面值的大小
@property (nonatomic, assign) int cardFlag;//标志是否可用

//单张牌排序
-(BOOL)isSmallWithOther:(Card *)other;
@end
