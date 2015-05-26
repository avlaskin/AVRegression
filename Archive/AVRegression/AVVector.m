//
//  AVVector.m
//  cameraRecognition
//
//  Created by Alexey Vlaskin on 7/03/2014.
//  Copyright (c) 2014 Alexey Vlaskin. All rights reserved.
//
#import "Common.h"
#import "AVVector.h"
#include <Accelerate/Accelerate.h>

@interface AVVector () {
    float *_vector_values;
}

@end

@implementation AVVector
- (void)dealloc
{
    if (_vector_values)
    {
        free(_vector_values);
        _vector_values = nil;
    }
}
-(instancetype)initWithLength:(NSUInteger)length
{
    self = [super init];
    if (self)
    {
        _length = length;
        //NSUInteger al = (4 - (length % 4)) + length;
        _vector_values = calloc(sizeof(float),length);
    }
    return self;
}

-(instancetype)initWithLength:(NSUInteger)length setAllValuesTo:(float)value
{
    self = [super init];
    if (self)
    {
        _length = length;
        _vector_values = calloc(sizeof(float),length);
        vDSP_vfill(&value,_vector_values,1,_length);
    }
    return self;
}

-(instancetype)initWithLength:(NSUInteger)length data:(float *)data
{
    self = [super init];
    if (self)
    {
        _length = length;
        _vector_values = calloc(sizeof(float),length);
        memcpy(_vector_values, data,sizeof(float)*length);
    }
    return self;
}

-(instancetype)initWithLength:(NSUInteger)length dataRetained:(float *)data
{
    self = [super init];
    if (self)
    {
        _length = length;
        _vector_values = data;
    }
    return self;
}

-(instancetype)initOneWithLength:(NSUInteger)length
{
    self = [super init];
    if (self)
    {
        float one = 1;
        _length = length;
        _vector_values = calloc(sizeof(float),length);
        vDSP_vfill(&one,_vector_values,1,_length);
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self)
    {
        _length = array.count;
        _vector_values = calloc(sizeof(float),_length);
        dispatch_apply(_length, dispatch_get_global_queue(0, 0), ^(size_t i) {
            _vector_values[i] = [((NSNumber *)array[i]) floatValue];
        });
    }
    return self;
}

+ (AVVector *)fromArray:(NSArray *)array {
    return [[AVVector alloc] initWithArray:array];
}

- (void)appendVector:(AVVector *)a {
    float *newVector = malloc(sizeof(float)*(_length +a.length));
    memcpy(newVector, _vector_values,_length*sizeof(float));
    memcpy(newVector+_length, a.data, a.length*sizeof(float));
    free(_vector_values);
    _vector_values = newVector;
    _length += a.length;
}

- (void)substractVector:(AVVector *)vector {
    float *newVector = malloc(sizeof(float)*(_length));
    vDSP_vsub([vector data], 1, _vector_values, 1, newVector, 1, _length);
    free(_vector_values);
    _vector_values = newVector;
}

- (void)power2 {
    float *newVector = malloc(sizeof(float)*(_length));
    vDSP_vsq(_vector_values,1,newVector,1,_length);
    free(_vector_values);
    _vector_values = newVector;
}

- (AVVector *)vectorOfPower:(float)power {
    int l = (int)_length;
    AVVector * res = [[AVVector alloc] initWithLength:_length];
    vvpowsf(res.data, &power, _vector_values, &l);
    return res;
}

- (AVVector *)vectorOfPower2 {
    AVVector *res = [[AVVector alloc] initWithLength:_length];
    vDSP_vsq(_vector_values,1,[res data],1,_length);
    return res;
}

- (float)sumElements {
    float res;
    vDSP_sve(_vector_values,1,&res,_length);
    return res;
}

- (float)findMax {
    float res;//does not matter what is res initialised with
    vDSP_maxv(_vector_values,1,&res,_length);
    return res;
}

- (float)findMin {
    float res;//does not matter what is res initialised with
    vDSP_minv(_vector_values,1,&res,_length);
    return res;
}

- (float)mean {
    float res = 0;
    vDSP_meanv(_vector_values,1,&res,_length);
    return res;
}

+ (float)dotVector:(AVVector*)a by:(AVVector*)b error:(NSError **)error
{
    if (a.length != b.length)
    {
        *error = [NSError errorWithDomain:@"" code:-11 userInfo:nil];
        return NAN;
    }
    float r = 0;
    vDSP_dotpr(a.data, 1, b.data, 1, &r, a.length);
    return r;
}

+ (float)meanVector:(AVVector*)vector {
    float res = 0;
    vDSP_meanv(vector.data,1,&res,vector.length);
    return res;
}

+ (AVVector*)multiplyVector:(AVVector*)a by:(AVVector*)b error:(NSError **)error
{
    if (a.length != b.length)
    {
        *error = [NSError errorWithDomain:@"" code:-11 userInfo:nil];
        return nil;
    }
    float *r = malloc(sizeof(float)*a.length);
    vDSP_vmul(a.data, 1, b.data, 1, r, 1, a.length);
    AVVector *res = [[AVVector alloc] initWithLength:a.length dataRetained:r];
    return res;
}

+ (AVVector*)sumVector:(AVVector*)a with:(AVVector*)b error:(NSError **)error
{
    if (a.length != b.length)
    {
        *error = [NSError errorWithDomain:@"" code:-11 userInfo:nil];
        return nil;
    }
    float *r = malloc(sizeof(float)*a.length);
    vDSP_vadd(a.data, 1, b.data, 1, r, 1, a.length);
    AVVector *res = [[AVVector alloc] initWithLength:a.length data:r];
    free(r);
    return res;
}

+ (AVVector*)multiplyVector:(AVVector *)a byScalar:(float)b
{
    float *r = calloc(a.length,sizeof(float));
    vDSP_vsmul(a.data, 1, &b, r, 1, a.length);
    AVVector *res = [[AVVector alloc] initWithLength:a.length dataRetained:r];
    return res;
}

- (float *)data
{
    return _vector_values;
}

- (float)valueAt:(NSUInteger)index
{
    if (index > _length)
    {
        return NAN;
    }
    return _vector_values[index];
}

- (void)setValue:(float)value atIndex:(NSUInteger)index
{
    if (index > _length)
    {
        return;
    }
    _vector_values[index] = value;
}

- (AVVector *)lagVectorBy:(NSUInteger)number {
    float *res = calloc(sizeof(float),self.length);
    if (number < _length) {
        memcpy(&(res[number]), _vector_values, sizeof(float)*(_length - number));
    }
    return [[AVVector alloc] initWithLength:_length dataRetained:res];
}

- (AVVector *)scaleVectorBy:(NSUInteger)p {
    float *res = malloc(sizeof(float)*self.length / p);
    memset(res, 0, sizeof(float)*self.length / p);
    for (NSUInteger i=0;i<self.length/p;i++) {
        vDSP_meanv(_vector_values+i*p,1,res+i,p);
    }
    return [[AVVector alloc] initWithLength:self.length/p dataRetained:res];
}

- (NSString *)description
{
    NSMutableString *s = [NSMutableString stringWithString:@" "];
    for (NSUInteger i=0;i<self.length;i++)
    {
        [s appendFormat:@"%f, \n",self.data[i]];
    }
    return s;
}

+ (float)correlation:(AVVector *)a with:(AVVector *)b {
    //calculation of correlation
    if (a.length != b.length) {
        return 0;
    }
    NSError *err = nil;
    float ma = [a mean];
    float mb = [b mean];
    AVVector *mav = [[AVVector alloc] initWithLength:a.length setAllValuesTo:-ma];
    AVVector *mbv = [[AVVector alloc] initWithLength:b.length setAllValuesTo:-mb];
    AVVector *aa = [AVVector sumVector:a with:mav error:&err];
    AVVector *bb = [AVVector sumVector:b with:mbv error:&err];
    
    float ab = [AVVector dotVector:aa by:bb error:&err];
    AVVector *a2 = [aa vectorOfPower2];
    AVVector *b2 = [bb vectorOfPower2];
    float a2sum = [a2 sumElements];
    float b2sum = [b2 sumElements];
    if (fabs(a2sum) <0.00001 || fabs(a2sum) <0.00001) {
        return 0;
    }
    return ab / sqrtf(a2sum * b2sum);
}

+ (AVVector *)addOneWithVector:(AVVector *)a
{
    float *f = malloc(sizeof(float)*(a.length+1));
    memcpy(&f[1],a.data,sizeof(float)*a.length);
    f[0] = 1;
    AVVector *r = [[AVVector alloc] initWithLength:(a.length+1) data:f];
    free(f);
    return r;
}

+ (AVVector *)removeOneFromVector:(AVVector *)a
{
    float *f = malloc(sizeof(float)*(a.length-1));
    memcpy(f,&(a.data[1]),sizeof(float)*(a.length-1));
    AVVector *r = [[AVVector alloc] initWithLength:(a.length-1) data:f];
    free(f);
    return r;
}

- (void)applyEvaluater:(AVEvaluateBlock)block
{
    dispatch_apply(_length, dispatch_get_global_queue(0, 0), ^(size_t i) {
        _vector_values[i] = block(_vector_values[i]);
    });
}

- (void)applyIndexEvaluater:(AVEvaluateIndexBlock)block
{
    dispatch_apply(_length, dispatch_get_global_queue(0, 0), ^(size_t i) {
        _vector_values[i] = block(_vector_values[i],i);
    });
}

- (void)multiplyByScalar:(float)b
{
    for (NSUInteger i=0;i<self.length;i++)
    {
        _vector_values[i] = _vector_values[i]*b;
    }
}

- (void)deMeanNormalise:(float)mean
                    max:(float)max
                    min:(float)min {
    float var = max - min;
    float *res = calloc(sizeof(float), _length);
    vDSP_vma(_vector_values,1,&var,0,&mean,0,res,1,_length);
    free(_vector_values);
    _vector_values = res;
}

- (bool)normalise {
    float max  = [self findMax];
    float min  = [self findMin];
    if (max != min) {
        float *res = calloc(sizeof(float), _length);
        float b = -min;
        float c = 1./(max-min);
        vDSP_vam(_vector_values,1,&b,0,&c,0,res,1,_length);
        free(_vector_values);
        _vector_values = res;
        return true;
    }
    return false;
}

- (bool)meanNormalise {
    float max  = [self findMax];
    float min  = [self findMin];
    if (max != min) {
        float mean = [self mean];
        float *res = calloc(sizeof(float), _length);
        float b = -mean;
        float c = 1./(max-min);
        vDSP_vam(_vector_values,1,&b,0,&c,0,res,1,_length);
        free(_vector_values);
        _vector_values = res;
        return true;
    }
    return false;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:self.length+2];
    [json setValue:@(self.length) forKey:kRowsNumber];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:self.length];
    for(NSUInteger i=0;i<self.length;i++)
    {
        [items addObject:@(_vector_values[i])];
    }
    [json setValue:items forKey:kValuesArray];
    return json;
}

+ (AVVector *)fromDictionary:(NSDictionary *)dictionary {
    NSNumber*r = [dictionary objectForKey:kRowsNumber];
    NSArray *v = [dictionary objectForKey:kValuesArray];
    if (r==nil || ![r isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    if (v==nil || ![v isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSUInteger rows = [r integerValue];
    if ([v count]!=rows) {
        return nil;
    }
    float *data = malloc(sizeof(float)*rows);
    for (int i =0;i<[v count];i++) {
        if ([v[i] isKindOfClass:[NSNumber class]]) {
            data[i] = [v[i] floatValue];
        }
    }
    AVVector *m = [[AVVector alloc] initWithLength:rows data:data];
    free(data);
    return m;
}



@end
