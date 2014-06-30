//
//  ContactUsViewController.m
//  MobiCart
//
//  Created by Mobicart on 7/6/10.
//  Copyright 2010 Mobicart. All rights reserved.
//

#import "ContactUsViewController.h"
#import "Constants.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MobiCartStart.h"
extern int controllersCount;
//extern   MobicartAppAppDelegate *_objMobicartAppDelegate;
@implementation ContactUsViewController

@synthesize _mapView,strStoreName;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        self.tabBarItem.image = [UIImage imageNamed:@"more_icon_02.png"];
        
        // Custom initialization
    }
    return self;
}

- (void)addCartButtonAndLabel
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    //Adding Shopping Cart on the Navigation Bar
	MobiCartStart *as=[[MobiCartStart alloc]init];
	UIButton *btnCartOnNavBar = [UIButton buttonWithType:UIButtonTypeCustom];
	btnCartOnNavBar.frame = CGRectMake(237, 5, 78, 34);
	[btnCartOnNavBar setBackgroundColor:[UIColor clearColor]];
	[btnCartOnNavBar setImage:[UIImage imageNamed:@"add_cart.png"] forState:UIControlStateNormal];
	[btnCartOnNavBar addTarget:as action:@selector(btnShoppingCart_Clicked:) forControlEvents:UIControlEventTouchUpInside];
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
    
    //Sa Vo fix bug the view show a white space at the bottom
    /*
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
     */
    
    //[NSThread detachNewThreadSelector:@selector(showLoadingbar) toTarget:self withObject:nil];
    [self showLoadingbar];
	if(controllersCount>5){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removedPoweredByMobicart" object:nil];
    }
    else
	[self addCartButtonAndLabel];
    
    
	[GlobalPreferences setCurrentNavigationController:self.navigationController];
    [self hideLoadingBar];
     
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewWillDisappear");
    
    
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
    
	
	lblCart = [[UILabel alloc] initWithFrame:CGRectMake(280, 5, 30, 34)];
	lblCart.backgroundColor = [UIColor clearColor];
	lblCart.textAlignment = UITextAlignmentCenter;
	lblCart.font = [UIFont boldSystemFontOfSize:16];
	lblCart.text = [NSString stringWithFormat:@"%d", iNumOfItemsInShoppingCart];
	lblCart.textColor = [UIColor whiteColor];
	[self.navigationController.navigationBar addSubview:lblCart];
	

	contentView=[[UIView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake( 0, 0, 320, 396) chageHieght:YES]];
	//contentView.backgroundColor=[UIColor colorWithRed:200.0/256 green:200.0/256 blue:200.0/256 alpha:1];
	//[GlobalPreferences setGradientEffectOnView:contentView :[UIColor whiteColor] :contentView.backgroundColor];
	
	self.view=contentView;

    
	
	UIImageView *imgBg=[[UIImageView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0,30, 320, 350) chageHieght:YES]];
	[imgBg setImage:[UIImage imageNamed:@"product_details_bg.png"]];
	[contentView addSubview:imgBg];
	[imgBg release];
	
	contactDetailsLbl=[[UITextView alloc]initWithFrame:CGRectMake(10, 30,310,130)];
	contactDetailsLbl.textColor=_savedPreferences.labelColor;
	contactDetailsLbl.font =[UIFont fontWithName:@"Helvetica" size:13.0];
	[contactDetailsLbl setBackgroundColor:[UIColor clearColor]];
	[contactDetailsLbl setEditable:NO];
	[contactDetailsLbl setText:@"Loading..."];
	[contactDetailsLbl resignFirstResponder];
	[contentView addSubview:contactDetailsLbl];
	[contactDetailsLbl	retain];
    
    
    _mapView = [[MKMapView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(10,160,300,197) chageHieght:YES]];
    
    
    
    [[_mapView layer]setBorderWidth:1.0];
    [[_mapView layer] setCornerRadius:10];
	[contentView addSubview:_mapView];
	_mapView.delegate = self;
    
	NSDictionary *dictMerchantDetails =[ServerAPI fetchAddressOfMerchant:[GlobalPreferences getMerchantEmailId]];
	dictUserDetails = [dictMerchantDetails objectForKey:@"user-address"];
	[self addressLocation];
    
    
	NSDictionary *dicAppSettings = [GlobalPreferences getSettingsOfUserAndOtherDetails];
	
	if (dicAppSettings)
    {
        self.strStoreName =[NSString stringWithFormat:@"%@", [dicAppSettings objectForKey:@"sSName"]];
    }
	else
    {
        self.strStoreName = @"Store Location";
    }
    
    
    //Sa Vo fix bug not display pointer if location turn off
    //Set Zoom level using Span
    
	annot= [[CSMapAnnotation alloc]initWithCoordinate:coord title:self.strStoreName subTitle:nil];
	[_mapView addAnnotation:annot];
	
    MKCoordinateSpan span;
    
    span.latitudeDelta=0.1;
    span.longitudeDelta=0.1;
    
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord,1000,1000);
	[_mapView setRegion:region animated:YES];
   

    
	UIView *viewTopBar=[[UIView alloc]initWithFrame:CGRectMake(0,-1, 320, 31)];
    [viewTopBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"barNews.png"]]];
    [contentView addSubview:viewTopBar];
    
	[contentView addSubview:viewTopBar];
    
    UIImageView *imgViewContactUs=[[UIImageView alloc]initWithFrame:CGRectMake(10,8,15,15)];
	[imgViewContactUs setImage:[UIImage imageNamed:@"contact_usIcon.png"]];
    [viewTopBar addSubview:imgViewContactUs];
    [imgViewContactUs release];
	
    UILabel *contactLbl=[[UILabel alloc]initWithFrame:CGRectMake(30,9,280, 15)];
	[contactLbl setBackgroundColor:[UIColor clearColor]];
	[contactLbl setText:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.more.contactus"]];
    [contactLbl setTextColor:[UIColor whiteColor]];
	[contactLbl setFont:[UIFont boldSystemFontOfSize:13]];
	[viewTopBar addSubview:contactLbl];
	[contactLbl release];
	[viewTopBar release];
    
    
    [self fetchDataFromServer];
    
}

#pragma mark - fetchDataFromServer
- (void)fetchDataFromServer
{
	NSAutoreleasePool* autoReleasePool = [[NSAutoreleasePool alloc] init];
    
	if (!arrAllData)
    {
        arrAllData = [[NSArray alloc] init];
    }
	
    arrAllData = (NSArray *)[GlobalPreferences getDictStaticPages];// [[ServerAPI fetchStaticPages] objectForKey:@"static-pages"];
	[self performSelectorOnMainThread:@selector(updateControls) withObject:nil waitUntilDone:YES];
	[autoReleasePool release];
}

#pragma mark updateControls
- (void)updateControls
{
	if ([arrAllData count] >0)
    {
		NSDictionary *dictTemp = [arrAllData objectAtIndex:1];
		if ((![[dictTemp objectForKey:@"sDescription"] isEqual:[NSNull null]]))
		{
			if ((![[dictTemp objectForKey:@"sDescription"] isEqualToString:@""]))
            {
				contactDetailsLbl.text = [dictTemp objectForKey:@"sDescription"];
            }
			
		}
		else
		{
			contactDetailsLbl.text = @"";
		}
	}
	else
    {
        contactDetailsLbl.text = @"";
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
	//_mapView.delegate = nil;
	//[contentView release];
    //	[contactDetailsLbl release];
    //	[arrAllData release];
    [super dealloc];
}


#pragma mark - Address Locator
- (void)addressLocation {
	NSString *google_key = @"ABQIAAAA0lbZAqHh-vHS7WCn1s8sFhSXNnz9Mc3EzpX9jxA7H0PRhkjvWRQFLP11Ocnm_ptoZlq5PxCc-3CtJw";
	
	if ((![dictUserDetails isEqual:[NSNull null]]) && (dictUserDetails !=nil))
	{
		NSString *strMerchantAddress = [NSString stringWithFormat:@"%@,%@,%@,%@",[dictUserDetails objectForKey:@"sAddress"],[dictUserDetails objectForKey:@"sCity"],[dictUserDetails objectForKey:@"sState"],[dictUserDetails objectForKey:@"sCountry"]];
        //Sa Vo fix bug google map doesn't display address exactly
        
        double latitude = 0, longitude = 0;
        NSString *esc_addr =  [strMerchantAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
        NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
        
        SBJSON *_JSONParser=[[[SBJSON alloc]init] autorelease];
        NSDictionary *dictJson = (NSDictionary*)[_JSONParser objectWithString:result error:nil];
        // Sa Vo - tnlq - fix bug crash when failed to received map location
        if (dictJson != nil && [[dictJson objectForKey:@"results"] objectAtIndex:0] != nil) {
            NSDictionary *locationDict = [[[[dictJson objectForKey:@"results"] objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"];
            longitude = [[locationDict objectForKey:@"lng"] doubleValue];
            latitude = [[locationDict objectForKey:@"lat"] doubleValue];
            
            CLLocationCoordinate2D location;
            location.latitude = latitude;
            location.longitude = longitude;
            
            
            coord.latitude = latitude;
            coord.longitude = longitude;
        }
	}
	
	else
	{
		
	}
}

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
