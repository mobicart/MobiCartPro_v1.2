//
//  MobiCartStart.h
//  MobicartApp
//
//  Created by Mobicart on 12/2/11.
//  Copyright 2010 Mobicart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "MobicartAppAppDelegate.h"

@class MobiCartWebView;
@class MobicartAppAppDelegate;

int controllersCount;
BOOL isNewsSection;

@interface MobiCartStart : UIViewController <UITabBarControllerDelegate,UINavigationControllerDelegate>
{
    
	BOOL hideMobicartCopyrightLogo;
    UIImage *imgFooter;
    
	
	MobiCartWebView *objMobiWebView;
    UIButton *btnCartOnNavBar;
    UILabel *lblCart;
    
    MobicartAppAppDelegate *delegate;
    
}


@property(nonatomic,retain)    UIImage *imgFooter;


// !!!: ********** USE THIS METHOD TO START APP ********* :!!!
+ (id)sharedApplication;
-(id)startMobicartOnMainWindow:(UIView *) _mainView withMerchantEmail:(NSString *)_merchantEmail;


// METHOD TO HANDLE MOBICART BRANDING ON MORE TAB
- (void)poweredMobicart;

- (void)removeMobicart;

@end
