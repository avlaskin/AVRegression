//
//  NSArray+Util.h
//
//  Created by Alexey Vlaskin on 6/03/2015.
//  Copyright (c) 2015. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 * This class supposed to be in CBAUtil, but it is here for me to test it perfectly first.
 *
 */


@interface NSArray (Util)

/**
 * Fast version of the method, assumes client does NOT do any mutations inside predicate
 */
- (id)findFirstObjectWithBlock:( BOOL(^)(id object, NSUInteger idx))block;

/**
 * Light weight version of the method, assumes client does NOY do any mutations inside predicate
 */
 - (NSArray *)filteredArrayUsingBlock:(BOOL(^)(id object, NSUInteger idx))block;

/**
 * This is thread-safe version. Predicate can mutate objects.
 */
- (NSArray *)filteredSafeArrayUsingBlock:(BOOL(^)(id object, NSUInteger idx))block;

- (NSArray *)mapArrayWithBlock:(id(^)(id object, NSUInteger idx))block;

- (NSUInteger)integerReduceArrayWithBlock:(NSUInteger(^)(id object, NSUInteger idx))block;

- (float)floatReduceArrayWithBlock:(float(^)(id object, NSUInteger idx))block;

@end
