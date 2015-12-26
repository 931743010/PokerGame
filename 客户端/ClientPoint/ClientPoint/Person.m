//
//  Person.m
//  ClientPoint
//
//  Created by qianfeng on 15-12-26.
//  Copyright (c) 2015年 sunck. All rights reserved.
//

#import "Person.h"

@implementation Person

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

-(void)playerName{
    SEL sel = @selector(scanfName);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel];
    }
}
-(void)configFile:(NSString *)path{
    SEL sel = @selector(readClientConfigFile:);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel withObject:path];
    }
}
-(void)joinServerWithAddress:(NSString *)address andPoint:(int)point{
    SEL sel = @selector(linkHostWithAddress:andPoint:);
    if ([_delegate respondsToSelector:sel]) {
        [_delegate performSelector:sel withObject:address withObject:[NSNumber numberWithInt:point]];
    }
}

@end
