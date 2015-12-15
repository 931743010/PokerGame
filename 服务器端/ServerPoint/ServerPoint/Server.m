//
//  Server.m
//  ServerPoint
//
//  Created by qianfeng on 15-12-15.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import "Server.h"
#import "Room.h"

#define ROOMCOUNT 20     //房间数量

static Server *signServer = nil;

@implementation Server
/**
 *  构造方法
 *
 *  @return 返回自己的地址
 */
-(id)init{
    if (self = [super init]) {
        _allRoomInfo = [[NSMutableArray alloc] initWithCapacity:ROOMCOUNT];
        _socketAndNameDic = [[NSMutableDictionary alloc] initWithCapacity:ROOMCOUNT * 3];
    }
    return self;
}
/**
 *  get方法
 *
 *  @return 返回存储所有房间数组的地址
 */
-(NSMutableArray *)allRoomInfo{
    return _allRoomInfo;
}
/**
 *  get方法
 *
 *  @return 返回存储(客户端socket号-客户端用户名)键值对字典的地址
 */
-(NSMutableDictionary *)socketAndNameDic{
    return _socketAndNameDic;
}

/**
 *  单例方法，类方法创建当前类的对象
 *
 *  @return 单例对象
 */
+(Server *)defaultPoint{
    @synchronized(self){
        if (signServer == nil) {
            //创建服务器对象
            signServer = [[Server alloc] init];
            //创建好服务器对象后直接添加ROOMCOUNT个空房间
            for (int i = 1; i <= ROOMCOUNT; i++) {
                Room *room = [[Room alloc] initWithRoomNum:i];
                //将房间添加到服务器对象属性数组中
                [signServer.allRoomInfo addObject:room];
            }
        }
    }
    return signServer;
}
/**
 *  释放单例对象
 */
+(void)deletePoint{
    if (signServer != nil) {
        signServer = nil;
    }
}


/**
 *  返回所有房间信息
 *
 *  @return 返回所有房间信息，可用于客户端打印
 */
/*示例如下
************************************************************
*
*
*    RoomNum: 1--RoomPer: 0    RoomNum: 2--RoomPer: 0
*    RoomNum: 3--RoomPer: 0    RoomNum: 4--RoomPer: 0
*    RoomNum: 5--RoomPer: 0    RoomNum: 6--RoomPer: 0
*    RoomNum: 7--RoomPer: 0    RoomNum: 8--RoomPer: 0
*    RoomNum: 9--RoomPer: 0    RoomNum:10--RoomPer: 0
*    RoomNum:11--RoomPer: 0    RoomNum:12--RoomPer: 0
*    RoomNum:13--RoomPer: 0    RoomNum:14--RoomPer: 0
*    RoomNum:15--RoomPer: 0    RoomNum:16--RoomPer: 0
*    RoomNum:17--RoomPer: 0    RoomNum:18--RoomPer: 0
*    RoomNum:19--RoomPer: 0    RoomNum:20--RoomPer: 0
*
*
************************************************************
 */
-(NSString *)roomInfoView{
    NSString *s = @"************************************************************";
    NSMutableString *viewInfoString = [[NSMutableString alloc] init];
    [viewInfoString appendFormat:@"\n%@\n*\n*\n", s];
    
    NSMutableString *str = [[NSMutableString alloc] initWithString:@"*"];
    for (int i = 0; i < ROOMCOUNT; i++) {
        if (i % 2 == 0 && i > 0) {
            [viewInfoString appendFormat:@"%@\n", str];
            [str setString:@"*"];
        }
        [str appendFormat:@"    %@", _allRoomInfo[i]];
    }
    [viewInfoString appendFormat:@"%@\n", str];
    [viewInfoString appendFormat:@"*\n*\n%@\n", s];
    
    return viewInfoString;
}


/**
 *  判断房间是否可用
 *
 *  @param roomId 待验证房间号码
 *
 *  @return YES为可用，NO为不可用
 */
-(BOOL)isExistFreeRoom:(NSString *)roomId{
    for (Room *room in _allRoomInfo) {
        if (room.roomNum == [roomId intValue]) {
            if (room.personNum < 3) {
                return YES;
            }
        }
    }
    return NO;
}



@end
