//
//  HomeViewController.m
//  MobiCart
//
//  Created by Mobicart on 7/6/10.
//  Copyright 2010 Mobicart. All rights reserved.
//

/** The View Controller for Mobicart HomeScreen **/

#import "HomeViewController.h"
#import "Constants.h"
#import "ProductModel.h"

BOOL isSortShown;
BOOL isPromotionalItem;

@implementation HomeViewController
@synthesize arrAppRecordsAllEntries;
@synthesize imageDownloadsInProgress, arrTemp, dictFeaturedProducts;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		// Custom initialization
		self.tabBarItem.image = [UIImage imageNamed:@"home_icon.png"];
	}
	return self;
}

#pragma mark View Controller Delegates

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	DDLogVerbose(@"LOAD OF HOME VIEW CONtROLLER STARTED");
	self.navigationItem.titleView = [GlobalPreferences createLogoImage];

	[self allocateMemoryToObjects];

	// Adding Loading bar at bottom
	[GlobalPreferences addLoadingBar_AtBottom:self.tabBarController.view withTextToDisplay:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.LoaderText"]];

	[self fetchSettings];

	NSInvocationOperation *operationFetchMainData = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchDataFromServer) object:nil];
	[GlobalPreferences addToOpertaionQueue:operationFetchMainData];
	[operationFetchMainData release];




	[self performSelector:@selector(createBasicControls) withObject:nil];
}

// View For ScrollView and Search Bar
- (void)createBasicControls {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	lblCart = [[UILabel alloc] initWithFrame:CGRectMake(280, 5, 30, 34)];
	lblCart.text = [NSString stringWithFormat:@"%d", iNumOfItemsInShoppingCart];
	lblCart.backgroundColor = [UIColor clearColor];
	lblCart.textAlignment = UITextAlignmentCenter;
	lblCart.font = [UIFont boldSystemFontOfSize:16];
	lblCart.textColor = [UIColor whiteColor];
	[self.navigationController.navigationBar addSubview:lblCart];

	contentView = [[UIView  alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0, 0, 320, 370) chageHieght:NO]];
	[contentView setBackgroundColor:navBarColorPreference];
	contentView.userInteractionEnabled = YES;
	self.view = contentView;
	if ([GlobalPreferences isScreen_iPhone5]) {
		horizontalScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40 + 40, 320, 235)];
	}
	else {
		horizontalScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, 320, 235)];
	}

	horizontalScrollView.tag = -11;
	//	horizontalScrollView.contentSize = CGSizeMake(320, 460);
	[horizontalScrollView setBackgroundColor:[UIColor clearColor]];
	horizontalScrollView.showsHorizontalScrollIndicator = NO;
	horizontalScrollView.showsVerticalScrollIndicator = NO;
	horizontalScrollView.maximumZoomScale = 4.0;
	horizontalScrollView.minimumZoomScale = 1.0;
	horizontalScrollView.clipsToBounds = YES;
	horizontalScrollView.delegate = self;
	horizontalScrollView.scrollEnabled = YES;
	horizontalScrollView.pagingEnabled = YES;
	[horizontalScrollView setUserInteractionEnabled:YES];
	[contentView addSubview:horizontalScrollView];



	//-----handle iPhone5 screen size------------------
	UIView *viewforscrollview = [[UIView alloc] initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0, 266, 320, 101) chageHieght:NO]];

	if (!((_savedPreferences.searchBgColor) || [_savedPreferences.searchBgColor isEqual:[NSNull null]])) {
		[GlobalPreferences setGradientEffectOnView:viewforscrollview:[UIColor colorWithRed:217.0 / 255.0 green:217.0 / 255.0 blue:217.0 / 255.0 alpha:1]:[UIColor darkGrayColor]];
	}
	else {
		[GlobalPreferences setGradientEffectOnView:viewforscrollview:[UIColor colorWithRed:217.0 / 255.0 green:217.0 / 255.0 blue:217.0 / 255.0 alpha:1]:_savedPreferences.searchBgColor];
	}


	[contentView addSubview:viewforscrollview];

	//------------------iPhone 5 screen handlle
	bottomHorizontalView = [[UIScrollView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0, 266, 320, 101) chageHieght:NO]];  bottomHorizontalView.backgroundColor = [UIColor clearColor];

	[bottomHorizontalView setContentSize:CGSizeMake(320, 70)];
	[bottomHorizontalView setShowsHorizontalScrollIndicator:NO];
	[contentView addSubview:bottomHorizontalView];
	[viewforscrollview release];

	//_searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(11,0,309,44)];
	_searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];

	[GlobalPreferences setSearchBarDefaultSettings:_searchBar];
	[_searchBar setDelegate:self];
	[contentView addSubview:_searchBar];

	UIView *viewRemoveLine = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
	[viewRemoveLine setBackgroundColor:self.navigationController.navigationBar.tintColor];
	[self.navigationController.navigationBar addSubview:viewRemoveLine];
	[self.navigationController.navigationBar bringSubviewToFront:viewRemoveLine];
	[viewRemoveLine release];

	//iPhone 5 screem size handlle

	if ([GlobalPreferences isScreen_iPhone5])
		backgroundImg = [[CustomImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 235 + 40)];
	else
		backgroundImg = [[CustomImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 235)];
	backgroundImg.backgroundColor = [UIColor clearColor];
	[horizontalScrollView addSubview:backgroundImg];

	[pool release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
		self.automaticallyAdjustsScrollViewInsets = NO;
	}


	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignSearchBar) name:@"resignSearchBarFromHome" object:nil];

	// Setting the current navigation controller in Global preferences
	[NSThread detachNewThreadSelector:@selector(setCurrentNavigationController:) toTarget:[GlobalPreferences class] withObject:self.navigationController];

	//    [GlobalPreferences performSelector:@selector(setCurrentNavigationController:) withObject:self.navigationController];

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isDataInShoppingCartQueue"] == TRUE) {
		// Fetch Shopping Cart Queue from local DB,  (and send it to the server, If internet is available now)
		NSInvocationOperation *operationFetchShoppingCartQueue = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchQueue_ShoppingCart) object:nil];

		[GlobalPreferences addToOpertaionQueue:operationFetchShoppingCartQueue];

		[operationFetchShoppingCartQueue release];
	}

	DLog(@"End of load home");
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];


	if ([GlobalPreferences getPersonLoginStatus]) {
		[GlobalPreferences setPersonLoginStatus:NO];
		[self fetchFeaturedProducts];
	}
	lblCart.text = [NSString stringWithFormat:@"%d", iNumOfItemsInShoppingCart];
	isPromotionalItem = NO;

	// 20/11/2014 Tuyen new code fix bug 27710 - Cart icon missing after payment success
	for (UIView *view in[self.navigationController.navigationBar subviews]) {
		if ([view isKindOfClass:[UIButton class]])
			view.hidden = FALSE;
		if ([view isKindOfClass:[UILabel class]])
			view.hidden = FALSE;
	}
	// End
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
}

- (void)resignSearchBar {
	[_searchBar resignFirstResponder];
}

- (void)dealloc {
	for (int i = 0; i < 15; i++) {
		[btnBlue[i] release];
		btnBlue[i] = nil;
		[lblPrice[i] release];
		lblPrice[i] = nil;
	}

	[arrBanners release];
	arrBanners = nil;

	[clothImg release];
	clothImg = nil;

	[backgroundImg release];
	backgroundImg = nil;

	[bottomHorizontalView release];
	bottomHorizontalView = nil;

	[contentView release];
	contentView = nil;

	if (_searchBar) {
		[_searchBar release];
	}

	if (lblCart) {
		[lblCart release];
	}

	if (arrAllData) {
		[arrAllData release];
	}


	[super dealloc];
}

#pragma mark Fetchers
/** Multithreaded Selectors to fetch data from server **/
- (void)fetchDataFromServer {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread detachNewThreadSelector:@selector(fetchFeaturedProducts) toTarget:self withObject:nil];

	/*
	   no need of another new thread..already on secodary thread
	 */
	[self fetchBannerImages];
	[pool release];
}

- (void)fetchBannerImages {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (dictBanners)
		dictBanners = nil;
	//store dict gallery images in the dict
	dictBanners = [GlobalPreferences getDictGalleryImages]; //delegate.dictGalleryImages;//[ServerAPI fetchBannerProducts];
	[dictBanners retain];

	[self performSelectorOnMainThread:@selector(updateControls) withObject:nil waitUntilDone:NO];
	[pool release];
}

// Handling Featured Products Details
- (void)fetchFeaturedProducts {
	NSAutoreleasePool *pooll = [[NSAutoreleasePool alloc]init];
	int countryID = 0, stateID = 0;

	NSDictionary *dictSettingsDetails = nil;
	dictSettingsDetails = [[GlobalPreferences getSettingsOfUserAndOtherDetails]retain];

	NSMutableArray *arrInfoAccount = nil;
	arrInfoAccount = [[SqlQuery shared] getAccountData:[GlobalPreferences getUserDefault_Preferences:@"userEmail"]];

	if ([arrInfoAccount count] > 0) {
		stateID = [[[NSUserDefaults standardUserDefaults] valueForKey:@"stateID"]intValue];
		countryID = [[[NSUserDefaults standardUserDefaults] valueForKey:@"countryID"]intValue];
	}
	else {
		countryID = [[dictSettingsDetails valueForKey:@"territoryId"]intValue];
		NSArray *arrtaxCountries = [dictSettingsDetails valueForKey:@"taxList"];

		for (int index = 0; index < [arrtaxCountries count]; index++) {
			if ([[[arrtaxCountries objectAtIndex:index]valueForKey:@"sState"]isEqualToString:@"Other"] && [[[arrtaxCountries objectAtIndex:index]valueForKey:@"territoryId"]intValue] == countryID) {
				stateID = [[[arrtaxCountries objectAtIndex:index]valueForKey:@"id"]intValue];
				break;
			}
		}
	}



	// Fetching Featured Products Details From Mobi-cart Server
	dictFeaturedProducts = [ServerAPI fetchFeaturedproducts:countryID:stateID:iCurrentAppId];

	[self performSelector:@selector(createDynamicControls)];

	//	[pool release];

	if (!dictFeaturedProducts) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		CATransition *animation = [CATransition animation];
		[animation setDelegate:self];
		[animation setType:kCATransitionPush];
		[animation setSubtype:kCATransitionFromLeft];
		[animation setDuration:1.0f];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		[UIView beginAnimations:nil context:context];
		[[bottomHorizontalView layer] addAnimation:animation forKey:kCATransition];

		[UIView commitAnimations];
	}
	// DLog(@"End of dynamic control");
	[dictSettingsDetails release];
	[pooll release];
}

//  Set the user settings into the global preferences (like tax type, tax charges for user's country etc)
- (void)fetchSettings {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *dicTemp = nil;
	// Fetching Featured Products Details From Mobi-cart Server
	dicTemp = [GlobalPreferences getDictSettings]; //delegate.dictSettings;//[ServerAPI fetchSettings];
	[GlobalPreferences setSettingsOfUserAndOtherDetails:dicTemp];
	[pool release];
}

#pragma mark show Gallery images

- (void)updateControls {
	int i;
	float currSysVer = [[[UIDevice currentDevice] systemVersion] floatValue];
	NSString *string = nil;

	if ([dictBanners count] > 0) {
		NSArray *galleryImageCollection = (NSArray *)dictBanners;
		if (backgroundImg && !isUpdateControlsCalled) {
			int posX = 0;
			int posY = 0;
			for (i = 0; i < [galleryImageCollection count]; i++) {
				NSDictionary *dictTemp = [galleryImageCollection objectAtIndex:i];

				if (currSysVer > 4)
					string = [dictTemp objectForKey:@"galleryImageIphone4"];
				else
					string = [dictTemp objectForKey:@"galleryImageIphone"];


				//check in
				CGRect rect = CGRectMake(posX, posY, 320, 235);

				//imageView for fullscreen image
				NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ServerAPI getImageUrl], string]];
				CustomImageView *customView = [[CustomImageView alloc]initWithUrl:url frame:CGRectMake(0, posY, 320, 235) isFrom:0];
				customView.isFromGallery = YES;

				//scrollView for holding image
				scroll = [[ContentScrollview alloc] initWithFrame:rect];
				[scroll addImageView:customView];

				//add imageView to the scrollView
				[scroll addSubview:customView];

				//add scrollView to the main-scrollView
				[horizontalScrollView addSubview:scroll];

				[scroll release];
				[customView release];
				posX += 320;
			}
			horizontalScrollView.contentSize = CGSizeMake([galleryImageCollection count] * 320, 235);
		}
	}
}

#pragma mark allocate Memory To Objects
- (void)allocateMemoryToObjects {
	if (!arrAllData) {
		arrAllData = [[NSArray alloc] init];
	}

	if (!dictFeaturedProducts) {
		dictFeaturedProducts = [[NSDictionary alloc]init];
	}

	if (!dictBanners) {
		dictBanners = [[NSDictionary alloc]init];
	}

	if (!arrBanners) {
		arrBanners = [[NSMutableArray alloc] init];
	}

	self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
}

- (void)updateDataForCurrent_Navigation_And_View_Controller {
	lblCart.text = [NSString stringWithFormat:@"%d", iNumOfItemsInShoppingCart];
}

// View For Featured Products
- (void)createDynamicControls {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	if (dictFeaturedProducts) {
		if (!self.arrAppRecordsAllEntries) {
			self.arrAppRecordsAllEntries = [[NSMutableArray alloc] init];
		}

		arrAllData = [dictFeaturedProducts objectForKey:@"featured-products"];
		[arrAllData retain];

		if ((![arrAllData isEqual:[NSNull null]]) && (arrAllData != nil)) {
			//UIImageView *img[[arrAllData count]];
			int newFeturedCount = [arrAllData count];

			if (newFeturedCount > 7) {
				newFeturedCount = 7;
			}
			CustomImageView *img[newFeturedCount];


			UIView *imgBgPrice[newFeturedCount];
			UILabel *lblPriceTax[newFeturedCount];
			int x = 8;

			for (int i = 0; i < newFeturedCount; i++) {
				btnBlue[i] = [UIButton buttonWithType:UIButtonTypeCustom];
				btnBlue[i].frame = CGRectMake(x, 6, 89, 89);
				[[btnBlue[i] layer] setCornerRadius:5];
				[btnBlue[i] setBackgroundImage:[UIImage imageNamed:@"place_holder.png"] forState:UIControlStateNormal];
				[btnBlue[i] setTag:i + 1];
				btnBlue[i].showsTouchWhenHighlighted = TRUE;
				[btnBlue[i] addTarget:self action:@selector(imageDetails:) forControlEvents:UIControlEventTouchUpInside];

				NSDictionary *dictTemp = [arrAllData objectAtIndex:i];
				NSString *strImageUrl;
				NSData *dataBannerImage;

				//img[i]=[[CustomImageView alloc]initWithFrame:CGRectMake(12, 9, 60, 65)];

				if ([[dictTemp objectForKey:@"productImages"] count] > 0) {
					strImageUrl = [[[dictTemp objectForKey:@"productImages"] objectAtIndex:0] objectForKey:@"productImageSmallIphone4"];
					//dataBannerImage = [ServerAPI fetchBannerImage:strImageUrl];


					img[i] = [[CustomImageView alloc] initWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [ServerAPI getImageUrl], strImageUrl]] frame:CGRectMake(12, 9, 60, 65) isFrom:0];
					[img[i] setClipsToBounds:YES];
					[btnBlue[i] addSubview:img[i]];
					[img[i] release];
				}
				else {
					dataBannerImage = nil;
				}

				[bottomHorizontalView addSubview:btnBlue[i]];
				imgBgPrice[i] = [[UIView alloc]initWithFrame:CGRectMake(x + 20, 11, 58, 30)];
				[bottomHorizontalView addSubview:imgBgPrice[i]];


				if ([_savedPreferences.strPriceBackground isEqualToString:@"null"]) {
					[imgBgPrice[i] setBackgroundColor:[UIColor colorWithRed:39.0 / 255.0 green:39.0 / 255.0 blue:39.0 / 255.0 alpha:1]];
				}
				else {
					[imgBgPrice[i] setBackgroundColor:_savedPreferences.searchBgColor];
				}

				[[imgBgPrice[i] layer] setCornerRadius:5];
				[[imgBgPrice[i] layer] setBorderColor:[_savedPreferences.searchBgColor CGColor]];
				[[imgBgPrice[i] layer] setBorderWidth:1];

				[imgBgPrice[i] release];

				lblPrice[i] = [[UILabel alloc]initWithFrame:CGRectMake(x + 32, 10, 50, 22)];
				[lblPrice[i] setFont:[UIFont boldSystemFontOfSize:9]];
				[lblPrice[i] setNumberOfLines:0];
				lblPrice[i].backgroundColor = [UIColor clearColor];
				[lblPrice[i] setTextAlignment:UITextAlignmentCenter];


				if ([_savedPreferences.strCurrencySymbol isEqualToString:@"<null>"] || _savedPreferences.strCurrencySymbol == nil) {
					_savedPreferences.strCurrencySymbol = @"";
				}

				if (![[dictTemp objectForKey:@"bTaxable"]isEqual:[NSNull null]]) {
					if ([[dictTemp objectForKey:@"bTaxable"] intValue] == 1) {
						NSString *strTaxType = [[NSString stringWithFormat:@"inc. %@", [dictTemp valueForKey:@"sTaxType"]] lowercaseString];
						if ([strTaxType isEqualToString:@"inc. default"]) {
							//strTaxType=@"";
							[imgBgPrice[i] setFrame:CGRectMake(x + 22, 11, 58, 22)];
							[lblPrice[i] setFrame:CGRectMake(x + 22, 11, 58, 22)];
						}
						else {
							lblPriceTax[i] = [[UILabel alloc]initWithFrame:CGRectMake(x + 22, 24, 58, 14)];
							[lblPriceTax[i] setFont:[UIFont boldSystemFontOfSize:9]];
							lblPriceTax[i].backgroundColor = [UIColor clearColor];

							[lblPrice[i] setFrame:CGRectMake(x + 22, 11, 58, 14)];

							[imgBgPrice[i] setFrame:CGRectMake(x + 22, 11, 58, 30)];
							[lblPriceTax[i] setText:strTaxType];
							[bottomHorizontalView addSubview:lblPriceTax[i]];
							[lblPriceTax[i] setTextColor:[UIColor whiteColor]];
							[lblPriceTax[i] setTextAlignment:UITextAlignmentCenter];
							[lblPriceTax[i] release];
						}
					}
					else {
						[imgBgPrice[i] setFrame:CGRectMake(x + 22, 11, 58, 22)];
						[lblPrice[i] setFrame:CGRectMake(x + 22, 11, 58, 22)];
						[lblPrice[i] setFont:[UIFont boldSystemFontOfSize:9]];
					}
				}


				[lblPrice[i] setText:[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, [ProductModel discountedPrice:dictTemp]]];

				[lblPrice[i] setTextColor:[UIColor whiteColor]];
				[bottomHorizontalView addSubview:lblPrice[i]];
				//x+=102;
				x += 96;
			}
			[bottomHorizontalView setContentSize:CGSizeMake(x, 70)];
			[GlobalPreferences setGradientEffectOnView:bottomHorizontalView:[UIColor colorWithRed:217.0 / 255.0 green:217.0 / 255.0 blue:217.0 / 255.0 alpha:1]:_savedPreferences.searchBgColor];
			CGContextRef context = UIGraphicsGetCurrentContext();
			CATransition *animation = [CATransition animation];
			[animation setDelegate:self];
			[animation setType:kCATransitionPush];
			[animation setSubtype:kCATransitionFromLeft];
			[animation setDuration:1.0f];
			[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
			[UIView beginAnimations:nil context:context];
			[[bottomHorizontalView layer] addAnimation:animation forKey:kCATransition];
			[UIView commitAnimations];
			//DLog(@"Create dynamic");
			// Calling this method again to update aal the images recenlty fetct, if in case, this method has called already
			if (isUpdateControlsCalled) {
				[self performSelectorOnMainThread:@selector(updateControls) withObject:nil waitUntilDone:NO];
				//  [self performSelector:@selector(updateControls)];

				// [NSThread detachNewThreadSelector:@selector(updateControls) toTarget:self withObject:nil];
			}
		}
		else {
			DLog(@"No Featured Products available (Home View Controller");
		}
	}
	else {
		DLog(@"No Featured Products available (Home View Controller");
	}
	[GlobalPreferences performSelector:@selector(dismissLoadingBar_AtBottom)];
	[pool release];
}

// Show Loading Bar while Loading Data
- (void)showLoadingbar {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
	[GlobalPreferences addLoadingBar_AtBottom:self.tabBarController.view withTextToDisplay:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.LoaderText"]];
	[pool release];
}

#pragma mark - Image Thumbnail selected
// This method handles the selection of Featured Product
- (void)imageDetails:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"popViewController" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"popViewControllerRead" object:nil];


	isPromotionalItem = YES;
	int stateID = 0, countryID = 0;

	int promotionalId = [sender tag];

	NSDictionary *dictSettingsDetails = nil;
	dictSettingsDetails = [[GlobalPreferences getSettingsOfUserAndOtherDetails]retain];

	NSMutableArray *arrInfoAccount = nil;
	arrInfoAccount = [[SqlQuery shared] getAccountData:[GlobalPreferences getUserDefault_Preferences:@"userEmail"]];

	if ([arrInfoAccount count] > 0) {
		stateID = [[[NSUserDefaults standardUserDefaults] valueForKey:@"stateID"]intValue];
		countryID = [[[NSUserDefaults standardUserDefaults] valueForKey:@"countryID"]intValue];
	}
	else {
		countryID = [[dictSettingsDetails valueForKey:@"territoryId"]intValue];
		NSArray *arrtaxCountries = [dictSettingsDetails valueForKey:@"taxList"];
		for (int index = 0; index < [arrtaxCountries count]; index++) {
			if ([[[arrtaxCountries objectAtIndex:index]valueForKey:@"sState"]isEqualToString:@"Other"] && [[[arrtaxCountries objectAtIndex:index]valueForKey:@"territoryId"]intValue] == countryID) {
				stateID = [[[arrtaxCountries objectAtIndex:index]valueForKey:@"id"]intValue];
				break;
			}
		}
	}

	NSString *productID;
	NSDictionary *dictTemp = [arrAllData objectAtIndex:promotionalId - 1];
	productID = [dictTemp valueForKey:@"id"];



	/* NSDictionary *dictDataForCurrentProduct;

	   if (![[dictTemp objectForKey:@"categoryId"]isKindOfClass:[NSNull class]])
	   {
	   if ([[dictTemp objectForKey:@"categoryId"] intValue]>0)
	   {
	   dictDataForCurrentProduct =  [ServerAPI fetchProductsWithCategories:[[dictTemp objectForKey:@"departmentId"] intValue]:[[dictTemp objectForKey:@"categoryId"] intValue]:countryID:stateID:iCurrentStoreId];
	   }
	   else
	   {
	   dictDataForCurrentProduct = [ServerAPI fetchProductsWithoutCategories:[[dictTemp objectForKey:@"departmentId"] intValue]:countryID:stateID:iCurrentStoreId];
	   }
	   }
	   else
	   {
	   dictDataForCurrentProduct=[ServerAPI fetchProductsWithoutCategories:[[dictTemp objectForKey:@"departmentId"] intValue]:countryID:stateID:iCurrentStoreId];
	   }

	   // Setting the bool variable, so the app can directly jump to the selected product detail
	   [GlobalPreferences setIsClickedOnFeaturedImage:YES];

	   NSArray *arrProducts=[dictDataForCurrentProduct objectForKey:@"products"];
	   int productIndex=0;
	   if ([[arrProducts valueForKey:@"id"] containsObject:productID])
	   {
	   productIndex=[[arrProducts valueForKey:@"id"]indexOfObject:productID];
	   }

	   // Set the bool value YES, to pop a controller to rool view controller, (In case, when featured product has been clicked, and when clicked on STORE tab, all elements can be popped out)

	   [GlobalPreferences setCurrentFeaturedProductDetails:[[dictDataForCurrentProduct objectForKey:@"products"] objectAtIndex:productIndex]];

	   NSInteger iCurrentDeptID = [[[[dictDataForCurrentProduct objectForKey:@"products"] objectAtIndex:0] objectForKey:@"departmentId"] intValue];

	   [GlobalPreferences setCurrentDepartmentId:iCurrentDeptID];
	   [GlobalPreferences setCanPopToRootViewController: YES];
	 */

	// Setting the bool variable, so the app can directly jump to the selected product detail
	[GlobalPreferences setIsClickedOnFeaturedImage:YES];
	[NSThread detachNewThreadSelector:@selector(sendDataForAnalytics:) toTarget:self withObject:productID];

	[GlobalPreferences setCurrentProductDetails:dictTemp];

	ProductDetailsViewController *objProductDetails = [[ProductDetailsViewController alloc]init];

	// Passing product details to ProductDetailsViewController
	objProductDetails.isWishlist = NO;

	objProductDetails.dicProduct = dictTemp;
	self.navigationItem.title = [[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.tabbar.store"];
	[self.navigationController pushViewController:objProductDetails animated:YES];
	[objProductDetails release];



	[dictSettingsDetails release];
}

#pragma mark - Product Analytics
- (void)sendDataForAnalytics:(NSString *)sProductId {
	if ((![sProductId isEqual:[NSNull null]]) || (![sProductId isEqualToString:@""])) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		[ServerAPI fetchProductAnalytics:sProductId];
		[pool release];
	}
}

#pragma mark Search Bar Delegates

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = YES;
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = NO;
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];

	GlobalSearchViewController *_globalSearch = [[GlobalSearchViewController alloc] initWithProductName:searchBar.text];
	[self.navigationController pushViewController:_globalSearch animated:YES];
	[_globalSearch release];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	// Only show the status bar‚Äôs cancel button while in edit mode
	searchBar.showsCancelButton = YES;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	searchBar.showsCancelButton = NO;
}

// Called when Search Cancel Button Tapped
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	// If a valid search was entered but the user wanted to cancel, bring back the main list content
	searchBar.showsCancelButton = NO;
	[searchBar resignFirstResponder];
	searchBar.text = @"";
}

#pragma mark fetch Shopping Cart Queue

// Fetch Shopping cart details. These are saved in case Internet is unavailable, once payment has been made succesfully, but before placing/sending the order to the server
- (void)fetchQueue_ShoppingCart {
	NSArray *arrShoppingCart_Queue = [[SqlQuery shared] getShoppingCartQueue];
	if ((arrShoppingCart_Queue) && ([GlobalPreferences isInternetAvailable])) {
		if ([arrShoppingCart_Queue count] > 0) {
			[self performSelector:@selector(sendDataToServer:) withObject:[arrShoppingCart_Queue objectAtIndex:0]];
		}
	}
}

#pragma mark Send Data To Server

// The data for placing/sending the order to Server, if Internet was Unavailable
- (void)sendDataToServer2:(NSDictionary *)dictShoppingCartQueueData {
	NSString *strDataToPost = [dictShoppingCartQueueData objectForKey:@"sDataToSend"];
	NSString *reponseRecieved = [ServerAPI SQLServerAPI:[dictShoppingCartQueueData objectForKey:@"sUrl"]:strDataToPost];

	// Now send data to the server for this recently made order
	if ([reponseRecieved isKindOfClass:[NSString class]]) {
		int iCurrentOrderId = [[[[[reponseRecieved componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@"}"] objectAtIndex:0] intValue];

		NSArray *arrIndividualProducts = [[SqlQuery shared] getIndividualProducts_Queue:0];
		for (int i = 0; i < [arrIndividualProducts count]; i++) {
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDataInShoppingCartQueue"];

			if ([GlobalPreferences isInternetAvailable]) {
				// Delete sold item from the cart
				[[SqlQuery shared] deleteItemFromIndividualQueue:[[[arrIndividualProducts objectAtIndex:i] objectForKey:@"iProductId"] intValue]];

				if (([arrIndividualProducts count] - 1) == i) {
					[[SqlQuery shared] deleteItemFromShoppingQueue:1];
					[[SqlQuery shared] emptyShoppingCart];
					lblCart.text = @"0";
					iNumOfItemsInShoppingCart = 0;
					[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDataInIndividualProductsQueue"];
				}
			}

			if (iCurrentOrderId > 0) {
				[ServerAPI product_order_NotifyURLSend:@"Sending Order Number Last Time":iCurrentOrderId];
			}
			else {
				DLog(@"INTERNET IS UNAVAILABLE, KEEPING DATA IN THE LOCAL DATABASE");
				[[SqlQuery shared] updateIndividualProducts_Queue:iCurrentOrderId:[[[arrIndividualProducts objectAtIndex:i] objectForKey:@"iProductId"] intValue]];
				[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDataInIndividualProductsQueue"];
			}
		}
	}

	else {
		DLog(@"Error While sending billing details to server (CheckoutViewController)");
	}
}

// 15/01/2015 Tuyen new code send order data to server
- (void)sendDataToServer:(NSDictionary *)dictShoppingCartQueueData {
    NSString *strDataToPost = [dictShoppingCartQueueData objectForKey:@"sDataToSend"];
    NSString *reponseRecieved = [ServerAPI SQLServerAPI:[dictShoppingCartQueueData objectForKey:@"sUrl"]:strDataToPost];
    
    // Now send data to the server for this recently made order
    if ([reponseRecieved isKindOfClass:[NSString class]]) {
        int iCurrentOrderId = [[[[[reponseRecieved componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@"}"] objectAtIndex:0] intValue];
        if (iCurrentOrderId > 0) {
            [[SqlQuery shared] deleteItemFromShoppingQueue:1];
            [[SqlQuery shared] emptyShoppingCart];
            lblCart.text = @"0";
            iNumOfItemsInShoppingCart = 0;
            lblCart.text = [NSString stringWithFormat:@"%d", iNumOfItemsInShoppingCart];
            
            [ServerAPI product_order_NotifyURLSend:@"Sending Order Number Last Time":iCurrentOrderId];
        }
        else {
            DDLogWarn(@"Error While sending billing details to server (CheckoutViewController)");
        }
    }
}

@end
