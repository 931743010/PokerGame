//
//  SCKSocket.h
//  服务器
//
//  Created by qianfeng on 15-11-23.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <strings.h>

@interface SCKSocket : NSObject

//连接socket
//+(int)SCKNetConnectWithServerAddress:(char *)host andPort:(int)nPort andDelayTime:(int)timeOut;
+(int)SCKNetConnectWithServerAddress:(NSString *)hostAdress andPort:(int)nPort andDelayTime:(int)timeOut;
//发送数据
+(NSUInteger)SCKNetWriteDataWithSocket:(int)nSocket data:(NSString *)dataString size:(int)lWriteSize;
//读取数据
+(NSUInteger)SCKNetReadDataWithSocket:(int)nSocket data:(NSMutableString *)readString size:(long)lReadSize;
//关闭socket
+(void)SCKNetCloseSocket:(int *)nSocket;

@end
