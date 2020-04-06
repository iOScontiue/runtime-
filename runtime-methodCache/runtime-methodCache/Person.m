//
//  Person.m
//  runtime-methodCache
//
//  Created by 卢育彪 on 2019/11/22.
//  Copyright © 2019年 luyubiao. All rights reserved.
//

#import "Person.h"

@implementation Person

- (IMP)test1
{
    IMP imp = [self methodForSelector:_cmd];
    return imp;
}

- (IMP)test2
{
    IMP imp = [self methodForSelector:_cmd];
    return imp;
}

- (IMP)test3
{
    IMP imp = [self methodForSelector:_cmd];
    return imp;
}

- (IMP)test4
{
    IMP imp = [self methodForSelector:_cmd];
    return imp;
}

- (IMP)test5
{
    IMP imp = [self methodForSelector:_cmd];
    return imp;
}

- (IMP)test6WithHeight:(CGFloat)height age:(NSInteger)age
{
    IMP imp = [self methodForSelector:_cmd];
    return imp;
}

- (IMP)test7WithName:(NSString*)name
{
    IMP imp = [self methodForSelector:_cmd];
    return imp;
}

@end
