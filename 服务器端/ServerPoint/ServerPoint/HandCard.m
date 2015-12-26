//
//  HandCard.m
//  ServerPoint
//
//  Created by qianfeng on 15-12-3.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import "HandCard.h"
#import "CardBox.h"
#import "Card.h"

@implementation HandCard
/**
 *  重写init方法
 *
 *  @return 返回对象
 */
-(id)init{
    if (self = [super init]) {
        //指向真正的对象
        _handCardsArray = [[NSMutableArray alloc] init];
    }
    return self;
}
-(NSMutableArray *)handCardsArray{
    return _handCardsArray;
}

/**
 *  抓牌
 *
 *  @param num      每个玩家抓拍张数
 *  @param perArray 保存玩家的数组
 */
+(void)grabCards:(int)num personArray:(NSMutableArray *)perArray{
    CardBox *cardBox = [CardBox defaultBox];
    for (int i = 0; i < num; i++) {
        for (HandCard *per in perArray) {
            Card *card = [[cardBox allCardsArray] objectAtIndex:0];
            [[per handCardsArray] addObject:card];
            
            [cardBox.allCardsArray removeObjectAtIndex:0];
        }
    }
    //手牌排序
    for (HandCard *per in perArray) {
        [per.handCardsArray sortUsingSelector:@selector(isSmallWithOther:)];
    }
}

/**
 *  计算手牌大小
 *
 *  @param perArray 保存玩家的数组
 */
+(void)calculateEveryPersonHandCardsPointSumFromArray:(NSMutableArray *)perArray{
    //按数组中顺序依次计算每个玩家的手牌点数大小
    for (HandCard *per in perArray) {
        //豹子
        if ([per.handCardsArray[0] cardPoint] == [per.handCardsArray[1] cardPoint] && [per.handCardsArray[0] cardPoint] == [per.handCardsArray[2] cardPoint]) {
            per.handCardsPointSum = 30000 + [per.handCardsArray[0] cardPoint] * 3;
        }
        //同花顺、同花
        else if ([[per.handCardsArray[0] cardColor] isEqualToString:[per.handCardsArray[1] cardColor]] && [[per.handCardsArray[0] cardColor] isEqualToString:[per.handCardsArray[2] cardColor]]){
            
            //同花顺
            if ([per.handCardsArray[0] cardPoint] - [per.handCardsArray[1] cardPoint] == 1 && [per.handCardsArray[0] cardPoint] - [per.handCardsArray[2] cardPoint] == 2) {
                per.handCardsPointSum = 24000 + [per.handCardsArray[1] cardPoint];
            }else if ([per.handCardsArray[0] cardPoint] == 14 && [per.handCardsArray[1] cardPoint] == 3 && [per.handCardsArray[2] cardPoint] == 2){
                per.handCardsPointSum = 24000 + [per.handCardsArray[2] cardPoint];
            }
            
            //同花
            else{
                per.handCardsPointSum = 18000 + [per.handCardsArray[0] cardPoint] * 300 + [per.handCardsArray[1] cardPoint] * 10 + [per.handCardsArray[2] cardPoint];
            }
        }
        
        //顺子
        else if ([per.handCardsArray[0] cardPoint] - [per.handCardsArray[1] cardPoint] == 1 && [per.handCardsArray[0] cardPoint] - [per.handCardsArray[2] cardPoint] == 2) {
            per.handCardsPointSum = 12000 + [per.handCardsArray[1] cardPoint];
        }else if ([per.handCardsArray[0] cardPoint] == 14 && [per.handCardsArray[1] cardPoint] == 3 && [per.handCardsArray[2] cardPoint] == 2){
            per.handCardsPointSum = 12000 + [per.handCardsArray[2] cardPoint];
        }
        
        //对子
        else if ([per.handCardsArray[1] cardPoint] == [per.handCardsArray[0] cardPoint]){
            per.handCardsPointSum = 6000 + [per.handCardsArray[1] cardPoint] * 20 + [per.handCardsArray[2] cardPoint];
        }else if ([per.handCardsArray[1] cardPoint] == [per.handCardsArray[2] cardPoint]){
            per.handCardsPointSum = 6000 + [per.handCardsArray[1] cardPoint] * 20 + [per.handCardsArray[0] cardPoint];
        }
        
        //单张
        else{
            per.handCardsPointSum = [per.handCardsArray[0] cardPoint] * 300 + [per.handCardsArray[1] cardPoint] * 10 + [per.handCardsArray[2] cardPoint];
        }
    }
}

-(NSString *)description{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    for (Card *card in _handCardsArray) {
        [str appendFormat:@"\t%@", card];
    }
    return str;
}


@end
