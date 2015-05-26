//
//  AVVector+Tests.m
//  weatherPrediction
//
//  Created by Alexey Vlaskin on 13/05/2015.
//  Copyright (c) 2015 Alexey Vlaskin. All rights reserved.
//

#import "AVVector+Tests.h"

@implementation AVVector (Tests)

- (BOOL)vectorsTest
{
    NSError *err = nil;
    float vdata1[] = {1,3,2,1,2};
    float vdata1_test[]= {-3,-9,-6,-3,-6};
    float vdata2[] = {0,2,3,2,0};
    AVVector *v1 = [[AVVector alloc] initWithLength:5 data:vdata1];
    AVVector *v1_test = [[AVVector alloc] initWithLength:5 data:vdata1_test];
    NSLog(@"a: %@ \n",[v1 description]);
    AVVector *v3 = [AVVector multiplyVector:v1 byScalar:3];
    AVVector *test1 = [AVVector sumVector:v1 with:v1_test error:&err];
    if ([test1 sumElements] > 0.00001) {
        NSLog(@"Test 1 failed");
        return NO;
    }
    NSLog(@"Test 1 a*3 %@ \n",[v3 description]);
    
    AVVector *v2 = [[AVVector alloc] initWithLength:5 data:vdata2];
    NSLog(@"b: %@ \n",[v2 description]);
    AVVector *v4 = [AVVector multiplyVector:v1 by:v2 error:&err];
    if (err)    {  NSLog(@"Fail ");  return NO;  }
    NSLog(@"Test 2 a*b %@ \n",[v4 description]);
    
    AVVector *v5 = [AVVector sumVector:v1 with:v2 error:&err];
    if (err)    {  NSLog(@"Fail ");  return NO;  }
    NSLog(@"Test 3 a+b %@ \n",[v5 description]);
    
    float v6 = [AVVector dotVector:v1 by:v2 error:&err];
    if (err)    {  NSLog(@"Fail ");  return NO;  }
    NSLog(@"Test 4 a.b %f \n",v6);
    return YES;
}

@end
