//
//  AVRegression.m
//  AVRegression
//
//  Created by Alexey Vlaskin on 26/05/2015.
//  Copyright (c) 2015 Alexey Vlaskin. All rights reserved.
//

#import "AVRegression.h"
#import "AVMatrix.h"

@implementation AVRegression

+ (AVVector *)solvePolynomialRegressionWithFeature:(AVVector *)x
                                                y:(AVVector *)y
                                           degree:(NSUInteger)d
                          regularisationParamater:(float)lyambda
{
    NSError *err = nil;
    AVMatrix *X = [[AVMatrix alloc] initWithRows:x.length cols:d+1];
    [X setFirstColumnToOne];
    [X setColumnWithVector:x columnIndex:1];
    for (NSUInteger i=2;i<=d;i++) {
        AVVector *v = [x vectorOfPower:i];//vvpowsf(res.data, &power, _vector_values, &l);
        [X setColumnWithVector:v columnIndex:i];
    }
    AVMatrix *X_t = [AVMatrix transposeMatrix:X];
    AVMatrix *XX = [AVMatrix mulMatrix:X_t by:X error:&err];
    if (lyambda > 0.001) {
        //regularisation part :
        AVMatrix *E = [AVMatrix identityMatrixOfSize:XX.rows];
        E.data[0] = 0;
        [E multiplyByScalar:lyambda];
        XX = [AVMatrix sumMatrix:XX with:E error:&err];
    }
    AVVector *thetta = nil;
    la_object_t la_A = la_matrix_from_float_buffer(XX.data, XX.rows, XX.cols, XX.cols, LA_NO_HINT, LA_DEFAULT_ATTRIBUTES);
    la_object_t la_Xt = la_matrix_from_float_buffer(X_t.data, X_t.rows, X_t.cols, X_t.cols, LA_NO_HINT, LA_DEFAULT_ATTRIBUTES);
    la_object_t la_y = la_vector_from_float_buffer(y.data, y.length, 1, LA_DEFAULT_ATTRIBUTES);
    la_object_t la_b = la_matrix_product(la_Xt, la_y);
    la_object_t la_x = la_solve(la_A, la_b);
    
    float *res = calloc(sizeof(float), d);
    if (la_vector_to_float_buffer(res, 1, la_x) != LA_SUCCESS) {
        NSLog(@"Failed");
        return nil;
    }
    thetta = [[AVVector alloc] initWithLength:d dataRetained:res];
    return thetta;
}

@end
