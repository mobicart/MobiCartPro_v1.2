//
//  ZooZSubscriptionRequest.h
//  ZooZSDK-iOS
//
//  Created by Sharon Ben-Rabi on 11/07/13.
//
//

#import <Foundation/Foundation.h>
#import "ZooZPaymentRequest.h"



@interface ZooZSubscriptionRequest : ZooZPaymentRequest

//Subscription frequency unit.
typedef enum {
	SubscriptionUnitDay,	//day
	SubscriptionUnitWeek,	//week
	SubscriptionUnitMonth,	//month
	SubscriptionUnitYear	//year
} ZooZSubscriptionPeriodUnit;



-(id)initWithAmount:(float)amount
		andCurrency:(NSString *) code
			  every:(int)periodNum
		 PeriodUnit:(NSString *)unit
 forNumberOfPeriods:(int)recurrence
andInvoiceReference:(NSString *)invNumber;

+(ZooZSubscriptionRequest *)openSubscriptionWithAmount:(float)amount
										   andCurrency:(NSString *) code
												 every:(int)periodNumber
											PeriodUnit:(ZooZSubscriptionPeriodUnit)unit
									forNumberOfPeriods:(int)recurring
								   andInvoiceReference:(NSString *)invNumber;

+(NSString *)getPeriodUnitString:(ZooZSubscriptionPeriodUnit)unit;

@property (nonatomic) ZooZSubscriptionPeriodUnit periodUnit; //Subscription frequency unit: day/week/month/year.
@property (nonatomic) int periodNumber; //The number of period units between two payments.
@property (nonatomic) int recurring; //Total number of payments.



@end

