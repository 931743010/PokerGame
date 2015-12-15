//
//  Room.m
//  ServerPoint
//
//  Created by qianfeng on 15-12-15.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import "Room.h"

@implementation Room
/**
 *  get方法
 *
 *  @return 返回对象中存储三个人的socket号码数组的地址
 */
-(NSMutableArray *)threePersonArray{
    return _threePersonArray;
}

/**
 *  构造方法
 *
 *  @param roomNum 当前房间的房间号(从1开始)
 *
 *  @return 返回自己的地址
 */
-(id)initWithRoomNum:(int)roomNum{
    if (self = [super init]) {
        _threePersonArray = [[NSMutableArray alloc] init];
        _roomNum = roomNum;
    }
    return self;
}


/**
 *  重写description方法
 *
 *  @return 返回当前房间的房间号与当前人数等信息
 */
-(NSString *)description{
    NSString *str = [NSString stringWithFormat:@"RoomNum:%2d--RoomPer:%2d", _roomNum, _personNum];
    return str;
}
@end
