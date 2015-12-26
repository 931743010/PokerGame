//
//  Person.h
//  ClientPoint
//
//  Created by qianfeng on 15-12-26.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PersonDelegate <NSObject>
-(void)scanfName;
-(void)readClientConfigFile:(NSString *)path;
-(void)linkHostWithAddress:(NSString *)address andPoint:(NSNumber *)point;
-(BOOL)testPersonName:(NSString *)name;

@end


@interface Person : NSObject

//代理
@property (nonatomic, assign) id<PersonDelegate>delegate;

//用户名
@property (nonatomic, copy) NSString *name;
//手牌字符打印形式
@property (nonatomic, copy) NSString *cardStyle;
//手牌点数大小
@property (nonatomic, assign) int pointSum;


//输入名字
-(void)playerName;
//读取配置文件
-(void)configFile:(NSString *)path;
//连接服务器
-(void)joinServerWithAddress:(NSString *)address andPoint:(int)point;

@end
