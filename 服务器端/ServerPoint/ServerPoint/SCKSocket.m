//
//  SCKSocket.m
//  服务器
//
//  Created by qianfeng on 15-11-23.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import "SCKSocket.h"

@implementation SCKSocket

/**
 *  创建socket、绑定socket、监听socket
 *
 *  @param nPort 设定端口号
 *
 *  @return socket号
 */
+(int)SCKNetMakeSocketWithPort:(int)nPort{
    struct sockaddr_in sin;
    int nSocket;
    int nRetCode;
    
    //创建socket
    nSocket = socket(AF_INET,SOCK_STREAM, 0);
    if (-1 == nSocket){
        return -1;
    }
    
    memset(&sin, 0, sizeof(sin));
    sin.sin_family      = AF_INET;
    sin.sin_addr.s_addr = htonl(INADDR_ANY) ;
    sin.sin_port        = htons(nPort);
    
    //绑定socket
    nRetCode = bind(nSocket, (struct sockaddr *)&sin, sizeof(sin));
    if (-1 == nRetCode){
        close( nSocket );
        return -1;
    }
    
    //监听
    nRetCode = listen(nSocket, 1024);
    if (-1 == nRetCode){
        close( nSocket );
        return -1;
    }
    
    return nSocket;
}

/**
 *  等待客户端连接
 *
 *  @param nSocket   socket号
 *  @param address   连接上的客户端地址
 *  @param blockFlag 是否阻塞 1阻塞 0非阻塞
 *
 *  @return <#return value description#>
 */
+(int)SCKNetAcceptSocketWithSocket:(int)nSocket receiveClientIp:(NSMutableString *)address isBlock:(char)blockFlag{
    
    struct sockaddr_in cli_addr;
    int nAccept = 0;
    int nFlags  = 0;
    unsigned int nAddrSize = 0;
    
    nAccept = -1;
    nAddrSize = sizeof(cli_addr);
    memset((void *)&cli_addr, 0, sizeof(cli_addr));
    
    if(0 == blockFlag){
        nFlags = fcntl(nSocket, F_GETFL, 0);
        fcntl(nSocket, F_SETFL, O_NONBLOCK | nFlags);
    }
    
    nAccept = accept(nSocket, (struct sockaddr *)&cli_addr, &nAddrSize);
    
    if(-1 == nAccept){
        if(EAGAIN != errno){
            return -1;
        }else{
            return -2;
        }
    }
    [address setString:[NSString stringWithUTF8String:inet_ntoa(cli_addr.sin_addr)]];
    return nAccept;
}



/**
 *  发送数据
 *
 *  @param nSocket    对方socket号
 *  @param dataString 数据
 *  @param lWriteSize 预计写数据长度
 *
 *  @return 实际写入长度
 */
+(NSUInteger)SCKNetWriteDataWithSocket:(int)nSocket data:(NSString *)dataString size:(int)lWriteSize{
    
    char *szNetWrite = (char *)malloc([dataString length]+1);
    char *temp = szNetWrite;
    memset(szNetWrite, 0, [dataString length]+1);
    for (int i = 0; i < [dataString length]; i++) {
        char chr = [dataString characterAtIndex:i];
        *szNetWrite = chr;
        szNetWrite++;
    }
    szNetWrite = temp;
    
    long lWrite  = 0;
    long lLeft   = 0;
    long lOffset = 0;
    
    lLeft = lWriteSize;
    lOffset = 0;
    
    while(lLeft > 0){
    again_write:
        lWrite = write(nSocket, szNetWrite + lOffset, lLeft);
        
        if(0 > lWrite){
            if (errno == EINTR){
                goto again_write;
            }
            return -1;
        }else if(0 == lWrite){
            return 0;
        }
        
        lLeft -= lWrite;
        lOffset += lWrite;
    }
    
    return lOffset;
}



/**
 *  读取数据
 *
 *  @param nSocket    对方端口号
 *  @param readString 保存读取数据
 *  @param lReadSize  预计读取数据长度
 *
 *  @return 实际读取数据长度
 */
+(NSUInteger)SCKNetReadDataWithSocket:(int)nSocket data:(NSMutableString *)readString size:(long)lReadSize{
    
    char *szNetRead = (char *)malloc(lReadSize);
    memset(szNetRead, 0, lReadSize);
    
    long lRead   = 0;
    long lLeft   = 0;
    long lOffset = 0;
    
    lLeft = lReadSize;
    lOffset = 0;
    
    while(lLeft > 0)
    {
    again_read:
        lRead = read(nSocket, szNetRead + lOffset, lLeft);
        
        if( 0 > lRead ){
            if (errno == EINTR){
                goto again_read;
            }
            return -1;
        }else if(0 == lRead){
            szNetRead[lOffset] = 0;
            return lOffset;
        }
        
        lLeft -= lRead;
        lOffset += lRead;
    }
    
    szNetRead[lOffset] = 0;
    NSString *string = [NSString stringWithUTF8String:szNetRead];
    [readString setString:string];
    
    return lOffset;
}

/**
 *  关闭socket
 *
 *  @param nSocket socket号
 */
+(void)SCKNetCloseSocket:(int *)nSocket{
    if(-1 != *nSocket){
        close(*nSocket);
        *nSocket = -1;
    }
    return;
}

@end

