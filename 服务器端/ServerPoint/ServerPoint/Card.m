//
//  Card.m
//  ServerPoint
//
//  Created by qianfeng on 15-12-3.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import "Card.h"

@implementation Card
/**
 *  字符串形式描述一张牌
 *
 *  @return 描述字符串结果
 */
-(NSString *)description{
    NSString *str = [NSString stringWithFormat:@"%@%@", _cardColor, _cardSize];
    return str;
}

/**
 *  单张牌排序
 *
 *  @param other 排序另一个对象
 *
 *  @return 是否排序
 */
-(BOOL)isSmallWithOther:(Card *)other{
    return self.cardPoint < other.cardPoint;
}
@end
