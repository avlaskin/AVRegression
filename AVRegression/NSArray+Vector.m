//
//  NSArray+Vector.m
//  accelerateIt
//
//  Created by Alexey Vlaskin on 15/04/2015.
//  Copyright (c) 2015 Alexey Vlaskin. All rights reserved.
//

#import "NSArray+Vector.h"
#import "AVVector.h"

@implementation NSArray (Vector)

- (AVVector *)toFloatVector {
    return [AVVector fromArray:self];
}

@end
