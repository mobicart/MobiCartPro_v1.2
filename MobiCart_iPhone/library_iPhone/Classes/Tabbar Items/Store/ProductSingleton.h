//
//  iProductSingleton.h
//  MobicartApp
//
//  Created by Surbhi Handa on 22/08/12.
//  Copyright (c) 2012 Net Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iProductSingleton : NSObject
{
    
@private  NSData *dataForProductImage;
@private  NSData *dataForCoverProductImage;
NSArray *arrImagesUrls;
@private BOOL loadingStatus;
@private BOOL imageCheck;

}
@property(nonatomic,retain)NSArray *arrImagesUrls;
+ (iProductSingleton *)productObj;
-(NSArray *)getProductImage;
-(NSData *)setProductImage:(NSArray *)arrImagesUrls picToShowAtAIndex:(NSInteger)_picNum willZoom:(NSNumber *)isHandlingZoomImage;
-(NSData *)setProductImage:(NSMutableArray *)arrImagesUrls picToShowAtAIndex:(NSInteger)_picNum ;


@end
