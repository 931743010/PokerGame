//
//  CardBox.m
//  ServerPoint
//
//  Created by qianfeng on 15-12-3.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import "CardBox.h"
#import "Card.h"

static CardBox *sign = nil;

@implementation CardBox
/**
 *  get方法
 *
 *  @return 保存54张扑克数组的对象
 */
-(NSMutableArray *)allCardsArray{
    return _allCardsArray;
}
/**
 *  重写init方法
 *
 *  @return 扑克盒对象
 */
-(id)init{
    if (self = [super init]) {
        //是数组指针指向一个真正的对象
        _allCardsArray = [[NSMutableArray alloc] init];
    }
    return self;
}
/**
 *  单例形式创建扑克盒对象
 *
 *  @return 扑克盒对象
 */
+(CardBox *)defaultBox{
    @synchronized(self){
        if (sign == nil) {
            //创建对象
            sign = [[CardBox alloc] init];
            
            //制造54个扑克对象放入扑克盒中
            [sign creatAllCardsToArray];
            //将54张扑克对象顺序打乱，相当于洗牌
            [sign shuffleCards];
        }
    }
    return sign;
}
+(id)allocWithZone:(struct _NSZone *)zone{
    @synchronized(self){
        if (sign == nil) {
            sign = [super allocWithZone:zone];
        }
    }
    return sign;
}
/**
 *  释放上一个扑克盒对象
 */
+(void)deleteSign{
    if (sign) {
        sign = nil;
    }
}


/**
 *  制造54个扑克对象放入扑克盒中
 */
-(void)creatAllCardsToArray{
    //F代表方块，M代表梅花，H代表红桃，E代表黑桃，W代表王
    NSArray *cardColorArray = @[@"F", @"M", @"H", @"E", @"W"];
    //元素本身是牌的花色，元素的下标是牌面值点数大小
    NSArray *cardSizeArray  = @[@"", @"", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K", @"A", @"X", @"D"];
    
    for (int i = 0; i <= 4; i++) {
        for (int j = 2; j <= 16; j++) {
            //控制i=4时，跳过j=2~14
            if (i == 4 && j != 15 && j != 16) {
                continue;
            }
            //控制i=0~3时，跳过j=15~16
            else if (i != 4 && (j == 15 || j == 16)) {
                continue;
            }
            //创建扑克对象
            Card *oneCard = [[Card alloc] init];
            
            //花色、大小、牌面值、是否可用进行相应赋值
            oneCard.cardColor = cardColorArray[i];
            oneCard.cardSize  = cardSizeArray[j];
            oneCard.cardPoint = j;
            oneCard.cardFlag  = 1;
            
            //放入数组(放入扑克盒的数组中)
            [_allCardsArray addObject:oneCard];
        }
    }
}
/**
 *  洗牌，将54张扑克在数组中的顺序打乱
 */
-(void)shuffleCards{
    //在整副牌中去除了大小王
    //    [_allCardsArray[52] setCardFlag:0];
    //    [_allCardsArray[53] setCardFlag:0];
    [_allCardsArray removeLastObject];
    [_allCardsArray removeLastObject];
    
    int index1 = 0;
    int index2 = 0;
    for (int count = 0; count <= 100000; count++) {
        index1 = arc4random()%52;//产生0~51(包含0和51)之间的随机数
        index2 = arc4random()%52;
        if (index1 == index2) {
            count--;
            continue;
        }
        //交换两张扑克的位置
        [_allCardsArray exchangeObjectAtIndex:index1 withObjectAtIndex:index2];
    }
}

-(NSString *)description{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    for (Card *card in _allCardsArray) {
        [str appendFormat:@"\n%@", card];
    }
    return str;
}



@end
