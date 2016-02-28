//
//  NSData+SSPPathSerialization.h
//  SSPPathSerialization
//
//  Created by Mikhail on 27/02/16.
//  Copyright © 2016 ssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSData (SSPPathSerialization)

+ (instancetype)ssp_dataWithCGPaths:(CFArrayRef)paths;
- (CFArrayRef)ssp_CGPaths;

@end
