//
//  MobicartAppDelegate.h
//  Mobicart
//
//  Created by Mobicart on 05/03/11.
//  Copyright Mobicart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class MobicartViewController;
@interface MobicartAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate,CLLocationManagerDelegate> {
    UIWindow *window;
    CLLocationManager *userLocation;
    MobicartViewController *viewController;
	UITabBarController *tabController;
	NSArray *arrAllData;
	UIImageView *backgroundImage;
	UIActivityIndicatorView *loadingIndicator;
    CLLocationCoordinate2D tempLocation;
    
    //Sa Vo fix bug display wrong title of More page on iOS 7.0
    NSArray *_arrMoreTitles;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MobicartViewController *viewController;
@property (nonatomic, retain) UITabBarController *tabController;
@property (nonatomic, retain) NSArray *arrAllData;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) UIImageView *backgroundImage;
//Sa Vo fix bug display wrong title of More page on iOS 7.0
@property (nonatomic, retain)  NSArray *arrMoreTitles;
@end

