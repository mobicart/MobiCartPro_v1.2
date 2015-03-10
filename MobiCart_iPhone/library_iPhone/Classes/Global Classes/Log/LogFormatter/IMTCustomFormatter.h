#import <Foundation/Foundation.h>
#import "DDLog.h"

@interface IMTCustomFormatter : NSObject <DDLogFormatter> {
	int _atomicLoggerCount;
	NSDateFormatter *_threadUnsafeDateFormatter;
}

@property (assign, atomic) int atomicLoggerCount;
@property (strong, nonatomic) NSDateFormatter *threadUnsafeDateFormatter;

+ (void)setupLogWriting;

@end
