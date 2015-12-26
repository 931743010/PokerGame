//
//  main.m
//  ClientPoint
//
//  Created by qianfeng on 15-12-14.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Client.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        //创建服务器对象
        Client *client = [[Client alloc] init];
        
        [client viewDidLoad];
        
    }
    return 0;
}

