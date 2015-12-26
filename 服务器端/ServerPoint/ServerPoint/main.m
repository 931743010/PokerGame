//
//  main.m
//  ServerPoint
//
//  Created by qianfeng on 15-12-14.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"
#import "SCKSocket.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        //配置文件路径
        NSString *hostConfigurationFilePath = @"/Users/qianfeng/Desktop/PokerGameV0.1/PokerGame/服务器端/ServerPoint/ServerPoint/hostConfigurationFile";
        //创建服务器对象
        Server *server = [Server defaultPoint:hostConfigurationFilePath];
        //查看默认房间信息
        NSLog(@"%@", [server allRoomInfoView]);
        
        //创建socket
        [server createServerSocket];
        
        //
        [server createThreadForWatchRoomPerNum];
        
        //等待客户端连接
        [server waitForClientJoin];
        
        
        
    }
    return 0;
}

