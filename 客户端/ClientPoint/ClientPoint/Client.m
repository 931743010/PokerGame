//
//  Client.m
//  ClientPoint
//
//  Created by qianfeng on 15-12-26.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import "Client.h"
#import "Person.h"
#import "SCKSocket.h"

@interface Client ()
{
    Person *_player;
}
@end

@implementation Client

/**
 *  重写init
 *
 *  @return 服务器对象
 */
-(id)init{
    if (self = [super init]) {
        //初始化一个玩家
        _player = [[Person alloc] init];
    }
    return self;
}

/**
 *  加载客户端度
 */
-(void)viewDidLoad{
    
    //将自己设置为玩家的代理
    _player.delegate = self;
    
    
    //输入用户
    [_player playerName];
    
    
    //读取配置文件
    NSString *path = @"/Users/qianfeng/Desktop/PokerGameV0.1/PokerGame/客户端/ClientPoint/ClientPoint/clientConfigFile";
    [_player configFile:path];
    
    
    //连接服务器
    [_player joinServerWithAddress:self.hostAddress andPoint:self.hostPoint];
}








//*************协议中方法*************
-(void)scanfName{
    char _c_name[20] = "";
    scanf("%s", _c_name);
    _player.name = [NSString stringWithUTF8String:_c_name];
}
-(void)readClientConfigFile:(NSString *)path{
    NSString *fileStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *array = [fileStr componentsSeparatedByString:@":"];
    self.hostAddress = array[0];
    self.hostPoint   = [array[1] intValue];
}
-(void)linkHostWithAddress:(NSString *)address andPoint:(NSNumber *)point{
    self.clientSocket = [SCKSocket SCKNetConnectWithServerAddress:address andPort:[point intValue] andDelayTime:0];
}




@end
