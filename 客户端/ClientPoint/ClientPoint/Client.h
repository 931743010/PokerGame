//
//  Client.h
//  ClientPoint
//
//  Created by qianfeng on 15-12-26.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Person.h"

@interface Client : NSObject <PersonDelegate>
//房间是否可用
@property (nonatomic, assign) BOOL isUse;
//主机ip地址（配置文件中读取）
@property (nonatomic, copy) NSString *hostAddress;
//主机端口号（配置文件中读取）
@property (nonatomic, assign) int hostPoint;
//客户端socket号
@property (nonatomic, assign) int clientSocket;


//加载客户端
-(void)viewDidLoad;

//执行线程
-(void)run;

@end
