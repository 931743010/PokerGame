//
//  Client.m
//  ClientPoint
//
//  Created by qianfeng on 15-12-26.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import "Client.h"
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
    
    
    
    
    //判断用户名是否可用
    [_player checkName];
    if (!_isUse) {
        NSLog(@"用户名已经存在");
        int socket = self.clientSocket;
        [SCKSocket SCKNetCloseSocket:&socket];
        return;
    }
    
    //选择房间等待游戏开始
    [_player play];
    
    
    while (1) {
        
    }
}

/**
 *  转换为明显字符串
 *
 *  @param str 字符形式的牌面情况
 *
 *  @return 带特殊字符的牌面情况
 */
-(NSString *)changeShow:(NSString *)str{
    NSMutableString *info = [NSMutableString stringWithString:str];
    for (int i = 0; i < [info length]; i++) {
        char chr = [info characterAtIndex:i];
        switch (chr) {
            case 'F':
                [info replaceCharactersInRange:NSMakeRange(i, 1) withString:@"♦️"];
                break;
            case 'M':
                [info replaceCharactersInRange:NSMakeRange(i, 1) withString:@"♣️"];
                break;
            case 'H':
                [info replaceCharactersInRange:NSMakeRange(i, 1) withString:@"❤️"];
                break;
            case 'E':
                [info replaceCharactersInRange:NSMakeRange(i, 1) withString:@"♠️"];
                break;
            case 'W':
                [info replaceCharactersInRange:NSMakeRange(i, 1) withString:@""];
                break;
        }
    }
    return info;
}



//*************协议中方法*************
/**
 *  当给_player发送playerName消息时调用此方法，得到玩家名字
 */
-(void)scanfName{
    char _c_name[20] = "";
    NSLog(@"输入玩家姓名");
    scanf("%s", _c_name);
    _player.name = [NSString stringWithUTF8String:_c_name];
}
/**
 *  当给_player发送configFile:消息时调用此方法，读取配置文件
 *
 *  @param path 配置文件路径
 */
-(void)readClientConfigFile:(NSString *)path{
    NSString *fileStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *array = [fileStr componentsSeparatedByString:@":"];
    self.hostAddress = array[0];
    self.hostPoint   = [array[1] intValue];
}
/**
 *  当给_player发送joinServerWithAddress: andPoint:消息时调用此方法，连接服务器
 *
 *  @param address 服务器地址
 *  @param point   服务器端口
 */
-(void)linkHostWithAddress:(NSString *)address andPoint:(NSNumber *)point{
    self.clientSocket = [SCKSocket SCKNetConnectWithServerAddress:address andPort:[point intValue] andDelayTime:0];
}
/**
 *  当给_player发送checkName消息时调用此方法
 *
 *  @param name 验证当前玩家姓名是否可用，如果可用_isUse为YES，否则为NO
 */
-(void)testPersonName:(NSString *)name{
    //写数据
    NSMutableString *writeString = [[NSMutableString alloc] initWithCapacity:700];
    //读取数据
    NSMutableString *readString = [[NSMutableString alloc] initWithCapacity:700];
    
    //验证当前用户名是否可用
    [writeString appendFormat:@"%@", _player.name];
    [SCKSocket SCKNetWriteDataWithSocket:self.clientSocket data:writeString size:700];
    
    [SCKSocket SCKNetReadDataWithSocket:self.clientSocket data:readString size:700];
    if ([readString isEqualToString:@"NO"]) {
        int socket = self.clientSocket;
        [SCKSocket SCKNetCloseSocket:&socket];
        _isUse = NO;
    }else {
        _isUse = YES;
    }
}
/**
 *  当给_player发送play消息时调用此方法，创建游戏线程
 */
-(void)playGame{
    NSThread *playThread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    [playThread start];
}




//************线程方法*************
-(void)run{
    //判断标志
    int flag = 0;
    NSMutableString *readString = [[NSMutableString alloc] initWithCapacity:700];
    NSMutableString *writeString = [[NSMutableString alloc] initWithCapacity:700];
    
    while (1){
        [readString setString:@""];
        [writeString setString:@""];
        //读取服务器发送的数据
        [SCKSocket SCKNetReadDataWithSocket:self.clientSocket data:readString size:700];
        
        //区分数据类型
        NSArray *array = [readString componentsSeparatedByString:@"##"];
        
        //首次打印房间信息
        if ([array[0] isEqualToString:@"FIRSTREFRESHROOMINFO"]) {
            NSLog(@"%@", array[1]);
            flag = 0;
        }
        
        //验证房间人数是否满员
        else if ([array[0] isEqualToString:@"ROOM"]){
            //没满员，可以进入该房间游戏
            if ([array[1] isEqualToString:@"YES"]) {
                flag = 1;
                
            }
            //满员，重新选择房间
            else{
                flag = 0;
                NSLog(@"该房间已经满了");
            }
        }
        //引入房间，等待满员开始游戏
        else if ([array[0] isEqualToString:@"ALLREFRESHROOMINFO"]){
            NSLog(@"%@", array[1]);
            NSLog(@"等待其他玩家进入");
            flag = 1;
        }
        //打印所有人的手牌
        else if ([array[0] isEqualToString:@"GAMEOFCARDSINFO"]){
            NSLog(@"%@", [self changeShow:array[1]]);
            
            flag = 1;
        }
        //打印自己的手牌
        else if ([array[0] isEqualToString:@"HANDCARDINFO"]){
            NSLog(@"我的手牌:%@", [self changeShow:array[1]]);
            NSLog(@"我是 %@", array[2]);
            flag = 0;
        }
        else{
            NSLog(@"%@", array);
        }
        
        
        //选择房间
        if (flag == 0) {
            char getStr[10] = "";
            NSLog(@"请输入房间号:");
            scanf("%s", getStr);
            NSString *roomNum = [NSString stringWithUTF8String:getStr];
            //手动刷新房间信息
            if ([roomNum isEqualToString:@"refresh"]) {
                [writeString appendFormat:@"REFRESHROOM##%@", roomNum];
                [SCKSocket SCKNetWriteDataWithSocket:self.clientSocket data:writeString size:700];
            }else{
                [writeString appendFormat:@"CHOOSEROOM##%@", roomNum];
                [SCKSocket SCKNetWriteDataWithSocket:self.clientSocket data:writeString size:700];
            }
        }
    }
}


@end
