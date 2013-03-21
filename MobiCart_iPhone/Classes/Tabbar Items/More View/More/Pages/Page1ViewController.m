//
//  Page1ViewController.m
//  MobicartApp
//
//  Created by Mobicart on 11/10/10.
//  Copyright 2010 Mobicart. All rights reserved.
//

/** The View and Text for Displaying Page 1 defined for Store **/

#import "Page1ViewController.h"
#import "Constants.h"
extern int controllersCount;

//extern   MobicartAppAppDelegate *_objMobicartAppDelegate;
@implementation Page1ViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        self.tabBarItem.image=[UIImage imageNamed:@"info.png"];
        // delegate=(MobicartAppAppDelegate *)[[UIApplication sharedApplication]delegate];
        // Custom initialization
    }
    return self;
}

- (void)addCartButtonAndLabel
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    // Adding Shopping Cart on the Navigation Bar
	MobiCartStart *appDelegate=[MobiCartStart sharedApplication];
	
	UIButton *btnCartOnNavBar = [UIButton buttonWithType:UIButtonTypeCustom];
	btnCartOnNavBar.frame = CGRectMake(237, 5, 78, 34);
	[btnCartOnNavBar setBackgroundColor:[UIColor clearColor]];
	[btnCartOnNavBar setImage:[UIImage imageNamed:@"add_cart.png"] forState:UIControlStateNormal];
	[btnCartOnNavBar addTarget:appDelegate action:@selector(btnShoppingCart_Clicked:) forControlEvents:UIControlEventTouchUpInside];
	[self.navigationController.navigationBar addSubview:btnCartOnNavBar];
	
	UILabel *lblCart = [[UILabel alloc] initWithFrame:CGRectMake(280, 5, 30, 34)];
	lblCart.backgroundColor = [UIColor clearColor];
	lblCart.textAlignment = UITextAlignmentCenter;
	lblCart.font = [UIFont boldSystemFontOfSize:16];
	lblCart.text = [NSString stringWithFormat:@"%d", iNumOfItemsInShoppingCart];
	lblCart.textColor = [UIColor whiteColor];
	[self.navigationController.navigationBar addSubview:lblCart];
	[lblCart release];
	[pool release];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    //[NSThread detachNewThreadSelector:@selector(showLoadingbar) toTarget:self withObject:nil];
    [self showLoadingbar];
	if(controllersCount>5){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removedPoweredByMobicart" object:nil];
    }else
        [self addCartButtonAndLabel];
	//[self performSelectorInBackground:@selector(addCartButtonAndLabel) withObject:nil];
	[GlobalPreferences setCurrentNavigationController:self.navigationController];
	
	
	UIView *contentView=[[UIView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake( 0, 0, 320, 396) chageHieght:YES]];
	contentView.backgroundColor=[UIColor colorWithRed:200.0/256 green:200.0/256 blue:200.0/256 alpha:1];
	contentView.tag = 101010;
	[GlobalPreferences setGradientEffectOnView:contentView :[UIColor whiteColor] :contentView.backgroundColor];
	self.view=contentView;
	
	UIImageView *imgBg=[[UIImageView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0,30, 320, 350) chageHieght:YES]];
	[imgBg setImage:[UIImage imageNamed:@"product_details_bg.png"]];
	[contentView addSubview:imgBg];
	[imgBg release];
	
	UIView *viewTopBar=[[[UIView alloc]initWithFrame:CGRectMake(0,-1, 320,31)]autorelease];
	[viewTopBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"barNews.png"]]];
	
	[contentView addSubview:viewTopBar];
	
	UIImageView *imgViewContactUs=[[UIImageView alloc]initWithFrame:CGRectMake(10,8,15,15)];
	[imgViewContactUs setImage:[UIImage imageNamed:@"deliveryIcon.png"]];
    [viewTopBar addSubview:imgViewContactUs];
    [imgViewContactUs release];
	
	
	
	UILabel *aboutLbl=[[UILabel alloc]initWithFrame:CGRectMake(30,9,280, 15)];
	
	[aboutLbl setBackgroundColor:[UIColor clearColor]];
	[aboutLbl setText:[self.title uppercaseString]];
	[aboutLbl setTextColor:[UIColor whiteColor]];
	[aboutLbl setFont:[UIFont boldSystemFontOfSize:13]];
	[viewTopBar addSubview:aboutLbl];
	[aboutLbl release];
	
    contentScrollView=[[UIScrollView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0,30, 320,330) chageHieght:YES]];
	[contentScrollView setBackgroundColor:[UIColor clearColor]];
	
	
	
	aboutDetailLblText=[[UILabel alloc]initWithFrame:CGRectMake( 10, 0, 300, 50)];
	aboutDetailLblText.textColor=_savedPreferences.labelColor;
	aboutDetailLblText.font =[UIFont fontWithName:@"Helvetica" size:12.0];
	[aboutDetailLblText setNumberOfLines:0];
	[aboutDetailLblText setLineBreakMode:UILineBreakModeWordWrap];
	[aboutDetailLblText setBackgroundColor:[UIColor clearColor]];
	aboutDetailLblText.text=[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.LoaderText"];
	[contentScrollView addSubview:aboutDetailLblText];
    aboutDetailLbl=[[UIWebView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(5, 5, 310, 320) chageHieght:YES]];
    [aboutDetailLbl setOpaque:0];
    aboutDetailLbl.delegate=self;
    aboutDetailLbl.dataDetectorTypes=UIDataDetectorTypeAll;
	[aboutDetailLbl setBackgroundColor:[UIColor clearColor]];
    
	[contentScrollView addSubview:aboutDetailLbl];
    if ([GlobalPreferences isScreen_iPhone5])
        [contentScrollView setContentSize:CGSizeMake(  320, 320+88)];
    else
        [contentScrollView setContentSize:CGSizeMake( 320, 320)];
	
	[contentView addSubview:contentScrollView];
    
    
    [self fetchDataFromServer];
	[contentView release];
    [self hideLoadingBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(controllersCount>5){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"poweredByMobicart" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"addCartButton" object:nil];
    }
	for (UIView *view in [self.navigationController.navigationBar subviews])
    {
		if (([view isKindOfClass:[UIButton class]]) || ([view isKindOfClass:[UILabel class]]))
        {
            [view removeFromSuperview];
        }
	}
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	self.navigationItem.titleView = [GlobalPreferences createLogoImage];
	
    
}

#pragma mark - fetchDataFromServer
- (void)fetchDataFromServer
{
	NSAutoreleasePool* autoReleasePool = [[NSAutoreleasePool alloc] init];
    
	if (!arrAllData)
    {
        arrAllData = [[NSArray alloc] init];
    }
	
    arrAllData = (NSArray *)[GlobalPreferences getDictStaticPages];//delegate.dictStaticPages;//[[ServerAPI fetchStaticPages] objectForKey:@"static-pages"];
	[self performSelectorOnMainThread:@selector(updateControls) withObject:nil waitUntilDone:YES];
	[autoReleasePool release];
}

#pragma mark updateControls
- (void)updateControls
{
    
	int index=[[arrAllData valueForKey:@"sName"]indexOfObject:@"page1"];
	if ([arrAllData count] >4)
	{
		NSDictionary *dictTemp = [arrAllData objectAtIndex:index];
		if ((![[dictTemp objectForKey:@"sDescription"] isEqualToString:@""]) && (![[dictTemp objectForKey:@"sDescription"] isEqual:[NSNull null]]))
		{
			aboutDetailLblText.hidden=YES;
            NSString * htmlString = [NSString stringWithFormat:@"<html><head><script> document.ontouchmove = function(event) { if (document.body.scrollHeight == document.body.clientHeight) event.preventDefault(); } </script><style type='text/css'>* { margin:0; padding:0; } p { color:%@; font-family:Helvetica; font-size:14px; } a { color:%@; text-decoration:none; }</style></head><body><p>%@</p></body></html>", _savedPreferences.strHexadecimalColor,_savedPreferences.subHeaderColor,[dictTemp objectForKey:@"sDescription"]];
            [aboutDetailLbl loadHTMLString:htmlString baseURL:nil];
            
            if([GlobalPreferences isScreen_iPhone5])
                [contentScrollView setContentSize:CGSizeMake( 320, 330+88)];
            else
                [contentScrollView setContentSize:CGSizeMake( 320, 330)];
		}
		
	}
	
	
	//Show Mobicart Logo at the bottom?
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	[contentScrollView release];
	[aboutDetailLbl release];
	[arrAllData release];
    [super dealloc];
}
#pragma  WebView Delegates
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType

{
    
    
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    aboutDetailLbl.scalesPageToFit=YES;
    //[self hideIndicator];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    
    
    
    
    
}


#pragma mark loading indicator


- (void)showLoadingbar
{
	if (!loadingActionSheet1.superview)
    {
        loadingActionSheet1 = [[UIActionSheet alloc] initWithTitle:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.LoaderText"] delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        [loadingActionSheet1 showInView:self.tabBarController.view];
        
    }
    
	
}

- (void)hideLoadingBar
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(runScheduledTask) userInfo:nil repeats:NO];
    aTimer=nil;
	
	[pool release];
}
/* runScheduledTask */

- (void)runScheduledTask {
    // Do whatever u want
    
    if (loadingActionSheet1.superview)
    {
        [loadingActionSheet1 dismissWithClickedButtonIndex:0 animated:YES];
        [loadingActionSheet1 release];
		loadingActionSheet1 = nil;
    }
    // Set the timer to nil as it has been fired
    
    
    
    
}



@end
