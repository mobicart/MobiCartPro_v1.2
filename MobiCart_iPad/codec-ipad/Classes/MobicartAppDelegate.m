//
//  MobicartAppDelegate.m
//  Mobicart
//
//  Created by Mobicart on 05/03/11.
//  Copyright Mobicart. All rights reserved.
//


#import "MobicartAppDelegate.h"
#import "MobicartViewController.h"
#import "libMobicart_iPad/MobicartStart.h"
#import "libMobicart_iPad/UserDetails.h"
#import "libMobicart_iPad/ServerAPI.h"
#import "libMobicart_iPad/SqlQuery.h"
#import "libMobicart_iPad/GlobalPrefrences.h"
#import <BugSense-iOS/BugSenseController.h>

@implementation MobicartAppDelegate

@synthesize window;
//@synthesize viewController,tabController;
@synthesize viewController,tabController,arrAllData,loadingIndicator,backgroundImage,imgloadView;
//Sa Vo fix bug display wrong title of More page on iOS 7.0
@synthesize arrMoreTitles = _arrMoreTitles;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Tuyen test write log
    [self setupLogWriting];
    DDLogVerbose(@"app did load");
    //
    
    // Sa Vo - tnlq -- import bugsense v3.4
    [BugSenseController sharedControllerWithBugSenseAPIKey:@"ab88c70d"];
    //
    // Sa Vo - tnlq - [09/06/2014] - fix bugs problem when orientation
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        
        self.window.clipsToBounds =YES;
        
        self.window.frame =  CGRectMake(0,0,self.window.frame.size.width,self.window.frame.size.height);
    }

    
    //Override point for customization after app launch.
    [viewController showSplash];
    [viewController hideSplash];
    
    [self performSelector:@selector(loading) withObject:nil];
    [self.window makeKeyAndVisible];
    
	return YES;
}

-(void)loading
{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    NSString *strMobicartEmail=[NSString stringWithFormat:@"%@",merchant_email];
   
    [[MobicartStart sharedApplication]startMobicartOnMainWindow:(UIWindow *)window withMerchantEmail:(NSString *)strMobicartEmail];
	
	// For getting geo coordinates of user location
    userLocation = [[CLLocationManager alloc] init];
    userLocation.delegate = self;
    
    // Tuyen
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
    // End
    
    // Tuyen close
    //	const CLLocationAccuracy * ptr = &kCLLocationAccuracyBestForNavigation;
    //	BOOL frameworkSupports = (ptr != NULL);
    //
    //    if (frameworkSupports)
    //    {
    //        userLocation.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    //    }
    //	else
    //    {
    //        userLocation.desiredAccuracy = kCLLocationAccuracyBest;
    //    }
    // Tuyen end
    
    [userLocation startUpdatingLocation];
	if([[NSUserDefaults standardUserDefaults]valueForKey:@"isFirstTime"]==nil)
    {
        
        [[NSUserDefaults standardUserDefaults]setValue:@"Not First Time" forKey:@"isFirstTime"];
        [[SqlQuery shared]setTblAccountDetails:@"demo" :@"demo@123.com" :@"demo123" :@"St123" :@"city" :@"United Kingdom" :@"NewCastle" :@"1" :@"" :@"" :@"" :@"" :@""];
    }
    [pool release];
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	tempLocation = newLocation.coordinate;
	
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
	DDLogError(@"Error in Location Services. Error:-- %@", error);
}





#pragma mark Push Notification Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
	NSString* tempToken = [[NSString stringWithFormat:@"%@",devToken] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	NSString *tempToken1 = [tempToken stringByReplacingOccurrencesOfString:@">" withString:@"" ];
	NSString *tokenString= [tempToken1 stringByReplacingOccurrencesOfString:@"<" withString:@"" ];
	
	NSData*	deviceToken = [[NSData alloc]initWithData:devToken];
	DDLogDebug(@"device token is: %@",deviceToken);
	
	NSString *strLatitude=[NSString stringWithFormat:@"%lf",tempLocation.latitude];
	NSString *strLongitude=[NSString stringWithFormat:@"%lf",tempLocation.longitude];
	[ServerAPI pushNotifications:strLatitude :strLongitude :tokenString:[GlobalPrefrences getCurrentAppId]];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    DDLogWarn(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:[[userInfo valueForKey:@"aps"]valueForKey:@"alert"] delegate:self cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
//    DDLogVerbose(@"app will Resign Active");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    DDLogVerbose(@"app Did Become Active");
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    DDLogVerbose(@"app Will Terminate");
}


#pragma mark -
#pragma mark Memory management


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    DDLogVerbose(@"Dealloc");
    [viewController release];
    [window release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

// Tuyen test write log
- (void)setupLogWriting {
    [IMTCustomFormatter setupLogWriting];
}

//

@end
