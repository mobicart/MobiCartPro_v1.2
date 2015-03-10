//
//  ProductModel.h
//  MobicartApp
//
//  Created by Surbhi Handa on 17/08/12.
//  Copyright (c) 2012 Net Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GlobalPreferences.h"
#import "Constants.h"
#import "SBJSON.h"

@interface ProductModel : NSObject
{
      
 
}


//**********


+ (NSString *)productActualPrice:(NSDictionary *)dicProduct;//product Actual price
+ (float)discountedPrice:(NSDictionary *)dicProduct;

+ (NSString *)calculateProductPrice:(NSDictionary *)dictData;//Product price without Discount
+ (NSString *)calculateDiscountedPrice:(NSDictionary *)dicProduct;//Discounted price of product

+ (NSString *)finalPriceWithoutTaxType:(NSDictionary *)dicProduct;// Price without tax
//Actual Price
+(NSString*)caluatePriceOptionProduct:(NSDictionary*)dicProduct pPrice:(float)optionPrice;
+ (NSString *)calculateOptionDiscountedPrice:(NSDictionary *)dicProduct pPrice:(float)oPrice;
+(NSString*)caluateOriginalPriceOptionProduct:(NSDictionary*)dicProduct pPrice:(float)optionPrice;

+(NSData *)displayProductImage:(NSArray *)arrImagesUrls picToShowAtAIndex:(NSInteger)_picNum willZoom:(NSNumber *)isHandlingZoomImage;

+(NSData *)displayProductImage:(NSMutableArray *)arrImagesUrls picToShowAtAIndex:(NSInteger)_picNum ;


//+(NSData *)displayProductName:(NSArray *)arrImagesUrls picToShowAtAIndex:(NSInteger)_picNum;

//+(NSInteger *)displayCartItemCount:(NSDictionary *)cartDict;
//- (BOOL)resetControls;




@end
