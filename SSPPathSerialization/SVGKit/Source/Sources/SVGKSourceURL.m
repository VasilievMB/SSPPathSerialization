#import "SVGKSourceURL.h"
#import "SVGKSource-private.h"

@interface SVGKSourceURL ()
@property (readwrite, nonatomic, strong) NSURL* URL;
@end

@implementation SVGKSourceURL

-(NSString *)keyForAppleDictionaries
{
	return [self.URL absoluteString];
}

+ (instancetype)sourceFromURL:(NSURL*)u {
	SVGKSourceURL* s = [[SVGKSourceURL alloc] initWithURL:u];
	return s;
}

+(NSInputStream*) internalCreateInputStreamFromURL:(NSURL*) u
{
	NSInputStream* stream = [NSInputStream inputStreamWithURL:u];
	
	if( stream == nil )
	{
		/* Thanks, Apple, for not implementing your own method.
		 c.f. http://stackoverflow.com/questions/20571069/i-cannot-initialize-a-nsinputstream
		 
		 NB: current Apple docs don't seem to mention this - certainly not in the inputStreamWithURL: method? */
		NSError* errorWithNSData;
		NSData *tempData = [NSData dataWithContentsOfURL:u options:0 error:&errorWithNSData];
		
		if( tempData == nil )
		{
			@throw [NSException exceptionWithName:@"NSDataCrashed" reason:[NSString stringWithFormat:@"Error internally in Apple's NSData trying to read from URL '%@'. Error = %@", u, errorWithNSData] userInfo:@{NSLocalizedDescriptionKey:errorWithNSData}];
		}
		else
			stream = [[NSInputStream alloc] initWithData:tempData];
	}
	//DO NOT DO THIS: let the parser do it at last possible moment (Apple has threading problems otherwise!) [stream open];
	
	return stream;
}


- (instancetype)initWithURL:(NSURL*)u
{
	NSInputStream* stream = [[self class] internalCreateInputStreamFromURL:u];
	
	if (self = [super initWithInputSteam:stream]) {
		self.URL = u;
	}
	return self;
}

-(id)copyWithZone:(NSZone *)zone
{
	id copy = [super copyWithZone:zone];
	
	if( copy )
	{	
		/** clone bits */
		[copy setURL:[self.URL copy]];
		
		/** Finally, manually intialize the input stream, as required by super class */
		[copy setStream:[[self class] internalCreateInputStreamFromURL:((SVGKSourceURL*)copy).URL]];
	}
	
	return copy;
}

- (SVGKSource *)sourceFromRelativePath:(NSString *)path {
	NSURL *url = [NSURL URLWithString:path relativeToURL:self.URL];
	return [SVGKSourceURL sourceFromURL:url];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"[SVGKSource: URL = \"%@\"]", self.URL ];
}

@end
