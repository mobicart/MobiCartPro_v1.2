//
//  MobicartAppViewController.h
//  MobicartApp
//
//  Created by Mobicart on 14/09/10.
//  Copyright Mobicart 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

BOOL isNewsSection;

@interface MobicartAppViewController : UIViewController<UITabBarControllerDelegate,CLLocationManagerDelegate> 
{
    UIWindow *_window;
    MobicartAppAppDelegate *_viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain)  MobicartAppAppDelegate *viewController;
-(void)loadData;
-(void)locateUser;
@end


