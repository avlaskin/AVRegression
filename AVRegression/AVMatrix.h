//
//  AVMatrix.h
//  cameraRecognition
//
//  Created by Alexey Vlaskin on 7/03/2014.
//  Copyright (c) 2014 Alexey Vlaskin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVVector.h"

@interface AVMatrix : NSObject

@property (nonatomic, assign) NSUInteger rows;
@property (nonatomic, assign) NSUInteger cols;
@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, assign,readonly) float *data;

- (instancetype)initWithRows:(NSUInteger)rows cols:(NSUInteger)cols;
- (instancetype)initWithRows:(NSUInteger)rows cols:(NSUInteger)cols data:(float *)data;
- (float)valueAtCol:(NSUInteger)x row:(NSUInteger)y;
- (void)setValue:(NSUInteger)x y:(NSUInteger)y value:(float)value;
- (void)randomPrefillWithLow:(float)rangeLow hi:(float)rangeHi;
- (void)setFirstColumnToOne;
- (void)setColumnWithVector:(AVVector *)vector columnIndex:(NSUInteger)col;
- (AVVector *)columnToVector:(NSUInteger)column;
- (void)applyEvaluater:(AVEvaluateBlock)block;
- (void)multiplyByScalar:(float)b;
- (NSDictionary *)toDictionary;

- (AVVector *)matrixToLineVector;
- (AVMatrix *)cutSubmatrixFromRow:(NSUInteger)row
                           column:(NSUInteger)column
                         sizeRows:(NSUInteger)sizeRows
                      sizeColumns:(NSUInteger)sizeColumns;
- (AVMatrix *)scaleMatrixBy:(NSUInteger)scale;//2,4,8,16,...
+ (AVMatrix *)identityMatrixOfSize:(NSUInteger)size;
+ (AVMatrix *)transposeMatrix:(AVMatrix *)a;
+ (AVMatrix *)vectorToMatrix:(AVVector *)vector;
+ (AVMatrix *)sumMatrix:(AVMatrix *)a with:(AVMatrix *)b error:(NSError **)error;
+ (AVMatrix *)mulMatrix:(AVMatrix *)a by:(AVMatrix *)b error:(NSError **)error;
+ (AVVector *)mulMatrix:(AVMatrix *)a byVector:(AVVector *)v error:(NSError **)error;
+ (AVMatrix *)mulMatrix:(AVMatrix *)a byScalar:(float)b;
+ (AVMatrix *)fromDictionary:(NSDictionary *)dictionary;

+ (AVMatrix *)inverseSquareMatrix:(AVMatrix *)matrix;
+ (AVMatrix *)inverse2SquareMatrix:(AVMatrix *)matrix;
+ (AVMatrix *)inverse3SquareMatrix:(AVMatrix *)matrix;

@end
