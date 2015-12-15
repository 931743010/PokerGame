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

+(int)SCKNetMakeSocketWithPort:(int)nPort;
+(int)SCKNetAcceptSocketWithSocket:(int)nSocket receiveClientIp:(NSMutableString *)address isBlock:(char)blockFlag;
+(int)SCKNetWriteDataWithSocket:(int)nSocket data:(NSString *)dataString size:(int)lWriteSize;




+(void)SCKNetCloseSocket:(int *)nSocket;



+(int)SCKNetReadDataWithSocket:(int)nSocket data:(NSMutableString *)readString size:(long)lReadSize;

@end
