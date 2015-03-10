#import "IMTCustomFormatter.h"
#import <libkern/OSAtomic.h>
#import "DDLog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

/**
 * For more information about creating custom formatters, see the wiki article:
 * https://github.com/CocoaLumberjack/CocoaLumberjack/wiki/CustomFormatters
 **/
@implementation IMTCustomFormatter

@synthesize atomicLoggerCount = _atomicLoggerCount;
@synthesize threadUnsafeDateFormatter = _threadUnsafeDateFormatter;

- (NSString *)stringFromDate:(NSDate *)date {
	NSString *dateFormatString = @"yyyy-MM-dd hh:mm:ss.SSS";

	int32_t loggerCount = OSAtomicAdd32(0, &_atomicLoggerCount);

	if (loggerCount <= 1) {
		// Single-threaded mode.

		if (_threadUnsafeDateFormatter == nil) {
			_threadUnsafeDateFormatter = [[NSDateFormatter alloc] init];
			[_threadUnsafeDateFormatter
			 setFormatterBehavior:NSDateFormatterBehavior10_4];
			[_threadUnsafeDateFormatter setDateFormat:dateFormatString];
		}

		return [_threadUnsafeDateFormatter stringFromDate:date];
	}
	else {
		// Multi-threaded mode.
		// NSDateFormatter is NOT thread-safe.

		NSString *key = @"MyCustomFormatter_NSDateFormatter";

		NSMutableDictionary *threadDictionary =
		    [[NSThread currentThread] threadDictionary];
		NSDateFormatter *dateFormatter = [threadDictionary objectForKey:key];

		if (dateFormatter == nil) {
			dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			[dateFormatter setDateFormat:dateFormatString];

			[threadDictionary setObject:dateFormatter forKey:key];
		}

		return [dateFormatter stringFromDate:date];
	}
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
	NSString *logLevel = nil;
	switch (logMessage->logFlag) {
		case LOG_FLAG_ERROR:
			logLevel = @"Error";
			break;

		case LOG_FLAG_WARN:
			logLevel = @"Warn";
			break;

		case LOG_FLAG_INFO:
			logLevel = @"Info";
			break;

		case LOG_FLAG_DEBUG:
			logLevel = @"Debug";
			break;

		default:
			logLevel = @"Verbose";
			break;
	}

	NSString *dateAndTime = [self stringFromDate:(logMessage->timestamp)];
	NSString *appName =
	    [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	NSString *threadId = [logMessage threadID];
	NSString *threadName = [NSString stringWithString:logMessage->threadName];
	NSString *fileName = [logMessage fileName];
	NSString *methodName = [logMessage methodName];
	NSNumber *lineNumber = [NSNumber numberWithInt:logMessage->lineNumber];
	NSString *logMsg = [NSString stringWithString:logMessage->logMsg];

	return [NSString
	        stringWithFormat:@"[%@] - [%@] - [%@:%@:%@] - [%@ %@] - [Line %@] - %@",
	        logLevel, dateAndTime, appName, threadId, threadName,
	        fileName, methodName, lineNumber, logMsg];
}

- (void)didAddToLogger:(id <DDLogger> )logger {
	OSAtomicIncrement32(&_atomicLoggerCount);
}

- (void)willRemoveFromLogger:(id <DDLogger> )logger {
	OSAtomicDecrement32(&_atomicLoggerCount);
}

+ (void)setupLogTypes {
	[DDLog addLogger:[DDASLLogger sharedInstance]];
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
}

+ (void)setupLogFormatter {
	IMTCustomFormatter *formatter = [[IMTCustomFormatter alloc] init];
	[[DDASLLogger sharedInstance] setLogFormatter:formatter];
	[[DDTTYLogger sharedInstance] setLogFormatter:formatter];
}

+ (void)setupLogColors {
	// Enable colors
	[[DDTTYLogger sharedInstance] setColorsEnabled:YES];

	// custom color for ERROR log or can use the default color
	UIColor *errorColor = [UIColor colorWithRed:198.0 / 255.0
	                                      green:31.0 / 255.0
	                                       blue:30.0 / 255.0
	                                      alpha:1.0];
	[[DDTTYLogger sharedInstance] setForegroundColor:errorColor
	                                 backgroundColor:nil
	                                         forFlag:LOG_FLAG_ERROR];

	// custom color for WARN log or can use the default color
	UIColor *warnColor = [UIColor colorWithRed:209.0 / 255.0
	                                     green:143.0 / 255.0
	                                      blue:95.0 / 255.0
	                                     alpha:1.0];
	[[DDTTYLogger sharedInstance] setForegroundColor:warnColor
	                                 backgroundColor:nil
	                                         forFlag:LOG_FLAG_WARN];

	// Custom color for INFO log
	UIColor *infoColor = [UIColor colorWithRed:82.0 / 255.0
	                                     green:190.0 / 255.0
	                                      blue:91.0 / 255.0
	                                     alpha:1.0];
	[[DDTTYLogger sharedInstance] setForegroundColor:infoColor
	                                 backgroundColor:nil
	                                         forFlag:LOG_FLAG_INFO];

	// use default color for DEBUG log

	// Custom color for VERBOSE log
	UIColor *verboseColor = [UIColor colorWithRed:4.0 / 255.0
	                                        green:175.0 / 255.0
	                                         blue:200.0 / 255.0
	                                        alpha:1.0];
	[[DDTTYLogger sharedInstance] setForegroundColor:verboseColor
	                                 backgroundColor:nil
	                                         forFlag:LOG_FLAG_VERBOSE];
}

+ (void)setupFileLogger {
	DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
	fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
	fileLogger.logFileManager.maximumNumberOfLogFiles = 7;

	[DDLog addLogger:fileLogger];

//	DDLogInfo(@"log file at: %@", [[fileLogger logFileManager] logsDirectory]);
}

+ (void)setupLogWriting {
	// setup log types
	[IMTCustomFormatter setupLogTypes];

	// setup log formatter
	[IMTCustomFormatter setupLogFormatter];

	// setup log colors
	[IMTCustomFormatter setupLogColors];

	// setup file logger
	[IMTCustomFormatter setupFileLogger];
}

@end
