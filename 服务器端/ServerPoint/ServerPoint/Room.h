//
//  Room.h
//  ServerPoint
//
//  Created by qianfeng on 15-12-15.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Room : NSObject
{
    //用来保存当前房间三个人的socket号码
    NSMutableArray *_threePersonArray;
}
-(NSMutableArray *)threePersonArray;

//当前房间的房间号码
@property (nonatomic, assign) int roomNum;
//当前房间的玩家人数
@property (nonatomic, assign) int personNum;

//创建房间对象时即赋予房间号码(从1开始)
-(id)initWithRoomNum:(int)roomNum;
@end
