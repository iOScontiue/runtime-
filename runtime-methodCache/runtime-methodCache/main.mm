//
//  main.m
//  runtime-methodCache
//
//  Created by 卢育彪 on 2019/11/20.
//  Copyright © 2019年 luyubiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#import "CacheBaseInfo.h"
#import "Person.h"

#define ORIGINAL_MASK 3

//方法缓存
struct cache_t *methodCaches;

//创建方法缓存
void createCaches(mask_t mask);
//存储方法
void saveSEL(char const*method, SEL selector, IMP methodIMP, char const*types);
//缓存扩容
void expandCaches();
//是否扩容
void isExpandCaches();
//被调方法是否存在缓存中
bool isMethodExist(SEL selector);
//打印缓存信息
void ergodicBuckets();
//处理方法
void handleMethod(char const *name, SEL selector, IMP imp);

//OC字符串转成C字符串
char* strConvertToChar(NSString *str);

void createCaches(mask_t mask) {
    //创建散列表
    struct bucket_t *originalBuckets = (struct bucket_t *)malloc(sizeof(struct bucket_t)*mask);
    for (int i = 0; i < mask; i++) {
        originalBuckets[i]._name = "";
        originalBuckets[i]._key = 0;
        originalBuckets[i]._imp = NULL;
        originalBuckets[i]._types = "null";
    }
    
    methodCaches = (struct cache_t *)malloc(sizeof(struct cache_t));
    methodCaches->_mask = (mask_t)(mask-1);
    methodCaches->_occupied = 0;
    methodCaches->_buckets = originalBuckets;
}

void saveSEL(char const*method, SEL selector, IMP methodIMP, char const*types) {
    //散列表是否为空
    if (methodCaches->_buckets && methodCaches->_mask+1 > 0) {
        mask_t begin = methodCaches->_mask & (long long)selector;
        mask_t i = begin;
        do {
            if (methodCaches->_buckets[i]._imp == NULL) {
                methodCaches->_buckets[i]._name = method;
                methodCaches->_buckets[i]._key = (long long)selector;
                methodCaches->_buckets[i]._imp = methodIMP;
                methodCaches->_buckets[i]._types = types;
                methodCaches->_occupied++;
                return ;//保存成功
            }
        } while ((i = cache_next(i, methodCaches->_mask)) != begin);
    }
}

void expandCaches() {
    //清空内存
    mask_t lastMask = methodCaches->_mask;
    free(methodCaches->_buckets);
    free(methodCaches);
    
    mask_t newMaskt = (lastMask+1)*2;
    createCaches(newMaskt);
}

void isExpandCaches() {
    if (methodCaches->_occupied == methodCaches->_mask+1) {
        expandCaches();
    }
}

bool isMethodExist(SEL selector) {
    isExpandCaches();
    
    IMP methodImplemetation = methodCaches->findSEL(selector);
    if (methodImplemetation) {
        NSLog(@"%@方法存在，直接调取", NSStringFromSelector(selector));
        return true;
    }
    return false;
}

char* strConvertToChar(NSString *str) {
    const char *expr = [str UTF8String];
    char *buf = new char[strlen(expr) + 1];// strlen得到的长度不包含\0, 所以需要加1
    strcpy(buf, expr); // 拷贝一份包含\0的备份
    return buf;
}

void ergodicBuckets() {
    struct bucket_t *buckets = methodCaches->_buckets;
    NSLog(@"_mask:%u---_occupied:%u", methodCaches->_mask, methodCaches->_occupied);
    for (int i = 0; i <= methodCaches->_mask; i++) {
        NSLog(@"i:%d---name:%s---key:%ld---imp:%p---types:%s", i, buckets[i]._name, buckets[i]._key, buckets[i]._imp, buckets[i]._types);
    }
}

void handleMethod(char const *name, SEL selector, IMP imp) {
    NSLog(@"-----------%s------------", name);
    if (!isMethodExist(selector)) {
         //字符串编码
         NSString *impType = [NSString stringWithUTF8String:@encode(IMP)];
         NSString *selfType = [NSString stringWithUTF8String:@encode(id)];
         NSString *selType = [NSString stringWithUTF8String:@encode(SEL)];
         NSString *heightType = [NSString stringWithUTF8String:@encode(CGFloat)];
         NSString *ageType = [NSString stringWithUTF8String:@encode(NSInteger)];
         NSString *nameType = [NSString stringWithUTF8String:@encode(NSString*)];
         
         //类型大小
         int idSize = sizeof(id);
         int selSize = sizeof(SEL);
         int heightSize = sizeof(CGFloat);
         int ageSize = sizeof(NSInteger);
         int nameSize = sizeof(NSString*);
         
         //所有形参所占字节数
         NSString *test15SumStr = [NSString stringWithFormat:@"%d", idSize+selSize];
         NSString *test6SumStr = [NSString stringWithFormat:@"%d", idSize+selSize+heightSize+ageSize];
         NSString *test7SumStr = [NSString stringWithFormat:@"%d", idSize+selSize+nameSize];
         
         //类型下标
         NSString *selfIndex = @"0";
         NSString *SELIndex = [NSString stringWithFormat:@"%d", idSize];
         NSString *heightIndex = [NSString stringWithFormat:@"%d", idSize+selSize];
         NSString *ageIndex = [NSString stringWithFormat:@"%d", idSize+selSize+heightSize];
         
         //例："i24@0:8i16f20"
         NSString *typeStr;
         if (strcmp(name, "test1") == 0 || strcmp(name, "test2") == 0  || strcmp(name, "test3") == 0 || strcmp(name, "test4") == 0 || strcmp(name, "test5") == 0) {
             typeStr = [NSString stringWithFormat:@"%@%@%@%@%@%@", impType, test15SumStr, selfType, selfIndex, selType, SELIndex];
         }
         if (strcmp(name, "test6WithHeight:age:") == 0) {
             typeStr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@", impType, test6SumStr, selfType, selfIndex, selType, SELIndex, heightType, heightIndex, ageType, ageIndex];
             
         }
         if (strcmp(name, "test7WithName:") == 0) {
             typeStr = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", impType, test7SumStr, selfType, selfIndex, selType, SELIndex, nameType, heightIndex];
         }
         
         char *types = strConvertToChar(typeStr);
         saveSEL(name, selector, imp, types);
    }
    
    ergodicBuckets();
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person *per = [[Person alloc] init];
        createCaches(ORIGINAL_MASK);
        
        handleMethod("test1", @selector(test1), [per test1]);
        handleMethod("test2", @selector(test2), [per test2]);
        handleMethod("test1", @selector(test1), [per test1]);
        handleMethod("test3", @selector(test3), [per test3]);
        handleMethod("test4", @selector(test4), [per test4]);
        handleMethod("test5", @selector(test5), [per test5]);
        handleMethod("test4", @selector(test4), [per test4]);
        handleMethod("test6WithHeight:age:", @selector(test6WithHeight:age:), [per test6WithHeight:1.7 age:30]);
        handleMethod("test7WithName:", @selector(test7WithName:), [per test7WithName:@"张三"]);
        
        free(methodCaches);
    }
    return 0;
}
