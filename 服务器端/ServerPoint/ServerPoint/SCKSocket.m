//
//  SCKSocket.m
//  服务器
//
//  Created by qianfeng on 15-11-23.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import "SCKSocket.h"

@implementation SCKSocket

//创建socket、绑定socket、监听socket
+(int)SCKNetMakeSocketWithPort:(int)nPort{
    struct sockaddr_in sin;
    int nSocket;
    int nValue;
    int nRetCode;
    
    //创建socket
    nSocket = socket(AF_INET,SOCK_STREAM, 0);
    if (-1 == nSocket){
        return -1;
    }
    
    nValue = 1;
    
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
    
    nRetCode = listen(nSocket, 1024);
    if (-1 == nRetCode){
        close( nSocket );
        return -1;
    }
    
    return nSocket;
}

+(int)SCKNetAcceptSocketWithSocket:(int)nSocket receiveClientIp:(NSMutableString *)address isBlock:(char)blockFlag{
    
    struct sockaddr_in cli_addr;
    
    int nAccept, nFlags;
    
    unsigned int nAddrSize;
    
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
    //strcpy(clientAddress, inet_ntoa(cli_addr.sin_addr));
    [address setString:[NSString stringWithUTF8String:inet_ntoa(cli_addr.sin_addr)]];
    return nAccept;

    
}



//写OC字符串数据
+(int)SCKNetWriteDataWithSocket:(int)nSocket data:(NSString *)dataString size:(int)lWriteSize{
    
    char *szNetWrite = (char *)malloc([dataString length]+1);
    char *temp = szNetWrite;
    memset(szNetWrite, 0, [dataString length]+1);
    for (int i = 0; i < [dataString length]; i++) {
        char chr = [dataString characterAtIndex:i];
        *szNetWrite = chr;
        szNetWrite++;
    }
    szNetWrite = temp;
    
    long lWrite, lLeft, lOffset;
    
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

//关闭socket
+(void)SCKNetCloseSocket:(int *)nSocket{
    if(-1 != *nSocket){
        close(*nSocket);
        *nSocket = -1;
    }
    return;
}

//读取数据
+(int)SCKNetReadDataWithSocket:(int)nSocket data:(NSMutableString *)readString size:(long)lReadSize{
    char *szNetRead = (char *)malloc(lReadSize);
    memset(szNetRead, 0, lReadSize);
    
    long lRead, lLeft, lOffset;
    
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
@end

