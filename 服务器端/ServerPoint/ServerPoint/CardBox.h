//
//  CardBox.h
//  ServerPoint
//
//  Created by qianfeng on 15-12-3.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardBox : NSObject
{
    //用于保存54张扑克对象
    NSMutableArray *_allCardsArray;
}
//get方法，用来得到保存54张扑克数据的对象
-(NSMutableArray *)allCardsArray;

//单例形式创建扑克盒对象
+(CardBox *)defaultBox;
//释放上一个扑克盒对象
+(void)deleteSign;

@end
