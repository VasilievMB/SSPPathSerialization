//
//  NSData+SSPPathSerialization.m
//  SSPPathSerialization
//
//  Created by Mikhail on 27/02/16.
//  Copyright © 2016 ssp. All rights reserved.
//

#import "NSData+SSPPathSerialization.h"
#import "SSPPathSerializer.h"

@implementation NSData (SSPPathSerialization)

+ (instancetype)ssp_dataWithCGPaths:(CFArrayRef)paths {
    SSPPathSerializer *serializer = [[SSPPathSerializer alloc] init];
    return [serializer dataWithCGPaths:paths];
}

- (CFArrayRef)ssp_CGPaths {
    SSPPathSerializer *serializer = [[SSPPathSerializer alloc] init];
    return [serializer pathsWithData:self];
}

@end
