//
//  Server.h
//  ServerPoint
//
//  Created by qianfeng on 15-12-15.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Server : NSObject
{
    //保存所有房间的信息
    NSMutableArray *_allRoomInfo;
    
    //存储键值对(客户端socket号-客户端用户名)，用于验证客户端连接时客户端用户是否重名
    NSMutableDictionary *_socketAndNameDic;
}
-(NSMutableArray *)allRoomInfo;
-(NSMutableDictionary *)socketAndNameDic;



//socket所需主机端口号(从配置文件hostConfigurationFile中读取)
@property (nonatomic, assign) int hostpoint;
//socket所需主机ip地址(从配置文件hostConfigurationFile中读取)
@property (nonatomic, copy) NSString *hostAddress;
//socket号
@property (nonatomic, assign) int socketNum;


//创建服务器对象，单例模式
+(Server *)defaultPoint;
//释放服务器对象
+(void)deletePoint;


//返回所有房间信息
-(NSString *)allRoomInfoView;


//判断房间是否可用
-(BOOL)isExistFreeRoom:(NSString *)roomId;


@end
