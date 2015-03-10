//
//  MobicartAppDelegate.m
//  MobicartApp
//
//  Created by Mobicart on 14/09/10.
//  Copyright Mobicart 2010. All rights reserved.

#import "MobicartAppDelegate.h"
#import "MobicartViewController.h"
#import "library/MobiCartStart.h"
#import "library/UserDetails.h"
#import "library/SqlQuery.h"
#import "library/ServerAPI.h"
#import "library/GlobalPreferences.h"
#import <BugSense-iOS/BugSenseController.h>

@implementation MobicartAppDelegate
@synthesize window;
@synthesize viewController, tabController, arrAllData, loadingIndicator, backgroundImage, mobicartView;
//Sa Vo fix bug display wrong title of More page on iOS 7.0
@synthesize arrMoreTitles = _arrMoreTitles;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Tuyen test write log
    [self setupLogWriting];
    DDLogVerbose(@"app did load");
    //
	// Sa Vo - tnlq -- import bugsense version 3.4
	[BugSenseController sharedControllerWithBugSenseAPIKey:@"20c78dd2"];
	//

	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		[application setStatusBarStyle:UIStatusBarStyleLightContent];

		self.window.clipsToBounds = YES;

		self.window.frame =  CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height);
	}

	window.rootViewController = viewController;

    // For getting geo coordinates of user location
    userLocation = [[CLLocationManager alloc] init];
    userLocation.delegate = self;
    
    // 06/03/2015 Tuyen new code handle location for iOS8
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([userLocation respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [userLocation requestWhenInUseAuthorization];
    }
#else
    const CLLocationAccuracy * ptr = &kCLLocationAccuracyBestForNavigation;
    BOOL frameworkSupports = (ptr != NULL);
    
    if (frameworkSupports)
    {
        userLocation.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    else
    {
        userLocation.desiredAccuracy = kCLLocationAccuracyBest;
    }
#endif
    // 06/03/2015 End
    
    // 06/03/2015 Tuyen close code handle location for iOS8
//    const CLLocationAccuracy *ptr = &kCLLocationAccuracyBestForNavigation;
//    BOOL frameworkSupports = (ptr != NULL);
//    
//    if (frameworkSupports) {
//        userLocation.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//    }
//    else {
//        userLocation.desiredAccuracy = kCLLocationAccuracyBest;
//    }
    // 06/03/2015 Tuyen end
    
    [userLocation startUpdatingLocation];
    // --------------------------------------------------
    
	[window makeKeyAndVisible];
	// Sa Vo - tnlq - 26/05/2014 set white background for UIPickerView
	[[UIPickerView appearance] setBackgroundColor:[UIColor whiteColor]];
	//

	return YES;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    DDLogVerbose(@"location Manager did Update To Location");
	tempLocation = newLocation.coordinate;
	[manager setDelegate:nil];

	// 07/11/2014 Tuyen close handle register notification iOS 8
	/*
	   [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
	 */
	// 07/11/2014 Tuyen end

	// 07/11/2014 Tuyen new code handle register notification iOS 8
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
	if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
		[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
		[[UIApplication sharedApplication] registerForRemoteNotifications];
	}
	else {
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
	}
#else
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#endif
	// 07/11/2014 Tuyen end
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	DDLogError(@"Error in Location Services. Error: %@", error);
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
    
    DDLogInfo(@"background");


}
- (void) applicationDidBecomeActive:(UIApplication *)application {
    
    DDLogInfo(@"active");
    
    
}
- (void) applicationWillEnterForeground:(UIApplication *)application {
    
    DDLogInfo(@"Foreground");
    
    
}
- (void) applicationWillResignActive:(UIApplication *)application{
    
    DDLogInfo(@"applicationWillResignActive");
    
    
}

#pragma mark Push Notification Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	NSString *tempToken = [[NSString stringWithFormat:@"%@", devToken] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	NSString *tempToken1 = [tempToken stringByReplacingOccurrencesOfString:@">" withString:@""];
	NSString *tokenString = [tempToken1 stringByReplacingOccurrencesOfString:@"<" withString:@""];

	NSData *deviceToken = [[NSData alloc]initWithData:devToken];
	DDLogDebug(@"device token is: %@", deviceToken);

	NSString *strLatitude = [NSString stringWithFormat:@"%lf", tempLocation.latitude];
	NSString *strLongitude = [NSString stringWithFormat:@"%lf", tempLocation.longitude];

	[ServerAPI pushNotifications:strLatitude:strLongitude:tokenString:[GlobalPreferences getCurrentAppId]];
	[deviceToken release];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err 
{
	DDLogWarn(@"Error in registration. Error: %@", err);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    DDLogVerbose(@"application did Receive Remote Notification");
    [GlobalPreferences createAlertWithTitle:@"Alert" message:[[userInfo valueForKey:@"aps"]valueForKey:@"alert"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
	[viewController release];
	[window release];

	if (loadingIndicator) {
		[loadingIndicator release];
	}

	if (backgroundImage) {
		[backgroundImage release];
	}
	//	if(userLocation)
	//		[userLocation release];


	[super dealloc];
}

// Tuyen test write log
- (void)setupLogWriting {
    [IMTCustomFormatter setupLogWriting];
}
//

@end
