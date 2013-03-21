//
//  StockCalculation.h
//  Mobicart
//
//  Created by Mobicart on 05/05/09.
//  Copyright 2009 Mobicart. All rights reserved.

#import <Foundation/Foundation.h>


@interface StockCalculation : NSObject {
	
	NSMutableArray *arrDropdown[100];
	BOOL isOutOfStock;
	int dropDownCount;
	NSString *strTitle;

}
-(BOOL)checkOptionsAvailability:(NSArray *)arrOptionsData;

@end
