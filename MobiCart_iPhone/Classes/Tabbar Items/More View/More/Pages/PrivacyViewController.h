//
//  PrivacyViewController.h
//  MobicartApp
//
//  Created by Mobicart on 11/10/10.
//  Copyright 2010 Mobicart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobicartAppAppDelegate.h"

@interface PrivacyViewController : UIViewController <UIWebViewDelegate>{

	UILabel *aboutDetailLblText;
    UIWebView *aboutDetailLbl;
	NSArray *arrAllData;
	UIScrollView *contentScrollView;
    
   // MobicartAppAppDelegate *delegate;
}
- (void)hideLoadingBar;

@end
