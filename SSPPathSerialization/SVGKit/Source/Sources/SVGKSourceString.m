#import "SVGKSourceString.h"
#import "SVGKSource-private.h"

@interface SVGKSourceString ()
@property (nonatomic, strong, readwrite) NSString* rawString;
@end

@implementation SVGKSourceString

- (instancetype)initWithContentsOfString:(NSString*)theStr
{
	NSString *tmpStr = [[NSString alloc] initWithString:theStr];
	NSInputStream* stream = [[NSInputStream alloc] initWithData:[tmpStr dataUsingEncoding:NSUTF8StringEncoding]];
	//DO NOT DO THIS: let the parser do it at last possible moment (Apple has threading problems otherwise!) [stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.rawString = tmpStr;
		self.approximateLengthInBytesOr0 = [theStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	}
	
	return self;
}

-(NSString *)keyForAppleDictionaries
{
	return self.rawString;
}

+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString {
	SVGKSourceString *s = [[self alloc] initWithContentsOfString:rawString];
	
	return s;
}

-(id)copyWithZone:(NSZone *)zone
{
	id copy = [super copyWithZone:zone];
	
	if( copy )
	{	
		/** clone bits */
		[copy setRawString:[self.rawString copy]];
		
		/** Finally, manually intialize the input stream, as required by super class */
		[copy setStream:[NSInputStream inputStreamWithData:[((SVGKSourceString*)copy).rawString dataUsingEncoding:NSUTF8StringEncoding]]];
	}
	
	return copy;
}

@end
