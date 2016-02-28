//
//  SSPPathSerializer.h
//  SSPPathSerialization
//
//  Created by Mikhail on 27/02/16.
//  Copyright © 2016 ssp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSPPathSerializer : NSObject

- (NSData *)dataWithCGPaths:(CFArrayRef)paths;
- (CFArrayRef)pathsWithData:(NSData *)data;

@end
