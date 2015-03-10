//
//  GlobalPrefrences.m
//  Mobicart
//
//  Created by Mobicart on 05/03/11.
//  Copyright Mobicart. All rights reserved.
//

#import "GlobalPrefrences.h"
#import "Constants.h"

@implementation GlobalPrefrences
static GlobalPrefrences *shared;

- (id)init {
	if (shared) {
		[self autorelease];
		return shared;
	}

	if (![super init]) return nil;

	shared = self;
	return self;
}

+ (id)shared {
	if (!shared) {
		[[GlobalPrefrences alloc] init];
	}
	return shared;
}

SBJSON *_JSONParser;


+ (void)setPersonLoginStatus:(BOOL)_status {
	isLoggedInStatuschanged = _status;   //Yes, if person is logged in else no;
}

+ (BOOL)getPersonLoginStatus {
	return isLoggedInStatuschanged;
}

#pragma mark Initilize GlobalPrefrences
+ (void)initializeGlobalControllers {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	//initializing JSON handler
	if (!_JSONParser)
		_JSONParser = [[SBJSON alloc]init];

	//initializing savedPreferences object
	if (!_savedPreferences)
		_savedPreferences = [[savedPreferences alloc] init];

	if (!queue)
		queue = [[NSOperationQueue alloc] init];
	iNumOfItemsInShoppingCart =  [[[SqlQuery shared]getShoppingCartProductIDs:YES] count];
	[pool release];
}

+ (void)setGlobalPreferences {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	//fetch the number of items in the shopping cart, and then set it on the global accesors
	iNumOfItemsInShoppingCart = [[[SqlQuery shared]getShoppingCartProductIDs:YES] count];

	[pool release];
}

#pragma mark Tabbar Settings
NSMutableArray *arrSelectedTabs;
NSMutableArray *arrSelectedTitles;

+ (void)setBackgroundTheme_OnView:(UIView *)setInView {
	UIImageView *bookBackGround = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1024, 719)];
	[bookBackGround setImage:[UIImage imageNamed:@"book.png"]];
	bookBackGround.backgroundColor = backGroundColor;
	[setInView addSubview:bookBackGround];
}

+ (void)setTabbarControllers_SelectedByUser:(NSDictionary *)dictFeatures {
	if (!arrSelectedTabs) {
		arrSelectedTabs = [[NSMutableArray alloc] init];
	}
	if (!arrSelectedTitles) {
		arrSelectedTitles = [[NSMutableArray alloc] init];
	}
	NSArray *arrTemp  = [dictFeatures objectForKey:@"features"];
	for (NSDictionary *dictData in arrTemp) {
		[arrSelectedTabs addObject:[dictData objectForKey:@"sIphoneHandle"]];
		[arrSelectedTitles addObject:[dictData objectForKey:@"sName"]];
	}
	if ([arrSelectedTitles count] > 0)
		[GlobalPrefrences setTabbarItemTitles:arrSelectedTitles];
}

+ (void)setTabbarItemTitles:(NSArray *)arrSelected_Titles {
	_savedPreferences.strTitleHome = @"";
	_savedPreferences.strTitleStore = @"";
	_savedPreferences.strTitleNews = @"";
	_savedPreferences.strTitleMyAccount = @"";
	_savedPreferences.strTitleAboutUs = @"";
	_savedPreferences.strTitleContactUs = @"";
	_savedPreferences.strTitleFaq = @"";
	_savedPreferences.strTitleShoppingCart = @"";
	_savedPreferences.strTitleTerms_Conditions = @"";
	_savedPreferences.strTitlePrivacy = @"";
	_savedPreferences.strTitlePage1 = @"";
	_savedPreferences.strTitlePage2 = @"";


	if ([arrSelected_Titles count] > 0) {
		for (int i = 0; i < [arrSelected_Titles count]; i++) {
			if ([[arrSelected_Titles objectAtIndex:i] isEqualToString:@"Home"]) {
				_savedPreferences.strTitleHome = [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.tabbar.home"];
			}
			else if ([[arrSelected_Titles objectAtIndex:i] isEqualToString:@"Store"]) {
				_savedPreferences.strTitleStore = [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.tabbar.store"];
			}
			else if ([[arrSelected_Titles objectAtIndex:i] isEqualToString:@"News"]) {
				_savedPreferences.strTitleNews = [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.tabbar.news"];
			}
			else if ([[arrSelected_Titles objectAtIndex:i] isEqualToString:@"My Account"]) {
				_savedPreferences.strTitleMyAccount = @"My Account";
			}
			else if ([[arrSelected_Titles objectAtIndex:i] isEqualToString:@"About Us"]) {
				_savedPreferences.strTitleAboutUs = [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.more.aboutus"];
			}
			else if ([[arrSelected_Titles objectAtIndex:i] isEqualToString:@"Contact Us"]) {
				_savedPreferences.strTitleContactUs = [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.more.contactus"];
			}
			else if ([[arrSelected_Titles objectAtIndex:i] isEqualToString:@"Shopping Cart"]) {
				_savedPreferences.strTitleShoppingCart = @"Shopping Cart";
			}
			else if ([[arrSelected_Titles objectAtIndex:i] isEqualToString:@"Terms"]) {
				_savedPreferences.strTitleTerms_Conditions = [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.more.tandc"];
			}
			else if ([[arrSelected_Titles objectAtIndex:i] isEqualToString:@"Privacy"]) {
				_savedPreferences.strTitlePrivacy = [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.more.privacy"];
			}
			else if ([[arrSelected_Titles objectAtIndex:i] isEqualToString:@"Page 1"]) {
				_savedPreferences.strTitlePage1 = @"Page 1";
			}
			else if ([[arrSelected_Titles objectAtIndex:i] isEqualToString:@"Page 2"]) {
				_savedPreferences.strTitlePage2 = @"Page 2";
			}
		}
	}
}

+ (NSArray *)tabBarControllers_SelectedByUser {
	//return ordering of tabbar items, as selected by user from the server
	if ([arrSelectedTabs count] > 0)
		return arrSelectedTabs;
	return nil;
}

+ (NSArray *)getAllNavigationTitles {
	NSArray *arrAllData = [[ServerAPI fetchTabbarPreferences:iCurrentAppId]objectForKey:@"features"];

	//Set title of "Privacy View Controller"

	if (![arrAllData isKindOfClass:[NSNull class]]) {
		for (int i = 0; i < [arrAllData count]; i++) {
			NSDictionary *dictTemp = [arrAllData objectAtIndex:i];
			if ([[dictTemp objectForKey:@"sIphoneHandle"]isEqualToString:@"Page1ViewController"])
				_savedPreferences.strTitlePage1 = [dictTemp objectForKey:@"tabTitle"];

			if ([[dictTemp objectForKey:@"sIphoneHandle"]isEqualToString:@"Page2ViewController"])
				_savedPreferences.strTitlePage2 = [dictTemp objectForKey:@"tabTitle"];
		}


		//Set title of "Page 1 View Controller"


		if ([arrAllData count] > 8) {
			NSDictionary *dictTemp = [arrAllData objectAtIndex:8];
			if ((![[dictTemp objectForKey:@"sTitle"] isEqualToString:@""]) && (![[dictTemp objectForKey:@"sTitle"] isEqual:[NSNull null]])) {
				if ([[dictTemp objectForKey:@"sIphoneHandle"]isEqualToString:@"Page1ViewController"]) {
					if ((![[dictTemp objectForKey:@"tabTitle"] isEqual:[NSNull null]])) {
						if (![[dictTemp objectForKey:@"tabTitle"] isEqualToString:@""]) {
							_savedPreferences.strTitlePage1 = [dictTemp objectForKey:@"tabTitle"];
						}
						else
							_savedPreferences.strTitlePage1 = [dictTemp objectForKey:@"sName"];
					}
					else
						_savedPreferences.strTitlePage1 = [dictTemp objectForKey:@"sName"];
				}
			}
		}
		//Set title of "Page 2 View Controller"

		if ([arrAllData count] > 9) {
			NSDictionary *dictTemp = [arrAllData objectAtIndex:9];
			if ((![[dictTemp objectForKey:@"sName"] isEqualToString:@""]) && (![[dictTemp objectForKey:@"sName"] isEqual:[NSNull null]])) {
				if ([[dictTemp objectForKey:@"sIphoneHandle"]isEqualToString:@"Page2ViewController"]) {
					if (![[dictTemp objectForKey:@"tabTitle"] isEqual:[NSNull null]]) {
						if (![[dictTemp objectForKey:@"tabTitle"] isEqualToString:@""]) {
							_savedPreferences.strTitlePage2 = [dictTemp objectForKey:@"tabTitle"];
						}
						else
							_savedPreferences.strTitlePage2 = [dictTemp objectForKey:@"sName"];
					}
					else
						_savedPreferences.strTitlePage2 = [dictTemp objectForKey:@"sName"];
				}
			}
		}
	}
	return ([NSArray arrayWithObjects:_savedPreferences.strTitleHome, _savedPreferences.strTitleStore, _savedPreferences.strTitleNews, _savedPreferences.strTitleMyAccount, _savedPreferences.strTitleAboutUs, _savedPreferences.strTitleContactUs, _savedPreferences.strTitleTerms_Conditions, _savedPreferences.strTitleShoppingCart, _savedPreferences.strTitlePrivacy, _savedPreferences.strTitlePage1, _savedPreferences.strTitlePage2, nil]);
}

#pragma mark - NSOperationQueue Handler

+ (void)addToOpertaionQueue:(NSInvocationOperation *)_opertion {
	if (!queue)
		queue = [[NSOperationQueue alloc] init];

	[queue addOperation:_opertion];
}

#pragma mark - Color Schemes

// This method converts any hexadevmal string into RGB colors
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	// String should be 6 or 8 characters
	if ([cString length] < 6) return [UIColor redColor];
	// strip 0X if it appears
	if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];

	if ([cString length] != 6) return [UIColor redColor];

	// Separate into r, g, b substrings
	NSRange range;
	range.location = 0;
	range.length = 2;
	NSString *rString = [cString substringWithRange:range];

	range.location = 2;
	NSString *gString = [cString substringWithRange:range];

	range.location = 4;
	NSString *bString = [cString substringWithRange:range];

	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];

	return [UIColor colorWithRed:((float)r / 255.0f)
	                       green:((float)g / 255.0f)
	                        blue:((float)b / 255.0f)
	                       alpha:1.0f];
}

+ (void)setColorScheme_SelectedByUser:(NSDictionary *)dictFeatures {
#define colorDict [dictFeatures objectForKey:@"colorscheme"]

	if (![colorDict isEqual:[NSNull null]]) {
		if (![[colorDict objectForKey:@"theme_color"] isEqual:[NSNull null]]) {
			UIColor *bgColor = [GlobalPrefrences colorWithHexString:[[dictFeatures objectForKey:@"colorscheme"]objectForKey:@"theme_color"]];

			_savedPreferences.bgColor = bgColor;
			backGroundColor = _savedPreferences.bgColor;
		}

		if (![[colorDict objectForKey:@"sub_header_color"] isEqual:[NSNull null]]) {
			UIColor *fgColor = [GlobalPrefrences colorWithHexString:[[dictFeatures objectForKey:@"colorscheme"]objectForKey:@"sub_header_color"]];
			_savedPreferences.fgColor = fgColor;
			subHeadingColor = _savedPreferences.fgColor;
			_savedPreferences.hexcolor = [[dictFeatures objectForKey:@"colorscheme"]objectForKey:@"sub_header_color"];
			HexVAlueForsubHeadingColor = _savedPreferences.hexcolor;
		}

		if (![[colorDict objectForKey:@"header_color"] isEqual:[NSNull null]]) {
			UIColor *textColor = [GlobalPrefrences colorWithHexString:[[dictFeatures objectForKey:@"colorscheme"]objectForKey:@"header_color"]];
			_savedPreferences.textheadingColor = textColor;
			headingColor = _savedPreferences.textheadingColor;
			_savedPreferences.hexHeadingcolor = [[dictFeatures objectForKey:@"colorscheme"]objectForKey:@"header_color"];
			HexVAlueForHeadingColor = _savedPreferences.hexHeadingcolor;
		}

		if (![[colorDict objectForKey:@"label_color"] isEqual:[NSNull null]]) {
			UIColor *textColor = [GlobalPrefrences colorWithHexString:[[dictFeatures objectForKey:@"colorscheme"]objectForKey:@"label_color"]];
			_savedPreferences.txtLabelColor = textColor;
			labelColor = _savedPreferences.txtLabelColor;
			_savedPreferences.hexLabelcolor = [[dictFeatures objectForKey:@"colorscheme"]objectForKey:@"label_color"];
			HexVAlueForLabelColor = _savedPreferences.hexLabelcolor;
		}
	}
}

#pragma mark LANGUAGE PREFERENCES
NSDictionary *dictLanguageLabels;

+ (void)setLanguageLabels:(NSDictionary *)_dictTemp {
	if (!dictLanguageLabels) {
		dictLanguageLabels = [[NSDictionary alloc] init];
	}

	dictLanguageLabels = _dictTemp;
	[dictLanguageLabels retain];
}

+ (NSDictionary *)getLangaugeLabels {
	return dictLanguageLabels;
}

#pragma mark ----- Store -----

// ******** Setters ********

+ (void)setNextDepartmentId:(NSInteger)_iNextDepartmentId {
	_savedPreferences._iNextDeptId = _iNextDepartmentId;
}

+ (void)setCurrentDepartmentId:(NSInteger)_iCurrentDepartmentId {
	_savedPreferences._iCurrentDeptId = _iCurrentDepartmentId;
}

+ (void)setCurrentCategoryId:(NSInteger)_iCurrentCategoryId {
	_savedPreferences._iCurrentCategoryId = _iCurrentCategoryId;
}

+ (void)setCurrentProductId:(NSInteger)_iCurrentProductId {
	_savedPreferences._iCurrentProductId = _iCurrentProductId;
}

#pragma mark HOME
BOOL _canPopToRootViewController;
+ (BOOL)canPopToRootViewController {
	return (_canPopToRootViewController);
}

BOOL isClickedOnFeaturedImage;
+ (void)setIsClickedOnFeaturedImage:(BOOL)_isClicked {
	isClickedOnFeaturedImage = _isClicked;
}

+ (BOOL)isClickedOnFeaturedProductFromHomeTab {
	return isClickedOnFeaturedImage;
}

+ (void)setCanPopToRootViewController:(BOOL)_canPop {
	_canPopToRootViewController = _canPop;
}

//Selected for Featured product

#pragma mark -
//Set current navigation controll
UINavigationController *currentNavigationController;
+ (void)setCurrentNavigationController:(UINavigationController *)_navigationController {
	currentNavigationController = _navigationController;
}

+ (UINavigationController *)getCurrentNavigationController {
	return currentNavigationController;
}

NSDictionary *dictCurrentFeaturedProduct;

NSDictionary *dictNextFeaturedProduct;
NSDictionary *dicAppVitals;


+ (void)setAppVitalsAndCountries:(NSDictionary *)_dicVitals {
	if (!dicAppVitals) {
		dicAppVitals = [[NSDictionary alloc] init];
	}

	dicAppVitals = _dicVitals;
	[dicAppVitals retain];
}

+ (void)setCurrentFeaturedProductDetails:(NSDictionary *)_dictTemp {
	if (!dictCurrentFeaturedProduct) {
		dictCurrentFeaturedProduct = [[NSDictionary alloc] init];
	}

	dictCurrentFeaturedProduct = _dictTemp;
	[dictCurrentFeaturedProduct retain];
}

+ (void)setNextProductDetails:(NSDictionary *)_dictTemp {
	if (!dictNextFeaturedProduct) {
		dictNextFeaturedProduct = [[NSDictionary alloc] init];
	}

	dictNextFeaturedProduct = _dictTemp;
	[dictNextFeaturedProduct retain];
}

+ (void)setCurrentItemsInCart:(BOOL)added {
	if (added)
		iNumOfItemsInShoppingCart += 1;
	else {
		if (iNumOfItemsInShoppingCart > 0)
			iNumOfItemsInShoppingCart -= 1;
	}
}

+ (NSInteger)getCurrenItemsInCart {
	return iNumOfItemsInShoppingCart;
}

//Current Selected Product Details

NSDictionary *dictCurrentProduct;

+ (void)setCurrentProductDetails:(NSDictionary *)_dictTemp {
	if (!dictCurrentProduct) {
		dictCurrentProduct = [[NSDictionary alloc] init];
	}

	dictCurrentProduct = _dictTemp;
}

UILabel *lblLoading;
UIView *viewLoading;

#pragma mark - Loading Bar At Bottom
UIView *loadingView;
+ (void)addLoadingBar_AtBottom:(UIView *)showInView withTextToDisplay:(NSString *)strText {
	loadingView = showInView;

	viewLoading = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
	[viewLoading setBackgroundColor:[UIColor blackColor]];
	[viewLoading setAlpha:0.4];
	[loadingView addSubview:viewLoading];

	//Sa Vo fix bug the loading bar no longer fill tabbar on iOS 7.x

	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(0, 711, 1024, 56)];
	}
	else {
		lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(0, 720, 1024, 45)];
	}
	[lblLoading setBackgroundColor:[UIColor whiteColor]];
	[lblLoading setText:strText];
	[lblLoading setAlpha:0.7];
	lblLoading.textAlignment = UITextAlignmentCenter;
	[lblLoading setFont:[UIFont boldSystemFontOfSize:25]];
	[loadingView addSubview:lblLoading];
	[loadingView bringSubviewToFront:lblLoading];

	[[UIApplication sharedApplication]beginIgnoringInteractionEvents];
}

+ (void)addLoadingBar_AtWindow:(UIView *)showInView withTextToDisplay:(NSString *)strText {
	loadingView = showInView;
	viewLoading = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 768, 1024)];
	[viewLoading setBackgroundColor:[UIColor blackColor]];
	[viewLoading setAlpha:0.4];
	[loadingView addSubview:viewLoading];


	//Sa Vo fix bug the loading bar no longer fill tabbar on iOS 7.x
	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
		lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(0, 711, 1024, 56)];
	}
	else {
		lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(-486, 491, 1024, 44)];
	}
	[lblLoading setBackgroundColor:[UIColor whiteColor]];
	[lblLoading setText:strText];
	[lblLoading setAlpha:0.7];
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

	if (orientation == UIDeviceOrientationLandscapeLeft) {
		//Sa Vo fix bug the loading bar no longer fill tabbar on iOS 7.x
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
			lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(0, 711, 1024, 56)];
		}
		else {
			[lblLoading setFrame:CGRectMake(-486, 491, 1024, 44)];
		}
		[lblLoading setTransform:CGAffineTransformMakeRotation(3.14 / 2)];
	}

	else {
		//Sa Vo fix bug the loading bar no longer fill tabbar on iOS 7.x
		if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
			lblLoading = [[UILabel alloc] initWithFrame:CGRectMake(0, 711, 1024, 56)];
		}
		else {
			[lblLoading setFrame:CGRectMake(230, 491, 1024, 44)];
		}
		[lblLoading setTransform:CGAffineTransformMakeRotation(-3.14 / 2)];
	}
	lblLoading.textAlignment = UITextAlignmentCenter;
	[lblLoading setFont:[UIFont boldSystemFontOfSize:25]];
	[loadingView addSubview:lblLoading];
	[loadingView bringSubviewToFront:lblLoading];

	[[UIApplication sharedApplication]beginIgnoringInteractionEvents];
}

+ (void)dismissLoadingBar_AtBottom {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[viewLoading removeFromSuperview];
	[lblLoading removeFromSuperview];

	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	[loadingView setUserInteractionEnabled:YES];

	[pool release];
}

#pragma mark User Settings And Tax Details
NSDictionary *dictUserSettings;
//Set the dictionary of the setting (like Country's tax type, ta charges, user email address, currency type, shopping list details, etc)
+ (void)setSettingsOfUserAndOtherDetails:(NSDictionary *)_dictSettings {
	if (!dictUserSettings)
		dictUserSettings = [[NSDictionary alloc] init];
	dictUserSettings = _dictSettings;

	[dictUserSettings retain];

	//***********************************Merchant Email Address**************
	NSString *payPalEmailAddress = [[dictUserSettings valueForKey:@"store"] valueForKey:@"sPaypalEmail"];
	if (![payPalEmailAddress isKindOfClass:[NSNull class]])
		[GlobalPrefrences setPaypalRecipientEmail:payPalEmailAddress];

	//***********************************PayPal Token*******************
	NSString *payPalToken = [[dictUserSettings valueForKey:@"store"] valueForKey:@"iphonePaypalToken"];
	if (![payPalToken isKindOfClass:[NSNull class]])
		[GlobalPrefrences setPaypalLiveToken:payPalToken];

	//18/09/2014 Sa VoSa Vo insert 2 keys for Paypal: Client ID and Scerect Id
	//**************************PayPal ClientId***************************
	NSString *payPalClientId = [[dictUserSettings valueForKey:@"store"] valueForKey:@"sIphonePaypalClientId"];
	if (![payPalClientId isKindOfClass:[NSNull class]])
		[GlobalPrefrences setPayPalClientId:payPalClientId];

	//**************************PayPal Secret Key***************************
	NSString *payPalSecretKey = [[dictUserSettings valueForKey:@"store"] valueForKey:@"sIphonePaypalSecretKey"];
	if (![payPalSecretKey isKindOfClass:[NSNull class]])
		[GlobalPrefrences setPaypalSecretKey:payPalSecretKey];



	//********************************PalPal Live Mode****************
	NSString *isPayPallive = [[dictUserSettings valueForKey:@"store"] valueForKey:@"sPayPalLive"];
	if (![isPayPallive isKindOfClass:[NSNull class]])
		[GlobalPrefrences setPaypalModeIsLive:isPayPallive];
	//**************************PayPal Mode enable***************************
	NSString *payPalModeEnable = [[dictUserSettings valueForKey:@"store"] valueForKey:@"paypalUsed"];
	if (![payPalModeEnable isKindOfClass:[NSNull class]])
		[GlobalPrefrences setPaypalModeEnable:payPalModeEnable];

	//********************************Zooz Mode enable****************
	NSString *zoozModeEnable = [[dictUserSettings valueForKey:@"store"] valueForKey:@"zoozUsed"];
	if (![zoozModeEnable isKindOfClass:[NSNull class]])
		[GlobalPrefrences setZoozModeEnable:zoozModeEnable];


	//***********************************iPad ZooZ Token**********
	NSString *iPhoneAppKey = [[dictUserSettings valueForKey:@"store"] valueForKey:@"iPadAppKey"];
	if (![iPhoneAppKey isKindOfClass:[NSNull class]])
		[GlobalPrefrences setZoozToken:iPhoneAppKey];

	//************************************ZooZ Live Mode*************
	NSString *isZoozModeToken = [[dictUserSettings valueForKey:@"store"] valueForKey:@"zoozLive"];
	if (![isZoozModeToken isKindOfClass:[NSNull class]])
		[GlobalPrefrences setZooZModeIsLive:isZoozModeToken];

	//************************************2c2p Mode***************
	NSString *_2c2pModeEnable = [[dictUserSettings valueForKey:@"store"] valueForKey:@"p2c2pUsed"];
	if (![_2c2pModeEnable isKindOfClass:[NSNull class]])
		[GlobalPrefrences set2c2pModeEnable:_2c2pModeEnable];

	NSString *_2c2pMerchantId = [[dictUserSettings valueForKey:@"store"] valueForKey:@"p2c2pMerchantId"];
	if (![_2c2pMerchantId isKindOfClass:[NSNull class]])
		[GlobalPrefrences set2c2pMerchantId:_2c2pMerchantId];

	NSString *_2c2pSecrectKey = [[dictUserSettings valueForKey:@"store"] valueForKey:@"p2c2pSecrectKey"];
	if (![_2c2pSecrectKey isKindOfClass:[NSNull class]]) {
		[GlobalPrefrences set2c2pSecrectKey:_2c2pSecrectKey];
	}

    // 13/01/2015 Tuyen close code fix bug crash when pay with 2c2p
//	NSString *_2c2pCurrencyNumber = [[dictUserSettings valueForKey:@"store"] valueForKey:@"p2c2pcurrencyNumber"];
    //
    
    // 13/01/2015 Tuyen new code fix bug crash when pay with 2c2p - value for key @"p2c2pcurrencyNumber" is NSDecimalNumber not String
    NSString *_2c2pCurrencyNumber = [[[dictUserSettings valueForKey:@"store"] valueForKey:@"p2c2pcurrencyNumber"] stringValue];
    //
	if (![_2c2pCurrencyNumber isKindOfClass:[NSNull class]]) {
		[GlobalPrefrences set2c2pCurrencyNumber:_2c2pCurrencyNumber];
	}

	//************************************iPay88 Mode***************
	NSString *iPay88ModeEnable = [[dictUserSettings valueForKey:@"store"] valueForKey:@"ipay88Used"];
	if (![iPay88ModeEnable isKindOfClass:[NSNull class]])
		[GlobalPrefrences setiPay88ModeEnable:iPay88ModeEnable];

	NSString *iPay88MerchatKey = [[dictUserSettings valueForKey:@"store"] valueForKey:@"ipay88MerchantKey"];
	if (![iPay88LiveToken isKindOfClass:[NSNull class]]) {
		[GlobalPrefrences setiPay88MerchantKey:iPay88MerchatKey];
	}

	NSString *iPay88MerchantCode = [[dictUserSettings valueForKey:@"store"] valueForKey:@"ipay88MerchantCode"];
	if (![iPay88MerchantCode isKindOfClass:[NSNull class]]) {
		[GlobalPrefrences setiPay88MerchantCode:iPay88MerchantCode];
	}

	//************************************Stripe Key**********************
	// 4/11/2014 Tuyen Stripe key
	NSString *stripePublishableKey = [[dictUserSettings valueForKey:@"store"] valueForKey:@"sStripePublishableKey"];
	if (![stripePublishableKey isKindOfClass:[NSNull class]])
		[GlobalPrefrences setStripePublishableKey:stripePublishableKey];

	NSString *stripeSecretKey = [[dictUserSettings valueForKey:@"store"] valueForKey:@"sStripeSecretKey"];
	if (![stripeSecretKey isKindOfClass:[NSNull class]])
		[GlobalPrefrences setStripeSecretKey:stripeSecretKey];

	NSString *parseApplicationId = [[dictUserSettings valueForKey:@"store"] valueForKey:@"sStripeApplicationId"];
	if (![parseApplicationId isKindOfClass:[NSNull class]])
		[GlobalPrefrences setParseApplicationId:parseApplicationId];

	NSString *parseClientKey = [[dictUserSettings valueForKey:@"store"] valueForKey:@"sStripeClientKey"];
	if (![parseClientKey isKindOfClass:[NSNull class]])
		[GlobalPrefrences setParseClientKey:parseClientKey];

	NSString *masterSecret = [[dictUserSettings valueForKey:@"store"] valueForKey:@"sStripeMasterKey"];
	if (![masterSecret isKindOfClass:[NSNull class]])
		[GlobalPrefrences setMasterSecret:masterSecret];

	// Not have
	NSString *parseAppName = [[dictUserSettings valueForKey:@"store"] valueForKey:@"parseAppName"];
	if (![parseAppName isKindOfClass:[NSNull class]])
		[GlobalPrefrences setParseAppName:parseAppName];

	NSString *isStripeModeLive = [[dictUserSettings valueForKey:@"store"] valueForKey:@"isStripeModeLive"];
	if (![isStripeModeLive isKindOfClass:[NSNull class]])
		[GlobalPrefrences setStripeModeIsLive:isStripeModeLive];

	NSString *isStripeEnable = [[dictUserSettings valueForKey:@"store"] valueForKey:@"stripeUsed"];
	if (![isStripeEnable isKindOfClass:[NSNull class]])
		[GlobalPrefrences setStripeModeEnable:isStripeEnable];

	BOOL isZeroDecimal = [[dictUserSettings valueForKey:@"store"] valueForKey:@"isZeroDecimal"];
	if (!isZeroDecimal)
		[GlobalPrefrences setIsZeroDecimal:isZeroDecimal];

	BOOL isStripeLive = [[dictUserSettings valueForKey:@"store"] valueForKey:@"stripeLive"];
	if (!isStripeLive) {
		[GlobalPrefrences setIsStripeLive:isStripeLive];
	}
	//4/11/2014 Tuyen End
    
    //***********************************Cash Key************************
    // 9/02/2015 Tuyen Cash fee key
    NSString *strDeliveryFee = [[dictUserSettings valueForKey:@"store"] valueForKey:@"fCodFee"];
    if (![strDeliveryFee isKindOfClass:[NSNull class]]) {
        float deliveryFee = [strDeliveryFee floatValue];
        [GlobalPrefrences setCashDeliveryFee:deliveryFee];
    }
    // 9/02/2015 Tuyen End

	_savedPreferences.strCurrency = [[dictUserSettings valueForKey:@"store"] valueForKey:@"sCurrency"];
	DDLogDebug(@"Currency is: %@", _savedPreferences.strCurrency);

	if ((_savedPreferences.strCurrency == nil) || ([_savedPreferences.strCurrency isKindOfClass:[NSNull class]])) {
		_savedPreferences.strCurrency = @"";
	}

	if (!_dictSettings)
		_savedPreferences.strCurrency = @"";

	[GlobalPrefrences setCurrencySymbol];
}

NSString *strMerchantCountry;
int iMerchantCountryID;
+ (void)setUserCountryAndStateForTax_country:(NSString *)_country countryID:(int)countryID {
	if (!strMerchantCountry)
		strMerchantCountry = [[NSString alloc]init];
	strMerchantCountry = _country;
	iMerchantCountryID = countryID;
}

+ (NSDictionary *)getAppVitals {
	return dicAppVitals;
}

+ (NSString *)getUserCountryFortax {
	return strMerchantCountry;
}

+ (int)getUserCountryID {
	return iMerchantCountryID;
}

+ (NSDictionary *)getSettingsOfUserAndOtherDetails {
	return dictUserSettings;
}

+ (void)setCurrencySymbol {
	NSString *strCode = @"";
	if ([_savedPreferences.strCurrency length] >= 3)
		strCode =  [_savedPreferences.strCurrency substringFromIndex:3];
	if ([strCode isEqualToString:@"USD"])
		_savedPreferences.strCurrencySymbol = @"$";
	else if ([strCode isEqualToString:@"EUR"])
		_savedPreferences.strCurrencySymbol = @"€";
	else if ([strCode isEqualToString:@"GBP"])
		_savedPreferences.strCurrencySymbol = @"£";
	else {
		if (strCode == nil)
			_savedPreferences.strCurrencySymbol = @"";
		else
			_savedPreferences.strCurrencySymbol = strCode;
	}
	if (!strCode)
		_savedPreferences.strCurrencySymbol = @"";
}

+ (float)getRoundedOffValue:(float)_num {
	NSDecimalNumber *testNumber = [NSDecimalNumber numberWithFloat:_num];
	NSDecimalNumberHandler *roundingStyle = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundBankers scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
	NSDecimalNumber *roundedNumber = [testNumber decimalNumberByRoundingAccordingToBehavior:roundingStyle];
	NSString *stringValue = [roundedNumber descriptionWithLocale:[NSLocale currentLocale]];

	float finalValue = [stringValue floatValue];
	return finalValue;
}

+ (void)setUserDefault_Preferences:(NSString *)value:(NSString *)key {
	[[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
}

+ (NSString *)getUserDefault_Preferences:(NSString *)forKey {
	return [[NSUserDefaults standardUserDefaults] valueForKey:forKey];
}

NSInteger iCurrentShoppingCartNum;
+ (void)setCurrentShoppingCartNum:(NSInteger)_num {
	iCurrentShoppingCartNum = _num;
}

+ (NSInteger)getCurrentShoppingCartNum {
	return iCurrentShoppingCartNum;
}

//********* Getters ********
//return details of current selected Featured product


+ (NSDictionary *)getCurrentFeaturedDetails {
	return dictCurrentFeaturedProduct;
}

+ (NSDictionary *)getNextFeaturedProductDetails {
	return dictNextFeaturedProduct;
}

+ (BOOL)validateEmail:(NSString *)candidate {
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:candidate];
}

#pragma mark - For Public APIs
NSString *strMerchantEmailID = nil;
+ (void)setMerchantEmailID:(NSString *)_merchantEmail {
	strMerchantEmailID = _merchantEmail;
	[strMerchantEmailID retain];
}

+ (NSString *)getMerchantEmailId {
	return strMerchantEmailID;
}

#pragma mark ----PayPal/ZooZ setter/getter


NSString *PAYPAL_LIVE_TOKEN_ID = nil;

#pragma mark setter/getter Zooz
NSString *zoozToken = nil;
+ (void)setZoozToken:(NSString *)_zoozToken {
	zoozToken = _zoozToken;
	[zoozToken retain];
}

+ (NSString *)getZoozPaymentToken {
	return zoozToken;
}

#pragma mark setter/getter PayPal/ZooZ
NSString *payPalEmail_ID = nil;
+ (void)setPaypalRecipientEmail:(NSString *)payPalEmail {
	payPalEmail_ID = payPalEmail;
	[payPalEmail_ID retain];
}

+ (NSString *)getPaypalRecipient_Email {
	return payPalEmail_ID;
}

NSString *payPalLiveToken;
+ (void)setPaypalLiveToken:(NSString *)_paypalToken {
	payPalLiveToken = _paypalToken;
	[payPalLiveToken retain];
}

+ (NSString *)getPaypalLiveToken {
	return payPalLiveToken;
}

//18/09/2014 Sa Vo
NSString *payPalClientId;
+ (void)setPayPalClientId:(NSString *)aPaypalClientId {
	payPalClientId = aPaypalClientId;
	[payPalClientId retain];
}

+ (NSString *)getPayPalClientId {
	return payPalClientId;
}

NSString *paypalSecretKey;
+ (void)setPaypalSecretKey:(NSString *)aPaypalSecretKey {
	paypalSecretKey = aPaypalSecretKey;
	[paypalSecretKey retain];
}

+ (NSString *)getPaypalSecretKey {
	return paypalSecretKey;
}

NSString *isPayPalModeLive;
+ (void)setPaypalModeIsLive:(NSString *)payPalMode {
	isPayPalModeLive = [payPalMode copy];
}

+ (NSString *)getPaypalModeIsLive {
	return isPayPalModeLive;
}

NSString *isZooZModeLive;
+ (void)setZooZModeIsLive:(NSString *)zooZMode {
	isZooZModeLive = [zooZMode copy];
}

+ (NSString *)getZooZModeIsLive {
	return isZooZModeLive;
}

#pragma mark setter/getter 2c2p

NSString *_2c2pLiveToken;
+ (void)set2c2pLiveToken:(NSString *)payment2c2pToken {
	_2c2pLiveToken = payment2c2pToken;
	[_2c2pLiveToken retain];
}

+ (NSString *)get2c2pLiveToken {
	return _2c2pLiveToken;
}

#pragma mark setter/getter iPay88

NSString *iPay88LiveToken;
+ (void)setiPay88LiveToken:(NSString *)iPay88Token {
	iPay88LiveToken = iPay88Token;
	[iPay88LiveToken retain];
}

+ (NSString *)getiPay88LiveToken {
	return iPay88LiveToken;
}

NSString *_is2c2pEnable;
+ (void)set2c2pModeEnable:(NSString *)is2c2pEnable {
	_is2c2pEnable = is2c2pEnable;
	[_is2c2pEnable retain];
}

+ (NSString *)get2c2pModeEnable {
	return _is2c2pEnable;
}

NSString *_isiPay88Enable;
+ (void)setiPay88ModeEnable:(NSString *)isiPay88Enable {
	_isiPay88Enable = isiPay88Enable;
	[_isiPay88Enable retain];
}

+ (NSString *)getiPay88ModeEnable {
	return _isiPay88Enable;
}

NSString *_iPay88MerchantKey;
+ (void)setiPay88MerchantKey:(NSString *)iPay88MerchantKey {
	_iPay88MerchantKey = iPay88MerchantKey;
	[_iPay88MerchantKey retain];
}

+ (NSString *)getiPay88MerchantKey {
	return _iPay88MerchantKey;
}

NSString *_iPay88MerchantCode;
+ (void)setiPay88MerchantCode:(NSString *)iPay88MerchantCode {
	_iPay88MerchantCode = iPay88MerchantCode;
	[_iPay88MerchantCode retain];
}

+ (NSString *)getiPay88MerchantCode {
	return _iPay88MerchantCode;
}

NSString *_2c2pMerchantId;
+ (void)set2c2pMerchantId:(NSString *)merchantId {
	_2c2pMerchantId = merchantId;
	[_2c2pMerchantId retain];
}

+ (NSString *)get2c2pMerchantId {
	return _2c2pMerchantId;
}

NSString *_2c2pSecrectKey;
+ (void)set2c2pSecrectKey:(NSString *)secrectKey {
	_2c2pSecrectKey = secrectKey;
	[_2c2pSecrectKey retain];
}

+ (NSString *)get2c2pSecrectKey {
	return _2c2pSecrectKey;
}

NSString *_2c2pCurrencyNumber;
+ (void)set2c2pCurrencyNumber:(NSString *)currencyNumber {
	_2c2pCurrencyNumber = currencyNumber;
	[_2c2pCurrencyNumber retain];
}

+ (NSString *)get2c2pCurrencyNumber {
	return _2c2pCurrencyNumber;
}

#pragma mark ----Reachibility Check
+ (BOOL)updateInterfaceWithReachability:(Reachability *)curReach {
	NetworkStatus netStatus = [curReach currentReachabilityStatus];
	BOOL connectionRequired = [curReach connectionRequired];
	BOOL connectionStatus = NO;

	switch (netStatus) {
		case NotReachable:
		{
			connectionRequired = NO;
			connectionStatus = NO;
			break;
		}

		case ReachableViaWWAN:
		{
			connectionStatus = YES;
			break;
		}

		case ReachableViaWiFi:
		{
			connectionStatus = YES;
			break;
		}
	}

	return connectionStatus;
}

+ (BOOL)isInternetAvailable {
	return ([self updateInterfaceWithReachability:internetReach]);
}

NSMutableArray *arrDeptDataHomes;
+ (void)setDepartmentsDataHomes:(NSArray *)arrDepts {
	if (!arrDeptDataHomes) {
		arrDeptDataHomes = [[NSMutableArray alloc] init];
	}
	[arrDeptDataHomes addObject:arrDepts];
}

+ (NSArray *)getDepartmentsDataHomes {
	if ([arrDeptDataHomes count]) {
		NSArray *arr = [[[NSArray alloc] initWithArray:[arrDeptDataHomes lastObject]] autorelease];
		if ([arrDeptDataHomes count] == 1)
			return arr;
		else {
			[arrDeptDataHomes removeLastObject];
			return arr;
		}
	}
	else {
		return 0;
	}
}

NSMutableArray *arrDeptNameHome;
+ (void)setDepartmentNamesHomes:(NSString *)nameStr {
	if (!arrDeptNameHome) {
		arrDeptNameHome = [[NSMutableArray alloc] init];
	}
	[arrDeptNameHome addObject:nameStr];
	// [arrDeptName retain];
}

+ (NSString *)getLastDepartmentNameHomes {
	if ([arrDeptNameHome count]) {
		NSString *str = [[[NSString alloc] initWithString:[arrDeptNameHome lastObject]] autorelease];
		[arrDeptNameHome removeLastObject];
		return str;
	}
	else {
		return @"";
	}
}

NSMutableArray *arrDeptDataStore;
+ (void)setDepartmentsDataStore:(NSArray *)arrDepts {
	if (!arrDeptDataStore) {
		arrDeptDataStore = [[NSMutableArray alloc] init];
	}
	[arrDeptDataStore addObject:arrDepts];
}

+ (NSArray *)getDepartmentsDataStore {
	if ([arrDeptDataStore count]) {
		NSArray *arr = [[[NSArray alloc] initWithArray:[arrDeptDataStore lastObject]] autorelease];
		if ([arrDeptDataStore count] == 1)
			return arr;
		else {
			[arrDeptDataStore removeLastObject];
			return arr;
		}
	}
	else {
		return 0;
	}
}

NSMutableArray *arrDeptNameStore;
+ (void)setDepartmentNamesStore:(NSString *)nameStr {
	if (!arrDeptNameStore) {
		arrDeptNameStore = [[NSMutableArray alloc] init];
	}
	[arrDeptNameStore addObject:nameStr];
}

+ (NSString *)getLastDepartmentNameStore {
	if ([arrDeptNameStore count]) {
		NSString *str = [[[NSString alloc] initWithString:[arrDeptNameStore lastObject]] autorelease];
		[arrDeptNameStore removeLastObject];
		return str;
	}
	else {
		return @"";
	}
}

+ (void)removeLocalData {
	if ([arrDeptDataStore count] > 0)
		[arrDeptDataStore removeAllObjects];
	if ([arrDeptNameStore count] > 0)
		[arrDeptNameStore removeAllObjects];
}

NSString *SECRETKEY;

+ (void)setMerchant_Secret_Key:(NSString *)_secretKey {
	SECRETKEY = [_secretKey copy];
}

+ (NSString *)getMerchant_Secret_Key {
	return SECRETKEY;
}

+ (NSInteger)getCurrentAppId {
	return iCurrentAppId;
}

//------------cureent  version
+ (float)getCureentSystemVersion {
	return [[[UIDevice currentDevice] systemVersion] floatValue];
}

BOOL isEditMode;
+ (void)setIsEditMode:(BOOL)_isEditMode {
	isEditMode = _isEditMode;
}

+ (BOOL)getIsEditMode {
	return isEditMode;
}

#pragma mark - Paypal/Zooz enable/disable
NSString *_isZoozEnable;
+ (void)setZoozModeEnable:(NSString *)isZoozEnable {
	_isZoozEnable = isZoozEnable;
	[_isZoozEnable retain];
}

+ (NSString *)getZoozModeEnable {
	return _isZoozEnable;
}

NSString *_isPayPalEnable;
+ (void)setPaypalModeEnable:(NSString *)isPayPalEnable {
	_isPayPalEnable = isPayPalEnable;
	[_isPayPalEnable retain];
}

+ (NSString *)getPaypalModeEnable {
	return _isPayPalEnable;
}

#pragma mark - Handle getter/setter Stripe
// 4/11/2014 Tuyen new code for Stripe

// Stripe enable/disable
NSString *_isStripeEnable;
+ (void)setStripeModeEnable:(NSString *)isStripeEnable {
	_isStripeEnable = isStripeEnable;
	[_isStripeEnable retain];
}

+ (NSString *)getStripeModeEnable {
	return _isStripeEnable;
}

NSString *stripePublishableKey;
+ (void)setStripePublishableKey:(NSString *)aStripePublishableKey {
	stripePublishableKey = aStripePublishableKey;
	[stripePublishableKey retain];
}

+ (NSString *)getStripePublishableKey {
	return stripePublishableKey;
}

NSString *stripeSecretKey;
+ (void)setStripeSecretKey:(NSString *)aStripeSecretKey {
	stripeSecretKey = aStripeSecretKey;
	[stripeSecretKey retain];
}

+ (NSString *)getStringSecretKey {
	return stripeSecretKey;
}

NSString *parseApplicationId;
+ (void)setParseApplicationId:(NSString *)aParseApplicationId {
	parseApplicationId = aParseApplicationId;
	[parseApplicationId retain];
}

+ (NSString *)getParseApplicationId {
	return parseApplicationId;
}

NSString *parseClientKey;
+ (void)setParseClientKey:(NSString *)aParseClientKey {
	parseClientKey = aParseClientKey;
	[parseClientKey retain];
}

+ (NSString *)getParseClientKey {
	return parseClientKey;
}

NSString *masterSecret;
+ (void)setMasterSecret:(NSString *)aMasterSecret {
	masterSecret = aMasterSecret;
	[masterSecret retain];
}

+ (NSString *)getMasterSecret {
	return masterSecret;
}

NSString *parseAppName;
+ (void)setParseAppName:(NSString *)aParseAppName {
	parseAppName = aParseAppName;
	[parseAppName retain];
}

+ (NSString *)getParseAppName {
	return parseAppName;
}

NSString *isStripeModeLive;
+ (void)setStripeModeIsLive:(NSString *)isStripeLive {
	isStripeModeLive = [isStripeLive copy];
}

+ (NSString *)getStripeModeIsLive {
    // DDLogDebug(@"%@",ISAPPTOKENLIVE);
    return isStripeModeLive;
}

BOOL isZeroDecimal;
+ (void)setIsZeroDecimal:(BOOL)aIsZeroDecimal {
	isZeroDecimal = aIsZeroDecimal;
}

+ (BOOL)getIsZeroDecimal {
    // DDLogDebug(@"%@",ISAPPTOKENLIVE);
    return isZeroDecimal;
}

BOOL isStripeLive;
+ (void)setIsStripeLive:(BOOL)aIsStripeLive {
	isStripeModeLive = aIsStripeLive;
}

+ (BOOL)getIsStripeLive {
	return isStripeModeLive;
}

// 09/02/2015 Tuyen Cash fee key
float cashDeliveryFee;
+ (void)setCashDeliveryFee:(float)aCashDeliveryFee{
    cashDeliveryFee = aCashDeliveryFee;
}

+ (float)getCasDeliveryFee{
    return cashDeliveryFee;
}
// 09/02/2015 Tuyen End

@end
