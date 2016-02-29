//
//  main.m
//  svgpathconverter
//
//  Created by Mikhail on 27/02/16.
//  Copyright © 2016 ssp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVGKit.h"
#import "NSData+SSPPathSerialization.h"

@implementation CALayer (RecursiveSublayers)

- (NSArray *)recursiveSublayers {
    NSMutableArray *sublayers = [self.sublayers mutableCopy];
    for (CALayer *sublayer in self.sublayers) {
        [sublayers addObjectsFromArray:[sublayer recursiveSublayers]];
    }
    return [sublayers copy];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray *args = [[NSProcessInfo processInfo] arguments];
        if (args.count < 2) {
            printf("Input file required\n");
            return EXIT_FAILURE;
        }
        
        NSString *input = args[1];
        if (!input.absolutePath) {
            input = [[NSFileManager defaultManager].currentDirectoryPath stringByAppendingPathComponent:input];
        }
        
        NSString *output = nil;
        
        if (args.count < 3) {
            output = [[input stringByDeletingPathExtension] stringByAppendingPathExtension:@"cgpath"];
        }
        
        SVGKImage *image = [SVGKImage imageWithContentsOfFile:input];
        assert(image != nil);
        
        NSArray *layers = [image.CALayerTree recursiveSublayers];
        layers = [layers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject isKindOfClass:[CAShapeLayer class]];
        }]];
        
        CFMutableArrayRef paths = CFArrayCreateMutable(kCFAllocatorDefault, layers.count, &kCFTypeArrayCallBacks);
        
        for (CAShapeLayer *layer in layers) {
            CGAffineTransform transform = CATransform3DGetAffineTransform(layer.transform);
            CGPoint translation = [layer convertPoint:CGPointZero toLayer:image.CALayerTree];
            transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
            CGPathRef path = CGPathCreateCopyByTransformingPath(layer.path, &transform);
            CFArrayAppendValue(paths, path);
        }
        
        NSData *data = [NSData ssp_dataWithCGPaths:paths];
        [data writeToFile:output atomically:YES];
    }
    return 0;
}
