//
//  ServerAPIiPad.m
//  ServerAPIiPad
//
//  Created by sumeet Kumar on 06/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerAPI.h"
#import "SBJSON.h"
//*******Store *********


//#define urlMainServer @"http://www.mobi-cart.com"

#define urlMainServer @"http://192.168.100.71:8181"

#pragma mark Store
#define urlAppFeatures @"app"
#define urlAppColorPreferences @"encolorscheme.json"
#define jsonDepartments_FileName @"/departments.json"
#define jsonCategories_FileName @"/categories.json"
#define jsonProducts_FileName @"/products.json"
#define jsonDetails_FileName @"/details.json"

#define urlStore @"store"

#define urlAnalyticsForProductViews @"product"
@implementation ServerAPI

SBJSON *_JSONParser;
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
		NSLog(@"Exception handling error: %@", ex);
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
		NSLog(@"Exception handling error: %@", ex);
		return FALSE;
	}
}

#pragma mark -
#pragma mark App Level Settings
+ (NSDictionary *)getAppStoreUserDetails:(NSString *)merchant_email {
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/user/%@/app-store-user.json", urlMainServer, merchant_email]];
	return dicTemp;
}

+ (NSDictionary *)fetchAppFeatures:(NSInteger)iCurrentAppId    //for app settings such as tab bar preferences etc.
{
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/features.json", urlMainServer, urlAppFeatures, iCurrentAppId]];
	return dicTemp;
}

+ (NSDictionary *)fetchAppColorScheme:(NSInteger)iCurrentAppId {
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/%@", urlMainServer, urlAppFeatures, iCurrentAppId, urlAppColorPreferences]];
	return dicTemp;
}

+ (NSDictionary *)fetchAppVitals:(NSInteger)iCurrentAppId {
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/vitals.json", urlMainServer, urlAppFeatures, iCurrentAppId]];
	return dicTemp;
}

+ (NSDictionary *)fetchStaticPages:(NSInteger)iCurrentAppId {
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/app/%d/static-pages.json", urlMainServer, iCurrentAppId]];
	return dicTemp;
}

+ (NSDictionary *)fetchSettings:(NSInteger)iCurrentStoreId {
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/settings.json", urlMainServer, urlStore, iCurrentStoreId]
	    ];
	return dicTemp;
}

+ (NSDictionary *)fetchMerchantAddress:(NSString *)merchant_email {
	NSString *strTemp = [NSString stringWithFormat:@"%@/user/%@/address.json", urlMainServer, merchant_email];
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:strTemp];
	return dicTemp;
}

#pragma mark -
#pragma mark Home Page Methods


+ (NSDictionary *)fetchGallaryImages:(NSInteger)iCurrentStoreId {
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/gallery-images.json", urlMainServer, urlStore, iCurrentStoreId]];
	return dicTemp;
}

+ (NSDictionary *)fetchFeaturedproducts:(int)countryID:(int)stateID:(NSInteger)iCurrentAppId {
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/featured-products.json?c=%d&s=%d", urlMainServer, urlAppFeatures, iCurrentAppId, countryID, stateID]];
	return dicTemp;
}

#pragma mark -
#pragma mark Store
+ (NSDictionary *)fetchAllProductsInStore:(int)_countryID stateID:(int)_stateID:(NSInteger)iCurrentStoreId {
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/store/%d/products.json?c=%d&s=%d", urlMainServer, iCurrentStoreId, _countryID, _stateID]];
	NSLog(@"%@", [NSString stringWithFormat:@"%@/store/%d/products.json?c=%d&s=%d", urlMainServer, iCurrentStoreId, _countryID, _stateID]);
	return dicTemp;
}

+ (NSString *)getCategoriesUrl:(NSInteger)_iCurrentDepartmentId:(NSInteger)iCurrentStoreId {
	return [NSString stringWithFormat:@"%@/%@/%d/department/%d%@", urlMainServer, urlStore, iCurrentStoreId, _iCurrentDepartmentId, jsonCategories_FileName];
}

+ (NSString *)getDepartmentUrl:(NSInteger)iCurrentStoreId {
	return [NSString stringWithFormat:@"%@/%@/%d%@", urlMainServer, urlStore, iCurrentStoreId, jsonDepartments_FileName];
}

+ (NSDictionary *)fetchDepartments:(NSInteger)iCurrentStoreId {
	NSString *strTemp  = [ServerAPI getDepartmentUrl:iCurrentStoreId];
	//fetch data from server
	NSDictionary *dictFeatures = [ServerAPI fetchDataFromServer:strTemp];
	return dictFeatures;
}

+ (NSDictionary *)fetchSubDepartments:(NSInteger)deptID:(NSInteger)iCurrentStoreId {
	NSString *strTemp = [ServerAPI getCategoriesUrl:deptID:iCurrentStoreId];
	NSDictionary *dictCategories = [ServerAPI fetchDataFromServer:strTemp];
	return dictCategories;
}

+ (NSDictionary *)fetchProductsWithCategories:(int)catID:(int)CountryID:(int)StateID:(NSInteger)iCurrentStoreId:(NSInteger)iCurrentDepartmentId {
	NSString *strTemp = [NSString stringWithFormat:@"%@?c=%d&s=%d", [ServerAPI getProductsUrl:catID:iCurrentStoreId:iCurrentDepartmentId], CountryID, StateID];
	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:strTemp];

	return dictTemp;
}

+ (NSDictionary *)fetchProductsWithoutCategories:(int)deptID:(int)CountryID:(int)StateID:(NSInteger)iCurrentStoreId {
	NSString *strUrl = [NSString stringWithFormat:@"%@", [ServerAPI getproductsWithoutCatogeriesUrl:deptID:iCurrentStoreId]];

	NSString *strCurrentProductURL = [NSString stringWithFormat:@"%@?c=%d&s=%d", strUrl, CountryID, StateID];

	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:strCurrentProductURL];

	return dictTemp;
}

+ (void)fetchProductAnalytics:(NSString *)sProductId {
	int iProductId = [sProductId intValue];
	NSString *strCurrentProductAnalyticsUrl = [NSString stringWithFormat:@"%@/%@/%d/view.json", urlMainServer, urlAnalyticsForProductViews, iProductId];
	[ServerAPI fetchDataFromServer:strCurrentProductAnalyticsUrl];
}

+ (NSDictionary *)fetchNewsAndTwitter:(NSInteger)iCurrentAppId {
	NSString *path = [NSString stringWithFormat:@"%@/%@/%d/news-items.json", urlMainServer, urlAppFeatures, iCurrentAppId];
	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:path];
	return dictTemp;
}

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

// 08/01/2015 Tuyen handle send list Order Item to server
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

+ (NSString *)SQLServerAPI:(NSString *)urlData:(NSString *)strDataToPost {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlMainServer, urlData]];
	NSString *reponseRecieved = [ServerAPI checkoutSendData:url withData:strDataToPost];
	return reponseRecieved;
}

+ (NSDictionary *)fetchProductDetails:(int)productId:(int)lcountryID:(int)stateID {
	NSString *strTemp = [NSString stringWithFormat:@"%@/%@/%d/%@?c=%d&s=%d", urlMainServer, urlAnalyticsForProductViews, productId, jsonDetails_FileName, lcountryID, stateID];
	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:strTemp];
	return dictTemp;
}

#pragma mark TaxShippingDetails
+ (NSDictionary *)fetchTaxShippingDetails:(int)countryID:(int)stateID:(NSInteger)iCurrentStoreId {
	NSString *strTempUrl = [NSString stringWithFormat:@"%@/store/%d/country/%d/state/%d/tax-shipping.json", urlMainServer, iCurrentStoreId, countryID, stateID];
	NSDictionary *dicTemp = [[ServerAPI fetchDataFromServer:strTempUrl] retain];
	return dicTemp;
}

+ (NSData *)fetchBannerImage:(NSString *)strImage {
	NSData *dataBannerImage = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlMainServer, strImage]]];
	return dataBannerImage;
}

+ (NSDictionary *)fetchDetailsOfProductWithID:(int)_productID {
	NSString *strTemp = [NSString stringWithFormat:@"%@/product/%d/details.json", urlMainServer, _productID];
	NSDictionary *dictProducts = [ServerAPI fetchDataFromServer:strTemp];
	return dictProducts;
}

+ (NSDictionary *)fetchDetailsOfProductWithID:(int)_productID countryID:(int)_country stateID:(int)_state {
	NSString *strTemp = [NSString stringWithFormat:@"%@/product/%d/details.json?c=%d&s=%d", urlMainServer, _productID, _country, _state];
	NSDictionary *dictProducts = [ServerAPI fetchDataFromServer:strTemp];
	return dictProducts;
}

+ (NSString *)getProductsUrl:(NSInteger)_iCurrentProductId:(NSInteger)iCurrentStoreId:(NSInteger)iCurrentDepartmentId {
	return [NSString stringWithFormat:@"%@/%@/%d/department/%d/category/%d%@", urlMainServer, urlStore, iCurrentStoreId, iCurrentDepartmentId, _iCurrentProductId, jsonProducts_FileName];
}

+ (NSString *)getproductsWithoutCatogeriesUrl:(NSInteger)_iCurrentDepartmentId:(NSInteger)iCurrentStoreId {
	return [NSString stringWithFormat:@"%@/store/%d/department/%d/products.json", urlMainServer, iCurrentStoreId, _iCurrentDepartmentId];
}

+ (NSDictionary *)fetchnextfeatureProduct:(int)depId countryId:(int)countryId stateId:(int)stateId:(NSInteger)iCurrentStoreId {
	NSString *strUrl = [NSString stringWithFormat:@"%@", [ServerAPI getproductsWithoutCatogeriesUrl:depId:iCurrentStoreId]];
	NSString *strCurrentProductURLNextProduct = [NSString stringWithFormat:@"%@?c=%d&s=%d", strUrl, countryId, stateId];
	NSDictionary *dictDataForNextProduct =  [ServerAPI fetchDataFromServer:strCurrentProductURLNextProduct];
	return dictDataForNextProduct;
}

+ (NSDictionary *)fetchnextfeatureProductwithcategory:(int)depId catId:(int)Catid countryId:(int)countryId stateId:(int)stateId:(NSInteger)iCurrentStoreId {
	NSString *strCurrentProductURLNextProduct = [NSString stringWithFormat:@"%@/%@/%d/department/%d/category/%d/products.json?c=%d&s=%d", urlMainServer, urlStore, iCurrentStoreId, depId, Catid, countryId, stateId];
	NSDictionary *dictDataForNextProduct =  [ServerAPI fetchDataFromServer:strCurrentProductURLNextProduct];
	return dictDataForNextProduct;
}

+ (NSDictionary *)fetchOrderDetails:(NSString *)_userEmail:(NSInteger)iCurrentAppId:(NSInteger)iCurrentStoreId {
	NSString *strURL = [NSString stringWithFormat:@"%@/app/%d/store/%d/buyer/%@/product-order-history.json", urlMainServer, iCurrentAppId, iCurrentStoreId, _userEmail];
	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:strURL];
	return dictTemp;
}

+ (NSString *)postReviewRatings:(NSString *)strDataToPost {
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/product-review-rating/save", urlMainServer]];
	NSString *reponseRecieved = [ServerAPI checkoutSendData:url withData:strDataToPost];
	return reponseRecieved;
}

+ (NSDictionary *)fetchTabbarPreferences:(NSInteger)iCurrentAppId {
	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:[NSString stringWithFormat:@"%@/%@/%d/features.json", urlMainServer, urlAppFeatures, iCurrentAppId]];
	return dicTemp;
}

+ (NSDictionary *)fetchStatesOfCountryWithID:(int)_countryID {
	NSString *strTemp = [NSString stringWithFormat:@"%@/country/%d/states.json", urlMainServer, _countryID];
	NSDictionary *dictStates = [ServerAPI fetchDataFromServer:strTemp];
	return dictStates;
}

+ (NSDictionary *)fetchStatesOfAcountryURL:(NSInteger)_iCountryCode {
	NSString *strURL = [NSString stringWithFormat:@"%@/country/%d/states.json", urlMainServer, _iCountryCode];

	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:strURL];
	return dicTemp;
}

+ (NSDictionary *)fetchGlobalSearchProducts:(NSString *)productName:(NSInteger)iCurrentAppId {
	NSString *strSearchKeywordUrl = [NSString stringWithFormat:@"%@/app/%d/search/%@/products.json", urlMainServer, iCurrentAppId, productName];

	NSDictionary *dicTemp = [ServerAPI fetchDataFromServer:strSearchKeywordUrl];
	return dicTemp;
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
	NSLog(@"%@", data);
	return data;
}

+ (void)pushNotifications:(NSString *)strLatitude:(NSString *)strLongitude:(NSString *)tokenString:(NSInteger)iCurrentAppId {
	NSString *urlDeviceTokenForNotification = [NSString stringWithFormat:@"%@/user/%d/%@/%@/%@/register.json", urlMainServer, iCurrentAppId, tokenString, strLongitude, strLatitude];
	[ServerAPI sendDataToServer:urlDeviceTokenForNotification];
}

+ (void)sendDataToServer:(NSString *)_url {
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
	NSLog(@"%@", data);
}

+ (NSURLRequest *)createTweetImageRequest:(NSString *)url {
	NSURLRequest *request;
	if (url != nil) {
		request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
	}
	return request;
}

#pragma mark -  Logo Nav Bar

+ (UIImage *)setLogoImage:(NSString *)logoUrl:(BOOL)isNull {
	UIImage *imgLogoLocal;

	if (isNull)
		imgLogoLocal = [UIImage imageNamed:@"Icon.png"];
	else {
		NSData *logoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", urlMainServer, logoUrl]]];


		imgLogoLocal = [UIImage imageWithData:logoData];
	}

	return imgLogoLocal;
}

#pragma mark -
#pragma mark fetchDataFromServer
+ (NSDictionary *)fetchDataFromServer:(NSString *)strURL {
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
	   NSLog(@"Exception handling error: %@",ex);
	   return nil;
	   }
	   return nil;
	 */

	if (!_JSONParser)
		_JSONParser = [[SBJSON alloc]init];
	@try {
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
		[request setURL:[NSURL URLWithString:strURL]];
		[request setHTTPMethod:@"POST"];
		// NSLog(@"%@",strURL);
		NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];

		NSDictionary *dict_JSONData = (NSDictionary *)[_JSONParser objectWithString:returnString error:nil];
		return(dict_JSONData);
	}
	@catch (NSException *ex)
	{
		NSLog(@"Exception handling error: %@", ex);
		return nil;
	}
	return nil;
}

+ (NSDictionary *)fetchNewsFromServer:(NSString *)strURL {
	if (!_JSONParser)
		_JSONParser = [[SBJSON alloc]init];
	@try {
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
		[request setURL:[NSURL URLWithString:strURL]];
		[request setHTTPMethod:@"POST"];

		NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		NSString *returnString = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];

		NSDictionary *dict_JSONData = (NSDictionary *)[_JSONParser objectWithString:returnString error:nil];
		return(dict_JSONData);
	}
	@catch (NSException *ex)
	{
		NSLog(@"Exception handling error: %@", ex);
		return nil;
	}
	return nil;
}

#pragma mark fetchDataFromServer
/*+ (NSString *)secureRequest:(NSURL *)url
   {
    @try
    {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];//888252887f8d7698e89a3ebd6f2940d3
        [request signRequestWithClientIdentifier:merchant_email secret:merchant_secret_key tokenIdentifier:nil secret:nil usingMethod:ASIOAuthHMAC_SHA1SignatureMethod];
        [request startSynchronous];
        NSString *responseString = [request responseString];
        return responseString;
    }
    @catch (NSException *ex)
    {
        NSLog(@"Exception handling error: %@",ex);
        return nil;
    }
    return nil;
   }*/
+ (UIImage *)fetchFooterLogo {
	UIImage *imgFooter;
	//  NSString *str=[NSString stringWithFormat:@"%@/static/assets/img/footer_logo.png",urlMainServer];
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

+ (NSDictionary *)fetchTweets:(NSInteger)iCurrentStoreId {
	NSString *strURL = [NSString stringWithFormat:@"%@/search/%d/tweets.json", urlMainServer, iCurrentStoreId];
	NSDictionary *dictTemp = [ServerAPI fetchDataFromServer:strURL];
	return dictTemp;
}

@end
