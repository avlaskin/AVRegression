//
//  AVVector+Tests.h
//  weatherPrediction
//
//  Created by Alexey Vlaskin on 13/05/2015.
//  Copyright (c) 2015 Alexey Vlaskin. All rights reserved.
//

#import "AVVector.h"

@interface AVVector (Tests)

- (BOOL)vectorsTest;
/*

- (void)matrixTest
{
    float vdata1[] = {1,3,2,1,2};
    float vdata2[] = {0,2,3,2,0};
    
    float vdata3[] = {1,3,2,
        0,2,5};
    float vdata4[] = {0,2,
        3,2,
        0,5};
    float vdata5[] = {1,-1,0};
    TSMatrix *m1 =  [[TSMatrix alloc] initWithRows:5 cols:1 data:vdata1];
    TSMatrix *m2 =  [[TSMatrix alloc] initWithRows:5 cols:1 data:vdata2];
    TSMatrix *m11 = [[TSMatrix alloc] initWithRows:3 cols:2 data:vdata3];
    TSMatrix *m12 = [[TSMatrix alloc] initWithRows:2 cols:3 data:vdata4];
    TSMatrix *m13 = [[TSMatrix alloc] initWithRows:3 cols:3];
    TSVector *v1  = [[TSVector alloc] initWithLength:3 data:vdata5];
    
    [m13 randomPrefillWithLow:-1. hi:1];
    
    NSLog(@"A: %@ \n",[m1 description]);
    NSLog(@"B: %@ \n",[m2 description]);
    NSLog(@"C: %@ \n",[m11 description]);
    NSLog(@"D: %@ \n",[m12 description]);
    TSMatrix *m121 = [TSMatrix transposeMatrix:m12];
    NSLog(@"D transposed: %@ \n",[m121 description]);
    NSLog(@"E: %@ \n",[m13 description]);
    NSLog(@"e: %@ \n",[v1 description]);
    
    NSError *err = nil;
    
    TSMatrix *m5 = [TSMatrix sumMatrix:m1 with:m2 error:&err];
    if (err)    {  NSLog(@"Fail ");  return;  }
    NSLog(@"Test 1 a+b %@ \n",[m5 description]);
    
    TSMatrix *m3 = [TSMatrix mulMatrix:m1 byScalar:5];
    if (err)    {  NSLog(@"Fail ");  return;  }
    NSLog(@"Test 2 A*5 %@ \n",[m3 description]);
    
    TSMatrix *m6 = [TSMatrix mulMatrix:m11 by:m12 error:&err];
    if (err)    {  NSLog(@"Fail ");  return;  }
    NSLog(@"Test 3 C*D %@ \n",[m6 description]);
    
    TSMatrix *m7 = [TSMatrix sumMatrix:m11 with:m12 error:&err];
    if (!err) {  NSLog(@"Fail ");  return;  }
    if (m7==nil && err)
    {
        err = nil;
        NSLog(@"Test 4 passed \n");
    }
    TSVector *m8 = [TSMatrix mulMatrix:m13 byVector:v1 error:&err];
    NSLog(@"Test 5 E*e %@ \n",[m8 description]);
}

 */

@end
