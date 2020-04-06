//
//  CacheBaseInfo.h
//  runtime-methodCache
//
//  Created by 卢育彪 on 2020/3/5.
//  Copyright © 2020 luyubiao. All rights reserved.
//

#ifndef CacheBaseInfo_h
#define CacheBaseInfo_h

//int类型
typedef uint32_t mask_t;

//uintptr_t表示long int类型
typedef uintptr_t cache_key_t;

//inline关键字：C++关联函数，表示在调用该函数处，直接替换成函数体内的代码（好处：避免频繁调用该函数导致内存消耗）
static inline mask_t cache_next(mask_t i, mask_t mask) {
    return i ? i-1 : mask;
}

//方法定义（key方法名，imp函数地址）
struct bucket_t {
    char const*_name;
    cache_key_t _key;
    IMP _imp;
    char const*_types;
};

struct cache_t {
    //方法存储（散列表）
    struct bucket_t *_buckets;
    //数组长度-1
    mask_t _mask;
    //已经存在的方法
    mask_t _occupied;
    
    //查找方法
    IMP findSEL(SEL selector) {
        mask_t begin = _mask & (long long)selector;
        mask_t i = begin;
        do {//如果查到直接返回，否则-1往回查找，直到又回到begin位置处
            if (_buckets[i]._key == (long long)selector) {
                return _buckets[i]._imp;
            }
        } while ((i = cache_next(i, _mask)) != begin);
        return NULL;//没有找到，返回null
    }
    
};


#endif /* CacheBaseInfo_h */
