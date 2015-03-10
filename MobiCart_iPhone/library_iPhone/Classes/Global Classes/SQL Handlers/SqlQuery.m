//
//  SqlQuery.m
//  Mobicart
//
//  Created by Mobicart on 05/05/09.
//  Copyright 2009 Mobicart. All rights reserved.
//

#import "SqlQuery.h"
#import "Constants.h"


@implementation SqlQuery

static SqlQuery *shared;

// Intitializes SqlQuery instance
- (id)init 
{
	if (shared) 
    {
        [self autorelease];
        return shared;
    }
	
	self =[super init];
//	shared = self;
	return self;
} 

// Creates a single instance of SqlQuery and returns the same every time called.
+ (id)shared 
{
    if (!shared) 
	{
        shared=[[SqlQuery alloc] init];
    }
    return shared;
}

#pragma mark User Account Details 



- (void)setTblAccountDetails:(NSString *)userName :(NSString *)eMailAddress :(NSString *)password :(NSString *)streetAddress :(NSString *)city :(NSString *)country :(NSString *)state :(NSString *)pincode :(NSString *)deliveryStreetAddress :(NSString *)deliveryCity :(NSString *)deliveryCountry :(NSString *)deliveryState :(NSString *)deliveryPincode
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *strQuery = [NSString stringWithFormat:@"insert into TblAccountDetails (sUserName, eMailAddress, sPassword, sStreetAddress, sCity, sState, sPincode, sCountry, sDeliveryStreetAddress, sDeliveryCity, sDeliveryState, sDeliveryPincode, sDeliveryCountry) values (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\",\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")", userName, eMailAddress, password, streetAddress, city, state, pincode, country, deliveryStreetAddress, deliveryCity, deliveryState, deliveryPincode, deliveryCountry];
	
	sql4 = [strQuery UTF8String];
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	int success=sqlite3_step(s_statement);
	if(success==SQLITE_ERROR)
	{
		NSAssert1 (0,@"Error: '%s'",sqlite3_errmsg(database));
	}
	sqlite3_finalize(s_statement);
}

- (void)updateTblAccountDetails:(NSString *)streetAddress :(NSString *)city :(NSString *)state :(NSString *)country :(NSString *)pincode :(NSString *)deliveryStreetAddress :(NSString *)deliveryCity :(NSString *)deliveryCountry :(NSString *)deliveryState :(NSString *)deliveryPincode : (NSString *)eMailAddress
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *strQuery = [NSString stringWithFormat:@"Update TblAccountDetails set  sStreetAddress=\"%@\", sCity=\"%@\", sState=\"%@\", sPincode=\"%@\", sCountry=\"%@\", sDeliveryStreetAddress=\"%@\", sDeliveryCity=\"%@\", sDeliveryState=\"%@\", sDeliveryPincode=\"%@\", sDeliveryCountry=\"%@\" where eMailAddress=\"%@\"", streetAddress, city, state, pincode, country, deliveryStreetAddress, deliveryCity, deliveryState, deliveryPincode, deliveryCountry, eMailAddress];
	
	sql4 = [strQuery UTF8String];
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	int success=sqlite3_step(s_statement);
	if(success==SQLITE_ERROR)
	{
		NSAssert1 (0,@"Error: '%s'",sqlite3_errmsg(database));
	}
	sqlite3_finalize(s_statement);
}

- (NSString *)getPassword:(NSString *)eMailAddress
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *str=[NSString stringWithFormat:@"select sPassword from TblAccountDetails where eMailAddress=\"%@\"",eMailAddress]; 
	
	sql4 = [str UTF8String];
	
	NSString *password = [NSString stringWithFormat:@""];
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	while (sqlite3_step(s_statement) == SQLITE_ROW)
	{
		char *cString;
		cString = (char *)sqlite3_column_text(s_statement, 0);
		
		password = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
		
	}
	
	sqlite3_finalize(s_statement);
	return password;
}

- (NSMutableArray *)getAccountData:(NSString *)eMailAddress
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *str=[NSString stringWithFormat:@"select * from TblAccountDetails where eMailAddress=\"%@\"",eMailAddress]; 
	
	sql4 = [str UTF8String];
	
	arrAccountData=[[NSMutableArray alloc]init];
	
	NSString *mailAddress, *streetAddress, *city, *state, *pincode, *country, *deliveryAddress, *deliveryCity, *deliveryState, *deliveryPincode, *deliveryCountry;
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	while (sqlite3_step(s_statement) == SQLITE_ROW)
	{
		char *cString, *cString1, *cString2, *cString3, *cString4, *cString5, *cString6, *cString7, *cString8, *cString9, *cString10;
		cString = (char *)sqlite3_column_text(s_statement, 1);
		cString1 = (char *)sqlite3_column_text(s_statement, 3);
		cString2 = (char *)sqlite3_column_text(s_statement, 4);
		cString3 = (char *)sqlite3_column_text(s_statement, 5);
		cString4 = (char *)sqlite3_column_text(s_statement, 6);
		cString5 = (char *)sqlite3_column_text(s_statement, 7);
		cString6 = (char *)sqlite3_column_text(s_statement, 8);
		cString7 = (char *)sqlite3_column_text(s_statement, 9);
		cString8 = (char *)sqlite3_column_text(s_statement, 10);
		cString9 = (char *)sqlite3_column_text(s_statement, 11);
		cString10 = (char *)sqlite3_column_text(s_statement, 12);
		
		mailAddress = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
		streetAddress = [[[NSString alloc] initWithString:(cString1) ? [NSString stringWithUTF8String:cString1]: @""] autorelease];
		city = [[[NSString alloc] initWithString:(cString2) ? [NSString stringWithUTF8String:cString2]: @""] autorelease];
		state = [[[NSString alloc] initWithString:(cString3) ? [NSString stringWithUTF8String:cString3]: @""] autorelease];
		pincode = [[[NSString alloc] initWithString:(cString4) ? [NSString stringWithUTF8String:cString4]: @""] autorelease];
		country = [[[NSString alloc] initWithString:(cString5) ? [NSString stringWithUTF8String:cString5]: @""] autorelease];
		deliveryAddress = [[[NSString alloc] initWithString:(cString6) ? [NSString stringWithUTF8String:cString6]: @""] autorelease];
		deliveryCity = [[[NSString alloc] initWithString:(cString7) ? [NSString stringWithUTF8String:cString7]: @""] autorelease];
		deliveryState = [[[NSString alloc] initWithString:(cString8) ? [NSString stringWithUTF8String:cString8]: @""] autorelease];
		deliveryPincode = [[[NSString alloc] initWithString:(cString9) ? [NSString stringWithUTF8String:cString9]: @""] autorelease];
		deliveryCountry = [[[NSString alloc] initWithString:(cString10) ? [NSString stringWithUTF8String:cString10]: @""] autorelease];
		
		[arrAccountData addObject:mailAddress];
		[arrAccountData addObject:streetAddress];
		[arrAccountData addObject:city];
		[arrAccountData addObject:state];
		[arrAccountData addObject:pincode];
		[arrAccountData addObject:country];
		[arrAccountData addObject:deliveryAddress];
		[arrAccountData addObject:deliveryCity];
		[arrAccountData addObject:deliveryState];
		[arrAccountData addObject:deliveryPincode];
		[arrAccountData addObject:deliveryCountry];
	}
	
	sqlite3_finalize(s_statement);
	return arrAccountData;
}

//returing Buyer's detail, needs to be fetched in case of paypal transactions
- (NSArray *)getBuyerData:(NSString *)eMailAddress
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *str=[NSString stringWithFormat:@"select * from TblAccountDetails where eMailAddress=\"%@\"",eMailAddress]; 
	
	sql4 = [str UTF8String];
	
	arrAccountData=[[NSMutableArray alloc]init];
	
	NSString *userName, *mailAddress, *streetAddress, *city, *state, *pincode, *country, *deliveryAddress, *deliveryCity, *deliveryState, *deliveryPincode, *deliveryCountry;
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	while (sqlite3_step(s_statement) == SQLITE_ROW)
	{
		char *cStringUser, *cString, *cString1, *cString2, *cString3, *cString4, *cString5, *cString6, *cString7, *cString8, *cString9, *cString10;
		cStringUser = (char *)sqlite3_column_text(s_statement, 0);
		cString = (char *)sqlite3_column_text(s_statement, 1);
		cString1 = (char *)sqlite3_column_text(s_statement, 3);
		cString2 = (char *)sqlite3_column_text(s_statement, 4);
		cString3 = (char *)sqlite3_column_text(s_statement, 5);
		cString4 = (char *)sqlite3_column_text(s_statement, 6);
		cString5 = (char *)sqlite3_column_text(s_statement, 7);
		cString6 = (char *)sqlite3_column_text(s_statement, 8);
		cString7 = (char *)sqlite3_column_text(s_statement, 9);
		cString8 = (char *)sqlite3_column_text(s_statement, 10);
		cString9 = (char *)sqlite3_column_text(s_statement, 11);
		cString10 = (char *)sqlite3_column_text(s_statement, 12);
		
		userName = [[[NSString alloc] initWithString:(cStringUser) ? [NSString stringWithUTF8String:cStringUser]: @""] autorelease];
		mailAddress = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
		streetAddress = [[[NSString alloc] initWithString:(cString1) ? [NSString stringWithUTF8String:cString1]: @""] autorelease];
		city = [[[NSString alloc] initWithString:(cString2) ? [NSString stringWithUTF8String:cString2]: @""] autorelease];
		state = [[[NSString alloc] initWithString:(cString3) ? [NSString stringWithUTF8String:cString3]: @""] autorelease];
		pincode = [[[NSString alloc] initWithString:(cString4) ? [NSString stringWithUTF8String:cString4]: @""] autorelease];
		country = [[[NSString alloc] initWithString:(cString5) ? [NSString stringWithUTF8String:cString5]: @""] autorelease];
		deliveryAddress = [[[NSString alloc] initWithString:(cString6) ? [NSString stringWithUTF8String:cString6]: @""] autorelease];
		deliveryCity = [[[NSString alloc] initWithString:(cString7) ? [NSString stringWithUTF8String:cString7]: @""] autorelease];
		deliveryState = [[[NSString alloc] initWithString:(cString8) ? [NSString stringWithUTF8String:cString8]: @""] autorelease];
		deliveryPincode = [[[NSString alloc] initWithString:(cString9) ? [NSString stringWithUTF8String:cString9]: @""] autorelease];
		deliveryCountry = [[[NSString alloc] initWithString:(cString10) ? [NSString stringWithUTF8String:cString10]: @""] autorelease];
		
		
		
		NSDictionary *dictBuyerDetails=[[NSDictionary alloc] initWithObjectsAndKeys: userName, @"sUserName", mailAddress, @"sEmailAddress", streetAddress, @"sStreetAddress",city, @"sCity", state, @"sState", pincode, @"sPincode", country, @"sCountry", deliveryAddress, @"sDeliveryAddress",  deliveryCity, @"sDeliveryCity",deliveryState, @"sDeliveryState",  deliveryPincode, @"sDeliveryPincode",deliveryCountry,@"sDeliveryCountry",nil];
		
		[arrAccountData addObject:dictBuyerDetails];
		[dictBuyerDetails release];
	}
	sqlite3_finalize(s_statement);
	return arrAccountData;
}

#pragma mark  Wishlish
- (void)setTblWishlist:(int)productID :(int)quantity :(NSString *)iProductOptionsId
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	
	sql4 = 	 "insert into TblWishlist (iProductId,iQuantity,iProductOptionId) values(?,?,?)";
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_bind_int(s_statement, 1, productID);
	sqlite3_bind_int(s_statement, 2, quantity);
	sqlite3_bind_text(s_statement, 3, [iProductOptionsId UTF8String], -1, SQLITE_TRANSIENT);
	
	//sqlite3_bind_text(s_statement, 3,iProductOptionsId);
	//sqlite3_bind_int(s_statement, 3, iProductOptionsId);
	
	int success=sqlite3_step(s_statement);
	if(success==SQLITE_ERROR)
	{
		NSAssert1 (0,@"Error: '%s'",sqlite3_errmsg(database));
	}
	sqlite3_finalize(s_statement);
	
}

- (NSMutableArray *)getWishlistProductIDs:(BOOL)isCheck
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *str=[NSString stringWithFormat:@"select * from TblWishlist"]; 
	
	sql4 = [str UTF8String];
	
	arrProductIDs=[[NSMutableArray alloc]init];
	
	NSString *productID,*quantity,*productOptionID;
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	if(isCheck)
	{
		while (sqlite3_step(s_statement) == SQLITE_ROW)
		{
			char *cString, *cString1;
			cString = (char *)sqlite3_column_text(s_statement, 1);
			cString1 = (char *)sqlite3_column_text(s_statement, 0);
			
			productID = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
			productOptionID = [[[NSString alloc] initWithString:(cString1) ? [NSString stringWithUTF8String:cString1]: @""] autorelease];
			
			NSDictionary *dicAddedProducts=[[NSDictionary alloc] initWithObjectsAndKeys: productID, @"id", productOptionID, @"productOptionID", nil];
			
			[arrProductIDs addObject:dicAddedProducts];
			[dicAddedProducts release];
			
		}
	}
	else
	{
		while (sqlite3_step(s_statement) == SQLITE_ROW)
		{
			char *cString;
			
			cString = (char *)sqlite3_column_text(s_statement, 0);
			productOptionID = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
			
			cString = (char *)sqlite3_column_text(s_statement, 1);
			productID = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
			
			cString = (char *)sqlite3_column_text(s_statement, 2);
			quantity = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
			
			NSDictionary *dicAddedProducts=[[NSDictionary alloc] initWithObjectsAndKeys: productOptionID, @"pOptionId", productID, @"id", quantity, @"quantity",nil];
			
			[arrProductIDs addObject:dicAddedProducts];
			[dicAddedProducts release];
		}
	}
	
	sqlite3_finalize(s_statement);
	return arrProductIDs;
}

- (NSMutableArray *)getWishListProductSizes:(int)productID
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *str=[NSString stringWithFormat:@"select * from TblWishlist where iProductId=%d", productID]; 
	
	sql4 = [str UTF8String];
	

	arrProductSizes=[[NSMutableArray alloc]init];
	
	NSString *productOptionID;
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	while (sqlite3_step(s_statement) == SQLITE_ROW)
	{
		char *cString;
		cString = (char *)sqlite3_column_text(s_statement, 0);
		
		productOptionID = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
		
		[arrProductSizes addObject:productOptionID];
		
	}
	
	sqlite3_finalize(s_statement);
	return arrProductSizes;
}

- (void)deleteItemFromWishList:(NSInteger)iProductId : (NSString *)sProductOptionID
{
	NSString *strQuery =[NSString stringWithFormat:@"delete from TblWishlist where iProductId = %d and iProductOptionId= '%@'",iProductId,sProductOptionID]; 
	
	sqlite3_stmt *delete_stmnt = nil; 
	
	if (sqlite3_prepare_v2(database, [strQuery UTF8String], -1, &delete_stmnt, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	if (sqlite3_step(delete_stmnt) == SQLITE_ERROR) 
	{
		NSAssert1(0, @"Error: failed to delete data -  '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(delete_stmnt);	
}

- (void)deleteItemFromWishList:(NSInteger)iProductId
{
	NSString *strQuery =[NSString stringWithFormat:@"delete from TblWishlist where iProductId = %d",iProductId]; 
	
	sqlite3_stmt *delete_stmnt = nil; 
	
	if (sqlite3_prepare_v2(database, [strQuery UTF8String], -1, &delete_stmnt, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	if (sqlite3_step(delete_stmnt) == SQLITE_ERROR) 
	{
		NSAssert1(0, @"Error: failed to delete data -  '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(delete_stmnt);	
}

#pragma mark Shopping Cart
- (void)updateTblShoppingCart: (int)quantity : (int)productID : (NSString *)productOptionID
{
	
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *strQuery = [NSString stringWithFormat:@"Update TblShoppingCart set  iQuantity=%d where iProductId=%d and iProductOptionsId='%@'", quantity, productID, productOptionID];
	
	sql4 = [strQuery UTF8String];
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	int success=sqlite3_step(s_statement);
	if(success==SQLITE_ERROR)
	{
		NSAssert1 (0,@"Error: '%s'",sqlite3_errmsg(database));
	}
	sqlite3_finalize(s_statement);
	
}

- (void)deleteItemFromShoppingCart:(NSInteger)iProductId : (NSString *)productOptionID
{
	NSString *strQuery =[NSString stringWithFormat:@"delete from TblShoppingCart where iProductId = %d and iProductOptionsId= '%@'",iProductId,productOptionID]; 
	
	sqlite3_stmt *delete_stmnt = nil; 
	
	if (sqlite3_prepare_v2(database, [strQuery UTF8String], -1, &delete_stmnt, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	if (sqlite3_step(delete_stmnt) == SQLITE_ERROR) 
	{
		NSAssert1(0, @"Error: failed to delete data -  '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(delete_stmnt);	
}

- (NSMutableArray *)getShoppingProductSizes:(int)productID
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *str=[NSString stringWithFormat:@"select iProductOptionsId from TblShoppingCart where iProductId=%d", productID]; 
	
	sql4 = [str UTF8String];
	
	arrProductOption=[[NSMutableArray alloc]init];
	
	NSString *productOptionID;
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	while (sqlite3_step(s_statement) == SQLITE_ROW)
	{
		char *cString;
		cString = (char *)sqlite3_column_text(s_statement, 0);
		
		productOptionID = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
		
		[arrProductOption addObject:productOptionID];
	}
	
	sqlite3_finalize(s_statement);
	return arrProductOption;
}

- (void)setTblShoppingCart:(int)productID :(int)quantity :(NSString *)iProductOptionId
{
	
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	
	sql4 = 	 "insert into TblShoppingCart (iProductId,iQuantity,iProductOptionsId) values(?,?,?)";
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_bind_int(s_statement, 1, productID);
	sqlite3_bind_int(s_statement, 2, quantity);
	sqlite3_bind_text(s_statement, 3, [iProductOptionId UTF8String], -1, SQLITE_TRANSIENT);
	
	//sqlite3_bind_text(s_statement, 3,iProductOptionsId);
	//sqlite3_bind_int(s_statement, 3, iProductOptionsId);
	
	int success=sqlite3_step(s_statement);
	if(success==SQLITE_ERROR)
	{
		NSAssert1 (0,@"Error: '%s'",sqlite3_errmsg(database));
	}
	sqlite3_finalize(s_statement);
	
	
	
	/*sqlite3_stmt *insert_statement = nil;
	 const char *sql = nil;
	 
	 NSString *strQuery = [NSString stringWithFormat:@"insert into TblShoppingCart (iProductId,iQuantity,iProductOptionsId) values(%d,%d,%@)", productID,quantity, iProductOptionsId];
	 
	 sql = [strQuery UTF8String];
	 
	 if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) 
	 {
	 NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	 }
	 
	 int success=sqlite3_step(insert_statement);
	 if(success==SQLITE_ERROR)
	 {
	 NSAssert1 (0,@"Error: '%s'",sqlite3_errmsg(database));
	 }
	 sqlite3_finalize(insert_statement);*/
}

- (NSMutableArray *)getShoppingCartProductIDs:(BOOL)isCheck
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *str=[NSString stringWithFormat:@"select * from TblShoppingCart"]; 
	
	sql4 = [str UTF8String];
	
	arrProductIDs=[[NSMutableArray alloc]init];
	
	NSString *productID,*quantity,*productOptionsId;
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	if(isCheck)
	{
		while (sqlite3_step(s_statement) == SQLITE_ROW)
		{
			char *cString, *cString1;
			cString = (char *)sqlite3_column_text(s_statement, 1);
			cString1 = (char *)sqlite3_column_text(s_statement, 0);
			
			productID = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
			productOptionsId = [[[NSString alloc] initWithString:(cString1) ? [NSString stringWithUTF8String:cString1]: @""] autorelease];
			
			NSDictionary *dicAddedProducts=[[NSDictionary alloc] initWithObjectsAndKeys: productID, @"id", productOptionsId, @"pOptionId", nil];
			
			[arrProductIDs addObject:dicAddedProducts];
			[dicAddedProducts release];
			
		}
	}
	else
	{
		while (sqlite3_step(s_statement) == SQLITE_ROW)
		{
			char *cString;
			
			cString = (char *)sqlite3_column_text(s_statement, 0);
			productOptionsId = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
			
			cString = (char *)sqlite3_column_text(s_statement, 1);
			productID = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
			
			cString = (char *)sqlite3_column_text(s_statement, 2);
			quantity = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
			
			NSDictionary *dicAddedProducts=[[NSDictionary alloc] initWithObjectsAndKeys: productID, @"id", quantity, @"quantity", productOptionsId,@"pOptionId",nil];
			
			[arrProductIDs addObject:dicAddedProducts];
			[dicAddedProducts release];
			
		}
	}
	
	sqlite3_finalize(s_statement);
	return arrProductIDs;
}

- (void)emptyShoppingCart
{
	NSString *strQuery =[NSString stringWithFormat:@"delete from TblShoppingCart"]; 
	
	sqlite3_stmt *delete_stmnt = nil; 
	
	if (sqlite3_prepare_v2(database, [strQuery UTF8String], -1, &delete_stmnt, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	if (sqlite3_step(delete_stmnt) == SQLITE_ERROR) 
	{
		NSAssert1(0, @"Error: failed to delete data -  '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(delete_stmnt);	
}


#pragma mark - TblQueue_ShoppingCart
- (void)addToQueue_Shoppingcart:(NSString *)dataToSend sendAtUrl:(NSString *)url
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	dataToSend = [dataToSend stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
	NSString *strQuery = [NSString stringWithFormat:@"insert into TblQueue_ShoppingCart (sWhereToSend, sDataToSend) values (\"%@\", \"%@\")", url, dataToSend];
	
	sql4 = [strQuery UTF8String];
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	int success=sqlite3_step(s_statement);
	if(success==SQLITE_ERROR)
	{
		NSAssert1 (0,@"Error: '%s'",sqlite3_errmsg(database));
	}
	
	
	sqlite3_finalize(s_statement);
	
	strQuery = [NSString stringWithFormat:@"select max(iShoppingOrderNum) from TblQueue_ShoppingCart"];
	
	sql4 = [strQuery UTF8String];
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	NSString *strQueueID;
	
	char *cString;
	cString = (char *)sqlite3_column_text(s_statement, 0);
	
	strQueueID = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
	
	int queueID = [strQueueID intValue];
	
	//SAVE IT IN THIS METHOD
	
	[GlobalPreferences setCurrentShoppingCartNum:queueID];
}

#pragma mark - TblQueue_IndvidualProducts
- (void)addToQueue_IndividualProducts:(NSInteger)iShoppingOrderNum dataToSend:(NSString *)dataToSend  sendAtUrl:(NSString *)url
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	dataToSend = [dataToSend stringByReplacingOccurrencesOfString:@"\"" withString:@"'"];
	NSString *strQuery = [NSString stringWithFormat:@"insert into TblQueue_IndividualProducts (sWhereToSend, sDataToSend, iShoppingOrderNum) values (\"%@\", \"%@\", %d)", url, dataToSend, iShoppingOrderNum];
	
	sql4 = [strQuery UTF8String];
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	int success=sqlite3_step(s_statement);
	if(success==SQLITE_ERROR)
	{
		NSAssert1 (0,@"Error: '%s'",sqlite3_errmsg(database));
	}
	sqlite3_finalize(s_statement);
}

- (NSMutableArray *)getShoppingCartQueue
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *str=[NSString stringWithFormat:@"select * from TblQueue_ShoppingCart"]; 
	
	sql4 = [str UTF8String];
	
	arrShoppingCartQueue = [[NSMutableArray alloc] init];
	
	NSString *sUrl, *sDataToSend;
	NSInteger iShoppingOrderNum;
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	while (sqlite3_step(s_statement) == SQLITE_ROW)
	{
		char *cString;
		cString = (char *)sqlite3_column_text(s_statement, 0);
		sUrl = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
		
		iShoppingOrderNum = sqlite3_column_int(s_statement, 1);
		
		cString = (char *)sqlite3_column_text(s_statement, 2);
		sDataToSend = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
		
		sDataToSend = [sDataToSend stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
		
		
		NSDictionary *dictTemp=[[NSDictionary alloc] initWithObjectsAndKeys: sUrl, @"sUrl", [NSString stringWithFormat:@"%d",iShoppingOrderNum], @"iShoppingOrderNum", sDataToSend,@"sDataToSend",nil];
		
		[arrShoppingCartQueue addObject:dictTemp];
		[dictTemp release];
	}
	
	return arrShoppingCartQueue;
}

- (NSMutableArray *)getIndividualProducts_Queue:(NSInteger) iShoppingOrderNum_FromLocalDB
{
	
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *strQuery=[NSString stringWithFormat:@"select * from TblQueue_IndividualProducts where iShoppingOrderNum=%d",iShoppingOrderNum_FromLocalDB]; 
	
	sql4 = [strQuery UTF8String];
	
	arrShoppingCartQueue = [[NSMutableArray alloc] init];
	
	NSString *sUrl, *sDataToSend;
	NSInteger iProductId, iShoppingOrderNum;
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	while (sqlite3_step(s_statement) == SQLITE_ROW)
	{
		char *cString;
		cString = (char *)sqlite3_column_text(s_statement, 0);
		sUrl = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
		
		iProductId = sqlite3_column_int(s_statement, 1);
		
		iShoppingOrderNum = sqlite3_column_int(s_statement, 2);
		
		cString = (char *)sqlite3_column_text(s_statement, 3);
		sDataToSend = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
		
		sDataToSend = [sDataToSend stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
		
		
		NSDictionary *dictTemp=[[NSDictionary alloc] initWithObjectsAndKeys: [NSString stringWithFormat:@"%d",iProductId], @"iProductId", sUrl, @"sUrl", [NSString stringWithFormat:@"%d",iShoppingOrderNum], @"iShoppingOrderNum", sDataToSend,@"sDataToSend",nil];
		
		[arrShoppingCartQueue addObject:dictTemp];
		[dictTemp release];
	}
	return arrShoppingCartQueue;
}

- (void)deleteItemFromIndividualQueue:(NSInteger)iProductId
{
	NSString *strQuery =[NSString stringWithFormat:@"delete from TblQueue_IndividualProducts where id = %d",iProductId]; 
	
	sqlite3_stmt *delete_stmnt = nil; 
	
	if (sqlite3_prepare_v2(database, [strQuery UTF8String], -1, &delete_stmnt, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	if (sqlite3_step(delete_stmnt) == SQLITE_ERROR) 
	{
		NSAssert1(0, @"Error: failed to delete data -  '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(delete_stmnt);	
}

- (void)deleteItemFromShoppingQueue:(NSInteger)iShoppingOrderNum
{
	NSString *strQuery =[NSString stringWithFormat:@"delete from TblQueue_ShoppingCart where iShoppingOrderNum = %d",iShoppingOrderNum]; 
	
	sqlite3_stmt *delete_stmnt = nil; 
	
	if (sqlite3_prepare_v2(database, [strQuery UTF8String], -1, &delete_stmnt, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	if (sqlite3_step(delete_stmnt) == SQLITE_ERROR) 
	{
		NSAssert1(0, @"Error: failed to delete data -  '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(delete_stmnt);	
}

- (void)updateIndividualProducts_Queue:(NSInteger) iShoppingOrderNum_FromLocalDB :(NSInteger) _id
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *strQuery = [NSString stringWithFormat:@"Update TblQueue_IndividualProducts set iShoppingOrderNum=%d where id=%d", iShoppingOrderNum_FromLocalDB, _id];
	
	sql4 = [strQuery UTF8String];
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	int success=sqlite3_step(s_statement);
	if(success==SQLITE_ERROR)
	{
		NSAssert1 (0,@"Error: '%s'",sqlite3_errmsg(database));
	}
	sqlite3_finalize(s_statement);
}

#pragma mark LANGUAGE PACK DATABASE OPERATIONS
-(void)deleteLangLabels
{
	NSString *strQuery =[NSString stringWithFormat:@"delete from TblLanguageLabels"]; 
	
	sqlite3_stmt *delete_stmnt = nil; 
	
	if (sqlite3_prepare_v2(database, [strQuery UTF8String], -1, &delete_stmnt, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	if (sqlite3_step(delete_stmnt) == SQLITE_ERROR) 
	{
		NSAssert1(0, @"Error: failed to delete data -  '%s'.", sqlite3_errmsg(database));
	}
	sqlite3_finalize(delete_stmnt);	
}

- (void)saveLanguageLabels:(NSDictionary *)dicData
{
	NSString *strTimeStamp = [[[[[NSString stringWithFormat:@"%@",[dicData valueForKey:@"timestamp"]] stringByReplacingOccurrencesOfString:@"(" withString:@""] stringByReplacingOccurrencesOfString:@")" withString:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"\"" withString:@""] ;
	
	sqlite3_stmt *insert_statement = nil;
	static char *sql=nil;
	sql= "insert into TblLanguageLabels(sKey,sValue) values(?,?)";
	
	NSArray *arrKeys = [NSArray arrayWithArray:[[[dicData valueForKey:@"labelsMap"] objectAtIndex:0]allKeys] ];
	
	for (int i=0; i<[arrKeys count]; i++) 
	{
		
		if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK)
		{
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
		}
		
		sqlite3_bind_text(insert_statement, 1, [[arrKeys objectAtIndex:i] UTF8String],-1 , SQLITE_TRANSIENT);
		sqlite3_bind_text(insert_statement, 2, [[[[dicData valueForKey:@"labelsMap"] objectAtIndex:0] valueForKey:[arrKeys objectAtIndex:i]] UTF8String] , -1, SQLITE_TRANSIENT);
		
		if(SQLITE_DONE != sqlite3_step(insert_statement))
		{
			DLog(@"Error while inserting Data. %@", sqlite3_errmsg(database));
		}
		sqlite3_reset(insert_statement);
		sqlite3_finalize(insert_statement);
	}
	
	
	if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK)
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	sqlite3_bind_text(insert_statement, 1, [[NSString stringWithFormat:@"TimeStamp"] UTF8String],-1 , SQLITE_TRANSIENT);
	sqlite3_bind_text(insert_statement, 2, [strTimeStamp UTF8String] , -1, SQLITE_TRANSIENT);
	
	if(SQLITE_DONE != sqlite3_step(insert_statement))
	{
		DLog(@"Error while inserting Data. %@", sqlite3_errmsg(database));
	}
	sqlite3_reset(insert_statement);
	sqlite3_finalize(insert_statement);
	
}
- (NSString *)getLanguageLabel:(NSString *)strKey
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *str=[NSString stringWithFormat:@"select sValue from TblLanguageLabels where sKey=\"%@\"",strKey]; 
	
	sql4 = [str UTF8String];
	
	strValue = [NSString stringWithFormat:@""];
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	while (sqlite3_step(s_statement) == SQLITE_ROW)
	{
		char *cString;
		cString = (char *)sqlite3_column_text(s_statement, 0);
		
		strValue = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
		
	}
	
	sqlite3_finalize(s_statement);
	return strValue;
}

- (NSDictionary*)getAllLabels
{
    sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *strQuery=[NSString stringWithFormat:@"select sKey,sValue from TblLanguageLabels"]; 
	
	sql4 = [strQuery UTF8String];
	
    dictData  = [[[NSMutableDictionary alloc] init] autorelease];
    
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	while (sqlite3_step(s_statement) == SQLITE_ROW)
	{
        char *cStringKey = (char *)sqlite3_column_text(s_statement, 0);
        char *cStringValue = (char *)sqlite3_column_text(s_statement, 1);
		if (cStringKey!=nil && cStringValue!=nil)
        {
            [dictData setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(s_statement, 1)] forKey:[NSString stringWithUTF8String:(char*)sqlite3_column_text(s_statement, 0)] ];
        }
		
	}
    sqlite3_finalize(s_statement);
	return dictData;
	
}

- (NSString *)getTimeStamp
{
	sqlite3_stmt *s_statement = nil;
	const char *sql4 = nil;
	NSString *str=[NSString stringWithFormat:@"select sValue from TblLanguageLabels where sKey='TimeStamp'"]; 
	
	sql4 = [str UTF8String];
	
	strValue = [NSString stringWithFormat:@""];
	
	if (sqlite3_prepare_v2(database, sql4, -1, &s_statement, NULL) != SQLITE_OK) 
	{
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}
	
	while (sqlite3_step(s_statement) == SQLITE_ROW)
	{
		char *cString;
		cString = (char *)sqlite3_column_text(s_statement, 0);
		
		strValue = [[[NSString alloc] initWithString:(cString) ? [NSString stringWithUTF8String:cString]: @""] autorelease];
		
	}
	sqlite3_finalize(s_statement);
	return strValue;
}

- (void)dealloc 
{
    if(arrAccountData)
        [arrAccountData release];
    if(arrProductIDs)
        [arrProductIDs release];
    if(arrProductSizes)
        [arrProductSizes release];
    if(arrProductOption)
        [arrProductOption release];
    if(arrShoppingCartQueue)
        [arrShoppingCartQueue release];
    if(strValue)
        [strValue release];
    if(dictData)
        [dictData release];
    
    [super dealloc];
}


@end
