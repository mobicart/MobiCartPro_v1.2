//
//  MobicartAppAppDelegate.h
//  MobicartApp
//
//  Created by Mobicart on 14/09/10.
//  Copyright Mobicart 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class MobicartAppViewController;

@interface MobicartAppAppDelegate : NSObject <UIApplicationDelegate,CLLocationManagerDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate> 
{
    UIWindow *window;
    MobicartAppViewController *viewController;
	CLLocationManager *userLocation;
	UITabBarController *tabController;
	NSArray *arrAllData;
	
	// loading indicator
	UIActivityIndicatorView *loadingIndicator;
	UIImageView *backgroundImage;
	CLLocationCoordinate2D tempLocation;
    
    //Sa Vo fix bug display wrong title of More page on iOS 7.0
    NSArray *_arrMoreTitles;
    
}


@property (nonatomic, retain)UIAlertView *alert;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UIView *mobicartView;
@property (nonatomic, retain) IBOutlet MobicartAppViewController *viewController;
@property (nonatomic, retain) UITabBarController *tabController;
@property (nonatomic, retain) NSArray *arrAllData;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) UIImageView *backgroundImage;
//Sa Vo fix bug display wrong title of More page on iOS 7.0
@property (nonatomic, retain)  NSArray *arrMoreTitles;




@end


