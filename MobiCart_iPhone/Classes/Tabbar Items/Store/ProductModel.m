//
//  ProductModel.m
//  MobicartApp
//
//  Created by Surbhi Handa on 17/08/12.
//  Copyright (c) 2012 Net Solutions. All rights reserved.
//

#import "ProductModel.h"
#import "Constants.h"


@implementation ProductModel




+(NSData * )displayProductImage:(NSArray *)arrImagesUrls picToShowAtAIndex:(NSInteger)_picNum willZoom:(NSNumber *)isHandlingZoomImage
{
  //  UIImageView *productImg1;   
    NSData *dataForProductImage;
    DLog(@"Array images %@",[arrImagesUrls description]);
    
	if ([arrImagesUrls count]==0)
	{
		dataForProductImage =nil;//[[[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_S_New" ofType:@"png"]] autorelease];
	}
	else 
	{
        // Checking if the data is to be fetched for medium sized image, or large image
		if (!isHandlingZoomImage)
        {
            dataForProductImage = [ServerAPI fetchBannerImage:[[arrImagesUrls objectAtIndex:_picNum] objectForKey:@"productImageMediumIphone"]];
        }
        else
        {
            dataForProductImage = [ServerAPI fetchBannerImage:[[arrImagesUrls objectAtIndex:_picNum] objectForKey:@"productImageCoverFlowIphone"]];
        }
	}
    
	if (!dataForProductImage)
	{
		dataForProductImage=nil;//[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_S_New" ofType:@"png"]];
	}    
    return dataForProductImage;
}

+ (NSData *)displayProductImage:(NSMutableArray *)arrImagesUrls picToShowAtAIndex:(NSInteger)_picNum 
{
    NSData *dataForProductImage;
 //   NSMutableArray *arrImages;
    DLog(@"Aray images cover flow %@",[arrImagesUrls description]);
	if ([arrImagesUrls count]==0)
	{
		dataForProductImage = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_M" ofType:@"png"]];
	}
	else 
	{
		dataForProductImage = [ServerAPI fetchBannerImage:[[arrImagesUrls objectAtIndex:_picNum] objectForKey:@"productImageCoverFlowIphone4"]];
	}
    
	if (!dataForProductImage)
	{
		dataForProductImage = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_M" ofType:@"png"]];
	}
	
    return dataForProductImage;
}

//- (void)displayProductImage:(NSMutableArray *)arrImagesUrls picToShowAtAIndex:(NSInteger)_picNum 
//{
//	if ([arrImagesUrls count]==0)
//	{
//		dataForProductImage = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_M" ofType:@"png"]];
//	}
//	else 
//	{
//		dataForProductImage = [ServerAPI fetchBannerImage:[[arrImages objectAtIndex:_picNum] objectForKey:@"productImageCoverFlowIphone4"]];
//	}
//    
//	if (!dataForProductImage)
//	{
//		dataForProductImage = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_M" ofType:@"png"]];
//	}
//	
//}
//- (BOOL)resetControls
//{
//    DLog(@"in reset controll");
//    if ((productImg1) || (productImg1.image==nil))
//    {
//        [productImg1 setImage:[UIImage imageWithData:dataForProductImage]];
//    }
//    
//    
//	[productImg1 setContentMode:UIViewContentModeScaleAspectFit];
//   return YES;
//    }

// Without INCL TAX display-- DISCOUNTED PRICE
+(float)discountedPrice:(NSDictionary *)dicProduct
{
    float finalProductprice=0;
    
    // Calculation of Discounted Price
    if ([[dicProduct valueForKey:@"bTaxable"]intValue]==1)
	{
		if ([[dicProduct objectForKey:@"fPrice"] floatValue]>[[dicProduct valueForKey:@"fDiscountedPrice"] floatValue])
        {
            finalProductprice= [[dicProduct valueForKey:@"fDiscountedPrice"] floatValue]+[[dicProduct valueForKey:@"fTax"] floatValue];
        }
		else
        {
            finalProductprice= [[dicProduct valueForKey:@"fPrice"] floatValue]+[[dicProduct valueForKey:@"fTax"] floatValue];
        }
	}
	else 
	{
		if ([[dicProduct objectForKey:@"fPrice"] floatValue]>[[dicProduct valueForKey:@"fDiscountedPrice"] floatValue])
        {
            finalProductprice= [[dicProduct valueForKey:@"fDiscountedPrice"] floatValue];
        }
		else
        {
            finalProductprice= [[dicProduct valueForKey:@"fPrice"] floatValue];
        }
    }
    
    return finalProductprice;
}

// With INCL TAX display-- DISCOUNTED PRICE
+ (NSString *)calculateDiscountedPrice:(NSDictionary *)dicProduct
{
    float finalProductprice=[self discountedPrice:dicProduct];
    
	NSString *strFinalProductPrice=@"";
    
    // Determine Final Product Price with Tax Type 
	if ([[dicProduct valueForKey:@"bTaxable"]intValue]==1)
	{
		if (![[dicProduct objectForKey:@"sTaxType"]isEqualToString:@"default"])
        {
            strFinalProductPrice=[NSString stringWithFormat:@"%0.2f (Inc %@)",finalProductprice,[dicProduct valueForKey:@"sTaxType"]];
        }
		else
        {
            strFinalProductPrice=[NSString stringWithFormat:@"%0.2f",finalProductprice];
        }
	}
	else
    {
		strFinalProductPrice=[NSString stringWithFormat:@"%0.2f",finalProductprice];
	}
    
    return strFinalProductPrice;
}


+ (NSString *)calculateOptionDiscountedPrice:(NSDictionary *)dicProduct pPrice:(float)oPrice
{
    float finalProductprice=[self discountedPrice:dicProduct];
    
	NSString *strFinalProductPrice=@"";
    
    // Determine Final Product Price with Tax Type 
	if ([[dicProduct valueForKey:@"bTaxable"]intValue]==1)
	{
		if (![[dicProduct objectForKey:@"sTaxType"]isEqualToString:@"default"])
        {
            strFinalProductPrice=[NSString stringWithFormat:@"%0.2f (Inc %@)",finalProductprice,[dicProduct valueForKey:@"sTaxType"]];
        }
		else
        {
            strFinalProductPrice=[NSString stringWithFormat:@"%0.2f",finalProductprice];
        }
	}
	else
    {
		strFinalProductPrice=[NSString stringWithFormat:@"%0.2f",finalProductprice];
	}
    
    return strFinalProductPrice;
}


// With INCL TAX display-- ORIGINAL PRICE
+ (NSString *)calculateProductPrice:(NSDictionary *)dicProduct 
{
    NSString *strFinalPrice;
    NSString *strFinalProductPrice=[NSString stringWithFormat:@"%@",[ProductModel calculateDiscountedPrice:dicProduct]];
    
    // Determine Only Tax Type
	NSString *strTaxType=[dicProduct objectForKey:@"sTaxType"];
    
	if ([strTaxType isEqualToString:@"default"])
    {
        strTaxType=@"";
    }
	else
    {
        strTaxType=[NSString stringWithFormat:@"(Inc %@)",strTaxType];	
    }
	
	if ([[dicProduct valueForKey:@"bTaxable"]intValue]==0)
    {
        strFinalPrice=[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, [[dicProduct objectForKey:@"fPrice"] floatValue]];
    }
	else	
	{
		if ([[dicProduct objectForKey:@"fPrice"] floatValue]>[[dicProduct valueForKey:@"fDiscountedPrice"] floatValue])
		{
			if ([[dicProduct valueForKey:@"bTaxable"]intValue]==1)
            {
                strFinalPrice=[NSString stringWithFormat:@"%@%0.2f %@", _savedPreferences.strCurrencySymbol,([[dicProduct objectForKey:@"fPrice"] floatValue]+[[dicProduct objectForKey:@"fTaxOnFPrice"] floatValue]),strTaxType];
            }
			else
            {
                strFinalPrice=[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol,([[dicProduct objectForKey:@"fPrice"] floatValue]+[[dicProduct objectForKey:@"fTax"] floatValue])];
            }
		}
		else
		{
            strFinalPrice=[NSString stringWithFormat:@"%@%@", _savedPreferences.strCurrencySymbol,strFinalProductPrice];
		}
	}
    
    return strFinalPrice;
}
//--------------------------------pPrice-----------------
+(NSString*)caluatePriceOptionProduct:(NSDictionary*)dicProduct pPrice:(float)optionPrice
{
    NSString *strFinalPrice;
    NSString *strFinalProductPrice=[NSString stringWithFormat:@"%@",[ProductModel calculateDiscountedPrice:dicProduct]];
    
    
    
    // Determine Only Tax Type
	NSString *strTaxType=[dicProduct objectForKey:@"sTaxType"];
    
	if ([strTaxType isEqualToString:@"default"])
    {
        strTaxType=@"";
    }
	else
    {
        strTaxType=[NSString stringWithFormat:@"(Inc. %@)",strTaxType];	
    }
	
	if ([[dicProduct valueForKey:@"bTaxable"]intValue]==0)
    {
        strFinalPrice=[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, [[dicProduct objectForKey:@"fPrice"] floatValue]+optionPrice];
    }
	else	
	{
		if ([[dicProduct objectForKey:@"fPrice"] floatValue]>[[dicProduct valueForKey:@"fDiscountedPrice"] floatValue])
		{
			if ([[dicProduct valueForKey:@"bTaxable"]intValue]==1)
            {
                strFinalPrice=[NSString stringWithFormat:@"%@%0.2f %@", _savedPreferences.strCurrencySymbol,([[dicProduct objectForKey:@"fPrice"] floatValue]+optionPrice+[[dicProduct objectForKey:@"fTaxOnFPrice"] floatValue]),strTaxType];
            }
			else
            {
                strFinalPrice=[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol,([[dicProduct objectForKey:@"fPrice"] floatValue]+optionPrice+[[dicProduct objectForKey:@"fTax"] floatValue])];
            }
		}
		else
		{
            float oPrice=optionPrice+[strFinalProductPrice floatValue];
            strFinalPrice=[NSString stringWithFormat:@"%@%@", _savedPreferences.strCurrencySymbol,[NSString stringWithFormat:@"%0.2f",oPrice]];
		}
	}
    //float oPrice=optionPrice+[strFinalPrice floatValue];
    // strFinalPrice=[NSString stringWithFormat:@"%0.2f",oPrice]; 
    
    return strFinalPrice;
}
//--------------------------------pPrice--ORIGINAL PRICE---------------
+(NSString*)caluateOriginalPriceOptionProduct:(NSDictionary*)dicProduct pPrice:(float)optionPrice
{
    float finalProductprice=[self discountedPrice:dicProduct];
    
    finalProductprice+=optionPrice;
    
	NSString *strFinalProductPrice=@"";
    
    // Determine Final Product Price with Tax Type 
	if ([[dicProduct valueForKey:@"bTaxable"]intValue]==1)
	{
		if (![[dicProduct objectForKey:@"sTaxType"]isEqualToString:@"default"])
        {
            strFinalProductPrice=[NSString stringWithFormat:@"%0.2f (Inc. %@)",finalProductprice,[dicProduct valueForKey:@"sTaxType"]];
        }
		else
        {
            strFinalProductPrice=[NSString stringWithFormat:@"%0.2f",finalProductprice];
        }
	}
	else
    {
		strFinalProductPrice=[NSString stringWithFormat:@"%0.2f",finalProductprice];
	}
    strFinalProductPrice=[NSString stringWithFormat:@"%@%@", _savedPreferences.strCurrencySymbol,strFinalProductPrice]; 
    return strFinalProductPrice;
}

// Without INCL TAX display-- ORIGINAL PRICE
+ (NSString *)productActualPrice:(NSDictionary *)dicProduct
{
    NSString *strFinalPrice;
    NSString *strFinalProductPrice=[NSString stringWithFormat:@"%@",[ProductModel calculateDiscountedPrice:dicProduct]];
	
	if ([[dicProduct valueForKey:@"bTaxable"]intValue]==0)
    {
        strFinalPrice=[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, [[dicProduct objectForKey:@"fPrice"] floatValue]];
    }
	else	
	{
		if ([[dicProduct objectForKey:@"fPrice"] floatValue]>[[dicProduct valueForKey:@"fDiscountedPrice"] floatValue])
		{
			if ([[dicProduct valueForKey:@"bTaxable"]intValue]==1)
            {
                strFinalPrice=[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol,([[dicProduct objectForKey:@"fPrice"] floatValue]+[[dicProduct objectForKey:@"fTaxOnFPrice"] floatValue])];
            }
			else
            {
                strFinalPrice=[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol,([[dicProduct objectForKey:@"fPrice"] floatValue]+[[dicProduct objectForKey:@"fTax"] floatValue])];
            }
		}
		else
		{
            strFinalPrice=[NSString stringWithFormat:@"%@%@", _savedPreferences.strCurrencySymbol,strFinalProductPrice];
		}
	}
    //  DLog(@"%@",strFinalPrice);
    return strFinalPrice;
    
}

// ONLY PRICE WITHOUT TAX TYPE
+ (NSString *)finalPriceWithoutTaxType:(NSDictionary *)dicProduct
{
    NSString *discount;
	NSString *strTaxTypeLenght=@"";
	strTaxTypeLenght=[dicProduct objectForKey:@"sTaxType"];
	
	if ([strTaxTypeLenght isEqualToString:@"default"])
    {
		discount = [NSString stringWithFormat:@"%@%@", _savedPreferences.strCurrencySymbol,[dicProduct objectForKey:@"fPrice"]];
    }
    else
	{
		if ([[dicProduct valueForKey:@"bTaxable"]intValue]==1)
        {
            discount = [NSString stringWithFormat:@"%@%@", _savedPreferences.strCurrencySymbol,[dicProduct objectForKey:@"fPrice"]];
        }
		else
        {
            discount = [NSString stringWithFormat:@"%@%@", _savedPreferences.strCurrencySymbol,[dicProduct objectForKey:@"fPrice"]];
        }
	}
    return discount;
}


@end
