//
//  MyAccountViewController.h
//  MobiCart
//
//  Copyright Mobicart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailsViewController.h"

// Sa Vo - tnlq - 28/05/2014
@interface MyAccountViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, DetailsViewControllerDelegate>
{
	UIAlertView *alertMain;	
	UIView *contentView;
	UITableView *tableView;
	NSMutableArray *showArray;
	UIButton *btnLogout;	
	UIView *viewWhenAlertViewIsVisible;	
	UIView *rightContentView, *rightView;
	UILabel *lblCart;
}

-(void)createTableView;
@end
