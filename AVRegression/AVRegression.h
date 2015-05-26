//
//  AVRegression.h
//  AVRegression
//
//  Created by Alexey Vlaskin on 26/05/2015.
//  Copyright (c) 2015 Alexey Vlaskin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "AVVector.h"

@interface AVRegression : NSObject

+ (AVVector *)solvePolynomialRegressionWithFeature:(AVVector *)x
                                                y:(AVVector *)y
                                           degree:(NSUInteger)d
                          regularisationParamater:(float)lyambda;


@end
