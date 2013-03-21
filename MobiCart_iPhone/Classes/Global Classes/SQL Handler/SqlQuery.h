//
//  SqlQuery.h
//  Mobicart
//
//  Created by Mobicart on 05/05/09.
//  Copyright 2009 Mobicart. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sql_Database.h"

@interface SqlQuery : Sql_Database
{
    NSMutableArray *arrAccountData;
    NSMutableArray *arrProductIDs;
    NSMutableArray *arrProductSizes;
    NSMutableArray *arrProductOption;
    NSMutableArray *arrShoppingCartQueue;
    NSString *strValue;
    NSMutableDictionary *dictData;
}

+ (id)shared;
#pragma mark Shopping cart
- (void)updateTblShoppingCart: (int)quantity :(int)productID : (NSString *)productOptionID;
- (void)deleteItemFromShoppingCart:(NSInteger)iProductId : (NSString *)productOptionID;
- (NSMutableArray *)getShoppingProductSizes:(int)productID;
- (void)setTblShoppingCart:(int)productID :(int)quantity :(NSString *)iProductOptionsId;
- (NSMutableArray *) getShoppingCartProductIDs:(BOOL)isCheck;
- (void)emptyShoppingCart;

#pragma mark My Account

/***** Setters ******/
-(void)setTblAccountDetails:(NSString *)userName :(NSString *)eMailAddress :(NSString *)password :(NSString *)streetAddress :(NSString *)city :(NSString *)country :(NSString *)state :(NSString *)pincode :(NSString *)deliveryStreetAddress :(NSString *)deliveryCity :(NSString *)deliveryCountry :(NSString *)deliveryState :(NSString *)deliveryPincode;

- (void)updateTblAccountDetails:(NSString *)streetAddress :(NSString *)city :(NSString *)state :(NSString *)country :(NSString *)pincode :(NSString *)deliveryStreetAddress :(NSString *)deliveryCity :(NSString *)deliveryCountry :(NSString *)deliveryState :(NSString *)deliveryPincode :(NSString *)eMailAddress
;

/****** Getters *******/
- (NSString *) getPassword:(NSString *)eMailAddress;
- (NSMutableArray *)getAccountData:(NSString *)eMailAddress;

#pragma mark Wishlist

- (void)setTblWishlist:(int)productID :(int)quantity :(NSString *)iProductOptionsId;
- (NSMutableArray *)getWishlistProductIDs:(BOOL)isCheck;
- (NSMutableArray *)getWishListProductSizes:(int)productID;
- (void)deleteItemFromWishList:(NSInteger)iProductId : (NSString *)sProductOptionID;
- (void)deleteItemFromWishList:(NSInteger)iProductId;

// Retreive buyer details, (In case of paypal transactions)
- (NSArray *)getBuyerData:(NSString *)eMailAddress;

#pragma mark - TblQueue_ShoppingCart
- (void)addToQueue_Shoppingcart:(NSString *)dataToSend sendAtUrl:(NSString *)url;
- (void)deleteItemFromShoppingQueue:(NSInteger)iShoppingOrderNum;

#pragma mark - TblQueue_IndvidualProducts
- (void)addToQueue_IndividualProducts:(NSInteger)iShoppingOrderNum dataToSend:(NSString *)data  sendAtUrl:(NSString *)url;

- (NSMutableArray *) getShoppingCartQueue;
- (void)deleteItemFromIndividualQueue:(NSInteger)iProductId;
- (NSMutableArray *) getIndividualProducts_Queue:(NSInteger) iShoppingOrderNum_FromLocalDB;
- (void)updateIndividualProducts_Queue:(NSInteger) iShoppingOrderNum_FromLocalDB :(NSInteger) _id;

#pragma mark LANGUAGE PACK DATABASE OPERATIONS
- (void)deleteLangLabels;
- (void)saveLanguageLabels:(NSDictionary *)dictData;
- (NSString *)getLanguageLabel:(NSString *)strKey;
- (NSDictionary*)getAllLabels;
- (NSString *)getTimeStamp;

@end
