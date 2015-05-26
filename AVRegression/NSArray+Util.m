//
//  NSArray+Util.m
//
//  Created by Alexey Vlaskin on 6/03/2015.
//  Copyright (c) 2015. All rights reserved.
//

#import "NSArray+Util.h"

@interface NSArray (Private)

- (NSArray *)filteredArrayUsingBlock:(BOOL(^)(id object, NSUInteger idx))predecate safe:(BOOL)safe;

@end

@implementation NSArray (Util)

- (id)findFirstObjectWithBlock:( BOOL(^)(id object, NSUInteger idx))predecate {
    if (predecate==nil) {
        return [self firstObject];
    }
    __block id result = nil;
    [self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        if (predecate(object,idx)) {
            *stop = YES;
            result = object;
        }
    }];
    return result;
}

- (NSArray *)filteredArrayUsingBlock:(BOOL(^)(id object, NSUInteger idx))block {
    return [self objectsAtIndexes:[self indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id object, NSUInteger idx, BOOL *stop) {
            return block(object,idx);
    }]];
}

- (NSArray *)filteredSafeArrayUsingBlock:(BOOL(^)(id object, NSUInteger idx))predecate {
    return [self filteredArrayUsingBlock:predecate safe:YES];
}

- (NSArray *)mapArrayWithBlock:(id(^)(id object, NSUInteger idx))block {
    __block __strong id *temp = (__strong id*)calloc(self.count,sizeof(id));
    dispatch_apply(self.count, dispatch_get_global_queue(0, 0), ^(size_t idx) {
        temp[idx] = (NSObject *)block(self[idx],idx);
    });
    NSArray *res = [NSArray arrayWithObjects:temp count:self.count];
    free(temp);
    return res;
}


- (NSUInteger)integerReduceArrayWithBlock:(NSUInteger(^)(id object, NSUInteger idx))block {
    __block NSUInteger res = 0;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        res += block(obj,idx);
    }];
    return res;
}

- (float)floatReduceArrayWithBlock:(float(^)(id object, NSUInteger idx))block {
    __block float res = 0;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        res += block(obj,idx);
    }];
    return res;
}

@end

@implementation NSArray (Private)

- (NSArray *)filteredArrayUsingBlock:(BOOL(^)(id object, NSUInteger idx))predecate safe:(BOOL)safe {
    if (predecate==nil) {
        return self;
    }
    NSLock *arrayLock = (safe) ? ([[NSLock alloc] init]) : nil;
    return [self objectsAtIndexes:[self indexesOfObjectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id object, NSUInteger idx, BOOL *stop) {
        [arrayLock lock];
        BOOL r = predecate(object,idx);
        [arrayLock unlock];
        return r;
    }]];
}

@end