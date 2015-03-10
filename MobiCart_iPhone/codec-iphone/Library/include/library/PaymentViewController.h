//
//  PaymentViewController.h
//  Stripe
//
//  Created by Alex MacCaw on 3/4/13.
//
//

#import <UIKit/UIKit.h>

@protocol PaymentViewControllerDelegate <NSObject>

- (void)paymentDidSuccess;

@end

@interface PaymentViewController : UIViewController

@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic, weak)id <PaymentViewControllerDelegate> deleagate;
- (IBAction)save:(id)sender;

@end
