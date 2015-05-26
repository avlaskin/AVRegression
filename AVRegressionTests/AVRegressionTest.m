//
//  AVRegressionTest.m
//  AVRegression
//
//  Created by Alexey Vlaskin on 26/05/2015.
//  Copyright (c) 2015 Alexey Vlaskin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSArray+Util.h"
#import "NSArray+Vector.h"
#import "AVRegression.h"

@interface AVRegressionTest : XCTestCase

@end

@implementation AVRegressionTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        NSArray *data = [[self class] readFromCSV];
        NSArray *xarray = [data mapArrayWithBlock:^id(NSDictionary* object, NSUInteger idx) {
            return @([[object objectForKey:@"x"] floatValue]);
        }];
        NSArray *yarray = [data mapArrayWithBlock:^id(NSDictionary* object, NSUInteger idx) {
            return @([[object objectForKey:@"y"] floatValue]);
        }];
        AVVector *x = [xarray toFloatVector];
        AVVector *y = [yarray toFloatVector];
        AVVector *result = [AVRegression solvePolynomialRegressionWithFeature:x
                                                                            y:y
                                                                       degree:2
                                                      regularisationParamater:0];
        NSLog(@" Result %@",result);
    }];
}

+ (NSDictionary *)processReadLine:(NSString *)lineStr {
    NSArray *comps = [lineStr componentsSeparatedByString:@","];
    if (comps.count > 1) {
        NSDictionary *d = @{ @"x" : @([comps[0] floatValue]),
                             @"y" : @([comps[1] floatValue]) };
        return d;
    }
    return nil;
}

+ (NSArray *)readFromCSV {
    NSError *outError = nil;
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSString *pathToFile = [myBundle pathForResource:@"lrdata" ofType:@"csv"];
    NSString *fileString = [NSString stringWithContentsOfFile:pathToFile encoding:NSUTF8StringEncoding error:&outError];
    if (!fileString) {
        NSLog(@"Error reading file.");
        return nil;
    }
    NSArray *allLines = [fileString componentsSeparatedByString:@"\n"];
    NSArray *data = [allLines mapArrayWithBlock:^id(id object, NSUInteger idx) {
        return [[self class] processReadLine:object];
    }];
    return data;
}

@end
