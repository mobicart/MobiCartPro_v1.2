//
//  MobicartStart.h
//  Mobicart
//
//  Created by Mobicart on 05/03/11.
//  Copyright Mobicart. All rights reserved.
//

#import <UIKit/UIKit.h>

UIViewController * nextController;

BOOL isNewsSection;
BOOL isMorePage;
int checkTab;
@interface MobicartStart : UIViewController<UINavigationControllerDelegate,UITabBarControllerDelegate,UITabBarDelegate> {
	UITableView *moreTableView;
	NSArray *arrTabbarDetails;
	UIView *detailsView;
	BOOL hideMobicartCopyrightLogo;
  UIView *viewRight;
    
    UIImage *imgFooter;
}
@property(nonatomic,retain) UIImage *imgFooter;
// !!!: ********** USE THIS METHOD TO START APP ********* :!!!
+ (id)sharedApplication;

-(id)startMobicartOnMainWindow:(UIWindow *) _window withMerchantEmail:(NSString *)_merchantEmail;

- (void)poweredMobicart;
- (void)removeMobicart;
@end
