//
//  SSPPathSerializationTests.m
//  SSPPathSerializationTests
//
//  Created by Mikhail on 27/02/16.
//  Copyright © 2016 ssp. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSData+SSPPathSerialization.h"

@interface SSPPathSerializationTests : XCTestCase {
    CFArrayRef _originalPaths;
}

@end

@implementation SSPPathSerializationTests

- (void)setUp {
    [super setUp];
    
    CFIndex nPaths = 10;
    CFMutableArrayRef paths = CFArrayCreateMutable(kCFAllocatorDefault, nPaths, &kCFTypeArrayCallBacks);
    
    for (CFIndex index = 0; index < nPaths; ++index) {
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathMoveToPoint(path, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(path, NULL, 100.0, 100.0);
        CGPathAddQuadCurveToPoint(path, NULL, 125.0, 125.0, 200.0, 0.0);
        CGPathAddCurveToPoint(path, NULL, 225.0, 0.0, 250.0, 25.0, 300.0, 100.0);
        CGPathAddArcToPoint(path, NULL, 100.0, 100.0, 200.0, 200.0, 100.0);
        CGPathCloseSubpath(path);
        CGPathAddEllipseInRect(path, NULL, CGRectMake(0.0, 0.0, 10.0, 50.0));
        CGPathAddRect(path, NULL, CGRectMake(100.0, 100.0, 200.0, 300.0));
        
        CFArrayAppendValue(paths, path);
    }
    
    _originalPaths = CFArrayCreateCopy(kCFAllocatorDefault, paths);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSerialization {
    NSData *originalData = [NSData ssp_dataWithCGPaths:_originalPaths];
    
    XCTAssertNotNil(originalData);
    XCTAssertGreaterThan(originalData.length, 0);
    
    CFArrayRef deserializedPaths = [originalData ssp_CGPaths];
    
    CFIndex nPaths = CFArrayGetCount(_originalPaths);
    XCTAssertEqual(nPaths, CFArrayGetCount(deserializedPaths));
    
    for (CFIndex index = 0; index < nPaths; ++index) {
        CGPathRef originalPath = CFArrayGetValueAtIndex(_originalPaths, index);
        CGPathRef deserializedPath = CFArrayGetValueAtIndex(deserializedPaths, index);
        XCTAssertTrue(CGPathEqualToPath(originalPath, deserializedPath));
    }
    
    XCTAssertEqualObjects(originalData, [NSData ssp_dataWithCGPaths:deserializedPaths]);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
