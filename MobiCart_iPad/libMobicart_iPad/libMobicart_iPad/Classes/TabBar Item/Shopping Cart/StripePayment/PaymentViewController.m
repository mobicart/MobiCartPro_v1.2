//
//  PaymentViewController.m
//
//  Created by Alex MacCaw on 2/14/13.
//  Copyright (c) 2013 Stripe. All rights reserved.
//

#import "Stripe.h"
#import "MBProgressHUD.h"
#import "PaymentViewController.h"
#import "PTKView.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface PaymentViewController () <PTKViewDelegate>
@property (weak, nonatomic) PTKView *paymentView;
@end

@implementation PaymentViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	self.title = @"Checkout";
	if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}

	// Setup save button
//    NSString *title = [NSString stringWithFormat:@"Pay $%@", self.amount];
	// 18/11/2014 Tuyen Fix bug 27706
	NSString *strAmount = @"";
	if ([GlobalPrefrences getIsZeroDecimal]) {
		strAmount = [NSString stringWithFormat:@"%0.0f", [self.amount doubleValue]];
	}
	else {
		strAmount = [NSString stringWithFormat:@"%0.2f", [self.amount doubleValue]];
	}
	NSString *title = [NSString stringWithFormat:@"Pay %@%@", _savedPreferences.strCurrencySymbol, strAmount];
	// End
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
	saveButton.enabled = NO;
	self.navigationItem.leftBarButtonItem = cancelButton;
	self.navigationItem.rightBarButtonItem = saveButton;

	// Setup checkout
	PTKView *paymentView = [[PTKView alloc] initWithFrame:CGRectMake(250, 20, 500, 55)];
	paymentView.delegate = self;
	self.paymentView = paymentView;
	[self.view addSubview:paymentView];
}

- (void)paymentView:(PTKView *)paymentView withCard:(PTKCard *)card isValid:(BOOL)valid {
	// Enable save button if the Checkout is valid
	self.navigationItem.rightBarButtonItem.enabled = valid;
}

- (void)cancel:(id)sender {
	DDLogInfo(@"Cancel payment with Stripe");
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
	DDLogInfo(@"Create card to payment");
	if (![self.paymentView isValid]) {
		return;
	}
	if (![Stripe defaultPublishableKey]) {
		UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No Publishable Key"
		                                                  message:@"Please specify a Stripe Publishable Key in Constants.m"
		                                                 delegate:nil
		                                        cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
		                                        otherButtonTitles:nil];
		[message show];
		return;
	}
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];
	STPCard *card = [[STPCard alloc] init];
	card.number = self.paymentView.card.number;
	card.expMonth = self.paymentView.card.expMonth;
	card.expYear = self.paymentView.card.expYear;
	card.cvc = self.paymentView.card.cvc;
	DDLogDebug(@"Card info -- number: %@ - expMont: %d - expYear: %d - cvc: %@", card.number, card.expMonth, card.expYear, card.cvc);
	[Stripe createTokenWithCard:card
	                 completion: ^(STPToken *token, NSError *error) {
	    [MBProgressHUD hideHUDForView:self.view animated:YES];
	    if (error) {
	        DDLogWarn(@"Stripe create token with card failed");
	        [self hasError:error];
		}
	    else {
	        [self hasToken:token];
		}
	}];
}

- (void)hasError:(NSError *)error {
	NSString *strError = [NSString stringWithFormat:@"Error %d, please contact us to check your issue.",
	                      [error code]];
	UIAlertView *message = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
	                                                  message:strError //[error localizedDescription]
	                                                 delegate:nil
	                                        cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
	                                        otherButtonTitles:nil];
	[message show];
}

- (void)hasToken:(STPToken *)token {
	DDLogInfo(@"Config parameter to payment");
	[MBProgressHUD showHUDAddedTo:self.view animated:YES];

	NSString *strCode = [_savedPreferences.strCurrency substringFromIndex:3];

	// 18/11/2014 Tuyen Close code fix bug 27706
	/*
	   NSNumber *amountInCents;
	   if ([GlobalPrefrences getIsZeroDecimal])
	   {
	    amountInCents = [NSNumber numberWithDouble:[self.amount doubleValue]];
	   }
	   else
	   {
	    amountInCents = [NSNumber numberWithDouble:[self.amount doubleValue]*100];
	   }
	 */
	// End close

	// 18/11/2014 Tuyen Fix bug 27706
	NSString *strAmount = @"";
	if ([GlobalPrefrences getIsZeroDecimal]) {
		double sumAmount = [self.amount doubleValue];
		strAmount = [NSString stringWithFormat:@"%0.0f", sumAmount];
	}
	else {
		double sumAmount = [self.amount doubleValue] * 100;
		strAmount = [NSString stringWithFormat:@"%0.2f", sumAmount];
	}

	NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
	[fmt setPositiveFormat:@"0.##"];
	NSNumber *amountInCents = [fmt numberFromString:strAmount];
	// End

	DDLogDebug(@"token:%@ - currency:%@ - amount:%@", token.tokenId, strCode, amountInCents);
	NSDictionary *chargeParams = @{
		@"token": token.tokenId,
		@"currency": strCode,
		@"amount": amountInCents, // this is in cents (i.e. $10)
	};

	if (!ParseApplicationId || !ParseClientKey) {
		UIAlertView *message =
		    [[UIAlertView alloc] initWithTitle:@"Todo: Submit this token to your backend"
		                               message:[NSString stringWithFormat:@"Good news! Stripe turned your credit card into a token: %@ \nYou can follow the "
		                                        @"instructions in the README to set up Parse as an example backend, or use this "
		                                        @"token to manually create charges at dashboard.stripe.com .",
		                                        token.tokenId]
		                              delegate:nil
		                     cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
		                     otherButtonTitles:nil];

		[message show];
		[MBProgressHUD hideHUDForView:self.view animated:YES];
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
		return;
	}

	// This passes the token off to our payment backend, which will then actually complete charging the card using your account's
	DDLogInfo(@"Start progress pay with Strip");
	[PFCloud callFunctionInBackground:@"charge"
	                   withParameters:chargeParams
	                            block: ^(id object, NSError *error) {
	    [MBProgressHUD hideHUDForView:self.view animated:YES];
	    if (error) {
	        DDLogWarn(@"Pay progress has error");
	        [self hasError:error];
	        return;
		}
	    [self.presentingViewController dismissViewControllerAnimated:YES
	                                                      completion: ^{
	        DDLogInfo(@"Pay with Stripe was success");
	        [self.deleagate paymentDidSuccess];
		}];
	}];
}

@end
