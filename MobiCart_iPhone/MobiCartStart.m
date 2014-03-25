//
//  MobiCartStart.m
//  MobicartApp
//
//  Created by Mobicart on 12/2/11.
//  Copyright 2010 Mobicart. All rights reserved.
//

/** This Class handles methods for initial start of the application. Initialy the application store user details, user preferences, tabs preferences, color schemes and other related details. **/

#import "MobiCartStart.h"
#import "MoreTableViewDataSource.h"
#import "MoreTableViewDelegate.h"


extern BOOL isPostReviews;

extern BOOL isStoreSearch;

extern BOOL isReadReviews;

MobicartAppAppDelegate *_objMobicartAppDelegate;

static MobiCartStart *shared;
@interface MobiCartStart (Private)

// Initial setup of App
- (void)initialSetup;

- (void)fetchDataFromServer;

- (void)fetchData;

- (void)createTabbarContorllers;

#pragma mark - Loading indicator setup
- (void)setupLoadingIndicator;

- (void)show_LoadingIndicator;

- (void)hide_LoadingIndicator;

@end

@implementation MobiCartStart

@synthesize imgFooter;

- (id)init
{
	if (shared)
    {
        [self autorelease];
		
        return shared;
    }
    self = [super init];
    
    //get delegate ref
    if(!delegate)
        delegate=(MobicartAppAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    //    if (self != nil)
    //    {
    //		shared = self;
    //    }
    return self;
}

#pragma mark - Helper Methods
+ (id)sharedApplication
{//DLog(@"2");
    if (!shared)
    {
        shared=[[MobiCartStart alloc] init];
    }
    
    return shared;
}

#pragma mark - Initializer

-(id)startMobicartOnMainWindow:(UIView *) _mainView withMerchantEmail:(NSString *)_merchantEmail
{
    NSLog(@"startMobicartOnMobicartView : STARTED");
    //DLog(@"3");
	self = [super init];
	
    if (self)
	{
		//_objMobicartAppDelegate = [[MobicartAppAppDelegate alloc] init];
		
        _objMobicartAppDelegate = (MobicartAppAppDelegate*)[UIApplication sharedApplication].delegate;
        
        // Custom initialization.
		if (_merchantEmail)
		{
			[GlobalPreferences setMerchantEmailID:_merchantEmail];
		}
		else
		{
			NSAssert(_merchantEmail,@"ERROR...! PLEASE ENTER MERCHANT EMAIL ID");
		}
		
		
		_objMobicartAppDelegate.mobicartView=_mainView;
		
        // Checking current version of Device
        
        // Inital setup of app
		//[self initialSetup];
        
        [self performSelector:@selector(initialSetup) withObject:nil];
        
        // Create tabbar Controller, with user selected tab items
        // DLog(@"Start creating tab");
		[self performSelector:@selector(createTabbarContorllers) withObject:nil ];
        
        //  [NSThread detachNewThreadSelector:@selector(createTabbarContorllers) toTarget:self withObject:nil];
        
        
		
        // For Mobicart branding
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(poweredMobicart) name:@"poweredByMobicart" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addCartButtonAndLabel) name:@"addCartButton" object:nil];
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMobicart) name:@"removedPoweredByMobicart" object:nil];
    }
    NSLog(@"startMobicartOnMobicartView : ENDED");
    return self;
}

#pragma mark Initial Setup
- (void)initialSetup
{
    //DLog(@"4");
	internetReach = [[Reachability reachabilityForInternetConnection] retain];
	
	[UIApplication sharedApplication].applicationIconBadgeNumber=0;
	
	if (![GlobalPreferences isInternetAvailable])
	{
		NSString* errorString;//= [NSString string];
		NSString* titleString ;//= [NSString string];
		NSString* cancelString;// = [NSString string];
		
		if ([[[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.text"] length]>0 && [[[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.title"] length]>0 && [[[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.cancelbutton"] length]>0)
		{
			errorString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.text"];
			
			titleString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.title"];
			
			cancelString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.cancelbutton"];
		}
		else
		{
			errorString = @"No Internet Connection. This Application requires Internet access to update its information";
			
			titleString = @"Alert";
			
			cancelString = @"OK";
		}
        [GlobalPreferences createAlertWithTitle:titleString message:errorString delegate:self cancelButtonTitle:cancelString otherButtonTitles:nil];
        
	}
	else
	{
        // Setup and start Loading indicator
        
        // [self performSelectorInBackground:@selector(setupLoadingIndicator) withObject:nil];
		
        // Initialising global objects
		[NSThread detachNewThreadSelector:@selector(initializeGlobalControllers) toTarget:[GlobalPreferences class] withObject:nil];
        
        
        
        /*
         NSInvocationOperation *operationFetchMainData = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchDataFromServer) object:nil];
         NSOperationQueue *que=[[NSOperationQueue alloc] init];
         [que addOperation:operationFetchMainData];
         [que release];
         [operationFetchMainData release];*/
        
        [self performSelector:@selector(fetchDataFromServer) withObject:nil];
        
	}
	
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	
	int ver = [currSysVer intValue];
	
	if (ver>3)
	{
		[GlobalPreferences setCurrentDevice4:YES];
		
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
	}
	else
	{
		[GlobalPreferences setCurrentDevice4:NO];
		
		[[UIApplication sharedApplication] setStatusBarHidden:NO];
	}
}

// Fetch AppID, MerchantID, StoreID, Color-schemes, Tabbar Preferences and AppVitals
- (void)fetchDataFromServer
{
    //DLog(@"5");
    
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	if (![GlobalPreferences isInternetAvailable])
	{
		NSString* errorString ;//= [NSString string];
		NSString* titleString ;//= [NSString string];
		NSString* cancelString;// = [NSString string];
		
		if ([[[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.text"] length]>0 && [[[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.title"] length]>0 && [[[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.cancelbutton"] length]>0)
		{
			errorString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.text"];
			
			titleString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.title"];
			
			cancelString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.cancelbutton"];
		}
		else
		{
			errorString = @"No Internet Connection. This Application requires Internet access to update its information";
			
			titleString = @"Alert";
			
			cancelString = @"OK";
		}
        [GlobalPreferences createAlertWithTitle:titleString message:errorString delegate:self cancelButtonTitle:cancelString otherButtonTitles:nil];
        
	}
	else
	{
        //ServerAPI *api=[[ServerAPI alloc]init];
        
        //fetch all data from the server
        [GlobalPreferences setAllDataDictionary];
        
        // Fetch App and Merchant Details from the server
		NSDictionary *dictAppDetails=nil;
		dictAppDetails =[GlobalPreferences getDictAppStoreUser];//delegate.dictAppStoreUser;//[ServerAPI getAppStoreUserDetails];
		
		if (!dictAppDetails)
		{
            //DLog(@"Dict app details");
			//dictAppDetails =[ServerAPI getAppStoreUserDetails];
		}
		else if (dictAppDetails)
		{
            //DLog(@"DictAppDetails");
			iCurrentAppId = [[dictAppDetails objectForKey:@"appId"] intValue];//[[[dictAppDetails objectForKey:@"app-store-user"] objectForKey:@"appId"] intValue]
			
			iCurrentMerchantId = [[dictAppDetails objectForKey:@"userId"] intValue];//[[[dictAppDetails objectForKey:@"app-store-user"]objectForKey:@"userId"] intValue];
			
			iCurrentStoreId = [[dictAppDetails objectForKey:@"storeId"] intValue];//[[[dictAppDetails objectForKey:@"app-store-user"] objectForKey:@"storeId"] intValue];
			
			BOOL hitLangService ;
			
			NSString *strTimeStamp = [NSString stringWithFormat:@"%@",[[SqlQuery shared]getTimeStamp]];
			
			DLog(@"time satmp%d",[strTimeStamp length]);
			
			if ([strTimeStamp length]>0 || strTimeStamp != nil || ![strTimeStamp isEqualToString:@""] || ![strTimeStamp isEqualToString:@" "])
			{
				hitLangService  = [ServerAPI isLangUpdated:strTimeStamp :iCurrentMerchantId];
			}
			else
			{
				hitLangService = FALSE;
			}
			
			// Fetch Language Pack Values for Labels
			//DLog(@"Dict labels");
			NSDictionary *dictLabels = [[NSDictionary alloc] init];
			
			if (!hitLangService)
			{
				dictLabels = [ServerAPI fetchLanguagePreferences:iCurrentMerchantId];
			}
			
            // Fetch tabbar preferences from server
			NSDictionary *dictFeatures = [GlobalPreferences getDictFeatures];//delegate.dictFeatures;//[ServerAPI fetchTabbarPreferences];
			
            // Fetch Color schemes
			NSDictionary *dictColorSchemes =[GlobalPreferences getDictColorScheme];//delegate.dictColorScheme;//[ServerAPI fetchColorScheme];
			
			NSDictionary *dictAppVitals = [GlobalPreferences getDictVitals];//delegate.dictVitals;//[ServerAPI fetchAppVitals];
            
            // Fetch Logo Image
            
			NSString *strLogo = [NSString stringWithFormat:@"%@",[dictAppVitals objectForKey:@"companyLogoIphone4"]];
			
			if ((![strLogo isEqual:[NSNull null]]) && (![strLogo isEqualToString:@"<null>"]) && ([strLogo length]!=0))
			{
				_savedPreferences.imgLogo=[ServerAPI setLogoImage:[NSString stringWithFormat:@"%@",strLogo] :NO];
			}
			else
			{
				_savedPreferences.imgLogo=[ServerAPI setLogoImage:[NSString stringWithFormat:@"%@",strLogo] :YES];
			}
			
			// Save Language Prefrences in Database
			if (!hitLangService && [dictLabels count]>0)
			{
				[[SqlQuery shared] deleteLangLabels];
				
				[[SqlQuery shared] saveLanguageLabels:[dictLabels valueForKey:@"Labels"]];
			}
			
            NSDictionary *dictLabelsFromData = [[NSDictionary alloc] initWithDictionary:[[SqlQuery shared]getAllLabels]];
            
            if ([dictLabelsFromData count]>0)
			{
                [GlobalPreferences setLanguageLabels:dictLabelsFromData];
            }
			
            // Set TabBar Controllers Selected by User
			if ([dictFeatures count] >0)
			{
				[GlobalPreferences setTabbarControllers_SelectedByUser:dictFeatures];
                
			}
            
			else
			{
				NSString* errorString ;//= [NSString string];
				NSString* titleString ;//= [NSString string];
				NSString* cancelString ;//= [NSString string];
				
				if ([[[SqlQuery shared]getLanguageLabel:@"key.iphone.server.notresp.title.error"] length]>0 && [[[SqlQuery shared]getLanguageLabel:@"key.iphone.server.notresp.text"] length]>0 && [[[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.cancelbutton"] length]>0)
				{
					errorString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.server.notresp.text"];
					
					titleString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.server.notresp.title.error"];
					
					cancelString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.cancelbutton"];
				}
				else
				{
					errorString = @"Server not responding";
					
					titleString = @"Error";
					
					cancelString = @"Ok";
				}
                [GlobalPreferences createAlertWithTitle:titleString message:errorString delegate:self cancelButtonTitle:cancelString otherButtonTitles:nil];
                
			}
			[GlobalPreferences setAppVitalsAndCountries:dictAppVitals];
			
			[GlobalPreferences setColorScheme_SelectedByUser:dictColorSchemes];
		}
		else
		{
			NSString* errorString ;//= [NSString string];
			NSString* titleString ;//= [NSString string];
			NSString* cancelString;// = [NSString string];
			
			if ([[[SqlQuery shared]getLanguageLabel:@"key.iphone.server.notresp.title.error"] length]>0 && [[[SqlQuery shared]getLanguageLabel:@"key.iphone.server.notresp.text"] length]>0 && [[[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.cancelbutton"] length]>0)
			{
				errorString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.home.try.later"];
				
				titleString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.server.notresp.title.error"];
				
				cancelString = [[SqlQuery shared]getLanguageLabel:@"key.iphone.nointernet.cancelbutton"];
			}
			else
			{
				errorString = @"Please try later..!";
				
				titleString = @"Server Not Responding";
				
				cancelString = @"OK";
			}
            [GlobalPreferences createAlertWithTitle:titleString message:errorString delegate:self cancelButtonTitle:cancelString otherButtonTitles:nil];
		}
	}
    // DLog(@"End");
    [pool release];
}

#pragma mark - Tabbar Controller Creators/Handlers

// Fetch StaticPages And Mobicart-Branding Details
- (void)fetchData
{
	NSAutoreleasePool* autoReleasePool = [[NSAutoreleasePool alloc] init];
	
	if (!_objMobicartAppDelegate.arrAllData)
    {
        _objMobicartAppDelegate.arrAllData = [[NSArray alloc] init];
    }
	
	_objMobicartAppDelegate.arrAllData =(NSArray *)[GlobalPreferences getDictStaticPages];//delegate.dictStaticPages;//[[ServerAPI fetchStaticPages] objectForKey:@"static-pages"];
	
	[_objMobicartAppDelegate.arrAllData retain];
    
    self.imgFooter=[ServerAPI fetchFooterLogo];
    
    // Remove Branding Check
	NSDictionary *dictTemp = [_objMobicartAppDelegate.arrAllData objectAtIndex:0];
	
	NSString *strBool = [dictTemp objectForKey:@"bCustomCopyrightPage"];
	
	if (([strBool isEqual:[NSNull null]]) || (strBool == nil))
    {
        hideMobicartCopyrightLogo = FALSE;
    }
	else
    {
        hideMobicartCopyrightLogo = [[dictTemp objectForKey:@"bCustomCopyrightPage"] boolValue];
    }
	
	[autoReleasePool release];
}

+(void)setTitleForViewController:(UIViewController *)_obj :(NSString *)strTitle
{
    if ([strTitle isKindOfClass:[NSString class]])
	{
		if ([strTitle isEqualToString:@"My Account"])
		{
            strTitle = [[SqlQuery shared] getLanguageLabel:@"key.iphone.tabbar.account"];
		}
	}
	
	_obj.title = strTitle;
}

-(BOOL)isDarkColor:(UIColor*)backgroundColor {
    
    const CGFloat *componentColors = CGColorGetComponents(backgroundColor.CGColor);
    
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    if (colorBrightness < 0.5)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// Initialize tabbar controllers, as per selected by user
- (void)createTabbarContorllers
{//DLog(@"6");
    // tabbar controllers, as per selected by user
	NSArray *arrFetchedControllers = [GlobalPreferences tabBarControllers_SelectedByUser];
	
	NSMutableArray *arrAllControllerObjects = [[NSMutableArray alloc] init];
	
	HomeViewController *_objHome=[[HomeViewController alloc]init];
	
	StoreViewController *_objStore = [[StoreViewController alloc] init];
	
	NewsViewController *_objNews= [[NewsViewController alloc] init];
	
	MyAccountViewController *_objMyAccount= [[MyAccountViewController alloc] init];
    
	AboutUsViewController *_objAboutUs= [[AboutUsViewController alloc] init];
	
	ContactUsViewController *_objContactUs= [[ContactUsViewController alloc] init];
	
	
	TermsViewController *_objTermsConditions = [[TermsViewController alloc] init];
	
	PrivacyViewController *_objPrivacy = [[PrivacyViewController alloc] init];
	
	Page1ViewController *_objPage1 = [[Page1ViewController alloc] init];
	
	Page2ViewController *_objPage2 = [[Page2ViewController alloc] init];
	
	[arrAllControllerObjects addObject:_objHome];
	
	[arrAllControllerObjects addObject:_objStore];
	
	[arrAllControllerObjects addObject:_objNews];
	
	[arrAllControllerObjects addObject:_objMyAccount];
	
	[arrAllControllerObjects addObject:_objAboutUs];
	
	[arrAllControllerObjects addObject:_objContactUs];
	
	[arrAllControllerObjects addObject:_objTermsConditions];
	
	[arrAllControllerObjects addObject:_objPrivacy];
	
	[arrAllControllerObjects addObject:_objPage1];
	
	[arrAllControllerObjects addObject:_objPage2];
    
	
    NSMutableArray *arrControllersToCreate = [[NSMutableArray alloc] init];
	
	for(int i=0; i<[arrAllControllerObjects count];i++)
	{
		NSString *strSelectedControllerName = NSStringFromClass([[arrAllControllerObjects objectAtIndex:i] class]);
		
		if ([arrFetchedControllers containsObject:strSelectedControllerName])
		{
			[arrControllersToCreate addObject:[arrAllControllerObjects objectAtIndex:i]];
		}
	}
    controllersCount=[arrControllersToCreate count];
	
	NSMutableArray *localControllersArray = [[NSMutableArray alloc] initWithCapacity: [arrControllersToCreate count]];
	
	_objMobicartAppDelegate.tabController = [[UITabBarController alloc] init];
	
	_objMobicartAppDelegate.tabController.delegate=self;
    
    //Sa Vo set default tint color of tabbar is black for both iOS 6.x and iOS 7.x
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
    }
	
	NSArray *arrAllNavigationTitles = [NSArray arrayWithArray:[GlobalPreferences getAllNavigationTitles]];
	
	NSMutableArray *arrSelectedTitles = [[[NSMutableArray alloc] init] autorelease];
	
    //Sa Vo fix bug display wrong title of More pages on iOS 7.0
    
    NSMutableArray *arrTitleMorePage = [[[NSMutableArray alloc] init] autorelease];
    
	for(int i =0; i<[arrAllNavigationTitles count]; i++)
	{
		if (![[arrAllNavigationTitles objectAtIndex:i] isEqual: @""])
        {
            [arrSelectedTitles addObject:[arrAllNavigationTitles objectAtIndex:i]];
        }
	}
    
    //Sa Vo fix bug display wrong title of More pages on iOS 7.0
    
    for (int i=0; i<[arrSelectedTitles count]; i++) {
        if(i>3){
            [arrTitleMorePage addObject:[arrSelectedTitles objectAtIndex:i]];
            
        }
    }
    
    _objMobicartAppDelegate.arrMoreTitles = [NSArray arrayWithArray:arrTitleMorePage];

	
    // For adding add to cart button
	UIButton *btnCart[[arrControllersToCreate count]];
	
	for (int i=0; i<[arrControllersToCreate count]; i++)
	{
		UINavigationController *localNavigationController = [[UINavigationController alloc] initWithRootViewController:[arrControllersToCreate objectAtIndex:i]];
		
		[localControllersArray addObject:localNavigationController];
        
		localNavigationController.delegate = self;
		
		[MobiCartStart setTitleForViewController:[arrControllersToCreate objectAtIndex:i] :[arrSelectedTitles objectAtIndex:i]];
		
		UIViewController *objTemp = [arrControllersToCreate objectAtIndex:i];
		
		if (i < ([arrControllersToCreate count]))
		{
			btnCart[i] = [UIButton buttonWithType:UIButtonTypeCustom];
			
			btnCart[i].frame = CGRectMake(237, 5, 78, 34);
            
			[btnCart[i] setBackgroundColor:[UIColor clearColor]];
			
			[btnCart[i] setImage:[UIImage imageNamed:@"add_cart.png"] forState:UIControlStateNormal];
			
			[btnCart[i] addTarget:self action:@selector(btnShoppingCart_Clicked:) forControlEvents:UIControlEventTouchUpInside];
			
			[objTemp.navigationController.navigationBar addSubview:btnCart[i]];
		}
		localNavigationController.navigationBar.tintColor=navBarColor;
        
        //Sa Vo fix bug not display tint color of navigation bar on iOS 7.x
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        {
            localNavigationController.navigationBar.barTintColor = navBarColor;
            localNavigationController.navigationBar.translucent = NO;
            
            //Sa Vo fix bug not display status bar text on dark background on iOS 7.x
            if ([self isDarkColor:navBarColor]) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }else{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                
            }
        }

		
		[localNavigationController release];
	}
	
	_objMobicartAppDelegate.tabController.viewControllers = localControllersArray;
	
    // To stop/block the Editing in more tab
	_objMobicartAppDelegate.tabController.customizableViewControllers = [NSArray arrayWithObjects:nil];
    
    
    /*for (UINavigationController*t in _objMobicartAppDelegate.tabController.viewControllers)
     {
     if ([t.tabBarController.tabBarItem title] == @"More")
     {
     [t setTitle:@"gdfg"];
     }
     }*/
    
    //    objDelegate.navController = _objMobicartAppDelegate.tabController.navigationController;
    //    [(MobicartAppAppDelegate*)[[UIApplication sharedApplication] delegate] ChangeMoreTab:(UINavigationController*)localControllersArray];
    
	[localControllersArray release];
	[_objHome release];
	[_objStore release];
	[_objMyAccount release];
	[_objNews release];
	[_objAboutUs release];
	[_objContactUs release];
	[_objTermsConditions release];
	[_objPrivacy release];
	[_objPage1 release];
	[_objPage2 release];
	
	[self hide_LoadingIndicator];
	
	[_objMobicartAppDelegate.mobicartView addSubview:_objMobicartAppDelegate.tabController.view];
}

#pragma mark - loading indicator (Global)

// Handling Loading Indicator on Splash screen
- (void)setupLoadingIndicator
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	_objMobicartAppDelegate.backgroundImage = [[UIImageView alloc] initWithFrame:_objMobicartAppDelegate.mobicartView.bounds];
	
	_objMobicartAppDelegate.backgroundImage.image = [UIImage imageNamed:@"Default.png"];
	
	[_objMobicartAppDelegate.mobicartView addSubview:_objMobicartAppDelegate.backgroundImage];
	
	[_objMobicartAppDelegate.backgroundImage setHidden:YES];
	
	CGRect frame = CGRectMake(145.0, 370.0, 27, 27);
	
	_objMobicartAppDelegate.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	
	[_objMobicartAppDelegate.loadingIndicator setFrame:frame];
	
	[_objMobicartAppDelegate.loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
	
	[_objMobicartAppDelegate.loadingIndicator startAnimating];
	
	[_objMobicartAppDelegate.mobicartView addSubview:_objMobicartAppDelegate.loadingIndicator];
	
	[self show_LoadingIndicator];
	
	[pool release];
}

// Show loading indicator
- (void)show_LoadingIndicator
{
	[_objMobicartAppDelegate.mobicartView bringSubviewToFront:_objMobicartAppDelegate.backgroundImage];
	
	[_objMobicartAppDelegate.mobicartView bringSubviewToFront:_objMobicartAppDelegate.loadingIndicator];
	
	[_objMobicartAppDelegate.loadingIndicator setHidden:NO];
	
	[_objMobicartAppDelegate.backgroundImage setHidden:NO];
}

// Hide loading indicator
- (void)hide_LoadingIndicator
{
	[_objMobicartAppDelegate.loadingIndicator setHidden:YES];
	
	[_objMobicartAppDelegate. backgroundImage setHidden:YES];
}

#pragma mark - button Shoppoing Cart Accessor

// Handling Loading Indicator at the time of loading data from Server
- (void)showLoadingbar
{
    
    //Adding loading bar to window instead of view to avoid Crash in iOS 7
    MobicartAppAppDelegate *appdelegate = (MobicartAppAppDelegate *)[UIApplication sharedApplication].delegate;
    
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    [GlobalPreferences addLoadingBar_AtBottom:appdelegate.window withTextToDisplay:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.LoaderText"]];
	
	[pool release];
}
- (void)hideLoadingbar
{
	//NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
	
	[GlobalPreferences dismissLoadingBar_AtBottom];
	
	//[pool release];
}

// Handling Shopping Cart Button Clicked Event
- (void)btnShoppingCart_Clicked:(id)sender
{
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	int countNavs = [[[GlobalPreferences getCurrentNavigationController] viewControllers] count];
	
	if (countNavs==1)
	{
		UIViewController *objsd = [[[GlobalPreferences getCurrentNavigationController] viewControllers] objectAtIndex:0];
		
		if ([[objsd title] isEqualToString:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.tabbar.home"]])
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"resignSearchBarFromHome" object:nil];
		}
		else if ([[objsd title] isEqualToString:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.tabbar.store"]])
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"resignSearchBarFromStore" object:nil];
		}
	}
	else if(countNavs==2) {
		UIViewController *objsd = [[[GlobalPreferences getCurrentNavigationController] viewControllers] objectAtIndex:1];
        
		if ([[objsd title] isEqualToString:@"Category"])
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"resignSearchBarFromCategory" object:nil];
		}
		else if ([[objsd title] isEqualToString:@"Products"])
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"resignSearchBarFromProducts" object:nil];
		}
	}
	else if(countNavs>2)
	{
		UIViewController *objsd = [[[GlobalPreferences getCurrentNavigationController] viewControllers] objectAtIndex:2];
		
		if ([[objsd title] isEqualToString:@"Products"])
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:@"resignSearchBarFromProducts" object:nil];
		}
	}
	
    
    
	
	
	UIView *imgBGView = (UIView *)[_objMobicartAppDelegate.mobicartView viewWithTag:668042];
	
	[imgBGView removeFromSuperview];
	
	[self removeMobicart];
	
	for(int i = 0; i < [_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews count]; i++)
	{
		if ([[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i] isKindOfClass:[UIButton class]])
		{
			[[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i]removeFromSuperview];
		}
		if ([[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i] isKindOfClass:[UILabel class]])
		{
			[[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i]removeFromSuperview];
		}
	}
	
	NSArray *arrDatabaseCart = [[SqlQuery shared]getShoppingCartProductIDs:NO];
	
	int selectedQuantity = 0;
	
	if ([arrDatabaseCart count]>0)
	{
		selectedQuantity=[[[arrDatabaseCart objectAtIndex:0]valueForKey:@"quantity"]intValue];
	}
    
	if (selectedQuantity>0 && isPostReviews==NO)
	{ 		//[self performSelectorInBackground:@selector(showLoadingbar) withObject:nil];
    }
    
	[arrDatabaseCart release];
	
	ShoppingCartViewController *objShopping = [[ShoppingCartViewController alloc] init];
    
    
    
	[[GlobalPreferences getCurrentNavigationController] pushViewController:objShopping animated:YES];
    
    
	[objShopping release];
}

- (void)addCartButtonAndLabel
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    //Adding Shopping Cart on the Navigation Bar
	
    for(int i = 0; i < [_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews count]; i++)
	{
		if ([[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i] isKindOfClass:[UIButton class]])
		{
			[[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i]removeFromSuperview];
		}
		
		if ([[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i] isKindOfClass:[UILabel class]])
		{
			[[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i]removeFromSuperview];
		}
	}
	
	MobiCartStart *as=[[MobiCartStart alloc]init];
	
    //if(controllersCount>5)
    {
        btnCartOnNavBar = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btnCartOnNavBar.frame = CGRectMake(237, 5, 78, 34);
        
        [btnCartOnNavBar setBackgroundColor:[UIColor clearColor]];
        
        [btnCartOnNavBar setImage:[UIImage imageNamed:@"add_cart.png"] forState:UIControlStateNormal];
        
        [_objMobicartAppDelegate.tabController.moreNavigationController.navigationBar addSubview:btnCartOnNavBar];
        
        [btnCartOnNavBar addTarget:as action:@selector(btnShoppingCart_Clicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_objMobicartAppDelegate.tabController.moreNavigationController.view addSubview:btnCartOnNavBar];
        
        
        lblCart = [[UILabel alloc] initWithFrame:CGRectMake(280, 5, 30, 34)];
        
        lblCart.backgroundColor = [UIColor clearColor];
        
        lblCart.textAlignment = UITextAlignmentCenter;
        
        lblCart.font = [UIFont boldSystemFontOfSize:16];
        
        lblCart.text = [NSString stringWithFormat:@"%d",iNumOfItemsInShoppingCart];
        
        lblCart.textColor = [UIColor whiteColor];
        
        //iOS7 Check to load Cart button on the exact location on the navigation Bar
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
        {
            btnCartOnNavBar.frame = CGRectMake(237, 25, 78, 34);
            lblCart.frame = CGRectMake(280, 25, 30, 34);
        }
        
        [_objMobicartAppDelegate.tabController.moreNavigationController.view addSubview:lblCart];
        
        [lblCart release];
        
        
    }
	
	
	[pool release];
}

#pragma mark - Tabbar Controller Delegates
// This will handle the navigations of More Section
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController1
{
	// If featured product was selected from "Home", then pop the view contorlller to root (i.e StoreViewController)
    int count=[[[GlobalPreferences getCurrentNavigationController] viewControllers]count];
	
	if (count>0)
	{
		if ([[[[GlobalPreferences getCurrentNavigationController] viewControllers]objectAtIndex:count-1] isKindOfClass:[ShoppingCartViewController class]])
		{
			[[GlobalPreferences getCurrentNavigationController]popViewControllerAnimated:YES];
		}
		else if ([[[[GlobalPreferences getCurrentNavigationController] viewControllers]objectAtIndex:count-1] isKindOfClass:[CheckoutViewController class]])
		{
			[[GlobalPreferences getCurrentNavigationController] popToViewController:[[[GlobalPreferences getCurrentNavigationController] viewControllers]objectAtIndex:count-3] animated:YES];
		}
	}
    
	[tabBarController.moreNavigationController popToRootViewControllerAnimated:YES];
    
	[tabBarController.moreNavigationController.navigationBar setTintColor:navBarColor];
	
	[tabBarController.moreNavigationController.visibleViewController.view setBackgroundColor:[UIColor clearColor]];
	
	tabBarController.moreNavigationController.navigationBar.topItem.titleView = [GlobalPreferences createLogoImage];
	
	if (tabBarController.moreNavigationController==viewController1||(controllersCount>=5&&_objMobicartAppDelegate.tabController.selectedIndex>3))
	{
        
		for(int i = 0; i < [_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews count]; i++)
		{
			if ([[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i] isKindOfClass:[UIButton class]])
			{
				[[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i]removeFromSuperview];
			}
			
			if ([[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i] isKindOfClass:[UILabel class]])
			{
				[[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i]removeFromSuperview];
			}
		}
		
		[tabBarController.moreNavigationController.view setFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0,0,320,430) chageHieght:YES]];
		
		UIView *imgBGView = (UIView *)[_objMobicartAppDelegate.mobicartView viewWithTag:668042];
		
		[imgBGView removeFromSuperview];
		
        // Add a footer view to the root table view of the moreNavigationController
		UIViewController *moreViewController = tabBarController.moreNavigationController.topViewController;
		
		MobiCartStart *as=[[MobiCartStart alloc]init];
		
        //if(!btnCartOnNavBar)
        {
            btnCartOnNavBar = [UIButton buttonWithType:UIButtonTypeCustom];
            
            btnCartOnNavBar.frame = CGRectMake(237,5, 78, 34);//25
            
            [btnCartOnNavBar setBackgroundColor:[UIColor clearColor]];
            
            [btnCartOnNavBar setImage:[UIImage imageNamed:@"add_cart.png"] forState:UIControlStateNormal];
            
            [btnCartOnNavBar addTarget:as action:@selector(btnShoppingCart_Clicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [_objMobicartAppDelegate.tabController.moreNavigationController.view addSubview:btnCartOnNavBar];
            
            
            lblCart = [[UILabel alloc] initWithFrame:CGRectMake(280, 5, 30, 34)];//25
            
            lblCart.backgroundColor = [UIColor clearColor];
            
            lblCart.textAlignment = UITextAlignmentCenter;
            
            lblCart.font = [UIFont boldSystemFontOfSize:16];
            
            lblCart.text = [NSString stringWithFormat:@"%d", iNumOfItemsInShoppingCart];
            
            lblCart.textColor = [UIColor whiteColor];
            
            //iOS 7 check to add Cart button on exact location on Navigation Bar
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            {
                btnCartOnNavBar.frame = CGRectMake(237, 25, 78, 34);
                lblCart.frame = CGRectMake(280, 25, 30, 34);
            }
            
            [_objMobicartAppDelegate.tabController.moreNavigationController.view addSubview:lblCart];
            
            [lblCart release];
        }
		
        
		[self showLoadingbar];
		
		UITableView *moreTableView = (UITableView*)moreViewController.view;
        
        UIView *viewBackground=[[UIView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0, 0, 320, 680) chageHieght:YES]];
        
		viewBackground.backgroundColor=[UIColor darkGrayColor];
        
		UIColor *tempColor = [UIColor colorWithRed:248.0/256 green:248.0/256 blue:248.0/256 alpha:1];
        
		UIColor *tempColor1 = [UIColor colorWithRed:203.0/256 green:203.0/256 blue:203.0/256 alpha:1];
        
		[GlobalPreferences setGradientEffectOnView:viewBackground :tempColor :tempColor1];
        
		[moreTableView setBackgroundView:viewBackground];
        
        [self fetchData];
        
        
        MoreTableViewDataSource *moreTableViewDataSource = [[MoreTableViewDataSource alloc] initWithDataSource:moreTableView.dataSource];
        
		moreTableView.dataSource = moreTableViewDataSource;
		
		MoreTableViewDelegate *objMoreDelegate=[[MoreTableViewDelegate alloc]initWithDelegate:moreTableView.delegate];
        
		if (!hideMobicartCopyrightLogo)
        {
            objMoreDelegate.isPoweredByMobicart=YES;
        }
		else
        {
            objMoreDelegate.isPoweredByMobicart=NO;
        }
        
		[moreTableView setSeparatorColor:[UIColor clearColor]];
		
		moreTableView.delegate=objMoreDelegate;
		
		if ([_objMobicartAppDelegate.arrAllData count]>0)
		{
			if (!hideMobicartCopyrightLogo)
			{
				[moreTableView setScrollEnabled:FALSE];
				
				[self poweredMobicart];
				
				[GlobalPreferences setMoreNavigationConroller_Footer:YES];
			}
		}
		
		if (([GlobalPreferences canPopToRootViewController]) && ([viewController1 isKindOfClass:[UINavigationController class]]))
		{
			[[GlobalPreferences getCurrentNavigationController] popToRootViewControllerAnimated:YES];
			
			[GlobalPreferences setIsClickedOnFeaturedImage:NO];
			
			[GlobalPreferences setCanPopToRootViewController:NO];
		}
		
		[self hideLoadingbar];
	}
	else
	{
        
		UIView *imgBGView = (UIView *)[_objMobicartAppDelegate.mobicartView viewWithTag:668042];
		
		[imgBGView removeFromSuperview];
		
		[self removeMobicart];
	}
    
    if (!hideMobicartCopyrightLogo)
    {
        if(controllersCount==4 && tabBarController.selectedIndex>2)
        {
            [self showLoadingbar];
            self.imgFooter=[ServerAPI fetchFooterLogo];
            [self poweredMobicart];
            [self hideLoadingbar];
        }
        
    }
    
	if (tabBarController.selectedIndex==0)
	{
		[[GlobalPreferences getCurrentNavigationController] popToRootViewControllerAnimated:YES];
	}
    
    // Setting current navigation Controller, so Cart button can perform corresponding selector
	if ([viewController1 isKindOfClass:[UINavigationController class]])
    {
        [GlobalPreferences setCurrentNavigationController:(UINavigationController *)viewController1];
    }
}

// Showing Mobi-Cart Branding on More Tab
- (void)poweredMobicart
{
	if (!hideMobicartCopyrightLogo)
    {
        UIView *imgBGView;
        if([GlobalPreferences isScreen_iPhone5])
        {
            imgBGView = [[UIView alloc] initWithFrame: CGRectMake(0, 439, 320, 60)];
        }
        else
        {
            // iOS 7 check on the PowerbyMobicart button 
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
            {
                imgBGView= [[UIView alloc] initWithFrame: CGRectMake(0, 369, 320, 60)];
            }
            else
            {
                imgBGView= [[UIView alloc] initWithFrame: CGRectMake(0, 352, 320, 60)];
            }
            
        }
		[imgBGView setBackgroundColor:[UIColor blackColor]];
        
		[imgBGView setTag:668042];
        
        UIButton *btnMobicart = [UIButton buttonWithType:UIButtonTypeCustom];
        
		btnMobicart.frame = CGRectMake(0,0,320,60);
        
		[btnMobicart setBackgroundColor:[UIColor clearColor]];
        
        [btnMobicart setImage:self.imgFooter forState:UIControlStateNormal];
        
		//[btnMobicart setImage:[UIImage imageNamed:@"footer_logo.png"] forState:UIControlStateNormal];
        
		[btnMobicart addTarget:self action:@selector(mobiLogoClicked) forControlEvents:UIControlEventTouchUpInside];
        
		[imgBGView addSubview:btnMobicart];
        
		
        CGContextRef context = UIGraphicsGetCurrentContext();
        
		CATransition *animation = [CATransition animation];
        
		[animation setDelegate:self];
        
		[animation setType: kCATransitionMoveIn];
        
		[animation setSubtype:kCATransitionFromTop];
        
		[animation setDuration:1.0f];
        
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        
		[UIView beginAnimations:nil context:context];
        
		[[imgBGView layer] addAnimation:animation forKey:kCATransition];
        
        
		[_objMobicartAppDelegate.mobicartView addSubview:imgBGView];
        
		[_objMobicartAppDelegate.mobicartView bringSubviewToFront:imgBGView];
        
		[imgBGView release];
        
        [UIView commitAnimations];
	}
}

// Hiding Mobi-cart Branding on More Tab while navigating throgh static pages
- (void)removeMobicart
{
	UIView *imgBGView = (UIView *)[_objMobicartAppDelegate.mobicartView viewWithTag:668042];
	
	[imgBGView removeFromSuperview];
}

// Clicking on Powered By Mobicart on More Tab
- (void)mobiLogoClicked
{
	UIView *imgBGView = (UIView *)[_objMobicartAppDelegate.mobicartView viewWithTag:668042];
    
	[imgBGView removeFromSuperview];
	if (objMobiWebView)
	{
		[objMobiWebView release];
	}
    
	objMobiWebView = [[MobiCartWebView alloc]init];
    
	[[GlobalPreferences getCurrentNavigationController] pushViewController:objMobiWebView animated:YES];
}

#pragma mark -
#pragma mark Memory management
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}



@end
