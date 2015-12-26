//
//  HandCard.h
//  ServerPoint
//
//  Created by qianfeng on 15-12-3.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HandCard : NSObject
{
    //保存3张手牌
    NSMutableArray *_handCardsArray;
}
-(NSMutableArray *)handCardsArray;
//手牌的牌面点数的和
@property (nonatomic, assign) int handCardsPointSum;

//抓牌
+(void)grabCards:(int)num personArray:(NSMutableArray *)perArray;

//计算手牌大小
+(void)calculateEveryPersonHandCardsPointSumFromArray:(NSMutableArray *)perArray;


@end
