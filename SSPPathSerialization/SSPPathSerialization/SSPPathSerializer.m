//
//  SSPPathSerializer.m
//  SSPPathSerialization
//
//  Created by Mikhail on 27/02/16.
//  Copyright © 2016 ssp. All rights reserved.
//

#import "SSPPathSerializer.h"

typedef CF_ENUM(int32_t, SSPPathElementType) {
    SSPPathElementTypeMoveToPoint = kCGPathElementMoveToPoint,
    SSPPathElementTypeAddLineToPoint = kCGPathElementAddLineToPoint,
    SSPPathElementTypeAddQuadCurveToPoint = kCGPathElementAddQuadCurveToPoint,
    SSPPathElementTypeAddCurveToPoint = kCGPathElementAddCurveToPoint,
    SSPPathElementTypeCloseSubpath = kCGPathElementCloseSubpath,
    SSPPathElementTypeBeginPath
};

typedef struct {
    Float64 x;
    Float64 y;
} SSPPathPoint;

static SSPPathPoint SSPPathPointMakeWithCGPoint(CGPoint point) {
    SSPPathPoint p;
    p.x = point.x;
    p.y = point.y;
    return p;
}

typedef struct {
    SSPPathElementType type;
} SSPPathElement;

#pragma pack(push, 1)

typedef struct {
    SSPPathElementType type;
    SSPPathPoint points[3];
} SSPPathPointElement;

#pragma pack(pop)

@implementation SSPPathSerializer {
    @private
    NSMutableData *_data;
}

void SSPPathSerializerApplierFunction(void *info, const CGPathElement *element);

- (NSData *)dataWithCGPaths:(CFArrayRef)paths {
    _data = [NSMutableData data];
    
    CFIndex nPaths = CFArrayGetCount(paths);
    for (CFIndex index = 0; index < nPaths; ++index) {
        [self beginPath];
        CGPathRef path = CFArrayGetValueAtIndex(paths, index);
        CGPathApply(path, (__bridge void * _Nullable)(self), SSPPathSerializerApplierFunction);
    }
    
    NSData *data = [_data copy];
    _data = nil;
    
    return data;
}

- (void)beginPath {
    SSPPathElement element;
    element.type = SSPPathElementTypeBeginPath;
    [_data appendBytes:&element length:sizeof(element)];
}

- (NSUInteger)numberOfPointsForElementType:(SSPPathElementType)type {
    switch (type) {
        case SSPPathElementTypeMoveToPoint:
        case SSPPathElementTypeAddLineToPoint:
            return 1;
        case SSPPathElementTypeAddQuadCurveToPoint:
            return 2;
        case SSPPathElementTypeAddCurveToPoint:
            return 3;
        default:
            return 0;
    }
}

- (void)appendPathElement:(const CGPathElement *)element {
    NSUInteger size = sizeof(SSPPathElement);
    SSPPathPointElement pointElement;
    pointElement.type = (SSPPathElementType)element->type;
    NSUInteger nPoints = [self numberOfPointsForElementType:pointElement.type];
    
    for (NSUInteger i = 0; i < nPoints; ++i) {
        pointElement.points[i] = SSPPathPointMakeWithCGPoint(element->points[i]);
    }
    
    size += nPoints * sizeof(SSPPathPoint);
    
    [_data appendBytes:&pointElement length:size];
}

void SSPPathSerializerApplierFunction(void *info, const CGPathElement *element) {
    SSPPathSerializer *serializer = (__bridge SSPPathSerializer *)(info);
    [serializer appendPathElement:element];
}

- (CFArrayRef)pathsWithData:(NSData *)data {
    NSParameterAssert(data != nil);
    
    CFMutableArrayRef paths = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    
    const void *bytes = data.bytes;
    NSUInteger length = data.length;
    NSUInteger offset = 0;
    CGMutablePathRef path = NULL;
    
    while (offset < length) {
        SSPPathElement *element = (SSPPathElement *)(bytes + offset);
        NSUInteger nPoints = 0;
        if (element->type == SSPPathElementTypeBeginPath) {
            path = CGPathCreateMutable();
            CFArrayAppendValue(paths, path);
        } else {
            SSPPathPointElement *pointElement = (SSPPathPointElement *)element;
            SSPPathPoint *p = pointElement->points;
            
            switch (pointElement->type) {
                case SSPPathElementTypeMoveToPoint:
                    CGPathMoveToPoint(path, NULL, p[0].x, p[0].y);
                    nPoints = 1;
                    break;
                case SSPPathElementTypeAddLineToPoint:
                    CGPathAddLineToPoint(path, NULL, p[0].x, p[0].y);
                    nPoints = 1;
                    break;
                case SSPPathElementTypeAddQuadCurveToPoint:
                    CGPathAddQuadCurveToPoint(path, NULL, p[0].x, p[0].y, p[1].x, p[1].y);
                    nPoints = 2;
                    break;
                case SSPPathElementTypeAddCurveToPoint:
                    CGPathAddCurveToPoint(path, NULL, p[0].x, p[0].y, p[1].x, p[1].y, p[2].x, p[2].y);
                    nPoints = 3;
                    break;
                case SSPPathElementTypeCloseSubpath:
                    CGPathCloseSubpath(path);
                    break;
                default:
                    NSAssert1(false, @"Incorrent element type: %d", pointElement->type);
                    break;
            }
        }
        offset += sizeof(SSPPathElement) + nPoints * sizeof(SSPPathPoint);
    }
    
    return paths;
}

@end
