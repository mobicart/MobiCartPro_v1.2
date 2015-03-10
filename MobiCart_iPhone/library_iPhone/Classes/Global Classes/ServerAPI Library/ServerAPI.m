//
//  ServerAPI.m
//  MobicartApp
//
//  Created by Mobicart on 31/04/11.
//  Copyright 2011 Mobicart. All rights reserved.
//
#import "ServerAPI.h"
#import "OAuthConsumer.h"
#import "ASIHTTPRequest.h"
#import "ASIHTTPRequest+OAuth.h"
#import "UserDetails.h"

// Tuyen close to test Stripe
//#define urlMainServer @"http://www.mobi-cart.com"  //Live
//#define urlMainServerImage @"http://www.mobi-cart.com" //image
//


//#define urlMainServer @"http://184.106.119.106:8181/mobi-cart/"//Demo
//#define urlMainServerImage @"http://184.106.119.106:8181"//image

//#define urlMainServer @"http://192.168.100.71:8181/mobi-cart/"  //Live
//#define urlMainServerImage @"http://192.168.100.71:8181/"//image

// Tuyen open to test Stripe
#define urlMainServer @"http://192.168.100.71:8181/"  //Live
#define urlMainServerImage @"http://192.168.100.71:8181/" //image
//


#define jsonDepartments_FileName @"/departments.json"
#define jsonCategories_FileName @"/categories.json"
#define jsonProducts_FileName @"/products.json"
#define jsonDetails_FileName @"/details.json"
#define urlStore @"store"
#define urlAppFeatures @"app"
#define urlAnalyticsForProductViews @"product"

@implementation ServerAPI
#pragma mark App

SBJSON * _JSONParser;
static NSDictionary *dicTemp;
+ (NSDictionary *)fetchLanguagePreferences:(NSInteger)iCurrentMerchantId {
	if (!_JSONParser) {
		_JSONParser = [[SBJSON alloc]init];
	}

	@try {
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];

		[request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/user/iphone/%d/labels.json", urlMainServer, iCurrentMerchantId]]];

		[request setHTTPMethod:@"GET"];

		NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

		NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];

		NSDictionary *dict_JSONData = (NSDictionary *)[_JSONParser objectWithString:returnString error:nil];

		return(dict_JSONData);
	}
	@catch (NSException *ex)
	{
		DLog(@"Exception handling error: %@", ex);
		return nil;
	}
}

+ (BOOL)isLangUpdated:(NSString *)strTimeStamp:(NSInteger)iCurrentMerchantId {
	if (!_JSONParser) {
		_JSONParser = [[SBJSON alloc]init];
	}

	@try {
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
		NSString *strUrl = [[NSString stringWithFormat:@"%@/user/iphone/insync/%d/%@/labels.json", urlMainServer, iCurrentMerchantId, strTimeStamp]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
		[request setURL:[NSURL URLWithString:strUrl]];

		[request setHTTPMethod:@"GET"];

		NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];

		NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];

		NSDictionary *dict_JSONData = (NSDictionary *)[_JSONParser objectWithString:returnString error:nil];

		return [[dict_JSONData valueForKey:@"Labels"] boolValue];
	}
	@catch (NSException *ex)
	{
		DLog(@"Exception handling error: %@", ex);
		return FALSE;
	}
}

//change url
+ (NSURLRequest *)createImageURLConnection:(NSString *)strImage {
	NSString *imageURLString = [NSString stringWithFormat:@"%@%@", urlMainServerImage, strImage];
	NSURLRequest *request = nil;
	if (imageURLString != nil) {
		request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURLString]];
	}
	return request;
}

+ (NSURLRequest *)createTweetImageRequest:(NSString *)url {
	NSURLRequest *request = nil;
	if (url != nil) {
		request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	}
	return request;
}

+ (NSData *)fetchBannerImage:(NSString *)strImage {
	NSData *dataBannerImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlMainServerImage, strImage]]];
	return dataBannerImage;
}

+ (void)pushNotifications:(NSString *)strLatitude:(NSString *)strLongitude:(NSString *)tokenString:(NSInteger)iCurrentAppId {
	NSString *urlDeviceTokenForNotification = [NSString stringWithFormat:@"%@/user/%d/%@/%@/%@/register.json", urlMainServer, iCurrentAppId, tokenString, strLongitude, strLatitude];
	[ServerAPI sendDataToServer:urlDeviceTokenForNotification];
}

+ (NSString *)getDepartmentUrl:(NSInteger)iCurrentStoreId {
	return [NSString stringWithFormat:@"%@/%@/%d%@", urlMainServer, urlStore, iCurrentStoreId, jsonDepartments_FileName];
}

+ (NSString *)getCategoriesUrl:(NSInteger)_iCurrentDepartmentId:(NSInteger)iCurrentStoreId {
	return [NSString stringWithFormat:@"%@/%@/%d/department/%d%@", urlMainServer, urlStore, iCurrentStoreId, _iCurrentDepartmentId, jsonCategories_FileName];
}

+ (NSString *)getproductsWithoutCatogeriesUrl:(NSInteger)_iCurrentDepartmentId:(NSInteger)iCurrentStoreId {
	return [NSString stringWithFormat:@"%@/store/%d/department/%d/products.json", urlMainServer, iCurrentStoreId, _iCurrentDepartmentId];
}

+ (NSDictionary *)fetchStatesOfAcountryURL:(NSInteger)_iCountryCode {
	NSString *strURL = [NSString stringWithFormat:@"%@/country/%d/states.json", urlMainServer, _iCountryCode];
	dicTemp = [ServerAPI fetchDataFromServer:strURL];
	return dicTemp;
}

+ (UIImage *)setLogoImage:(NSString *)logoUrl:(BOOL)isNull {
	UIImage *imgLogoLocal;

	if (isNull) {
		imgLogoLocal = [UIImage imageNamed:@"icon.png"];
	}
	else {
		NSString *strUrlLogo = [NSString stringWithFormat:@"%@%@", urlMainServerImage, logoUrl];
		NSData *logoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", strUrlLogo]]];
		imgLogoLocal = [UIImage imageWithData:logoData];
	}

	return imgLogoLocal;
}

+ (NSDictionary *)getAppStoreUserDetails:(NSString *)merchantEmailId {
	//DLog(@"%@",merchantEmailId);
	dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/user/%@/app-store-user.json", urlMainServer, merchantEmailId]];
	return dicTemp;
}

+ (NSDictionary *)fetchTabbarPreferences:(NSInteger)iCurrentAppId {
	dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/features.json", urlMainServer, urlAppFeatures, iCurrentAppId]];
	return dicTemp;
}

+ (NSDictionary *)fetchColorScheme:(NSInteger)iCurrentAppId {
	dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/encolorscheme.json", urlMainServer, urlAppFeatures, iCurrentAppId]];
	return dicTemp;
}

+ (NSDictionary *)fetchAppVitals:(NSInteger)iCurrentAppId {
	dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/vitals.json", urlMainServer, urlAppFeatures, iCurrentAppId]];
	return dicTemp;
}

+ (NSDictionary *)fetchStaticPages:(NSInteger)iCurrentAppId {
	dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/app/%d/static-pages.json", urlMainServer, iCurrentAppId]];
	return dicTemp;
}

+ (NSDictionary *)fetchBannerProducts:(NSInteger)iCurrentStoreId {
	dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/gallery-images.json", urlMainServer, urlStore, iCurrentStoreId]];

	return dicTemp;
}

+ (NSDictionary *)fetchFeaturedproducts:(int)countryID:(int)stateID:(NSInteger)iCurrentAppId {
	dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/featured-products.json?c=%d&s=%d", urlMainServer, urlAppFeatures, iCurrentAppId, countryID, stateID]];
	return dicTemp;
}

+ (NSDictionary *)fetchSettings:(NSInteger)iCurrentStoreId {
	// NSString* str=[NSString stringWithFormat:@"%@/%@/%d/settings.json", urlMainServer, urlStore, iCurrentStoreId];
	// DLog(@"test%@",str);

	dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/settings.json", urlMainServer, urlStore, iCurrentStoreId]];
	DLog(@"%@", [NSString stringWithFormat:@"%@/%@/%d/settings.json", urlMainServer, urlStore, iCurrentStoreId]);
	return dicTemp;
}

+ (NSDictionary *)fetchSearchProducts:(NSString *)sProductName:(int)countrId:(int)stateId:(NSInteger)iCurrentAppId {
	NSString *strURL = [NSString stringWithFormat:@"%@/app/%d/search/%@/products.json?c=%d&s=%d", urlMainServer, iCurrentAppId, sProductName, countrId, stateId];
	dicTemp = [ServerAPI fetchDataFromServer:strURL];
	return dicTemp;
}

#pragma mark store URL's
+ (void)fetchProductAnalytics:(NSString *)sProductId {
	int iProductId = [sProductId intValue];

	NSString *strCurrentProductAnalyticsUrl = [NSString stringWithFormat:@"%@/%@/%d/view.json", urlMainServer, urlAnalyticsForProductViews, iProductId];
	[ServerAPI fetchDataFromServer:strCurrentProductAnalyticsUrl];
}

+ (NSDictionary *)fetchProductsWithCategories:(int)deptID:(int)catID:(int)CountryID:(int)StateID:(NSInteger)iCurrentStoreId {
	NSString *strCurrentProductURL = [NSString stringWithFormat:@"%@/%@/%d/department/%d/category/%d/products.json?c=%d&s=%d", urlMainServer, urlStore, iCurrentStoreId, deptID, catID, CountryID, StateID];
	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:strCurrentProductURL];

	return dictTemp;
}

+ (NSDictionary *)fetchProductsWithoutCategories:(int)deptID:(int)CountryID:(int)StateID:(NSInteger)iCurrentStoreId {
	NSString *strUrl = [NSString stringWithFormat:@"%@", [ServerAPI getproductsWithoutCatogeriesUrl:deptID:iCurrentStoreId]];

	NSString *strCurrentProductURL = [NSString stringWithFormat:@"%@?c=%d&s=%d", strUrl, CountryID, StateID];

	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:strCurrentProductURL];

	return dictTemp;
}

+ (NSDictionary *)fetchProductsWithCategoriesAndSubCategories_departmentID:(int)deptID categoryID:(int)catID startRow:(int)startRow endRow:(int)endMaxRow countyID:(int)_country stateID:(int)_state userId:(NSInteger)iCurrentMerchantId storeId:(NSInteger)iCurrentStoreId {
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/user/%d/%@/%d/department/%d/category/%d/startRow/%d/end/%d/products.json?c=%d&s=%d", urlMainServer, iCurrentMerchantId, urlStore, iCurrentStoreId, deptID, catID, startRow, endMaxRow, _country, _state]];



	return dicTemp;
}

+ (NSDictionary *)fetchProductsWithoutCategories_departmentID:(int)departmentID startRow:(int)startRow endRow:(int)endMaxRow countryID:(int)_country stateID:(int)_state userId:(NSInteger)iCurrentMerchantId storeId:(NSInteger)iCurrentStoreId {
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/user/%d/%@/%d/department/0/category/%d/startRow/%d/end/%d/products.json?c=%d&s=%d", urlMainServer, iCurrentMerchantId, urlStore, iCurrentStoreId, departmentID, startRow, endMaxRow, _country, _state]];




	return dicTemp;
}

+ (NSDictionary *)fetchAllDepartments:(NSInteger)iCurrentStoreId {
	NSString *strTemp  = [ServerAPI getDepartmentUrl:iCurrentStoreId];
	// DLog(@"Test %@",strTemp);
	NSDictionary *dictFeatures = [ServerAPI fetchDataFromServer:strTemp];
	return dictFeatures;
}

+ (NSDictionary *)fetchAllCatogeries:(NSInteger)iCurrentDepartmentId:(NSInteger)iCurrentStoreId {
	NSString *strTemp = [ServerAPI getCategoriesUrl:iCurrentDepartmentId:iCurrentStoreId];
	NSDictionary *dictCategories = [ServerAPI fetchDataFromServer:strTemp];
	return dictCategories;
}

+ (NSDictionary *)fetchSubCategories:(int)categoryId:(NSInteger)iCurrentStoreId {
	NSString *strTemp = [ServerAPI getCategoriesUrl:categoryId:iCurrentStoreId];
	NSDictionary *dictCategories = [ServerAPI fetchDataFromServer:strTemp];
	return dictCategories;
}

+ (NSDictionary *)fetchDetailsOfProductWithID:(int)_productID {
	NSString *strTemp = [NSString stringWithFormat:@"%@/product/%d/details.json", urlMainServer, _productID];
	// DLog(@"Test %@",strTemp);
	NSDictionary *dictProducts = [ServerAPI fetchDataFromServer:strTemp];
	return dictProducts;
}

+ (NSDictionary *)fetchDetailsOfProductWithID:(int)_productID countryID:(int)_country stateID:(int)_state {
	NSString *strTemp = [NSString stringWithFormat:@"%@/product/%d/details.json?c=%d&s=%d", urlMainServer, _productID, _country, _state];
	//DLog(@"Test %@",strTemp);
	NSDictionary *dictProducts = [ServerAPI fetchDataFromServer:strTemp];
	return dictProducts;
}

+ (NSDictionary *)fetchStatesOfCountryWithID:(int)_countryID {
	NSString *strTemp = [NSString stringWithFormat:@"%@/country/%d/states.json", urlMainServer, _countryID];
	NSDictionary *dictStates = [ServerAPI fetchDataFromServer:strTemp];
	return dictStates;
}

+ (NSDictionary *)fetchOrderDetails:(NSString *)_userEmail:(NSInteger)iCurrentAppId:(NSInteger)iCurrentStoreId {
	NSString *strURL = [NSString stringWithFormat:@"%@/app/%d/store/%d/buyer/%@/product-order-history.json", urlMainServer, iCurrentAppId, iCurrentStoreId, _userEmail];
	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:strURL];
	return dictTemp;
}

#pragma mark NewsDetail
+ (NSDictionary *)fetchNewsItem:(NSInteger)iCurrentAppId {
	NSString *path = [NSString stringWithFormat:@"%@/%@/%d/news-items.json", urlMainServer, urlAppFeatures, iCurrentAppId];
	//DLog(@"%@",path);
	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:path];
	return dictTemp;
}

+ (NSDictionary *)fetchTwitterFeedFor:(NSInteger)iCurrentStoreId {
	NSString *strURL = [NSString stringWithFormat:@"%@/search/%d/tweets.json", urlMainServer, iCurrentStoreId];
	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:strURL];
	return dictTemp;
}

+ (NSDictionary *)fetchAddressOfMerchant:(NSString *)merchantemail {
	NSString *strTemp = [NSString stringWithFormat:@"%@/user/%@/address.json", urlMainServer, merchantemail];
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:strTemp];
	return dicTemp;
}

#pragma mark Shopping Cart Product Details
+ (NSDictionary *)fetchProductDetails:(int)productId:(int)lcountryID:(int)stateID {
	NSString *strTemp = [NSString stringWithFormat:@"%@/%@/%d/%@?c=%d&s=%d", urlMainServer, urlAnalyticsForProductViews, productId, jsonDetails_FileName, lcountryID, stateID];
	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:strTemp];
	return dictTemp;
}

#pragma mark TaxShippingDetails
+ (NSDictionary *)fetchTaxShippingDetails:(int)countryID:(int)stateID:(NSInteger)iCurrentStoreId {
	NSString *strTempUrl = [NSString stringWithFormat:@"%@/store/%d/country/%d/state/%d/tax-shipping.json", urlMainServer, iCurrentStoreId, countryID, stateID];
	dicTemp = [[ServerAPI fetchDataFromServer:strTempUrl] retain];

	return dicTemp;
}

#pragma mark SecureRequest
/*+ (NSString *)secureRequest:(NSURL *)url
   {
    @try
    {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];//888252887f8d7698e89a3ebd6f2940d3
        //DLog(@"Merchant email--%@, Merchant Secret Key--%@",[GlobalPreferences getMerchantEmailId],[GlobalPreferences getMerchant_Secret_Key]);

        [request signRequestWithClientIdentifier:[GlobalPreferences getMerchantEmailId] secret:[GlobalPreferences getMerchant_Secret_Key] tokenIdentifier:nil secret:nil usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];

        [request startSynchronous];

        NSString *responseString = [request responseString];

        //  //DLog(@"Response String %@",responseString);

        return responseString;
    }
    @catch (NSException *ex)
    {
        DLog(@"Exception handling error: %@",ex);
        return nil;
    }
    return nil;
   }
 */

#pragma mark fetchDataFromServer
+ (NSDictionary *)fetchDataFromServer:(NSString *)strURL {
	//WITH OAUTH

/*
    if(!_JSONParser)
    {
        _JSONParser = [[SBJSON alloc]init];
    }
    @try
    {
        NSString *returnString = [ServerAPI secureRequest:[NSURL URLWithString:strURL]];
        NSDictionary *dict_JSONData = (NSDictionary*)[_JSONParser objectWithString:returnString error:nil];
        return(dict_JSONData);
    }
    @catch (NSException* ex)
    {
        DLog(@"Exception handling error: %@",ex);
        return nil;
    }
    return nil;
 */


	//WITHOUT OAUTH

	if (!_JSONParser) {
		_JSONParser = [[SBJSON alloc]init];
	}
	@try {
		//make request url
		NSMutableURLRequest *request = [self makeRequestUrl:strURL];
		DLog(@"%@", request);

		//get json data from server
		NSString *serverData = [self processServerRequest:request];

		//parse data to dictionary
		NSDictionary *dictionary = [self processServerData:serverData];
		//if nil is returned,means data parsing failed
		if (!dictionary) {
			[self parsingFailed];
		}
		else {
			return dictionary;
		}
	}
	@catch (NSException *ex)
	{
		DLog(@"Exception handling error: %@", ex);
	}
	return nil;
}

#pragma mark make request Url
+ (NSMutableURLRequest *)makeRequestUrl:(NSString *)urlString {
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	return request;
}

#pragma mark process server request
+ (NSString *)processServerRequest:(NSURLRequest *)request {
	NSURLResponse *_response;
	NSError *_error = nil;

	if (![GlobalPreferences isInternetAvailable]) {
		[GlobalPreferences createAlertWithTitle:@"" message:@"Please check your network connection or try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	}
	else {
		NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&_response error:&_error];
		NSString *serverData = nil;
		@try {
			if (_error == nil) {
				serverData = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];
			}
			else {
				[self receivedErrorFromServer];
			}
		}
		@catch (NSException *exception)
		{
			DLog(@"catching %@ reason %@", [exception name], [exception reason]);
		}
		return serverData;
	}
}

#pragma mark processServerData
+ (NSDictionary *)processServerData:(NSString *)data {
	NSDictionary *dict_JSONData = (NSDictionary *)[_JSONParser objectWithString:data error:nil];
	if ([dict_JSONData isKindOfClass:[NSDictionary class]]) {
		return(dict_JSONData);
	}
	else {
		return nil;
	}
}

#pragma mark receivedErrorFromServer
+ (void)receivedErrorFromServer {
	//[GlobalPreferences createAlertWithTitle:@"Error in fetching" message:@"Please try again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	DLog(@"Error in fetching");
}

#pragma mark parsingFailed
+ (void)parsingFailed {
	//[GlobalPreferences createAlertWithTitle:@"Error in parsing" message:@"Please try again later" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	DLog(@"Error in parsing");
}

#pragma mark product methods

+ (NSString *)product_orderSaveURLSend:(NSString *)strDataToPost {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/product-order/save", urlMainServer]];
	NSString *reponseRecieved = [ServerAPI checkoutSendData:url withData:strDataToPost];
	return reponseRecieved;
}

+ (NSString *)product_order_ItemSaveURLSend:(NSString *)strDataToPost {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/product-order-item-multiple/save", urlMainServer]];
	NSString *reponseRecieved = [ServerAPI checkoutSendData:url withData:strDataToPost];
	return reponseRecieved;
}

// 15/01/2015 Tuyen handle send list Order Item to server
+ (NSString *)sendListOrderItemToServer:(NSString *)strDataToPost {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/product-order-multiple-items/save", urlMainServer]];
    NSString *reponseRecieved = [ServerAPI checkoutSendData:url withData:strDataToPost];
    return reponseRecieved;
}
//

+ (NSString *)product_order_NotifyURLSend:(NSString *)strDataToPost:(int)iCurrentOrderId {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/product-order/%d/notify.json", urlMainServer, iCurrentOrderId]];
	NSString *reponseRecieved = [ServerAPI checkoutSendData:url withData:@"Sending Order Number Last Time"];
	return reponseRecieved;
}

+ (NSString *)postReviewRatings:(NSString *)strDataToPost {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/product-review-rating/save", urlMainServer]];
	NSString *reponseRecieved = [ServerAPI checkoutSendData:url withData:strDataToPost];
	return reponseRecieved;
}

+ (NSString *)SQLServerAPI:(NSString *)urlData:(NSString *)strDataToPost {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlMainServer, urlData]];
	NSString *reponseRecieved = [ServerAPI checkoutSendData:url withData:strDataToPost];
	return reponseRecieved;
}

+ (NSString *)checkoutSendData:(NSURL *)_url withData:(NSString *)strDataToPost {
	NSData *postData = [strDataToPost dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];

	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:_url];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

	[request setHTTPBody:postData];

	NSError *error;
	NSURLResponse *response;
	NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *data = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	DLog(@"%@", data);
	return data;
}

+ (void)sendDataToServer:(NSString *)_url {
	/*ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:_url]];

	   //[request addRequestHeader:@"Content-Length" value:nil];
	   [request addRequestHeader:@"Content-type" value:@"application/json"];
	   [request addRequestHeader:@"Accept" value:@"application/json"];

	   [request signRequestWithClientIdentifier:@"wladimir@mobi-cart.com" secret:@"888252887f8d7698e89a3ebd6f2940d3" tokenIdentifier:nil secret:nil usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
	   [request startSynchronous];

	   NSString *responseString = [request responseString];

	   DLog(@"%@",responseString);*/
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:_url]];
	[request setHTTPMethod:@"POST"];
	[request setValue:nil forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setHTTPBody:nil];

	NSError *error;
	NSURLResponse *response;
	NSData *urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *data = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
	DLog(@"%@", data);
	[data release];
}

+ (UIImage *)fetchFooterLogo {
	UIImage *imgFooter;

	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/static/assets/img/footer_logo.png", urlMainServer]]];
	if (data != nil)
		imgFooter = [UIImage imageWithData:data];
	else
		imgFooter = [UIImage imageNamed:@""];
	return imgFooter;
}

+ (NSString *)getImageUrl {
	return urlMainServer;
}

@end
