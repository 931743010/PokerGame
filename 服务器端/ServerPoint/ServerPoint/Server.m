//
//  Server.m
//  ServerPoint
//
//  Created by qianfeng on 15-12-15.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import "Server.h"
#import "Room.h"
#import "SCKSocket.h"
#import "HandCard.h"
#import "CardBox.h"

#define ROOMCOUNT 20     //房间数量

static Server *signServer = nil;

@implementation Server
/**
 *  构造方法
 *
 *  @param path 配制文件地址
 *
 *  @return 对象
 */
-(id)initWithFile:(NSString *)path{
    if (self = [super init]) {
        _allRoomInfo = [[NSMutableArray alloc] initWithCapacity:ROOMCOUNT];
        _socketAndNameDic = [[NSMutableDictionary alloc] initWithCapacity:ROOMCOUNT * 3];
        
        //读取配置文件，获取主机IP于端口号
        NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
       
        _hostPoint = [fileString intValue];
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
+(Server *)defaultPoint:(NSString *)hostConfigurationFile{
    @synchronized(self){
        if (signServer == nil) {
            //创建服务器对象
            signServer = [[Server alloc] initWithFile:hostConfigurationFile];
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
-(NSString *)allRoomInfoView{
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

/**
 *  创建socket连接
 */
-(void)createServerSocket{
    self.socketNum = [SCKSocket SCKNetMakeSocketWithPort:_hostPoint];
}


/**
 *  创建监听线程，当房间人数为3时则开始游戏
 */
-(void)createThreadForWatchRoomPerNum{
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(watchThread) object:nil];
    [thread start];
}


/**
 *  等待用户连接
 */
-(void)waitForClientJoin{
    while (1) {
        NSLog(@"等待客户端连接……\n\n\n");
        NSMutableString *clientAddress = [[NSMutableString alloc] init];
        int accept = [SCKSocket SCKNetAcceptSocketWithSocket:self.socketNum receiveClientIp:clientAddress isBlock:1];
        //NSLog(@"clientAddress = %@", clientAddress);
        
        NSMutableString *readString = [[NSMutableString alloc] initWithCapacity:700];
        [SCKSocket SCKNetReadDataWithSocket:accept data:readString size:700];
        
        //验证用户名是否可用
        int flag = 0;
        
        for (NSNumber *key in _socketAndNameDic) {
            NSString *oneName = _socketAndNameDic[key];
            if ([oneName isEqualToString:readString]) {
                flag = 1;
                break;
            }
        }
        
        if (flag == 1) {
            [SCKSocket SCKNetWriteDataWithSocket:accept data:@"NO" size:700];
            [SCKSocket SCKNetCloseSocket:&accept];
        }else{
            [SCKSocket SCKNetWriteDataWithSocket:accept data:@"YES" size:700];
            //将此客户端号存入服务器数组
            [_socketAndNameDic setObject:readString forKey:[NSNumber numberWithInt:accept]];
            
            
            //用户验证链接成功，则服务器开启对象用户处理线程
            NSThread *myThread = [[NSThread alloc] initWithTarget:self selector:@selector(run:) object:[NSNumber numberWithInt:accept]];
            myThread.name = [NSString stringWithFormat:@"%d", accept];
            [myThread start];
        }
        //NSLog(@"dic = %@", _socketAndNameDic);
    }
}



//*************线程方法****************
/**
 *  对应于客户端的执行线程
 *
 *  @param accept 客户端的socket号
 */
-(void)run:(NSNumber *)accept{
    NSMutableString *readString = [[NSMutableString alloc] initWithCapacity:700];
    NSMutableString *writeString = [[NSMutableString alloc] initWithCapacity:700];
    //首次发送当前房间信息
    [writeString appendFormat:@"FIRSTREFRESHROOMINFO##%@", [self allRoomInfoView]];
    [SCKSocket SCKNetWriteDataWithSocket:[accept intValue] data:writeString size:700];
    
    while (1) {
        //读取服务器发送的数据
        [readString setString:@""];
        [writeString setString:@""];
        [SCKSocket SCKNetReadDataWithSocket:[accept intValue] data:readString size:700];
        
        NSArray *array = [readString componentsSeparatedByString:@"##"];
        
        if ([array[0] isEqualToString:@"CHOOSEROOM"]) {
            //判断房间是否可用
            BOOL is = [self isExistFreeRoom:array[1]];
            if (!is) {
                //房间不可用
                [SCKSocket SCKNetWriteDataWithSocket:[accept intValue] data:@"ROOM##NO" size:700];
            }else{
                //房间可用
                [SCKSocket SCKNetWriteDataWithSocket:[accept intValue] data:@"ROOM##YES" size:700];
                
                //房间相应人数增加一人
                for (Room *room in _allRoomInfo) {
                    if (room.roomNum == [array[1] intValue]) {
                        room.personNum += 1;
                        [room.threePersonArray addObject:accept];
                    }
                }
                
                
                //通知每一个用户刷新房间信息
                for (NSNumber *socket in _socketAndNameDic) {
                    [writeString setString:@""];
                    [writeString appendFormat:@"ALLREFRESHROOMINFO##%@", [self allRoomInfoView]];
                    [SCKSocket SCKNetWriteDataWithSocket:[socket intValue] data:writeString size:700];
                }
            }
        }
        else if ([array[0] isEqualToString:@"REFRESHROOM"]){
            [writeString appendFormat:@"FIRSTREFRESHROOMINFO##%@", [self allRoomInfoView]];
            [SCKSocket SCKNetWriteDataWithSocket:[accept intValue] data:writeString size:700];
        }
    }
}

/**
 *  监听线程，当房间人数为3时则开始游戏
 */
-(void)watchThread{
    NSMutableString *writeString = [[NSMutableString alloc] initWithCapacity:700];
    NSMutableArray *threeHandCards = [[NSMutableArray alloc] initWithCapacity:3];
    while (1) {
        sleep(1);
        for (Room *room in _allRoomInfo) {
            //为3时则开始游戏
            if (room.personNum == 3) {
                room.personNum = 0;
                
                for (int loop = 0; loop < 3; loop++) {
                    HandCard *handCard = [[HandCard alloc] init];
                    [threeHandCards addObject:handCard];
                }
                [HandCard grabCards:3 personArray:threeHandCards];
                
                [HandCard calculateEveryPersonHandCardsPointSumFromArray:threeHandCards];
                //找到牌值最大的值
                int max = [[threeHandCards objectAtIndex:0] handCardsPointSum];
                if ([[threeHandCards objectAtIndex:1] handCardsPointSum] > max) {
                    max = [[threeHandCards objectAtIndex:1] handCardsPointSum];
                }
                if ([[threeHandCards objectAtIndex:2] handCardsPointSum] > max) {
                    max = [[threeHandCards objectAtIndex:2] handCardsPointSum];
                }
                
                //合成三个人手牌的整体信息
                NSMutableString *allPlayerCards = [[NSMutableString alloc] initWithString:@"GAMEOFCARDSINFO##RAT:"];
                for (HandCard *h in threeHandCards) {
                    [allPlayerCards appendFormat:@"\n%@", h];
                }
                
                //发给每个人
                int i = 0;
                int flag = 0;
                for (NSNumber *accp in room.threePersonArray) {
                    [writeString appendString:@"HANDCARDINFO##"];
                    [SCKSocket SCKNetWriteDataWithSocket:[accp intValue] data:allPlayerCards size:700];
                    
                    HandCard *m = threeHandCards[i++];
                    [writeString appendFormat:@"%@", m];
                    if (m.handCardsPointSum == max && flag == 0) {
                        [writeString appendString:@"##WINER"];
                        flag++;
                    }else{
                        [writeString appendString:@"##LOSER"];
                    }
                    [SCKSocket SCKNetWriteDataWithSocket:[accp intValue] data:writeString size:700];
                    [writeString setString:@""];
                }
                
                [room.threePersonArray removeAllObjects];
                [threeHandCards removeAllObjects];
                
                
                [CardBox deleteSign];
            }
        }
    }
}
@end
