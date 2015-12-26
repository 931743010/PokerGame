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
 *  连接服务器
 *
 *  @param hostAdress 服务器主机地址
 *  @param nPort      服务器端口号
 *  @param timeOut    延时时间，0为不延时
 *
 *  @return socket号
 */
+(int)SCKNetConnectWithServerAddress:(NSString *)hostAdress andPort:(int)nPort andDelayTime:(int)timeOut{
    
    //得到C字符串主机地址
    char host[20] = "";
    for (int i = 0; i < [hostAdress length]; i++) {
        host[i] = [hostAdress characterAtIndex:i];
    }
    
    int nSocket = 0;
    int ipAddr  = 0;
    int flags   = 0;
    struct sockaddr_in sin;
    struct hostent *ph;
    
    unsigned int nValue=1;
    
    nSocket = socket( AF_INET,SOCK_STREAM, 0 );
    if ( -1 == nSocket ){
        return -1;
    }
    
    if(timeOut > 0){
        flags = fcntl(nSocket, F_GETFL, 0);
        fcntl(nSocket, F_SETFL, flags | O_NONBLOCK);
        bzero(&sin,sizeof(sin));
    }
    
    bzero(&sin,sizeof(sin));
    
    sin.sin_family = AF_INET;
    sin.sin_port = htons(nPort);
    
    ipAddr = inet_addr(host);
    if(ipAddr != -1){
        memcpy(&(sin.sin_addr.s_addr), &ipAddr, sizeof(ipAddr));
    }else{
        if(NULL == (ph = gethostbyname(host))){
            return -1;
        }
        memcpy(&(sin.sin_addr.s_addr), ph->h_addr, ph->h_length);
    }
    if(timeOut <= 0){
        if(-1 == connect(nSocket, (struct sockaddr *)&sin, sizeof(sin))){
            [self SCKNetCloseSocket:&nSocket];
            return -1;
        }
    }else{
        struct timeval tmv ;
        fd_set r;
        int ret = 0;
        
        tmv.tv_sec =  timeOut/1000;
        tmv.tv_usec = (int)(1000 * (timeOut - tmv.tv_sec * 1000));
        
        if(-1 == connect(nSocket, (struct sockaddr *) &sin, sizeof(sin) )){
            if(errno == EINPROGRESS){
                FD_ZERO(&r);
                FD_SET(nSocket, &r);
                ret = select(nSocket+1, NULL, &r, NULL, &tmv);
                if(ret > 0){
                    int error = 0;
                    getsockopt(nSocket, SOL_SOCKET, SO_ERROR, &error, &nValue);
                    if(error != 0){
                        [self SCKNetCloseSocket:&nSocket];
                        return -1;
                    }
                }
                else if(ret == 0){
                    [self SCKNetCloseSocket:&nSocket];
                    return -1;
                }
                else{
                    [self SCKNetCloseSocket:&nSocket];
                    return -1;
                }
            }
            else{
                [self SCKNetCloseSocket:&nSocket];
                return -1;
            }
        }
        fcntl(nSocket, F_SETFL, flags);
    }
    
    nValue =1;
    setsockopt(nSocket, SOL_SOCKET, SO_KEEPALIVE, &nValue, sizeof(int));
    return nSocket;
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

