//
//  AVMatrix.m
//  cameraRecognition
//
//  Created by Alexey Vlaskin on 7/03/2014.
//  Copyright (c) 2014 Alexey Vlaskin. All rights reserved.
//

#import "AVMatrix.h"
#import "AVVector.h"
#import "Common.h"

#include <Accelerate/Accelerate.h>
#include <simd/simd.h>

@interface AVMatrix (){
    float *_matrix_values;
}

@end


@implementation AVMatrix
- (void)dealloc
{
    if (_matrix_values)
    {
        free(_matrix_values);
        _matrix_values = nil;
    }
}

-(instancetype)initWithRows:(NSUInteger)rows cols:(NSUInteger)cols
{
    self = [super init];
    if (self)
    {
        _cols = cols;
        _rows = rows;
        _length = cols*rows;
        _matrix_values = calloc(sizeof(float),_length);
    }
    return self;
}
-(instancetype)initWithRows:(NSUInteger)rows cols:(NSUInteger)cols data:(float *)data
{
    self = [super init];
    if (self)
    {
        _cols = cols;
        _rows = rows;
        _length = cols*rows;
        _matrix_values = malloc(sizeof(float)*_length);
        memcpy(_matrix_values,data,sizeof(float)*_length);
    }
    return self;
}
- (float)valueAtCol:(NSUInteger)x row:(NSUInteger)y
{
    if (x>_cols || y>_rows)
    {
        return NAN;
    }
    return _matrix_values[x+y*_cols];
}
- (void)setValue:(NSUInteger)x y:(NSUInteger)y value:(float)value
{
    if (x>_cols || y>_rows)
    {
        return;
    }
    _matrix_values[x+y*_cols] = value;
}

- (AVVector *)matrixToLineVector {
    return [[AVVector alloc] initWithLength:self.rows*self.cols data:self.data];
}

+ (AVMatrix *)inverseSquareMatrix:(AVMatrix *)matrix
{
    float *A = matrix.data;
    __CLPK_integer N = (int)matrix.rows;
    AVMatrix *res = [[AVMatrix alloc] initWithRows:matrix.rows cols:matrix.cols data:A];
    __CLPK_integer *IPIV = calloc(sizeof(__CLPK_integer), N);
    __CLPK_integer LWORK = N*N;
    float *WORK = calloc(sizeof(float),LWORK);
    __CLPK_integer INFO;
    sgetrf_(&N,&N,res.data,&N,IPIV,&INFO);
    sgetri_(&N,res.data,&N,IPIV,WORK,&LWORK,&INFO);
    free(IPIV);
    free(WORK);
    return res;
}

+ (AVMatrix *)inverse2SquareMatrix:(AVMatrix *)matrix
{
    __CLPK_integer N = (int)matrix.rows;
    AVMatrix *copyMatrix = [[AVMatrix alloc] initWithRows:matrix.rows cols:matrix.cols data:matrix.data];
    AVMatrix *identityRes = [AVMatrix identityMatrixOfSize:matrix.cols];
    __CLPK_integer nrhs = N;
    __CLPK_integer lda = (__CLPK_integer)matrix.cols;//stride a
    __CLPK_integer ldb = (__CLPK_integer)matrix.cols;//stride b
    __CLPK_integer *ipiv = malloc(sizeof(__CLPK_integer)*N);
    __CLPK_integer info;
    sgesv_(&N, &nrhs, copyMatrix.data, &lda, ipiv, identityRes.data, &ldb, &info);
    free(ipiv);
    return identityRes;
}

+ (AVVector *)solveSystem:(AVMatrix*)matrixA rightSide:(AVVector *)vectorB {
    //Solves Ax = b - finds x
    la_object_t A = la_matrix_from_float_buffer(matrixA.data, matrixA.rows, matrixA.cols, matrixA.cols, LA_NO_HINT, LA_DEFAULT_ATTRIBUTES);
    la_object_t b = la_vector_from_float_buffer(vectorB.data, vectorB.length, 1, LA_DEFAULT_ATTRIBUTES);
    la_object_t x = la_solve(A, b);
    float *res = calloc(sizeof(float), vectorB.length);
    if (la_vector_to_float_buffer(res, 1, x) != LA_SUCCESS) {
        return nil;
    }
    return [[AVVector alloc] initWithLength:vectorB.length dataRetained:res];
}

+ (AVMatrix *)inverse3SquareMatrix:(AVMatrix *)matrix
{
    int N = (int)matrix.rows;
    if (N > 3) {
        return [self inverseSquareMatrix:matrix];
    } else {
        float *d = calloc(sizeof(float), N*N);
        if (N == 2) {
            matrix_float2x2 m = matrix_from_rows((vector_float2){[matrix data][0],[matrix data][1]},
                                               (vector_float2){[matrix data][2],[matrix data][3]});
            matrix_float2x2 mInv = matrix_invert(m);
            d[0] = mInv.columns[0][0];
            d[1] = mInv.columns[1][0];
            d[2] = mInv.columns[0][1];
            d[3] = mInv.columns[1][1];
            return [[AVMatrix alloc] initWithRows:N cols:N data:d];
        } else if (N == 3) {
            matrix_float3x3 m = matrix_from_rows((vector_float3){[matrix data][0],[matrix data][1],[matrix data][2]},
                                                 (vector_float3){[matrix data][3],[matrix data][4],[matrix data][5]},
                                                 (vector_float3){[matrix data][6],[matrix data][7],[matrix data][8]});
            matrix_float3x3 mInv = matrix_invert(m);
            d[0] = mInv.columns[0][0];
            d[1] = mInv.columns[1][0];
            d[2] = mInv.columns[2][0];
            
            d[3] = mInv.columns[0][1];
            d[4] = mInv.columns[1][1];
            d[5] = mInv.columns[2][1];
            
            d[6] = mInv.columns[0][2];
            d[7] = mInv.columns[1][2];
            d[8] = mInv.columns[2][2];
        }
        else {
            return nil;
        }
        return [[AVMatrix alloc] initWithRows:N cols:N data:d];
    }
    return nil;
}

+ (AVMatrix *)identityMatrixOfSize:(NSUInteger)size {
    __block AVMatrix *res = [[AVMatrix alloc] initWithRows:size cols:size];
    dispatch_apply(size, dispatch_get_global_queue(0, 0), ^(size_t i) {
        [res setValue:i y:i value:1.0];
    });
    return res;
}

+ (AVMatrix*)sumMatrix:(AVMatrix*)a with:(AVMatrix*)b error:(NSError **)error
{
    if (a.rows != b.rows || a.cols != b.cols)
    {
        *error = [NSError errorWithDomain:@"" code:-12 userInfo:nil];
        return nil;
    }
    float *r = malloc(sizeof(float)*a.length);
    vDSP_vadd(a.data, 1, b.data, 1, r, 1, a.length);
    AVMatrix *m = [[AVMatrix alloc] initWithRows:a.rows cols:a.cols data:r];
    free(r);
    return m;
}

+ (AVMatrix*)mulMatrix:(AVMatrix*)a by:(AVMatrix*)b error:(NSError **)error
{
    if (a.cols != b.rows)
    {
        *error = [NSError errorWithDomain:@"" code:-12 userInfo:nil];
        return nil;
    }
    float *c = malloc(a.rows*b.cols*sizeof(float));
    vDSP_mmul(a.data,1,b.data,1,c,1,a.rows,b.cols,a.cols);
    AVMatrix *m = [[AVMatrix alloc] initWithRows:a.rows cols:b.cols data:c];
    free(c);
    return m;
}

+ (AVMatrix*)mulMatrix:(AVMatrix *)a byScalar:(float)b
{
    float *r = malloc(sizeof(float)*a.length);
    vDSP_vsmul(a.data, 1, &b, r, 1, a.length);
    AVMatrix *res = [[AVMatrix alloc] initWithRows:a.rows cols:a.cols data:r];
    free(r);
    return res;
}

- (void)setFirstColumnToOne
{
    for (NSUInteger i =0;i<self.rows;i++)
    {
        _matrix_values[i*self.cols] = 1;
    }
}

- (float *)data
{
    return _matrix_values;
}

- (AVVector *)columnToVector:(NSUInteger)column
{
    float *r = malloc(sizeof(float)*self.rows);
    for (NSUInteger i=0;i<self.rows;i++)
    {
        r[i] = [self valueAtCol:column row:i];//memcpy?
    }
    AVVector *v = [[AVVector alloc] initWithLength:self.rows data:r];
    free(r);
    return v;
}

- (void)setColumnWithVector:(AVVector *)vector
                columnIndex:(NSUInteger)col {
    if (col > self.cols) {
        NSLog(@"Error : column index out of range");
        return;
    }
    if (vector.length > self.rows) {
        NSLog(@"Error : vector is too big");
        return;
    }
    for (NSUInteger i=0;i<vector.length;i++) {
        [self setValue:col y:i value:[vector valueAt:i]];
    }
}

+ (AVMatrix *)vectorToMatrix:(AVVector *)vector
{
    float *r = malloc(sizeof(float)*vector.length);
    memcpy(r,vector.data,sizeof(float)*vector.length);
    AVMatrix *m = [[AVMatrix alloc] initWithRows:vector.length cols:1 data:r];
    free(r);
    return m;
}

- (void)randomPrefillWithLow:(float)rangeLow hi:(float)rangeHi
{
    for (NSUInteger i=0;i<self.length;i++) {
        NSUInteger x = arc4random() % 1000;
        _matrix_values[i] = rangeLow + (rangeHi-rangeLow)*(float)x * 0.001f;
    }
}

+ (AVVector *)mulMatrix:(AVMatrix *)a byVector:(AVVector *)v error:(NSError **)error
{
    AVMatrix *b = [AVMatrix vectorToMatrix:v];
    return [[self mulMatrix:a by:b error:error] columnToVector:0];
}

- (void)applyEvaluater:(AVEvaluateBlock)block
{
    dispatch_apply(_length, dispatch_get_global_queue(0, 0), ^(size_t i) {
        _matrix_values[i] = block(_matrix_values[i]);
    });
}

#pragma mark - description

- (NSString *)description
{
    NSMutableString *d = [NSMutableString stringWithFormat:@"\n "];
    for (NSUInteger i =0;i<self.rows;i++)
    {
        for(NSUInteger j = 0;j<self.cols;j++)
        {
            [d appendString:[NSString stringWithFormat:@"%f, ",_matrix_values[j+i*self.cols]]];
        }
        [d appendString:@"\n "];
    }
    [d appendString:@"\n "];
    return d;
}

- (void)multiplyByScalar:(float)b
{
    cblas_sscal((int)_length, b, _matrix_values,1);
}

+ (AVMatrix *)transposeMatrix:(AVMatrix *)a
{
    AVMatrix *res = [[AVMatrix alloc] initWithRows:a.cols cols:a.rows];
    for (NSUInteger i =0;i<a.rows;i++)
    {
        for (NSUInteger j=0;j<a.cols;j++)
        {
            [res setValue:i y:j value:[a valueAtCol:j row:i]];
        }
    }
    return res;
}

- (AVMatrix *)cutSubmatrixFromRow:(NSUInteger)row
                           column:(NSUInteger)column
                         sizeRows:(NSUInteger)sizeRows
                      sizeColumns:(NSUInteger)sizeColumns
{
    
    AVMatrix *res = [[AVMatrix alloc] initWithRows:sizeRows cols:sizeColumns];
    //vDSP_mmov(_matrix_values+column + row*_cols,res.data,sizeColumns,sizeRows,_rows,sizeColumns);
    
     //old slow impl
    for (NSUInteger i=0;i<sizeColumns;i++) {
        for (NSUInteger j=0;j<sizeRows;j++) {
            [res setValue:i y:j value:[self valueAtCol:column+i row:row+j]];
        }
    }
    return res;
}

- (AVMatrix *)scaleMatrixBy:(NSUInteger)scale {
    return nil;
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithCapacity:self.length+3];
    [json setValue:@(self.cols) forKey:kColumnsNumber];
    [json setValue:@(self.rows) forKey:kRowsNumber];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:self.length];
    for(NSUInteger i=0;i<self.length;i++)
    {
        [items addObject:@(_matrix_values[i])];
    }
    [json setValue:items forKey:kValuesArray];
    return json;
}

+ (AVMatrix *)fromDictionary:(NSDictionary *)dictionary {
    NSNumber*c = [dictionary objectForKey:kColumnsNumber];
    NSNumber*r = [dictionary objectForKey:kRowsNumber];
    NSArray *v = [dictionary objectForKey:kValuesArray];
    if (c==nil || ![c isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    if (r==nil || ![r isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    if (v==nil || ![v isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSUInteger cols = [c integerValue];
    NSUInteger rows = [r integerValue];
    if ([v count]!=cols*rows) {
        return nil;
    }
    float *data = malloc(sizeof(float)*cols*rows);
    for (int i =0;i<[v count];i++) {
        if ([v[i] isKindOfClass:[NSNumber class]]) {
            data[i] = [v[i] floatValue];
        }
    }
    AVMatrix *m = [[AVMatrix alloc] initWithRows:rows cols:cols data:data];
    free(data);
    return m;
}

@end
