//
//  AVVector.h
//  cameraRecognition
//
//  Created by Alexey Vlaskin on 7/03/2014.
//  Copyright (c) 2014 Alexey Vlaskin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef float(^AVEvaluateBlock)(float v);
typedef float(^AVEvaluateIndexBlock)(float v,NSUInteger index);

@interface AVVector : NSObject

@property (nonatomic, assign) NSUInteger length;
@property (nonatomic, assign,readonly) float *data;

- (instancetype)initWithLength:(NSUInteger)length;
- (instancetype)initWithLength:(NSUInteger)length setAllValuesTo:(float)value;
- (instancetype)initWithLength:(NSUInteger)length data:(float *)data;
- (instancetype)initWithLength:(NSUInteger)length dataRetained:(float *)data;
- (instancetype)initOneWithLength:(NSUInteger)length;

//NSArray interfaces
- (instancetype)initWithArray:(NSArray *)array;
- (NSDictionary *)toDictionary;

//operations
- (float)valueAt:(NSUInteger)index;
- (void)setValue:(float)value atIndex:(NSUInteger)index;
- (void)applyEvaluater:(AVEvaluateBlock)block;
- (void)applyIndexEvaluater:(AVEvaluateIndexBlock)block;
- (void)multiplyByScalar:(float)b;
- (void)substractVector:(AVVector *)vector;
- (void)power2;
- (AVVector *)vectorOfPower:(float)power;
- (void)appendVector:(AVVector *)a;
- (float)sumElements;
- (float)findMax;
- (float)findMin;
- (float)mean;
- (bool)normalise;
- (bool)meanNormalise;
- (void)deMeanNormalise:(float)mean
                    max:(float)max
                    min:(float)min;
- (AVVector *)vectorOfPower2;
- (AVVector *)scaleVectorBy:(NSUInteger)p;
- (AVVector *)lagVectorBy:(NSUInteger)number;

//static operations
+ (AVVector*)multiplyVector:(AVVector*)a by:(AVVector*)b error:(NSError **)error;
+ (AVVector*)sumVector:(AVVector*)a with:(AVVector*)b error:(NSError **)error;
+ (AVVector*)multiplyVector:(AVVector *)a byScalar:(float)b;
+ (AVVector *)addOneWithVector:(AVVector *)a;
+ (AVVector *)removeOneFromVector:(AVVector *)a;
+ (AVVector *)fromDictionary:(NSDictionary *)dictionary;
+ (AVVector *)fromArray:(NSArray *)dictionary;

//static reduce operations
+ (float)meanVector:(AVVector*)vector;
+ (float)dotVector:(AVVector*)a by:(AVVector*)b error:(NSError **)error;
+ (float)correlation:(AVVector *)a with:(AVVector *)b;

@end
