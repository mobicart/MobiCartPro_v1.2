//
//  MobicartViewController.m
//  MobicartApp
//
//  Created by Mobicart on 14/09/10.
//  Copyright Mobicart 2010. All rights reserved.


#import "MobicartViewController.h"
#import "library/MobiCartStart.h"
#import "library/SqlQuery.h"
#import "library/GlobalPreferences.h"
#import "library/UserDetails.h"
@implementation MobicartViewController




// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self loadData];
    [self locateUser];
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)loadData
{
    DDLogVerbose(@"loadData");
    NSString *strMobicartEmail = [NSString stringWithFormat:@"%@",merchant_email];
    
    //----------mobi-cart app start and fill data
    [[MobiCartStart sharedApplication] startMobicartOnMainWindow:self.view withMerchantEmail:strMobicartEmail];
    
}

-(void)locateUser
{
    DDLogVerbose(@"locateUser");
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    
	// For getting geo coordinates of user location
	    if([[NSUserDefaults standardUserDefaults]valueForKey:@"isFirstTime"]==nil)
    {
        
        [[NSUserDefaults standardUserDefaults]setValue:@"Not First Time" forKey:@"isFirstTime"];
        
        [[SqlQuery shared]setTblAccountDetails:@"demo" :@"demo@123.com" :@"demo123" :@"St123" :@"city" :@"United Kingdom" :@"NewCastle" :@"1" :@"" :@"" :@"" :@"" :@""];
    }
    
    
	
    [pool release];
    
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)dealloc
{
    [super dealloc];
    
}

@end
