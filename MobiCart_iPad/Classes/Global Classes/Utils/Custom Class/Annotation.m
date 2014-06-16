#import "Annotation.h"


@implementation CSMapAnnotation

@synthesize coordinate = _coordinate;

-(id) initWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title subTitle:(NSString *)subTitle
{
	self = [super init];
	_coordinate = coordinate;
	_title      = [title retain];
	_subTitle = [subTitle retain];
	return self;
}

- (NSString *)title
{
	return _title;
}

- (NSString *)subtitle
{
	return _subTitle;
}

-(void) dealloc
{
	[_title    release];
	[_subTitle release];
	[super dealloc];
}

@end
