//
//  Person.h
//  runtime-methodCache
//
//  Created by 卢育彪 on 2019/11/22.
//  Copyright © 2019年 luyubiao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

- (IMP)test1;
- (IMP)test2;
- (IMP)test3;
- (IMP)test4;
- (IMP)test5;
- (IMP)test6WithHeight:(CGFloat)height age:(NSInteger)age;
- (IMP)test7WithName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
