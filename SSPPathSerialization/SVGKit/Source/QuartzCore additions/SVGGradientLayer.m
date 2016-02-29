//
//  SVGGradientLayer.m
//  SVGKit-iOS
//
//  Created by zhen ling tsai on 19/7/13.
//  Copyright (c) 2013 na. All rights reserved.
//

#import "SVGGradientLayer.h"
#include <tgmath.h>

@implementation SVGGradientLayer

@synthesize maskPath;
@synthesize stopIdentifiers;
@synthesize transform;

- (id)init
{
	if ((self = [super init]))
	{
		_radialTransform = CGAffineTransformIdentity;
	}
	return self;
}

- (void)dealloc {
    CGPathRelease(maskPath);
}

- (void)setMaskPath:(CGPathRef)maskP {
    if (maskP != maskPath) {
        CGPathRelease(maskPath);
        maskPath = CGPathRetain(maskP);
    }
}

- (void)renderInContext:(CGContextRef)ctx {
	
    CGContextSaveGState(ctx);

	if (self.maskPath)
	{
		CGContextAddPath(ctx, self.maskPath);
		CGContextClip(ctx);
	}
    if ([self.type isEqualToString:kExt_CAGradientLayerRadial]) {
        
        size_t num_locations = self.locations.count;
        
        //NOT USED: size_t numbOfComponents = 0;
        CGColorSpaceRef colorSpace = NULL;
		
        if (self.colors.count) {
            CGColorRef colorRef = (__bridge CGColorRef)(self.colors)[0];
            //NOT USED: numbOfComponents = CGColorGetNumberOfComponents(colorRef);
            colorSpace = CGColorGetColorSpace(colorRef);
            
            CGFloat *locations = calloc(num_locations, sizeof(CGFloat));
            
            for (NSInteger x = 0; x < num_locations; x++) {
                locations[x] = [[self.locations objectAtIndex:x] floatValue];
			}
			
			CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) self.colors, locations);
            CGPoint position = self.centerPoint;
			
			CGContextConcatCTM(ctx, self.radialTransform);
			
			CGContextSetAlpha(ctx, self.opacity);
			CGContextDrawRadialGradient(ctx, gradient, position, 0, position, self.radius, kCGGradientDrawsAfterEndLocation);
            
            free(locations);
            CGGradientRelease(gradient);
        }
    } 
    else if (!CGRectIsEmpty(self.bounds)) {
    
        [super renderInContext:ctx];
    }
    CGContextRestoreGState(ctx);
}

#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
- (void)setStopColor:(UIColor *)color forIdentifier:(NSString *)identifier {
    NSInteger i = 0;
    for (NSString *key in stopIdentifiers) {
        if ([key isEqualToString:identifier]) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.colors];
            const CGFloat *colors = CGColorGetComponents((__bridge CGColorRef)arr[i]);
            CGFloat a = colors[3];
            const CGFloat *colors2 = CGColorGetComponents(color.CGColor);
            CGFloat r = colors2[0];
            CGFloat g = colors2[1];
            CGFloat b = colors2[2];
            arr[i] = (id)[UIColor colorWithRed:r green:g blue:b alpha:a].CGColor;
            self.colors = arr;
            return;
        }
        i++;
    }
}
#else
- (void)setStopColor:(NSColor *)color forIdentifier:(NSString *)identifier
{
	NSInteger i = 0;
    for (NSString *key in stopIdentifiers) {
        if ([key isEqualToString:identifier]) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:self.colors];
            const CGFloat *colors = CGColorGetComponents((__bridge CGColorRef)arr[i]);
            CGFloat a = colors[3];
			CGFloat r = 0;
            CGFloat g = 0;
            CGFloat b = 0;
			if ([color respondsToSelector:@selector(CGColor)]) {
				const CGFloat *colors2 = CGColorGetComponents(color.CGColor);
				r = colors2[0];
				g = colors2[1];
				b = colors2[2];
			} else {
				[color getRed:&r green:&g blue:&b alpha:NULL];
			}
			CGColorRef newColor = CGColorCreateGenericRGB(r, g, b, a);
            arr[i] = CFBridgingRelease(newColor);
            self.colors = arr;
            return;
        }
        i++;
    }

}
#endif

- (BOOL)containsPoint:(CGPoint)p {
    BOOL boundsContains = CGRectContainsPoint(self.bounds, p);
	if( boundsContains )
	{
		BOOL pathContains = CGPathContainsPoint(self.maskPath, NULL, p, false);
		
		if( pathContains )
		{
			return TRUE;
		}
	}
	return FALSE;
}

@end
