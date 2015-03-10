//
//  MobicartAppDelegate.h
//  MobicartApp
//
//  Created by Mobicart on 14/09/10.
//  Copyright Mobicart 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class MobicartViewController;

@interface MobicartAppDelegate : NSObject <UIApplicationDelegate,CLLocationManagerDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate> 
{
    UIWindow *window;
    MobicartViewController *viewController;
	
	UITabBarController *tabController;
	NSArray *arrAllData;
	CLLocationManager *userLocation;
	// loading indicator
	UIActivityIndicatorView *loadingIndicator;
	UIImageView *backgroundImage;
	CLLocationCoordinate2D tempLocation;
    
    //Sa Vo fix bug display wrong title of More page on iOS 7.0
    NSArray *_arrMoreTitles;
    
}

//@property (nonatomic)int isFromMoreTab;
//@property (nonatomic, retain)UIAlertView *alert;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UIView *mobicartView;
@property (nonatomic, retain) IBOutlet MobicartViewController *viewController;
@property (nonatomic, retain) UITabBarController *tabController;
@property (nonatomic, retain) NSArray *arrAllData;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) UIImageView *backgroundImage;

//Sa Vo fix bug display wrong title of More page on iOS 7.0
@property (nonatomic, retain)  NSArray *arrMoreTitles;
@end

