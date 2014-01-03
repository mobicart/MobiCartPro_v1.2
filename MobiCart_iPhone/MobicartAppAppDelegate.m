//
//  MobicartAppAppDelegate.m
//  MobicartApp
//
//  Created by Mobicart on 14/09/10.
//  Copyright Mobicart 2010. All rights reserved.

#import "MobicartAppAppDelegate.h"
#import "MobicartAppViewController.h"
#import "MobiCartStart.h"
#import "UserDetails.h"
#import "SqlQuery.h"

@implementation MobicartAppAppDelegate
@synthesize window;  
@synthesize mobicartView,viewController,tabController,arrAllData,loadingIndicator,backgroundImage,alert;




#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
        
        self.window.clipsToBounds =YES;
        
        self.window.frame =  CGRectMake(0,0,self.window.frame.size.width,self.window.frame.size.height);
    }
    
    window.rootViewController=viewController;
    
    [window makeKeyAndVisible];
    //[self getUUID];
    userLocation = [[CLLocationManager alloc] init];
	userLocation.delegate = self;
    
	const CLLocationAccuracy * ptr = &kCLLocationAccuracyBestForNavigation;
	BOOL frameworkSupports = (ptr != NULL);
	
    if(frameworkSupports)
    {
        userLocation.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
	else
    {
        userLocation.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
	[userLocation startUpdatingLocation];
    return YES;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	tempLocation = newLocation.coordinate;
	[manager setDelegate:nil];
	
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	DLog(@"Error in Location Services. Error: %@", error);
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
   
    
}
#pragma mark Push Notification Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken 
{   
	NSString* tempToken = [[NSString stringWithFormat:@"%@",devToken] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	NSString *tempToken1 = [tempToken stringByReplacingOccurrencesOfString:@">" withString:@"" ];
	NSString *tokenString= [tempToken1 stringByReplacingOccurrencesOfString:@"<" withString:@"" ];
	
	NSData*	deviceToken = [[NSData alloc]initWithData:devToken];
	NSLog(@"device token is: %@",tempToken);
	
	NSString *strLatitude=[NSString stringWithFormat:@"%lf",tempLocation.latitude];
	NSString *strLongitude=[NSString stringWithFormat:@"%lf",tempLocation.longitude];
	
	[ServerAPI pushNotifications:strLatitude :strLongitude :tokenString :[GlobalPreferences getCurrentAppId]];
    [deviceToken release];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err 
{
	DLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [GlobalPreferences createAlertWithTitle:@"Alert" message:[[userInfo valueForKey:@"aps"]valueForKey:@"alert"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc 
{
    [viewController release];
    [window release];
	
	if(loadingIndicator)
    {
        [loadingIndicator release];
    }
	
	if(backgroundImage)
    {
        [backgroundImage release];
    }

	
	
    [super dealloc];
}




@end
