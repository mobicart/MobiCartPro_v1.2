//
//  ZooZSubscriptionResponse.h
//  ZooZSDK-iOS
//
//  Created by Sharon Ben-Rabi on 11/07/13.
//
//

#import <Foundation/Foundation.h>
#import "ZooZPaymentResponse.h"

@interface ZooZSubscriptionResponse : ZooZPaymentResponse

//The subscription ID in display form, can be used to to search and filter in the zooz portal in the transaction reports
@property(nonatomic, retain) NSString *subscriptionDisplayID;
//The subscription ID as a token, to be used in Server extended APIs, and for tracking in your system.
@property(nonatomic, retain) NSString *subscriptionID;
@property(nonatomic, retain) NSString *subscriptionStatus;

@end
