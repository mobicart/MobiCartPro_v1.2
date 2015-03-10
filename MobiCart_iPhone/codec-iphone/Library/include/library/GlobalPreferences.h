//
//  GlobalPreferences.h
//  MobiCart
//
//  Created by Mobicart on 7/7/10.
//  Copyright 2010 Mobicart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import <Foundation/NSString.h>
#import "SBJSON.h"
#import "MobicartAppDelegate.h"

extern BOOL isNewsSection;

@class Reachability;
Reachability* internetReach;
BOOL isLoggedInStatuschanged;

// The queue to run "ParseOperation"
NSOperationQueue *queue;

@interface GlobalPreferences:NSObject
{
	UIColor *navigationBarColor;
}

@property (nonatomic, retain) UIColor *navigationBarColor;



+(BOOL)isInternetAvailable;


#pragma mark -
+(void)initializeGlobalControllers;
//+(NSDictionary *)fetchDataFromServer:(NSString *)strURL;
//+(void)sendDataToServer:(NSString*)_url;



#pragma mark -
+(void)setCurrencySymbol;
+(void)setPersonLoginStatus:(BOOL)_status;
+(BOOL)getPersonLoginStatus;

+(void)setLanguageLabels:(NSDictionary *)_dictTemp;
+(NSDictionary *) getLangaugeLabels;

#pragma mark Tabbar Settings
+(void)setTabbarControllers_SelectedByUser:(NSDictionary *)dictFeatures;
+(NSArray *)tabBarControllers_SelectedByUser;

+(void)setTabbarItemTitles:(NSArray *)arrSelected_Titles;
+(NSArray *)getAllNavigationTitles;

#pragma mark - Search Bar Default Settings
+(void)setSearchBarDefaultSettings:(UISearchBar *)_searchBar;


#pragma mark - Home
+(BOOL)canPopToRootViewController;
+(void)setCanPopToRootViewController:(BOOL) _canPop;


+(void)setCurrentNavigationController: (UINavigationController *)_navigationController;

+(UINavigationController *)getCurrentNavigationController;


+(UIView*)createLogoImage;
+(void)setColorScheme_SelectedByUser:(NSDictionary *)dictFeatures;

// Set gradient effect on the view
+(void)setGradientEffectOnView:(UIView *)view :(UIColor *)mainColor :(UIColor *)secondaryColor;

#pragma mark ----- Store
+(void)setCurrentDepartmentId:(NSInteger )_iCurrentDepartmentId;
+(void)setCurrentCategoryId:(NSInteger )_iCurrentCategoryId;
+(void)setCurrentProductId:(NSInteger )_iCurrentProductId;

+(void)setCurrentFeaturedProductDetails:(NSDictionary *)_dictTemp;
+(void)setIsClickedOnFeaturedImage:(BOOL)_isClicked;


//+(NSString *)getDepartmentUrl;
//+(NSString *)getCategoriesUrl:(NSInteger)_iCurrentDepartmentId;

//+(NSString *)getProductsUrl:(NSInteger)_iCurrentProductId;
+(NSDictionary *) getCurrentFeaturedDetails;
+(void)setCurrentProductDetails:(NSDictionary *)_dictTemp;
+(NSDictionary *) getCurrentProductDetails;

+(BOOL) isClickedOnFeaturedProductFromHomeTab;


+ (UIColor *) colorWithHexString: (NSString *)stringToConvert;



#pragma mark ------ Shopping Cart -------

/******* SHOPPING CART *******/

// Label on the navigation bar
+(float) getRoundedOffValue:(float)_num;

+(void)setCurrentItemsInCart:(BOOL)added;

+(NSInteger)getCurrenItemsInCart;
+ (BOOL) validateEmail: (NSString *) candidate;
+(void)setUserDefault_Preferences:(NSString *)value :(NSString *)key;
+(NSString *)getUserDefault_Preferences:(NSString *)forKey;
+(void)setUserCountryAndStateForTax_country:(NSString*)_country countryID:(int)countryID;
+(NSString*)getUserCountryFortax;
+(int)getUserCountryID;


//**********User setting Details **************
+(void)setSettingsOfUserAndOtherDetails:(NSDictionary *)dictSettings;
+(NSDictionary *)getSettingsOfUserAndOtherDetails;

//*********************App Vitals**********

+(void)setAppVitalsAndCountries:(NSDictionary*)_dicVitals;
+(NSDictionary *) getAppVitals;
//+(NSString*)fetchStatesOfAcountryURL:(NSInteger)_iCountryCode;

//*************************************
+(void)goToShoppingCart:(UIViewController *)_currentViewController;

+(void)setShadowOnView:(UIView *)_view :(UIColor *)_shadowColor :(BOOL)_includeGradient :(UIColor *)mainColor :(UIColor *)secondaryColor;

#pragma mark - NSOperationQueue Handler

+(void)addToOpertaionQueue:(NSInvocationOperation *) _opertion;


#pragma mark - Loading Indicator
+(void) addLoadingIndicator_OnView:(UIView *)_view;
+(void) stopLoadingIndicator;
+(void) startLoadingIndicator;

#pragma mark - Loading Bar At Bottom
+(void)addLoadingBar_AtBottom:(UIView *)showInView withTextToDisplay:(NSString *)strText;
+(void)dismissLoadingBar_AtBottom;


+(void) setCurrentShoppingCartNum:(NSInteger) _num;
+(NSInteger) getCurrentShoppingCartNum;

#pragma mark - Current Device

+(void) setCurrentDevice4:(BOOL) _device4;
+(BOOL) getCurrentDevice4;

#pragma mark - More Navigation Controller Settings
+(void) setMoreNavigationConroller_Footer:(BOOL)isShowing;
+(BOOL) isShowingFooterLogo_OnMoreNavigationController;


#pragma mark - API Settings
+(void) setMerchantEmailID:(NSString *)_merchantEmail;
+(NSString *)getMerchantEmailId;

#pragma mark - Paypal/Zooz Live Token
+(void) setPaypalLiveToken:(NSString *)paypalToken;
+(NSString *) getPaypalLiveToken;

//18/09/2014 Sa Vo
#pragma mark - Paypal Live ClientId & Secrect
+(void)setPayPalClientId:(NSString *)aPaypalClientId;
+(NSString *) getPayPalClientId;

+(void)setPaypalSecretKey:(NSString *)aPaypalSecretKey;
+(NSString *) getPaypalSecretKey;

+(void) setZoozToken:(NSString *)_zoozToken;
+(NSString *) getZoozPaymentToken;

+(void) setPaypalRecipientEmail:(NSString *)_PayPalEmail;
+(NSString *) getPaypalRecipient_Email;

#pragma mark - Paypal/Zooz Live Mode
+(void) setZoozModeIsLive:(NSString *)isZoozLive;
+(NSString *) getZoozModeIsLive;

+(void) setPaypalModeIsLive:(NSString *)isPayPalLive;
+(NSString *) getPaypalModeIsLive;

+(void)setiPay88LiveToken:(NSString *)iPay88Token;
+(NSString *) getiPay88LiveToken;

+(void)set2c2pLiveToken:(NSString *)payment2c2pToken;
+(NSString *) get2c2pLiveToken;


+(void)set2c2pCurrencyNumber:(NSString *)currencyNumber;
+(NSString*)get2c2pCurrencyNumber;

#pragma mark - Paypal/Zooz enable/disable
+(void) setZoozModeEnable:(NSString *)isZoozEnable;
+(NSString *) getZoozModeEnable;

+(void) setPaypalModeEnable:(NSString *)isPayPalEnable;
+(NSString *) getPaypalModeEnable;

+(void) set2c2pModeEnable:(NSString *)is2c2pEnable;
+(NSString*) get2c2pModeEnable;

+(void) setiPay88ModeEnable:(NSString *)isiPay88Enable;
+(NSString*) getiPay88ModeEnable;

+(void)setiPay88MerchantKey:(NSString *)iPay88MerchantKey;
+(NSString*)getiPay88MerchantKey;

+(void)setiPay88MerchantCode:(NSString*)iPay88MerchantCode;
+(NSString*)getiPay88MerchantCode;

+(void)set2c2pMerchantId:(NSString*)merchantId;
+(NSString*)get2c2pMerchantId;

+(void)set2c2pSecrectKey:(NSString*)secrectKey;
+(NSString*)get2c2pSecrectKey;

//common alert
+(void )createAlertWithTitle:(NSString *)withTitle message:(NSString *)withMessage delegate:(id)withDelegate cancelButtonTitle:(NSString *)withCancelButtonTitle otherButtonTitles :(NSString *)withOtherButtonTitles;

+(void)setAllDataDictionary;
//***************************iProduct Count*******
+(void)setProductCount:(NSInteger)productCount;
+(NSInteger)getProductCount;
//-----------getcureentAppId
+(NSInteger)getCurrentAppId;


+(BOOL)isScreen_iPhone5;
#pragma mark - Set Dimensions according to Screen Size iPhone/iPhone5
+(CGRect)setDimensionsAsPerScreenSize:(CGRect)tempRect chageHieght:(BOOL)changeHeight;
+(float)getCureentSystemVersion;


//----------------------------mobicaer start up-----setter/getter
+(void)setDictAppStoreUser:(NSDictionary*)_dictAppStoreUser;
+(NSDictionary*)getDictAppStoreUser;

+(void)setDictFeatures:(NSDictionary*)_dictFeatures;
+(NSDictionary*)getDictFeatures;

+(void)setDictColorScheme:(NSDictionary*)_dictColorScheme;
+(NSDictionary*)getDictColorScheme;

+(void)setDictVitals:(NSDictionary*)_dictVitals;
+(NSDictionary*)getDictVitals;

+(void)setDictSettings:(NSDictionary*)_dictSettings;
+(NSDictionary*)getDictSettings;

+(void)setDictGalleryImages:(NSDictionary*)_dictGalleryImages;
+(NSDictionary*)getDictGalleryImages;

+(void)setDictStaticPages:(NSDictionary*)_dictStaticPages;
+(NSDictionary*)getDictStaticPages;
+(void)InitializeLoadingIndictor;
+(void)showLoadingIndicator;
+(void)hideLoadingIndicator;

// Tuyen new code for Stripe

// Stripe live mode
+(void) setStripeModeIsLive:(NSString*)isStripeLive;
+(NSString *) getStripeModeIsLive;

// Stripe enable/disable
+(void) setStripeModeEnable:(NSString *)isStripeEnable;
+(NSString*) getStripeModeEnable;

// Stripe key
+(void)setStripePublishableKey:(NSString *)aStripePublishableKey;
+(NSString *)getStripePublishableKey;
+(void)setStripeSecretKey:(NSString*)aStripeSecretKey;
+(NSString*)getStringSecretKey;
+(void)setParseApplicationId:(NSString*)aParseApplicationId;
+(NSString*)getParseApplicationId;
+(void)setParseClientKey:(NSString*)aParseClientKey;
+(NSString*)getParseClientKey;
+(void)setMasterSecret:(NSString*)aMasterSecret;
+(NSString*)getMasterSecret;
+(void)setParseAppName:(NSString*)aParseAppName;
+(NSString*)getParseAppName;
+(void) setIsZeroDecimal:(BOOL)aIsZeroDecimal;
+(BOOL) getIsZeroDecimal;
+(void)setIsStripeLive:(BOOL)aIsStripeLive;
+(BOOL)getIsStripeLive;
// Tuyen end

// 09/02/2015 Tuyen Cash fee key
+ (void)setCashDeliveryFee;
+ (float)getCasDeliveryFee;
// 09/02/2015 Tuyen End
@end





