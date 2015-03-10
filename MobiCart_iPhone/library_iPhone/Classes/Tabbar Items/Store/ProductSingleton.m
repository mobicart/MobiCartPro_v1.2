//
//  iProductSingleton.m
//  MobicartApp
//
//  Created by Surbhi Handa on 22/08/12.
//  Copyright (c) 2012 Net Solutions. All rights reserved.
//

#import "ProductSingleton.h"
#import "Constants.h"

@implementation iProductSingleton
@synthesize arrImagesUrls;
static iProductSingleton *productObj;

+ (iProductSingleton *)productObj 
{
	@synchronized(self) 
	{
		if(!productObj) 
		{
			productObj = [[iProductSingleton alloc] init];
			DLog(@"session object initialized");			
		}
		DLog(@"session already initialized");
	}
	DLog(@"returning session object");
	
	return productObj;
    
    }

-(NSArray *)getProductImage
{
    NSDictionary *dictTemp = [GlobalPreferences getCurrentFeaturedDetails];
    arrImagesUrls = [dictTemp objectForKey:@"productImages"];
    
    DLog(@"Dictemp description %@",[arrImagesUrls description]);
    return arrImagesUrls;
}

-(NSData * )setProductImage:(NSArray *)arrImagesUrlArray picToShowAtAIndex:(NSInteger)_picNum willZoom:(NSNumber *)isHandlingZoomImage
{
    DLog(@"Array images %@",[arrImagesUrlArray description]);
    
	if ([arrImagesUrlArray count]==0)
	{
		dataForProductImage =nil;//[[[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_S_New" ofType:@"png"]] autorelease];
		loadingStatus=NO;
		imageCheck=YES;
	}
	else 
	{
        // Checking if the data is to be fetched for medium sized image, or large image
		if (!isHandlingZoomImage)
        {
            dataForProductImage = [ServerAPI fetchBannerImage:[[arrImagesUrlArray objectAtIndex:_picNum] objectForKey:@"productImageMediumIphone"]];
        }
        else
        {
            dataForProductImage = [ServerAPI fetchBannerImage:[[arrImagesUrlArray objectAtIndex:_picNum] objectForKey:@"productImageCoverFlowIphone"]];
        }
	}
    
	if (!dataForProductImage)
	{
		dataForProductImage=nil;//[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_S_New" ofType:@"png"]];
		imageCheck=YES;
	}
    
    
    return dataForProductImage;
    

	
	
}
- (NSData *)setProductImage:(NSMutableArray *)imagesUrls picToShowAtAIndex:(NSInteger)_picNum 
{
  
    //   NSMutableArray *arrImages;
    DLog(@"Aray images cover flow %@",[imagesUrls description]);
	if ([imagesUrls count]==0)
	{
		dataForCoverProductImage = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_M" ofType:@"png"]];
	}
	else 
	{
		dataForCoverProductImage = [ServerAPI fetchBannerImage:[[imagesUrls objectAtIndex:_picNum] objectForKey:@"productImageCoverFlowIphone4"]];
	}
    
	if (!dataForCoverProductImage)
	{
		dataForCoverProductImage = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_M" ofType:@"png"]];
	}
	
    return dataForCoverProductImage;
}
@end
