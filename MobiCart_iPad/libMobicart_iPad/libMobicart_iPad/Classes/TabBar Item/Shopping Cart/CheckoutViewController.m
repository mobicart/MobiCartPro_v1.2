//
//  CheckoutViewController.m
//  MobiCart
//
//  Created by Mobicart on 8/31/10.
//  Copyright 2010 Mobicart. All rights reserved.
//`

#import "CheckoutViewController.h"
#import "Constants.h"
// 05/8/2014 Tuyen close code
//#import "PayPalPayment.h"
//#import "PayPalAdvancedPayment.h"
//#import "PayPalAmounts.h"
//#import "PayPalReceiverAmounts.h"
//#import "PayPalAddress.h"
//#import "PayPalInvoiceItem.h"
//#import "PayPalMobile.h"
// End
#import "my2c2pSDK.h"
#import "my2c2pConfig.h"
#import "paymentFormViewController.h"
#include "Ipay88ViewController.h"

// 04/11/2014 Tuyen new code for Stripe
#import "Stripe.h"
#import <Parse/Parse.h>
#import "Stripe+ApplePay.h"
#import "PaymentViewController.h"
#import "ShippingManager.h"
#import <PassKit/PassKit.h>

#if DEBUG
#import "STPTestPaymentAuthorizationViewController.h"
#import "PKPayment+STPTestKeys.h"
#endif
// End

// 11/11/2014 Tuyen new fix bug wrong GUI when present view iOS8
#import "ShoppingCartViewController.h"
// End

#import "JSON.h"

MobicartAppDelegate *_objMobicartAppDelegate;

extern BOOL isLoadingTableFooter;

//18/09/2014 Sa Vo
@interface CheckoutViewController () <paymentFormViewControllerSourceDelegate, PKPaymentAuthorizationViewControllerDelegate, PaymentViewControllerDelegate> {
	NSString *_enviroment;
}

@property NSString *enviroment;
@property (nonatomic, strong) paymentFormViewController *paymentForm;
// 05/11/2014 Tuyen new code for Stripe
@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic) ShippingManager *shippingManager;
// End

@end


@implementation CheckoutViewController

@synthesize grandTotalValue, fSubTotalAmount, fTaxAmount, arrProductIds, fShippingCharges, sCountry, fSubTotal, arrCartItems, btnPayPal, btnZooz, cashOnDBtn, btnPaywithStripe, superVC;

//18/09/2014 Sa Vo
@synthesize enviroment = _enviroment;



/*
   // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
   - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
   if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
   // Custom initialization
   }
   return self;
   }


 */
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	DDLogCVerbose(@"Load View");

	isLoadingTableFooter = TRUE;
	NSMutableArray *arrInfoAccount = [[NSMutableArray alloc]init];
	arrInfoAccount = [[SqlQuery shared] getAccountData:[GlobalPrefrences getUserDefault_Preferences:@"userEmail"]];


	contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 450, 610)];
	contentView.backgroundColor = [UIColor clearColor];
	contentView.tag = 101010;
	self.view = contentView;

	UIImageView *imgViewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(-10, 2, 25, 25)];
	[imgViewIcon setImage:[UIImage imageNamed:@"page_1.png"]];
	[imgViewIcon setBackgroundColor:[UIColor clearColor]];
	[contentView addSubview:imgViewIcon];


	UILabel *lbltotprice = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 30)];
	[lbltotprice setBackgroundColor:[UIColor clearColor]];
	[lbltotprice setText:@"Total to be charged is: "];
	lbltotprice.textColor = headingColor;
	[lbltotprice setFont:[UIFont boldSystemFontOfSize:23]];
	[contentView addSubview:lbltotprice];

	UIImageView *imgHorizontalDottedLine = [[UIImageView alloc]initWithFrame:CGRectMake(-5, 50, 416, 2)];
	[imgHorizontalDottedLine setImage:[UIImage imageNamed:@"dot_line.png"]];

	[contentView addSubview:imgHorizontalDottedLine];
	[imgHorizontalDottedLine release];

	contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 450, 560)];
	[contentScrollView setBackgroundColor:[UIColor clearColor]];
	[contentView addSubview:contentScrollView];




	NSDictionary *dicSettings = [[NSDictionary alloc]init];
	dicSettings = [GlobalPrefrences getSettingsOfUserAndOtherDetails];
	[dicSettings retain];

	NSMutableArray *interShippingDict = [[NSMutableArray alloc]init];
	NSDictionary *contentDict = [dicSettings objectForKey:@"store"];
	NSArray *arrShipping = [contentDict objectForKey:@"shippingList"];
	[interShippingDict retain];

	NSDictionary *taxDict = [dicSettings objectForKey:@"store"];
	NSArray *arrTax = [contentDict objectForKey:@"taxList"];
	[taxDict retain];

	for (int index = 0; index < [arrShipping count]; index++) {
		[interShippingDict addObject:[arrShipping objectAtIndex:index]];
	}

	for (int index = 0; index < [arrTax count]; index++) {
		[interShippingDict addObject:[arrTax objectAtIndex:index]];
	}
	int countryID = 0, stateID = 0;
	if ([arrInfoAccount count] > 0) {
		for (int i = 0; i < [interShippingDict count]; i++) {
			if ([[arrInfoAccount objectAtIndex:10] isEqualToString:[[interShippingDict objectAtIndex:i] valueForKey:@"sCountry"]]) {
				countryID = [[[interShippingDict objectAtIndex:i] valueForKey:@"territoryId"] intValue];

				if ([[arrInfoAccount objectAtIndex:8] isEqualToString:[[interShippingDict objectAtIndex:i] valueForKey:@"sState"]]) {
					stateID = [[[interShippingDict objectAtIndex:i] valueForKey:@"stateId"] intValue];
				}
			}
		}
	}


	if (stateID == 0) {
		NSDictionary *dicStates;
		//fetch data from server
		dicStates = [ServerAPI fetchStatesOfAcountryURL:countryID];

		for (int index = 0; index < [dicStates count]; index++) {
			if ([[[dicStates valueForKey:@"sName"] objectAtIndex:index]isEqualToString:@"Other"])
				stateID = [[[dicStates valueForKey:@"id"]objectAtIndex:index]intValue];
		}
	}

	[dicSettings release];
	[interShippingDict release];

	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *dictTax = [ServerAPI fetchTaxShippingDetails:countryID:stateID:iCurrentStoreId];
	[dictTax retain];

	fShippingCharges = [[TaxCalculation shared]calculateShippingForCheckoutScreen:arrProductIds taxDetails:dictTax];

	fShippingCharges = [GlobalPrefrences getRoundedOffValue:fShippingCharges];
	float taxPercent = [[[dictTax valueForKey:@"tax"] valueForKey:@"fTax"] floatValue];
	taxPercent = [GlobalPrefrences getRoundedOffValue:taxPercent];
	float _fSubTotal = 0;
	float shippingtax = 0.0;



	if ([[[dictTax valueForKey:@"tax"] valueForKey:@"fTax"] isKindOfClass:[NSNull class]])
		shippingtax = 0.0;
	else
		shippingtax = [[[dictTax valueForKey:@"tax"] valueForKey:@"fTax"] floatValue];


	shippingtax = [GlobalPrefrences getRoundedOffValue:shippingtax];
	//[pool release];

	int yValue = 50;

	NSMutableArray *arrTaxable = [[NSMutableArray alloc] init];

	for (int i = 0; i <= [arrProductIds count]; i++) {
		if (i == 0) {
			UILabel *lblProductNames = [[UILabel alloc] init];
			lblProductNames.frame = CGRectMake(10, yValue, 150, 30);
			[lblProductNames setBackgroundColor:[UIColor clearColor]];
			lblProductNames.textColor = subHeadingColor;

			lblProductNames.font = [UIFont boldSystemFontOfSize:12];
			lblProductNames.textAlignment = UITextAlignmentLeft;
			lblProductNames.lineBreakMode = UILineBreakModeTailTruncation;
			lblProductNames.text = [NSString stringWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.checkout.name"]];
			[contentScrollView addSubview:lblProductNames];
			[lblProductNames release];

			UILabel *lblProductQuantity = [[UILabel alloc] init];
			lblProductQuantity.frame = CGRectMake(165, yValue, 40, 30);
			[lblProductQuantity setBackgroundColor:[UIColor clearColor]];
			lblProductQuantity.textColor = subHeadingColor;

			lblProductQuantity.font = [UIFont boldSystemFontOfSize:12];
			lblProductQuantity.textColor = subHeadingColor;
			lblProductQuantity.textAlignment = UITextAlignmentLeft;
			lblProductQuantity.lineBreakMode = UILineBreakModeTailTruncation;
			lblProductQuantity.text = [NSString stringWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.checkout.qty"]];
			[contentScrollView addSubview:lblProductQuantity];
			[lblProductQuantity release];

			UILabel *lblProductSize = [[UILabel alloc] init];
			lblProductSize.frame = CGRectMake(220, yValue, 80, 30);
			[lblProductSize setBackgroundColor:[UIColor clearColor]];
			lblProductSize.textColor = subHeadingColor;

			lblProductSize.font = [UIFont boldSystemFontOfSize:12];
			lblProductSize.textColor = subHeadingColor;
			lblProductSize.textAlignment = UITextAlignmentLeft;
			lblProductSize.lineBreakMode = UILineBreakModeTailTruncation;
			lblProductSize.text = [NSString stringWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.checkout.options"]];
			[contentScrollView addSubview:lblProductSize];
			[lblProductSize release];

			UILabel *lblProductSubTotal = [[UILabel alloc] init];
			lblProductSubTotal.frame = CGRectMake(300, yValue, 80, 30);
			[lblProductSubTotal setBackgroundColor:[UIColor clearColor]];
			lblProductSubTotal.textColor = subHeadingColor;

			lblProductSubTotal.font = [UIFont boldSystemFontOfSize:12];
			lblProductSubTotal.textColor = subHeadingColor;
			lblProductSubTotal.textAlignment = UITextAlignmentRight;
			lblProductSubTotal.lineBreakMode = UILineBreakModeTailTruncation;
			lblProductSubTotal.text = [NSString stringWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.checkout.sub-total"]];
			[contentScrollView addSubview:lblProductSubTotal];
			[lblProductSubTotal release];


			UILabel *lblProductTax = [[UILabel alloc] init];
			lblProductTax.frame = CGRectMake(295, yValue, 53, 30);
			[lblProductTax setBackgroundColor:[UIColor clearColor]];
			lblProductTax.textColor = subHeadingColor;

			lblProductTax.font = [UIFont boldSystemFontOfSize:12];
			lblProductTax.textAlignment = UITextAlignmentCenter;
			lblProductTax.lineBreakMode = UILineBreakModeTailTruncation;
			lblProductTax.text = [NSString stringWithFormat:@"Tax"];
			[lblProductTax release];

			UILabel *lblProductTotal = [[UILabel alloc] init];
			lblProductTotal.frame = CGRectMake(325, yValue, 70, 30);
			[lblProductTotal setBackgroundColor:[UIColor clearColor]];
			lblProductTotal.textColor = subHeadingColor;

			lblProductTotal.font = [UIFont boldSystemFontOfSize:13];
			lblProductTotal.textAlignment = UITextAlignmentRight;
			lblProductTotal.lineBreakMode = UILineBreakModeTailTruncation;
			lblProductTotal.text = [NSString stringWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.checkout.totalcost"]];
			[lblProductTotal release];
		}
		else {
			UILabel *lblProductNames = [[UILabel alloc] init];
			lblProductNames.frame = CGRectMake(10, yValue, 150, 30);
			[lblProductNames setBackgroundColor:[UIColor clearColor]];
			lblProductNames.textColor = subHeadingColor;
			lblProductNames.font = [UIFont boldSystemFontOfSize:12];
			lblProductNames.textAlignment = UITextAlignmentLeft;
			lblProductNames.lineBreakMode = UILineBreakModeTailTruncation;
			lblProductNames.text = [NSString stringWithFormat:@"%@", [[arrProductIds objectAtIndex:i - 1] valueForKey:@"sName"]];
			[contentScrollView addSubview:lblProductNames];
			[lblProductNames release];

			UILabel *lblProductQuantity = [[UILabel alloc] init];
			lblProductQuantity.frame = CGRectMake(170, yValue, 30, 30);
			[lblProductQuantity setBackgroundColor:[UIColor clearColor]];
			lblProductQuantity.textColor = subHeadingColor;
			lblProductQuantity.font = [UIFont boldSystemFontOfSize:12];
			lblProductQuantity.textAlignment = UITextAlignmentLeft;
			lblProductQuantity.lineBreakMode = UILineBreakModeTailTruncation;
			lblProductQuantity.text = [NSString stringWithFormat:@"%@", [[arrProductIds objectAtIndex:i - 1] valueForKey:@"quantity"]];
			[contentScrollView addSubview:lblProductQuantity];
			[lblProductQuantity release];

			int optionSizeIndex = 555545;
			NSString *sizeName;

			if ([[[arrProductIds objectAtIndex:i - 1] valueForKey:@"pOptionId"] intValue] == 0) {
				sizeName = @"";
			}
			else {
				NSMutableArray *dictOption = [[arrProductIds objectAtIndex:i - 1] objectForKey:@"productOptions"];

				NSMutableArray *arrProductOptionSize = [[[NSMutableArray alloc] init] autorelease];

				for (int i = 0; i < [dictOption count]; i++)
					[arrProductOptionSize addObject:[[dictOption objectAtIndex:i] valueForKey:@"id"]];

				if ([arrProductOptionSize containsObject:[NSNumber numberWithInt:[[[arrProductIds objectAtIndex:i - 1] valueForKey:@"pOptionId"] integerValue]]])
					optionSizeIndex = [arrProductOptionSize indexOfObject:[NSNumber numberWithInt:[[[arrProductIds objectAtIndex:i - 1] valueForKey:@"pOptionId"] intValue]]];

				if (optionSizeIndex < 15455 && optionSizeIndex >= 0)
					sizeName = [[dictOption objectAtIndex:optionSizeIndex] valueForKey:@"sName"];
				else
					sizeName = @"";
			}

			UILabel *lblProductSize = [[UILabel alloc] init];
			lblProductSize.frame = CGRectMake(222, yValue, 70, 30);
			[lblProductSize setBackgroundColor:[UIColor clearColor]];
			lblProductSize.textColor = subHeadingColor;
			lblProductSize.font = [UIFont boldSystemFontOfSize:12];
			lblProductSize.textAlignment = UITextAlignmentLeft;
			lblProductSize.lineBreakMode = UILineBreakModeTailTruncation;
			lblProductSize.text = [NSString stringWithFormat:@"%@", sizeName];
			[contentScrollView addSubview:lblProductSize];
			[lblProductSize release];

			float productCost = 0, productTax = 0;



			NSArray *arrTempTaxDetails = [[TaxCalculation shared]calculatetaxForCheckOutScreen:arrProductIds withSettings:dicSettings forIndex:i forCountryID:countryID taxAmount:taxPercent];


			productCost = [[arrTempTaxDetails objectAtIndex:0] floatValue];

			productCost = [GlobalPrefrences getRoundedOffValue:productCost];
			priceWithoutTax += [[arrTempTaxDetails objectAtIndex:1] floatValue];


			float productTotal = [[arrTempTaxDetails objectAtIndex:2] floatValue];
			productTotal = [GlobalPrefrences getRoundedOffValue:productTotal];

			_fSubTotal += productTotal;
			_fSubTotal = [GlobalPrefrences getRoundedOffValue:_fSubTotal];
			///	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

			fTaxAmount = [GlobalPrefrences getRoundedOffValue:fTaxAmount];
			if ([[[dicSettings valueForKey:@"store"]valueForKey:@"bIncludeTax"]intValue] == 1) {
				if (countryID == 0) {
					istaxToBeApplied = NO;
					productTax = 0;
					fTaxAmount = 0;
					productTotal = productTotal;
					fShippingCharges = 0;
				}
				else {
					istaxToBeApplied = YES;
					productTax = [[arrTempTaxDetails objectAtIndex:4] floatValue];
					fTaxAmount += productTax;
					productTotal = productTotal;
				}
			}
			else {
				istaxToBeApplied = NO;
			}



			grandTotalValue += productTotal;
			//[pool release];

			UILabel *lblProductSubTotal = [[UILabel alloc] init];
			lblProductSubTotal.frame = CGRectMake(300, yValue, 80, 30);
			[lblProductSubTotal setBackgroundColor:[UIColor clearColor]];
			lblProductSubTotal.textColor = subHeadingColor;
			lblProductSubTotal.font = [UIFont boldSystemFontOfSize:12];
			lblProductSubTotal.textAlignment = UITextAlignmentRight;
			lblProductSubTotal.lineBreakMode = UILineBreakModeTailTruncation;
			//lblProductSubTotal.text = [NSString stringWithFormat:@"%@%0.2f",_savedPreferences.strCurrencySymbol,productCost * [[[arrProductIds objectAtIndex:i-1]valueForKey:@"quantity"] intValue]];
			lblProductSubTotal.text = [NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, productCost];
			[contentScrollView addSubview:lblProductSubTotal];
			[lblProductSubTotal release];


			UILabel *lblProductTax = [[UILabel alloc] init];
			lblProductTax.frame = CGRectMake(285, yValue, 53, 30);
			[lblProductTax setBackgroundColor:[UIColor clearColor]];
			lblProductTax.textColor = subHeadingColor;
			lblProductTax.font = [UIFont boldSystemFontOfSize:12];
			lblProductTax.textAlignment = UITextAlignmentCenter;
			lblProductTax.lineBreakMode = UILineBreakModeTailTruncation;
			lblProductTax.text = [NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, productTax];
			[lblProductTax release];


			UILabel *lblProductTotal = [[UILabel alloc] init];
			lblProductTotal.frame = CGRectMake(325, yValue, 68, 40);
			[lblProductTotal setBackgroundColor:[UIColor clearColor]];
			lblProductTotal.textColor = subHeadingColor;
			lblProductTotal.font = [UIFont boldSystemFontOfSize:12];
			lblProductTotal.textAlignment = UITextAlignmentRight;
			lblProductTotal.numberOfLines = 2;
			lblProductTotal.lineBreakMode = UILineBreakModeTailTruncation;

			NSString *strTemptaxType = [[dictTax valueForKey:@"tax"] valueForKey:@"sType"];

			if ([strTemptaxType isEqualToString:@"default"])
				strTemptaxType = @"tax";


			if (istaxToBeApplied == YES)
				lblProductTotal.text = [NSString stringWithFormat:@"%@%0.2f\n(Inc. %@)", _savedPreferences.strCurrencySymbol, productTotal, strTemptaxType];
			else
				lblProductTotal.text = [NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, productTotal];

			[lblProductTotal release];
		}
		yValue += 40;
	}

	fShippingCharges = [[NSString stringWithFormat:@"%0.2f", fShippingCharges] floatValue];

	grandTotalValue += fShippingCharges;
	[arrTaxable release];

	UIImageView *imgLineView1 = [[UIImageView alloc]initWithFrame:CGRectMake(8, yValue, 374, 2)];
	[imgLineView1 setImage:[UIImage imageNamed:@"horizontal-line.png"]];
	[contentScrollView addSubview:imgLineView1];
	[imgLineView1 release];



	UILabel *lblSubTotalCharges = [[UILabel alloc] init];
	lblSubTotalCharges.frame = CGRectMake(210, yValue + 10, 170, 20);
	[lblSubTotalCharges setBackgroundColor:[UIColor clearColor]];
	lblSubTotalCharges.textColor = subHeadingColor;
	lblSubTotalCharges.font = [UIFont boldSystemFontOfSize:14];
	lblSubTotalCharges.textAlignment = UITextAlignmentRight;
	lblSubTotalCharges.text = [NSString stringWithFormat:@"%@:	%@%0.2f", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.checkout.sub-total"], _savedPreferences.strCurrencySymbol, priceWithoutTax];
	[contentScrollView addSubview:lblSubTotalCharges];
	[lblSubTotalCharges release];




	UILabel *lblTaxAmount = [[UILabel alloc] init];
	lblTaxAmount.frame = CGRectMake(220, lblSubTotalCharges.frame.origin.y + lblSubTotalCharges.frame.size.height, 160, 20);
	[lblTaxAmount setBackgroundColor:[UIColor clearColor]];
	lblTaxAmount.textColor = subHeadingColor;
	lblTaxAmount.font = [UIFont boldSystemFontOfSize:14];
	lblTaxAmount.textAlignment = UITextAlignmentRight;
	lblTaxAmount.text = [NSString stringWithFormat:@"%@:	%@%0.2f", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.tax"], _savedPreferences.strCurrencySymbol, fTaxAmount];
	[contentScrollView addSubview:lblTaxAmount];
	[lblTaxAmount release];

	UILabel *lblShippingCharges = [[UILabel alloc] init];
	lblShippingCharges.frame = CGRectMake(180, lblTaxAmount.frame.origin.y + lblTaxAmount.frame.size.height, 200, 20);
	[lblShippingCharges setBackgroundColor:[UIColor clearColor]];
	lblShippingCharges.textColor = subHeadingColor;
	lblShippingCharges.font = [UIFont boldSystemFontOfSize:14];
	lblShippingCharges.textAlignment = UITextAlignmentRight;
	lblShippingCharges.text = [NSString stringWithFormat:@" %@:	%@%0.2f", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.shipping"], _savedPreferences.strCurrencySymbol, fShippingCharges];
	[contentScrollView addSubview:lblShippingCharges];
	[lblShippingCharges release];

	fSubTotalAmount = grandTotalValue;

	UILabel *lblShippingTax = [[UILabel alloc] init];
	lblShippingTax.frame = CGRectMake(178, lblShippingCharges.frame.origin.y + lblTaxAmount.frame.size.height, 200, 20);
	[lblShippingTax setBackgroundColor:[UIColor clearColor]];
	lblShippingTax.textColor = subHeadingColor;
	lblShippingTax.font = [UIFont boldSystemFontOfSize:14];
	lblShippingTax.textAlignment = UITextAlignmentRight;
	[contentScrollView addSubview:lblShippingTax];

	if ([[[dicSettings valueForKey:@"store"] valueForKey:@"bTaxShipping"]intValue] == 1)
		lblShippingTax.text = [NSString stringWithFormat:@"%@: %@%0.2f", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.tax.shipping"], _savedPreferences.strCurrencySymbol, (fShippingCharges * shippingtax) / 100];
	else
		lblShippingTax.text = [NSString stringWithFormat:@"%@: %@0.00", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.tax.shipping"], _savedPreferences.strCurrencySymbol];
	[lblShippingTax release];


	if ([[[dicSettings valueForKey:@"store"] valueForKey:@"bTaxShipping"]intValue] == 1)
		taxOnShipping = ((fShippingCharges * shippingtax) / 100);
	else {
		taxOnShipping = 0;
		shippingtax = 0;
	}

	taxOnShipping = [GlobalPrefrences getRoundedOffValue:taxOnShipping];
	shippingtax = [[NSString stringWithFormat:@"%0.2f", shippingtax] floatValue];
	taxOnShipping = [[NSString stringWithFormat:@"%0.2f", taxOnShipping] floatValue];


	grandTotalValue = grandTotalValue + ((fShippingCharges * shippingtax) / 100);


	UILabel *lblStars = [[UILabel alloc]initWithFrame:CGRectMake(210, lblShippingTax.frame.origin.y + lblShippingTax.frame.size.height, 210, 20)];
	[lblStars setBackgroundColor:[UIColor clearColor]];
	[lblStars setText:@"****************************"];
	[lblStars setTextColor:subHeadingColor];
	[contentScrollView
	 addSubview:lblStars];
	[lblStars release];




	UILabel *lblGrandTotal = [[UILabel alloc] init];
	lblGrandTotal.frame = CGRectMake(190, lblStars.frame.origin.y + lblStars.frame.size.height - 7, 190, 20);
	[lblGrandTotal setBackgroundColor:[UIColor clearColor]];
	lblGrandTotal.textColor = subHeadingColor;
	lblGrandTotal.font = [UIFont boldSystemFontOfSize:18];
	lblGrandTotal.textAlignment = UITextAlignmentRight;
	lblGrandTotal.text = [NSString stringWithFormat:@"%@: %@%0.2f", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.checkout.total"], _savedPreferences.strCurrencySymbol, grandTotalValue];
	[contentScrollView addSubview:lblGrandTotal];

	//Meanwhile load user details from the local DB
	[self performSelectorInBackground:@selector(fetchDataFromLocalDB) withObject:nil];


	UILabel *lblprice = [[UILabel alloc] initWithFrame:CGRectMake(275, 0, 150, 30)];
	[lblprice setBackgroundColor:[UIColor clearColor]];
	[lblprice setText:[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, grandTotalValue]];
	lblprice.textColor = subHeadingColor;
	[lblprice setFont:[UIFont boldSystemFontOfSize:21]];
	[contentView addSubview:lblprice];



	UILabel *lblCountryTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, yValue + 10, 100, 20)];
	[lblCountryTitle setText:[NSString stringWithFormat:@"%@:", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.checkout.country"]]];
	[lblCountryTitle setBackgroundColor:[UIColor clearColor]];
	lblCountryTitle.textColor = headingColor;
	lblCountryTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
	[contentScrollView addSubview:lblCountryTitle];
	[lblCountryTitle release];


	UILabel *lblCountryFooter = [[UILabel alloc] initWithFrame:CGRectMake(12, yValue + 30, 100, 20)];
	[lblCountryFooter setText:[arrInfoAccount objectAtIndex:10]];
	[lblCountryFooter setBackgroundColor:[UIColor clearColor]];
	lblCountryFooter.textColor = subHeadingColor;
	lblCountryFooter.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
	[contentScrollView addSubview:lblCountryFooter];
	[lblCountryFooter release];

	UILabel *lblStateTitle = [[UILabel alloc] initWithFrame:CGRectMake(12, yValue + 60, 100, 20)];
	[lblStateTitle setText:[NSString stringWithFormat:@"%@:", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.signup.state"]]];
	[lblStateTitle setBackgroundColor:[UIColor clearColor]];
	lblStateTitle.textColor = headingColor;
	lblStateTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
	[contentScrollView addSubview:lblStateTitle];
	[lblStateTitle release];


	UILabel *lblStateFooter = [[UILabel alloc] initWithFrame:CGRectMake(12, yValue + 80, 100, 20)];
	[lblStateFooter setText:[arrInfoAccount objectAtIndex:8]];
	[lblStateFooter setBackgroundColor:[UIColor clearColor]];
	lblStateFooter.textColor = subHeadingColor;
	lblStateFooter.font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
	[contentScrollView addSubview:lblStateFooter];
	[lblStateFooter release];
	int yAxise = lblGrandTotal.frame.origin.y + lblGrandTotal.frame.size.height + 50;
	/*********************************integration with PayPAl payment gatway***************/
	if ([[GlobalPrefrences getPaypalModeEnable] intValue] == 1 && ([GlobalPrefrences getPayPalClientId].length != 0)) {
		DDLogInfo(@"PayPal has Token and PayPal Mode");
		DDLogDebug(@"PayPalToken: %@", [GlobalPrefrences getPaypalLiveToken]);
		DDLogDebug(@"PayPalMode:  %@", [GlobalPrefrences getPaypalModeIsLive]);
		//DuyenHK: change to new Paypal library
//        NSLog(@"PayPal version%@",[PayPal buildVersion]);
		////////////

		//18/09/2014 Sa Vo
		[PayPalMobile initializeWithClientIdsForEnvironments:@{ PayPalEnvironmentProduction : [GlobalPrefrences getPayPalClientId],
		                                                        PayPalEnvironmentSandbox : [GlobalPrefrences getPayPalClientId] }];

		if ([[GlobalPrefrences getPaypalModeIsLive]intValue] == 1) {
			//DuyenHK: change to new Paypal library
//            [PayPal initializeWithAppID:[GlobalPrefrences getPaypalLiveToken] forEnvironment:ENV_LIVE];
//            [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_CLIENT_ID_FOR_PRODUCTION",
//                                                                   PayPalEnvironmentSandbox : @"YOUR_CLIENT_ID_FOR_SANDBOX"}];

			self.enviroment = PayPalEnvironmentProduction;
		}
		else {
			//DuyenHK: change to new Paypal library
//            [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];
//
//            [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_CLIENT_ID_FOR_PRODUCTION",
//                                                                   PayPalEnvironmentSandbox : @"YOUR_CLIENT_ID_FOR_SANDBOX"}];
			/////////

			self.enviroment = PayPalEnvironmentSandbox;
		}

		//18/09/2014 Sa Vo
		// Preconnect to PayPal early
		if ([[GlobalPrefrences getPaypalModeEnable] intValue] == 1 && ([GlobalPrefrences getPayPalClientId].length != 0)) {
			[PayPalMobile preconnectWithEnvironment:self.enviroment];
		}

		//DuyenHK: change to new Paypal library
		/*UIButton * btn = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:@selector(payWithPayPal) andButtonType:BUTTON_278x43];

		   UIButton * btn = [[UIButton alloc] init];

		   btn.frame = CGRectMake (70, lblGrandTotal.frame.origin.y+lblGrandTotal.frame.size.height+30, 278, 38);*/


		btnPayPal = [UIButton buttonWithType:UIButtonTypeCustom];

		[btnPayPal addTarget:self action:@selector(payWithPayPal) forControlEvents:UIControlEventTouchUpInside];

		[btnPayPal setTitle:[NSString stringWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.paybypaypalnew"]] forState:UIControlStateNormal];
		[btnPayPal setBackgroundImage:[UIImage imageNamed:@"checkout_btn.png"] forState:UIControlStateNormal];
		[btnPayPal layer].cornerRadius = 5.0;
		[btnPayPal.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
		btnPayPal.frame = CGRectMake(70, yAxise, 278, 38);
		yAxise += 50;

		[contentScrollView addSubview:btnPayPal];
	}

	/*********************************integration with Zooz payment gatway****************************************/
	if ([[GlobalPrefrences getZoozModeEnable] intValue] == 1 && ([GlobalPrefrences getZoozPaymentToken].length != 0)) {
		DDLogInfo(@"ZooZ has AppUnique ID and Zooz Mode");
		DDLogDebug(@"iPad ZooZ App Unique ID:  %@", [[NSBundle mainBundle] bundleIdentifier]);
		DDLogDebug(@"iPad ZooZ key:  %@", [GlobalPrefrences getZoozPaymentToken]);
		DDLogDebug(@"ZooZ Mode:  %@", [GlobalPrefrences getZooZModeIsLive]);

		btnZooz = [UIButton buttonWithType:UIButtonTypeCustom];

		[btnZooz addTarget:self action:@selector(payWithZooz) forControlEvents:UIControlEventTouchUpInside];

		[btnZooz setTitle:[NSString stringWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.PayWithPaypal"]] forState:UIControlStateNormal];
		[btnZooz setBackgroundImage:[UIImage imageNamed:@"checkout_btn.png"] forState:UIControlStateNormal];
		[btnZooz layer].cornerRadius = 5.0;
		[btnZooz.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
		btnZooz.frame = CGRectMake(70, yAxise, 278, 38);

		yAxise += 50;
		[contentScrollView addSubview:btnZooz];
	}

	/**************************iPay88*******************************************************/
	if ([[GlobalPrefrences getiPay88ModeEnable] intValue] == 1 && [GlobalPrefrences getiPay88MerchantCode].length != 0 && [GlobalPrefrences getiPay88MerchantKey].length != 0) {
		DDLogInfo(@"iPay88 has Merchant key and iPay88 Mode");
		DDLogDebug(@"iPad88 Merchant key:  %@", [GlobalPrefrences getiPay88MerchantKey]);

		UIButton *btnPaywithiPay88 = [UIButton buttonWithType:UIButtonTypeCustom];
		[btnPaywithiPay88 addTarget:self action:@selector(payWithiPay88) forControlEvents:UIControlEventTouchUpInside];
		[btnPaywithiPay88 setTitle:[NSString stringWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.paywithipay88"]] forState:UIControlStateNormal];
		[btnPaywithiPay88 setBackgroundImage:[UIImage imageNamed:@"checkout_btn.png"] forState:UIControlStateNormal];
		//        btnPaywithiPay88.backgroundColor=navBarColor;
		[btnPaywithiPay88 layer].cornerRadius = 5.0;
		[btnPaywithiPay88.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];


		btnPaywithiPay88.frame = CGRectMake(70, yAxise, 278, 38);

		yAxise = yAxise + 50;


		[contentScrollView addSubview:btnPaywithiPay88];
	}
	/**************************2C2P*******************************************************/
	if ([[GlobalPrefrences get2c2pModeEnable] intValue] == 1 && [GlobalPrefrences get2c2pMerchantId].length != 0 && [GlobalPrefrences get2c2pSecrectKey].length != 0) {
		DDLogInfo(@"2C2P has Merchant key, Secrect key and 2C2P Mode");
		DDLogDebug(@"2C2P Merchant key:  %@", [GlobalPrefrences get2c2pMerchantId]);
		DDLogDebug(@"2C2P Secrect key:  %@", [GlobalPrefrences get2c2pSecrectKey]);

		UIButton *btnPaywithi2C2P = [UIButton buttonWithType:UIButtonTypeCustom];
		[btnPaywithi2C2P addTarget:self action:@selector(payWith2C2P) forControlEvents:UIControlEventTouchUpInside];
		[btnPaywithi2C2P setTitle:[NSString stringWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.paywith2c2p"]] forState:UIControlStateNormal];
		[btnPaywithi2C2P setBackgroundImage:[UIImage imageNamed:@"checkout_btn.png"] forState:UIControlStateNormal];
		//        btnPaywithi2C2P.backgroundColor=navBarColor;
		[btnPaywithi2C2P layer].cornerRadius = 5.0;
		[btnPaywithi2C2P.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];


		btnPaywithi2C2P.frame = CGRectMake(70, yAxise, 278, 38);

		yAxise = yAxise + 50;


		[contentScrollView addSubview:btnPaywithi2C2P];
	}

	// 05/11/2014 Tuyen new code handle add new button Pay with Stripe
	/************************ Tuyen Stripe ***********************************************************/
	if ([[GlobalPrefrences getStripeModeEnable] intValue] == 1 && ([GlobalPrefrences getStripePublishableKey].length != 0) && ([GlobalPrefrences getParseApplicationId].length != 0) && ([GlobalPrefrences getParseClientKey].length != 0)) {
		DDLogInfo(@"Stripe has Publishable key, Application key, ParseClient key and Stripe Mode");
		DDLogDebug(@"Stripe Publishable key:  %@", [GlobalPrefrences getStripePublishableKey]);
		DDLogDebug(@"Stripe Application key:  %@", [GlobalPrefrences getParseApplicationId]);
		DDLogDebug(@"Stripe ParseClient key:  %@", [GlobalPrefrences getParseClientKey]);

		[Stripe setDefaultPublishableKey:[GlobalPrefrences getStripePublishableKey]];

		[Parse setApplicationId:[GlobalPrefrences getParseApplicationId] clientKey:[GlobalPrefrences getParseClientKey]];

		btnPaywithStripe = [UIButton buttonWithType:UIButtonTypeCustom];
		[btnPaywithStripe addTarget:self action:@selector(payWithStripe) forControlEvents:UIControlEventTouchUpInside];
		[btnPaywithStripe setTitle:[NSString stringWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.paywithstripe"]] forState:UIControlStateNormal];
		[btnPaywithStripe setBackgroundImage:[UIImage imageNamed:@"checkout_btn.png"] forState:UIControlStateNormal];
		[btnPaywithStripe layer].cornerRadius = 5.0;
		[btnPaywithStripe.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];


		btnPaywithStripe.frame = CGRectMake(70, yAxise, 278, 38);

		yAxise = yAxise + 50;

		[contentScrollView addSubview:btnPaywithStripe];
	}
	// Tuyen end

	/*********************************integration with Cash on devlivery ****************************************/
	if (![[[dicSettings valueForKey:@"store"] valueForKey:@"codEnabled"]isEqual:[NSNull null]]) {
		if ([[[dicSettings valueForKey:@"store"] valueForKey:@"codEnabled"]intValue] == 1) {
			DDLogInfo(@"Cash on Delivery codenable");

			cashOnDBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			
            // 09/02/2015 Tuyen new handle add delivery fee
//            [cashOnDBtn addTarget:self action:@selector(cashOnDeveliery) forControlEvents:UIControlEventTouchUpInside];
            [cashOnDBtn addTarget:self action:@selector(chooseCashOnDeveliery) forControlEvents:UIControlEventTouchUpInside];
            // 09/02/2015 Tuyen end

			[cashOnDBtn setTitle:[NSString stringWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.CashOnDelivery"]] forState:UIControlStateNormal];
			[cashOnDBtn setBackgroundImage:[UIImage imageNamed:@"checkout_btn.png"] forState:UIControlStateNormal];

			[cashOnDBtn layer].cornerRadius = 5.0;
			[cashOnDBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];

			cashOnDBtn.frame = CGRectMake(70, yAxise, 278, 38);
			[contentScrollView addSubview:cashOnDBtn];
			[contentScrollView setContentSize:CGSizeMake(450, cashOnDBtn.frame.origin.y + cashOnDBtn.frame.size.height + 200)];
		}
		// 28/11/2014 Tuyen new code fix bug 27827
		else {
			DDLogInfo(@"Cash on Delivery code disable");

			[contentScrollView setContentSize:CGSizeMake(450, yAxise + 38 + 200)];
		}
		// End
	}
	else {
		// Tuyen close because set frame wrong if have pay by iPay88 and 2C2P
//		[contentScrollView setContentSize:CGSizeMake(450, btnZooz.frame.origin.y + btnZooz.frame.size.height + 200)];
		//

		// Tuyen new code set frame
		[contentScrollView setContentSize:CGSizeMake(450, yAxise + 38 + 200)];
		//
	}

	if (!sMerchantPaypayEmail)
		sMerchantPaypayEmail = [[NSString alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	for (UIView *view in[self.navigationController.navigationBar subviews]) {
		if ([view isKindOfClass:[UIButton class]])
			view.hidden = TRUE;
		if ([view isKindOfClass:[UILabel class]])
			view.hidden = TRUE;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	for (UIView *view in[self.navigationController.navigationBar subviews]) {
		if ([view isKindOfClass:[UIButton class]])
			view.hidden = FALSE;


		if ([view isKindOfClass:[UILabel class]])
			view.hidden = FALSE;
	}
}

#pragma mark PayPal Integration
- (void)payWithPayPal {
	//DuyenHK: change to new Paypal library


	/*
	   NSLog(@"PayPal");

	   if(![GlobalPrefrences getIsEditMode])
	   {
	    NSString *strCode =[_savedPreferences.strCurrency substringFromIndex:3];
	    NSDictionary *dicAppSettings = [GlobalPrefrences getSettingsOfUserAndOtherDetails];
	    [PayPal getPayPalInst].shippingEnabled = TRUE;
	            //optional, set dynamicAmountUpdateEnabled to TRUE if you want to compute
	    //shipping and tax based on the user's address choice, default: FALSE

	    [PayPal getPayPalInst].dynamicAmountUpdateEnabled = FALSE;

	    //optional, choose who pays the fee, default: FEEPAYER_EACHRECEIVER
	    [PayPal getPayPalInst].feePayer = FEEPAYER_EACHRECEIVER;

	    //for a payment with a single recipient, use a PayPalPayment object


	    PayPalPaymentType paymentType =TYPE_GOODS;
	    PayPalPayment *payment =[[PayPalPayment alloc] init];
	    payment.recipient=[GlobalPrefrences getPaypalRecipient_Email];

	    payment.paymentCurrency=strCode;
	    payment.paymentType=paymentType;
	    //payment.subTotal=[NSString stringWithFormat:@"%0.2f",priceWithoutTax];
	    payment.description = [NSString stringWithFormat:@"Total Amount"];
	    payment.merchantName = [NSString stringWithFormat:@"%@", [[dicAppSettings objectForKey:@"store"] objectForKey:@"sSName"]];


	    NSString *subToatal;
	    NSString *totalShiping;
	    NSString *tax;
	    totalShippingAmount=0.0;

	    float shipping = fShippingCharges + taxOnShipping;
	    totalShippingAmount=shipping;

	    totalShiping =  [NSString stringWithFormat:@"%0.2f", totalShippingAmount] ;
	    tax=[NSString stringWithFormat:@"%0.2f",[GlobalPrefrences getRoundedOffValue:fTaxAmount]];

	    subToatal=[NSString stringWithFormat:@"%0.2f",priceWithoutTax];

	    payment.subTotal = [NSDecimalNumber decimalNumberWithString:subToatal];

	    //invoiceData is a PayPalInvoiceData object which contains tax, shipping, and a list of PayPalInvoiceItem objects
	    payment.invoiceData = [[[PayPalInvoiceData alloc] init] autorelease];
	    payment.invoiceData.totalShipping = [NSDecimalNumber decimalNumberWithString:totalShiping];
	    payment.invoiceData.totalTax = [NSDecimalNumber decimalNumberWithString:tax];

	    //invoiceItems is a list of PayPalInvoiceItem objects
	    //NOTE: sum of totalPrice for all items must equal payment.subTotal
	    //NOTE: example only shows a single item, but you can have more than one
	    payment.invoiceData.invoiceItems = [NSMutableArray array];
	    PayPalInvoiceItem *item = [[PayPalInvoiceItem alloc] init];
	    item.totalPrice = payment.subTotal;
	    item.name = @"Total Amount";
	    [payment.invoiceData.invoiceItems addObject:item];

	    [[PayPal getPayPalInst] checkoutWithPayment:payment];


	   }*/


	DDLogVerbose(@"Choose pay with Paypal");
	// 02/12/2014 Tuyen fix bug don't check internet connection when payment with Paypal
	if (![GlobalPrefrences isInternetAvailable]) {
		NSString *errorString = [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.text"];
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.title"] message:errorString delegate:nil cancelButtonTitle:nil otherButtonTitles:[[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.cancelbutton"], nil];
		[errorAlert show];
		[errorAlert release];
	}
	else {
		// 05/8/2014 Tuyen new code
		totalShippingAmount = 0.0;

		float shippingFloat = fShippingCharges + taxOnShipping;
		totalShippingAmount = shippingFloat;

		NSString *strCode = [_savedPreferences.strCurrency substringFromIndex:3];
		NSDictionary *dicAppSettings = [GlobalPrefrences getSettingsOfUserAndOtherDetails];
		// Tuyen fix bug subTotal contains more than 2 fractional digits
		//    NSDecimalNumber *subTotal = [[NSDecimalNumber alloc] initWithFloat:priceWithoutTax];
		NSString *totals = [NSString stringWithFormat:@"%0.2f", priceWithoutTax];
		NSDecimalNumber *subTotal = [NSDecimalNumber decimalNumberWithString:totals];
		//
		NSString *totalShiping =  [NSString stringWithFormat:@"%0.2f", totalShippingAmount];
		NSString *taxString = [NSString stringWithFormat:@"%0.2f", [GlobalPrefrences getRoundedOffValue:fTaxAmount]];

		PayPalItem *item1 = [PayPalItem itemWithName:@"Total Amount"
		                                withQuantity:1
		                                   withPrice:subTotal
		                                withCurrency:strCode
		                                     withSku:@""];

		NSArray *items = @[item1];
		NSDecimalNumber *subtotal = [PayPalItem totalPriceForItems:items];

		// Optional: include payment details
		NSDecimalNumber *shipping = [NSDecimalNumber decimalNumberWithString:totalShiping];
		NSDecimalNumber *tax = [NSDecimalNumber decimalNumberWithString:taxString];
		PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subTotal
		                                                                           withShipping:shipping
		                                                                                withTax:tax];

		NSDecimalNumber *total = [[subtotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];

		PayPalPayment *payment = [[PayPalPayment alloc] init];
		payment.amount = total;
		payment.currencyCode = strCode;
		payment.shortDescription = [NSString stringWithFormat:@"Total Amount"];
		payment.items = items;  // if not including multiple items, then leave payment.items as nil
		payment.paymentDetails = paymentDetails; // if not including payment details, then leave payment.paymentDetails as nil

		DDLogDebug(@"Item price:%@ - Ship:%@ - Tax:%@ - Total:%@ --- with Currency: %@", subTotal, shipping, tax, payment.amount, payment.currencyCode);

		if (!payment.processable) {
			// This particular payment will always be processable. If, for
			// example, the amount was negative or the shortDescription was
			// empty, this payment wouldn't be processable, and you'd want
			// to handle that here.
			DDLogWarn(@"Paypal payment don't processable");
			if ([subTotal compare:[NSNumber numberWithInt:0]] == NSOrderedSame) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your subtotal amount is invalid" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];

				[alert show];

				[alert release];
			}
		}
		else {
			// Update payPalConfig re accepting credit cards.
			// Set up payPalConfig
			PayPalConfiguration *_payPalConfig = [[PayPalConfiguration alloc] init];
			_payPalConfig.acceptCreditCards = YES;
			//    _payPalConfig.languageOrLocale = @"en";
			_payPalConfig.merchantName = [NSString stringWithFormat:@"%@", [[dicAppSettings objectForKey:@"store"] objectForKey:@"sSName"]];
			_payPalConfig.languageOrLocale = [NSLocale preferredLanguages][0];
			_payPalConfig.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;

			PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment
			                                                                                            configuration:_payPalConfig
			                                                                                                 delegate:self];
			DDLogInfo(@"Present Paypal payment view");
			[self presentViewController:paymentViewController animated:YES completion:nil];
			// End
		}
	}
	// End
}

#pragma mark PayPalPaymentDelegate methods

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
	DDLogInfo(@"PayPal Payment Success!");
	[self dismissViewControllerAnimated:YES completion:nil];
	int state = paymentViewController.state;

	UIAlertView *alert = nil;
	if (state == PayPalPaymentViewControllerStateInProgress) {
		//Send the order information/details to the server
		[self performSelectorInBackground:@selector(sendDataToServer:) withObject:@"2"];

		NSString *strTitle = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.title"]];

		NSString *strMessage = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.text"]];

		NSString *strCancelButton = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.cancelbutton"]];

		if ([strTitle length] > 0 && [strMessage length] > 0 && [strCancelButton length] > 0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.text"] delegate:self cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

			[alert show];

			[alert release];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Order Approved" message:@"Thank you, your order has been completed successfully. Please visit the 'Account' tab for further details." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];

			[alert show];

			[alert release];
		}
		[strTitle release];
		[strMessage release];
		[strCancelButton release];
	}
	else {
		alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.text"] delegate:nil cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
	}
}

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
	DDLogInfo(@"PayPal Payment Canceled");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.text"] delegate:nil cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

	[alert show];

	[alert release];

	[self dismissViewControllerAnimated:YES completion:nil];
}

//DuyenHK mark code: change to new Paypal
/*#pragma mark PayPal delegates Integration
   -(void)RetryInitialization
   {
    if([[GlobalPrefrences getPaypalModeIsLive]intValue]==1)
    {
        //DuyenHK: change to new Paypal library
   //        [PayPal initializeWithAppID:[GlobalPrefrences getPaypalLiveToken] forEnvironment:ENV_LIVE];
        [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_CLIENT_ID_FOR_PRODUCTION",
                                                               PayPalEnvironmentSandbox : @"YOUR_CLIENT_ID_FOR_SANDBOX"}];
    }
    else
    {
   //        [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];
        [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction : @"YOUR_CLIENT_ID_FOR_PRODUCTION",
                                                               PayPalEnvironmentSandbox : @"YOUR_CLIENT_ID_FOR_SANDBOX"}];
        //////////
    }

   }
   - (void)paymentSuccessWithKey:(NSString *)payKey andStatus:(PayPalPaymentStatus)paymentStatus {

    status = PAYMENTSTATUS_SUCCESS;
    NSString *severity = [[PayPal getPayPalInst].responseMessage objectForKey:@"severity"];
    NSLog(@"severity: %@", severity);
    NSString *category = [[PayPal getPayPalInst].responseMessage objectForKey:@"category"];
    NSLog(@"category: %@", category);
    NSString *errorId = [[PayPal getPayPalInst].responseMessage objectForKey:@"errorId"];
    NSLog(@"errorId: %@", errorId);
    NSString *message = [[PayPal getPayPalInst].responseMessage objectForKey:@"message"];
    NSLog(@"message: %@", message);



   }

   //paymentFailedWithCorrelationID is a required method. in it, you should
   //record that the payment failed and perform any desired bookkeeping. you should not do any user interface updates.
   //correlationID is a string which uniquely identifies the failed transaction, should you need to contact PayPal.
   //errorCode is generally (but not always) a numerical code associated with the error.
   //errorMessage is a human-readable string describing the error that occurred.
   - (void)paymentFailedWithCorrelationID:(NSString *)correlationID {

    NSString *severity = [[PayPal getPayPalInst].responseMessage objectForKey:@"severity"];
    NSLog(@"severity: %@", severity);
    NSString *category = [[PayPal getPayPalInst].responseMessage objectForKey:@"category"];
    NSLog(@"category: %@", category);
    NSString *errorId = [[PayPal getPayPalInst].responseMessage objectForKey:@"errorId"];
    NSLog(@"errorId: %@", errorId);
    NSString *message = [[PayPal getPayPalInst].responseMessage objectForKey:@"message"];
    NSLog(@"message: %@", message);

    status = PAYMENTSTATUS_FAILED;

   }*/
/*
   //paymentCanceled is a required method. in it, you should record that the payment was canceled by
   //the user and perform any desired bookkeeping. you should not do any user interface updates.
   - (void)paymentCanceled
   {
    status = PAYMENTSTATUS_CANCELED;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.text"] delegate:nil cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

    [alert show];

    [alert release];

   }
 */

//DuyenHK mark code: change to new Paypal

//paymentLibraryExit is a required method. this is called when the library is finished with the display
//and is returning control back to your app. you should now do any user interface updates such as
//displaying a success/failure/canceled message.
/*
   - (void)paymentLibraryExit {
    UIAlertView *alert = nil;
    switch (status) {
        case PAYMENTSTATUS_SUCCESS:
        {

            //Send the order information/details to the server
            [self performSelectorInBackground:@selector(sendDataToServer:) withObject:@"2"];

            NSString *strTitle = [[NSString alloc] initWithFormat:@"%@",[[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.title"] ];

            NSString *strMessage = [[NSString alloc] initWithFormat:@"%@",[[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.text"]];

            NSString *strCancelButton = [[NSString alloc] initWithFormat:@"%@",[[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.cancelbutton"] ];

            if ([strTitle length]>0 && [strMessage length]>0 && [strCancelButton length]>0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.text"] delegate:self cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

                [alert show];

                [alert release];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Order Approved" message:@"Thank you, your order has been completed successfully. Please visit the 'Account' tab for further details." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];

                [alert show];

                [alert release];
            }
            [strTitle release];
            [strMessage release];
            [strCancelButton release];



            break;


        }

        case PAYMENTSTATUS_FAILED:
            alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.text"] delegate:nil cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];


            break;
        case PAYMENTSTATUS_CANCELED:
            //alert = [[UIAlertView alloc] initWithTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.title"] message:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.text"] delegate:nil cancelButtonTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

            break;
    }
    [alert show];
    [alert release];
   }*/


////////////////////


#pragma mark Zooz Payment Integration
- (void)payWithZooz {
	DDLogInfo(@"pay With ZooZ");
	if (![GlobalPrefrences getIsEditMode]) {
		DDLogInfo(@"%@", [[NSBundle mainBundle] bundleIdentifier]);
		NSString *strCode = [_savedPreferences.strCurrency substringFromIndex:3];

		NSString *invRef;
		invRef = [NSString stringWithFormat:@"INV-%@", [NSDate new]];

		totalShippingAmount = 0.0;

		float shipping = fShippingCharges + taxOnShipping;
		totalShippingAmount = shipping;

		float totalAmount = priceWithoutTax + totalShippingAmount + [GlobalPrefrences getRoundedOffValue:fTaxAmount];

		ZooZ *zooz = [ZooZ sharedInstance];
		zooz.rootView = _objMobicartAppDelegate.tabController.view;
		zooz.tintColor = backGroundColor;
		ZooZPaymentRequest *req = [zooz createPaymentRequestWithTotal:totalAmount invoiceRefNumber:invRef delegate:self];
		req.currencyCode = strCode;

		DDLogDebug(@"Item price:%f - Ship:%f - Tax:%f - Total:%f ---- with currency: %@", priceWithoutTax, totalShippingAmount, [GlobalPrefrences getRoundedOffValue:fTaxAmount], totalAmount, req.currencyCode);

		/* Optional - recommended */
		req.payerDetails.firstName = [[arrUserDetails objectAtIndex:0] objectForKey:@"sUserName"];
		req.payerDetails.lastName = @"";
		req.payerDetails.email = [[arrUserDetails objectAtIndex:0] objectForKey:@"sEmailAddress"];
		req.payerDetails.billingAddress.zipCode = [[arrUserDetails objectAtIndex:0] objectForKey:@"sPincode"];

		req.payerDetails.billingAddress.country = [[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryCountry"];
		req.payerDetails.billingAddress.state = [[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryState"];

		req.payerDetails.billingAddress.city = [[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryCity"];
		req.payerDetails.billingAddress.streetAddress = [[arrUserDetails objectAtIndex:0] objectForKey:@"sStreetAddress"];

		req.requireAddress = NO;
		DDLogInfo(@"Set product info for ZooZ payment request");
		for (int i = 0; i < [arrProductIds count]; i++) {
			float price;
			NSString *nameOption;
			NSMutableArray *productNameOpt;
			productNameOpt =  [self fetchNameOptionProduct:i];

			nameOption = [productNameOpt objectAtIndex:0];

			if ([[[arrProductIds objectAtIndex:i] objectForKey:@"fPrice"] floatValue] > [[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue]) {
				price = [[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue];
				price += [[productNameOpt objectAtIndex:1] floatValue];
			}
			else {
				price = [[[arrProductIds objectAtIndex:i] objectForKey:@"fPrice"] floatValue];
				price += [[productNameOpt objectAtIndex:1] floatValue];
			}

			ZooZInvoiceItem *item = [ZooZInvoiceItem invoiceItem:price quantity:[[[arrProductIds objectAtIndex:i] objectForKey:@"quantity"] intValue] name:[NSString stringWithFormat:@"%@", nameOption]];


			item.itemId = [NSString stringWithFormat:@"%d", [[[arrProductIds objectAtIndex:i] objectForKey:@"id"] intValue]]; // optional

			[req addItem:item];
		}
		/* End of optional */

		if ([[GlobalPrefrences getZoozPaymentToken] length] == 0) {
			zooz.sandbox = YES;
			[zooz openPayment:req forAppKey:@""];
		}
		else {
			if ([[GlobalPrefrences  getZooZModeIsLive] intValue] == 1) {
				DDLogInfo(@"Pay ZooZ with live mode");
				zooz.sandbox = NO;
				[zooz openPayment:req forAppKey:[GlobalPrefrences getZoozPaymentToken]];
			}
			else {
				DDLogInfo(@"Pay ZooZ with sandbox mode");
				zooz.sandbox = YES;
				[zooz openPayment:req forAppKey:[GlobalPrefrences getZoozPaymentToken]];
			}
		}
	}
}

#pragma mark fetching option and name of product

- (NSMutableArray *)fetchNameOptionProduct:(int)k {
	NSMutableString *newproductName;

	NSMutableArray *test = [NSMutableArray new];

	NSMutableArray *strArray = [NSMutableArray new];
	float optionPrice = 0;

	newproductName = [NSString stringWithFormat:@"%@", [[arrProductIds objectAtIndex:k] valueForKey:@"sName"]];



	int optionSizesIndex[100];

	if (!([[[arrProductIds objectAtIndex:k] valueForKey:@"pOptionId"] intValue] == 0)) {
		NSMutableArray *dictOption = [[arrProductIds objectAtIndex:k] objectForKey:@"productOptions"];

		NSMutableArray *arrProductOptionSize = [[[NSMutableArray alloc] init] autorelease];

		for (int i = 0; i < [dictOption count]; i++) {
			[arrProductOptionSize addObject:[[dictOption objectAtIndex:i] valueForKey:@"id"]];
		}

		NSArray *arrSelectedOptions = [[[arrCartItems objectAtIndex:k] valueForKey:@"pOptionId"] componentsSeparatedByString:@","];

		if ([arrProductOptionSize count] != 0 && [arrSelectedOptions count] != 0) {
			for (int count = 0; count < [arrSelectedOptions count]; count++) {
				if ([arrProductOptionSize containsObject:[NSNumber numberWithInt:[[arrSelectedOptions objectAtIndex:count] integerValue]]]) {
					optionSizesIndex[count] = [arrProductOptionSize indexOfObject:[NSNumber numberWithInt:[[arrSelectedOptions objectAtIndex:count]  intValue]]];
				}
			}
		}




		for (int count = 0; count < [arrSelectedOptions count]; count++) {
			optionPrice += [[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"pPrice"]floatValue];


			[test addObject:[NSString stringWithFormat:@"%@: %@", [[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sTitle"], [[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sName"]]];

			//NSLog(@"%@",[test componentsJoinedByString:@"," ]);
		}


		[strArray addObject:[NSString stringWithFormat:@"%@ [%@]", newproductName, [test componentsJoinedByString:@","]]];
		[strArray addObject:[NSString stringWithFormat:@"%f", optionPrice]];

		return strArray;
	}
	else {
		[strArray addObject:[NSString stringWithFormat:@"%@", newproductName]];
		[strArray addObject:[NSString stringWithFormat:@"%f", optionPrice]];
		return strArray;
	}
}

#pragma mark iPay88 Integrate
- (void)payWithiPay88 {
	DDLogInfo(@"Choose pay with iPay88");
	NSString *strCode = [_savedPreferences.strCurrency substringFromIndex:3];
	NSString *strCountryCode = [_savedPreferences.strCurrency substringWithRange:NSMakeRange(0, 2)];

	NSString *subToatal;
	NSString *totalShiping;
	NSString *tax;
	totalShippingAmount = 0.0;

	float shipping = fShippingCharges + taxOnShipping;
	totalShippingAmount = shipping;

	totalShiping =  [NSString stringWithFormat:@"%0.2f", totalShippingAmount];
	tax = [NSString stringWithFormat:@"%0.2f", [GlobalPrefrences getRoundedOffValue:fTaxAmount]];

	float totalAmount = priceWithoutTax + totalShippingAmount + [GlobalPrefrences getRoundedOffValue:fTaxAmount];

	/* 1. Setting IpayPayment Object - BEGIN */
	IpayPayment *payment = [[IpayPayment alloc] init];
	[payment setPaymentId:@""];
	[payment setMerchantKey:[GlobalPrefrences getiPay88MerchantKey]];
	[payment setMerchantCode:[GlobalPrefrences getiPay88MerchantCode]];
	[payment setRefNo:[self getTimeStamp]];
	[payment setAmount:[NSString stringWithFormat:@"%.2f", totalAmount]];
//    [payment setAmount:@"1.00"];
	[payment setCurrency:strCode];
	[payment setProdDesc:@"Total Amount"];
//    [payment setUserEmail:[GlobalPrefrences getUserDefault_Preferences:@"userEmail"]];
	[payment setUserEmail:@"sdktester@ipay88.com"];
	/* Nhan Lam hard code
	   [payment setUserName:@"DemoAcc1234"];
	   [payment setUserEmail:@"sdktester@ipay88.com"];
	   [payment setUserContact:@"0171234567"];
	   [payment setRemark:@"Testing SDK"];
	 */
	[payment setLang:@"UTF-8"];
	[payment setCountry:strCountryCode];

	DDLogDebug(@"Item price:%f - Ship:%f - Tax:%f - Total:%@ ---- with currency: %@", priceWithoutTax, totalShippingAmount, [GlobalPrefrences getRoundedOffValue:fTaxAmount], payment.amount, payment.currency);
	DDLogInfo(@"Ipay Payment user email:%@", payment.userEmail);
	/* 1. Setting IpayPayment Object - END */

	/* 2. SDK Initialization - BEGIN */
	paymentiPay88 = [[Ipay alloc] init];
	paymentiPay88.delegate = self;
	/* 2. SDK Initialization - END */


	/* 3. Payment Checkout Method - BEGIN */
	paymentView = [paymentiPay88 checkout:payment];
	/* 3. Payment Checkout Method - END */

	Ipay88ViewController *vcTemp = [[Ipay88ViewController alloc] init];
	iPay88Navigation = [[UINavigationController alloc] initWithRootViewController:vcTemp];
	[vcTemp.view addSubview:paymentView];

	DDLogInfo(@"Present iPay88 payment view");
	// 03/12/2014 Tuyen close code fix Bug 27874 - wrong GUI when present view iOS8
//	[self presentViewController:iPay88Navigation animated:YES completion:nil];
	// End

	// 03/12/2014 Tuyen new fix Bug 27874 - wrong GUI when present view iOS8
	[self.superVC presentViewController:iPay88Navigation animated:YES completion:nil];
	// End

	[vcTemp release];
	[payment release];
}

- (void)paymentSuccess:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withAuthCode:(NSString *)authCode {
	DDLogInfo(@"payment success");
	
    // 03/12/2014 Tuyen close code fix Bug 27874 - wrong GUI when present view iOS8
//    [self dismissViewControllerAnimated:YES completion: ^{
//        [self processPaymentSucces:@"4"];
//        [iPay88Navigation release];
//    }];
    // End
    
    // 03/12/2014 Tuyen new fix Bug 27874 - wrong GUI when present view iOS8
    [self.superVC dismissViewControllerAnimated:YES completion: ^{
        [self processPaymentSucces:@"4"];
        [iPay88Navigation release];
    }];
    // End
}

- (void)paymentFailed:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withErrDesc:(NSString *)errDesc {
	DDLogWarn(@"payment failed, refNo=%@; transId=%@; erroDes=%@", refNo, transId, errDesc);
	// 03/12/2014 Tuyen close code fix Bug 27874 - wrong GUI when present view iOS8
//    [self dismissViewControllerAnimated:YES completion: ^{
//        [paymentView removeFromSuperview];
//        [self errorMessage:@"Your order failed. Touch \"Pay by iPay88\" to try again"];
//        [iPay88Navigation release];
//    }];
    // End
    
    // 03/12/2014 Tuyen new fix Bug 27874 - wrong GUI when present view iOS8
    [self.superVC dismissViewControllerAnimated:YES completion: ^{
        [paymentView removeFromSuperview];
        [self errorMessage:@"Your order failed. Touch \"Pay by iPay88\" to try again"];
        [iPay88Navigation release];
    }];
    // End
}

- (void)paymentCancelled:(NSString *)refNo withTransId:(NSString *)transId withAmount:(NSString *)amount withRemark:(NSString *)remark withErrDesc:(NSString *)errDesc {
	DDLogInfo(@"payment cancelled");
	// 03/12/2014 Tuyen close code fix Bug 27874 - wrong GUI when present view iOS8
//    [self dismissViewControllerAnimated:YES completion: ^{
//        [iPay88Navigation release];
//    }];
    // End
    
    // 03/12/2014 Tuyen new fix Bug 27874 - wrong GUI when present view iOS8
    [self.superVC dismissViewControllerAnimated:YES completion: ^{
        [iPay88Navigation release];
    }];
    // End
	//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"payment cancelled" message:[NSString stringWithFormat:@"refNo=%@\ntransId=%@\namount=%@\nremark=%@\nerrDesc=%@",refNo,transId,amount,remark,errDesc] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	//    [alert show];
}

#pragma mark 2C2P Integrate
- (void)payWith2C2P {
	DDLogInfo(@"Choose pay with 2C2P");
	NSString *strCode = [GlobalPrefrences get2c2pCurrencyNumber];

	totalShippingAmount = 0.0;

	float shipping = fShippingCharges + taxOnShipping;
	totalShippingAmount = shipping;

	float totalAmount = priceWithoutTax + totalShippingAmount + [GlobalPrefrences getRoundedOffValue:fTaxAmount];

	my2c2pSDK *my2c2p = [[my2c2pSDK alloc] initWithPrivateKey:[my2c2pConfig PRIVATE_KEY]];

	my2c2p.merchantID = [GlobalPrefrences get2c2pMerchantId];
	my2c2p.uniqueTransactionCode = [NSString stringWithFormat:@"JT%@", [self getTimeStamp]];
	my2c2p.desc = @"No Product Detail";
	my2c2p.amt = totalAmount;
	my2c2p.currencyCode = strCode;
	my2c2p.userDefined1 = @"";
	my2c2p.userDefined2 = @"";
	my2c2p.userDefined3 = @"";
	my2c2p.userDefined4 = @"";
	my2c2p.userDefined5 = @"";
	my2c2p.payCategoryID = @"";

	my2c2p.secretKey = [GlobalPrefrences get2c2pSecrectKey];
	my2c2p.enableStoreCard = YES;
	my2c2p.productionMode = YES;
	my2c2p.displayPaymentPage = YES;

	DDLogDebug(@"Item price:%f - Ship:%f - Tax:%f - Total:%f ---- with currency: %@", priceWithoutTax, totalShippingAmount, [GlobalPrefrences getRoundedOffValue:fTaxAmount], my2c2p.amt, my2c2p.currencyCode);

	self.paymentForm = [[paymentFormViewController alloc] initWithNibName:@"myPaymentFormViewController" bundle:nil];

	//for nav color
	//    self.paymentForm.navBarColor = [UIColor colorWithRed:0.811 green:0.05 blue:0.078 alpha:1];

	//delegate for paymentForm View DidLoad
	self.paymentForm.delegateVC = self;


	if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
		//for iOS 7
		self.paymentForm.navButtonTintColor = [UIColor whiteColor];
	}
	else {
		//for iOS 6
		self.paymentForm.navButtonTintColor = [UIColor colorWithRed:0.811 green:0.05 blue:0.078 alpha:1];
	}

	//for nav title
	self.paymentForm.navTitleColor = [UIColor whiteColor];

	//request with paymentform
	[my2c2p requestWithTarget:self AndPaymentForm:self.paymentForm onResponse: ^(NSDictionary *response) {
	    DDLogDebug(@"2C2P response: %@", response);

	    if ([response[@"respCode"] isEqualToString:@"00"]) {
	        [self processPaymentSucces:@"3"];
		}
	    else {
	        [self errorMessage:@"Your order failed. Touch \"Pay by 2c2p\" to try again"];
		}
	} onFail: ^(NSError *error) {
	    DDLogWarn(@"2C2P payment fail");
	    if (error) {
	        [[[UIAlertView alloc] initWithTitle:[error localizedDescription] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		}
	}];
}

#pragma mark Cash On Develiery Integration
// 9/02/2015 Tuyen new handle add delivery fee
- (void)chooseCashOnDeveliery{
    float deliveryFee = [GlobalPrefrences getCasDeliveryFee];
    if (deliveryFee > 0) {
        NSString *strAlert = [NSString stringWithFormat:@"You need to pay an extra amount of %0.2f as 'Cash On Delivery Fee'. \nIs this ok?", [GlobalPrefrences getCasDeliveryFee]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:strAlert delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        [alert setTag:Delivery_Fee_Alert_Tag];
        [alert show];
        [alert release];
    }else{
        [self cashOnDeveliery];
    }
}
// 9/02/2015 Tuyen end

- (void)cashOnDeveliery {
	DDLogInfo(@"Choose cash on develiery");
	if (![GlobalPrefrences getIsEditMode]) {
		DDLogInfo(@"Start pay");
		[self performSelectorInBackground:@selector(sendDataToServer:) withObject:@"1"];

		NSString *strTitle = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.title"]];

		NSString *strMessage = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.text"]];

		NSString *strCancelButton = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.cancelbutton"]];

		if ([strTitle length] > 0 && [strMessage length] > 0 && [strCancelButton length] > 0) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.text"] delegate:self cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

			[alert show];

			[alert release];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Order Approved" message:@"Thank you, your order has been completed successfully. Please visit the 'Account' tab for further details." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];

			[alert show];

			[alert release];
		}
		[strTitle release];
		[strMessage release];
		[strCancelButton release];
	}
}

- (void)openPaymentRequestFailed:(ZooZPaymentRequest *)request withErrorCode:(int)errorCode andErrorMessage:(NSString *)errorMessage {
	DDLogWarn(@"failed: %@", errorMessage);
	//this is a network / integration failure, not a payment processing failure.
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.text"] delegate:nil cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

	[alert show];

	[alert release];
}

- (void)paymentSuccessWithResponse:(ZooZPaymentResponse *)response {
	DDLogInfo(@"payment success with payment Id: %@, %@, %@, %f", response.fundSourceType, response.lastFourDigits, response.transactionDisplayID, response.paidAmount);
}

- (void)paymentSuccessDialogClosed {
	DDLogInfo(@"Payment dialog closed after success");
	//see paymentSuccessWithResponse: for the response transaction ID.
	[self performSelectorInBackground:@selector(sendDataToServer:) withObject:@"0"];

	NSString *strTitle = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.title"]];

	NSString *strMessage = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.text"]];

	NSString *strCancelButton = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.cancelbutton"]];

	if ([strTitle length] > 0 && [strMessage length] > 0 && [strCancelButton length] > 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.text"] delegate:self cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

		[alert show];

		[alert release];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Order Approved" message:@"Thank you, your order has been completed successfully. Please visit the 'Account' tab for further details." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];

		[alert show];

		[alert release];
	}
	[strTitle release];
	[strMessage release];
	[strCancelButton release];
}

// 18/11/2014 Tuyen open to fix bug crash when Cancel ZooZ
- (void)paymentCanceled {
	DDLogInfo(@"payment cancelled");

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.text"] delegate:nil cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

	[alert show];

	[alert release];
	//dialog closed without payment completed
}

// End

// 06/11/2014 Tuyen new code for Stripe
#pragma mark - Stripe Integration
- (void)payWithStripe {
	DDLogVerbose(@"Choose pay with Stripe");
	// Calculate among
	self.amount = 0;

	totalShippingAmount = 0.0;

	float shippingFloat = fShippingCharges + taxOnShipping;
	totalShippingAmount = shippingFloat;

	//    NSString *strCode =[_savedPreferences.strCurrency substringFromIndex:3];

	NSString *totals = [NSString stringWithFormat:@"%0.2f", priceWithoutTax];
	NSDecimalNumber *subTotal = [NSDecimalNumber decimalNumberWithString:totals];

	NSString *totalShiping =  [NSString stringWithFormat:@"%0.2f", totalShippingAmount];
	NSString *taxString = [NSString stringWithFormat:@"%0.2f", [GlobalPrefrences getRoundedOffValue:fTaxAmount]];

	// Optional: include payment details
	NSDecimalNumber *shipping = [NSDecimalNumber decimalNumberWithString:totalShiping];
	NSDecimalNumber *tax = [NSDecimalNumber decimalNumberWithString:taxString];
	self.amount = [[subTotal decimalNumberByAdding:shipping] decimalNumberByAdding:tax];

	DDLogDebug(@"Item price:%@ - Ship:%@ - Tax:%@ - Total:%@ ", subTotal, shipping, tax, self.amount);


	if ([self.amount compare:[NSNumber numberWithInt:0]] == NSOrderedDescending) {
		PaymentViewController *paymentViewController = [[PaymentViewController alloc] initWithNibName:nil bundle:nil];
		paymentViewController.amount = self.amount;
		paymentViewController.deleagate = self;
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paymentViewController];
		// 11/11/2014 Tuyen close fix bug wrong GUI when present view iOS8
		//    [self presentViewController:navController animated:YES completion:nil];
		// End

		DDLogInfo(@"Present Stripe payment view controller");
		// 11/11/2014 Tuyen new fix bug wrong GUI when present view iOS8
		[self.superVC presentViewController:navController animated:YES completion:nil];
		// End
	}
	else {
		DDLogWarn(@"Total amount of order is invail");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your subtotal amount is invalid" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}

	//    }
}

#pragma mark  PaymentViewController Delegate
- (void)paymentDidSuccess {
	DDLogInfo(@"Pay with Stripe was success");
	[self performSelectorInBackground:@selector(sendDataToServer:) withObject:@"5"];

	NSString *strTitle = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.title"]];

	NSString *strMessage = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.text"]];

	NSString *strCancelButton = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.cancelbutton"]];

	if ([strTitle length] > 0 && [strMessage length] > 0 && [strCancelButton length] > 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.text"] delegate:self cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

		[alert show];

		[alert release];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Order Approved" message:@"Thank you, your order has been completed successfully. Please visit the 'Account' tab for further details." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];

		[alert show];

		[alert release];
	}
	[strTitle release];
	[strMessage release];
	[strCancelButton release];
}

// 06/11/2014 Tuyen End

#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 09/02/2015 Tuyen new handle add delivery fee
    if ([alertView tag] == Delivery_Fee_Alert_Tag) {
        if (buttonIndex == 1) {
            [self cashOnDeveliery];
        }
    }
    // 09/02/2015 Tuyen end
    else{
        iNumOfItemsInShoppingCart = 0;
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabBarItem" object:nil];
    }
}

#pragma mark Fetch Data From SQLite DB

- (void)fetchDataFromLocalDB {
	//NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (!arrUserDetails)
		arrUserDetails = [[NSArray alloc] init];

	arrUserDetails = [[SqlQuery shared] getBuyerData:[GlobalPrefrences getUserDefault_Preferences:@"userEmail"]];

	//[pool release];
}

#pragma mark Send Data To Server
- (void)sendDataToServer2:(NSString *)paymentMode {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// NSString *strCode =[_savedPreferences.strCurrency substringFromIndex:3];

	NSString *strDataToPost = [NSString stringWithFormat:@"{\"storeId\":%d,\"appId\":%d,\"merchantId\":%d,\"fAmount\":%0.2f,\"sMerchantPaypalEmail\":\"%@\",\"fTaxAmount\":%0.2f,\"fShippingAmount\":%0.2f,\"fTotalAmount\":%0.2f,\"sBuyerName\":\"%@\",\"sBuyerEmail\":\"%@\",\"iBuyerPhone\":null,\"sShippingStreet\":\"%@\",\"sShippingCity\":\"%@\",\"sShippingState\":\"%@\",\"sShippingPostalCode\":\"%@\",\"sShippingCountry\":\"%@\",\"sBillingStreet\":\"%@\",\"sBillingCity\":\"%@\",\"sBillingState\":\"%@\",\"sBillingPostalCode\":\"%@\",\"sBillingCountry\":\"%@\",\"paymentMode\":%@,\"orderCurrency\":\"%@\"}", iCurrentStoreId, iCurrentAppId, iCurrentMerchantId, priceWithoutTax, [GlobalPrefrences getPaypalRecipient_Email], [GlobalPrefrences getRoundedOffValue:fTaxAmount], totalShippingAmount, grandTotalValue, [[arrUserDetails objectAtIndex:0] objectForKey:@"sUserName"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sEmailAddress"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryAddress"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryCity"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryState"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryPincode"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryCountry"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sStreetAddress"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sCity"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sState"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sPincode"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sCountry"], paymentMode, _savedPreferences.strCurrency];



	if (![GlobalPrefrences isInternetAvailable]) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDataInShoppingCartQueue"];

		// If internet is not available, then save the data into the database, for sending it later

		DDLogInfo(@"INTERNET IS UNAVAILABLE, SAVING DATA IN THE LOCAL DATABASE");

		[[SqlQuery shared] addToQueue_Shoppingcart:strDataToPost sendAtUrl:[NSString stringWithFormat:@"/product-order/save"]];
		for (int i = 0; i < [arrProductIds count]; i++) {
			float price;

			if ([[[arrProductIds objectAtIndex:i] objectForKey:@"fPrice"] floatValue] > [[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue]) {
				price = [[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue];
			}
			else {
				price = [[[arrProductIds objectAtIndex:i] objectForKey:@"fPrice"] floatValue];
			}

			NSString *dataToSave = [NSString stringWithFormat:@"{\"productId\":%d,\"fAmount\":%0.2f,\"orderId\":0,\"productOptionId\":%@,\"iQuantity\":%d,\"id\":null}", [[[arrProductIds objectAtIndex:i] objectForKey:@"id"] intValue], price, [[arrCartItems objectAtIndex:i] objectForKey:@"pOptionsId"], [[[arrProductIds objectAtIndex:i] objectForKey:@"quantity"] intValue]];




			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDataInIndividualProductsQueue"];

			[[SqlQuery shared] addToQueue_IndividualProducts:[GlobalPrefrences getCurrentShoppingCartNum] dataToSend:dataToSave sendAtUrl:[NSString stringWithFormat:@"/product-order-item-multiple/save"]];
		}
	}

	else {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDataInShoppingCartQueue"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDataInIndividualProductsQueue"];

		NSString *reponseRecieved = [ServerAPI product_orderSaveURLSend:strDataToPost];

		// Now send data to the server for this recently made order
		if ([reponseRecieved isKindOfClass:[NSString class]]) {
			int iCurrentOrderId = [[[[[reponseRecieved componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@"}"] objectAtIndex:0] intValue];

//			for (int i = 0; i < [arrProductIds count]; i++) {
//				NSString *dataToSave = [NSString stringWithFormat:@"{\"productId\":%d,\"fAmount\":%0.2f,\"orderId\":%d,\"productOptionId\":\"%@\",\"iQuantity\":%d,\"id\":null}", [[[arrProductIds objectAtIndex:i] objectForKey:@"id"] intValue], [[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue], iCurrentOrderId, [[arrCartItems objectAtIndex:i] valueForKey:@"pOptionId"], [[[arrProductIds objectAtIndex:i] objectForKey:@"quantity"] intValue]];
//
//				//NSLog(@"string to be printed%@", dataToSave);
//				if (![GlobalPrefrences isInternetAvailable]) {
//					// If internet is not available, then save the data into the database, for sending it later
//
//					DDLogInfo(@"INTERNET IS UNAVAILABLE, SAVING DATA IN THE LOCAL DATABASE");
//
//					[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDataInIndividualProductsQueue"];
//
//					[[SqlQuery shared] addToQueue_IndividualProducts:iCurrentOrderId dataToSend:dataToSave sendAtUrl:[NSString stringWithFormat:@"/product-order-item-multiple/save"]];
//				}
//
//				else {
//					[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDataInIndividualProductsQueue"];
//					[ServerAPI product_order_ItemSaveURLSend:dataToSave];
//				}
//
//				[[SqlQuery shared] deleteItemFromShoppingCart:[[[arrProductIds objectAtIndex:i] valueForKey:@"id"]integerValue]:[[arrCartItems objectAtIndex:i] valueForKey:@"pOptionId"]];
//			}
            
            NSMutableArray *arrProductItem = [[NSMutableArray alloc] init];
            for (int i = 0; i < [arrProductIds count]; i++) {
                NSMutableDictionary *dicItem = [[NSMutableDictionary alloc] init];
                //                NSString *strProductID = [NSString stringWithFormat:@"%d", [[[arrProductIds objectAtIndex:i] objectForKey:@"id"] intValue]];
                [dicItem setObject:[[arrProductIds objectAtIndex:i] objectForKey:@"id"] forKey:k_ProductID];
                NSString *strAmount = [NSString stringWithFormat:@"%0.2f", [[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue]];
                [dicItem setObject:strAmount forKey:k_fAmount];
                //                NSString *strOrderID = [NSString stringWithFormat:@"%d", iCurrentOrderId];
                [dicItem setObject:[NSString stringWithFormat:@"%d", iCurrentOrderId] forKey:@"orderId"];
                [dicItem setObject:[[arrCartItems objectAtIndex:i] valueForKey:@"pOptionId"] forKey:k_ProductOptionId];
                //                NSString *strQuantity = [NSString stringWithFormat:@"%@", [[arrProductIds objectAtIndex:i] objectForKey:@"quantity"]];
                [dicItem setObject:[[arrProductIds objectAtIndex:i] objectForKey:@"quantity"] forKey:k_iQuantity];
                [dicItem setObject:@"0" forKey:@"id"];
                [arrProductItem addObject:dicItem];
                
                [dicItem release];
            }
            NSString *dataToSave = [arrProductItem JSONRepresentation];
            
            //NSLog(@"string to be printed%@", dataToSave);
            if (![GlobalPrefrences isInternetAvailable]) {
                // If internet is not available, then save the data into the database, for sending it later
                
                DDLogInfo(@"INTERNET IS UNAVAILABLE, SAVING DATA IN THE LOCAL DATABASE");
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDataInIndividualProductsQueue"];
                
                [[SqlQuery shared] addToQueue_IndividualProducts:iCurrentOrderId dataToSend:dataToSave sendAtUrl:[NSString stringWithFormat:@"/product-order-multiple-items/save"]];
            }
            
            else {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDataInIndividualProductsQueue"];
                [ServerAPI sendListOrderItemToServer:dataToSave];
            }
            
            [[SqlQuery shared] emptyShoppingCart];

			if (iCurrentOrderId > 0) {
				[ServerAPI product_order_NotifyURLSend:@"Sending Order Number Last Time":iCurrentOrderId];
			}
		}
		else {
			DDLogWarn(@"Error While sending billing details to server (CheckoutViewController)");
		}
	}

	[pool release];
}

// 14/01/2015 Tuyen new code send order data to server
- (void)sendDataToServer:(NSString *)paymentMode {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // 09/02/2015 Tuyen new handle add delivery fee
    float totalAmount;
    totalAmount = grandTotalValue;
    // Check CashOnDelivery case
    if ([paymentMode isEqualToString:@"1"]) {
        float deliveryFee = [GlobalPrefrences getCasDeliveryFee];
        totalAmount = totalAmount + deliveryFee;
    }
    // 09/02/2015 Tuyen end
    
    // 1. Prepare data
    NSMutableDictionary *dicData = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *dicOrder = [[NSMutableDictionary alloc] init];
    NSMutableArray *arrOrderItem = [[NSMutableArray alloc] init];
    
    // prepare data for productOrder
    [dicOrder setObject:[NSString stringWithFormat:@"%d", iCurrentStoreId] forKey:@"storeId"];
    [dicOrder setObject:[NSString stringWithFormat:@"%d", iCurrentAppId] forKey:@"appId"];
    [dicOrder setObject:[NSString stringWithFormat:@"%d", iCurrentMerchantId] forKey:@"merchantId"];
    [dicOrder setObject:[NSString stringWithFormat:@"%0.2f", priceWithoutTax] forKey:@"fAmount"];
    [dicOrder setObject:[GlobalPrefrences getPaypalRecipient_Email] forKey:@"sMerchantPaypalEmail"];
    [dicOrder setObject:[NSString stringWithFormat:@"%0.2f", [GlobalPrefrences getRoundedOffValue:fTaxAmount]] forKey:@"fTaxAmount"];
    [dicOrder setObject:[NSString stringWithFormat:@"%0.2f", totalShippingAmount] forKey:@"fShippingAmount"];
    // 09/02/2015 Tuyen new handle add delivery fee
//    [dicOrder setObject:[NSString stringWithFormat:@"%0.2f", grandTotalValue] forKey:@"fTotalAmount"];
    [dicOrder setObject:[NSString stringWithFormat:@"%0.2f", totalAmount] forKey:@"fTotalAmount"];
    // 09/02/2015 Tuyen end
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sUserName"] forKey:@"sBuyerName"];
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sEmailAddress"] forKey:@"sBuyerEmail"];
//    [dicOrder setObject:@"" forKey:@"iBuyerPhone"];
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryAddress"] forKey:@"sShippingStreet"];
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryCity"] forKey:@"sShippingCity"];
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryState"] forKey:@"sShippingState"];
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryPincode"] forKey:@"sShippingPostalCode"];
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryCountry"] forKey:@"sShippingCountry"];
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sStreetAddress"] forKey:@"sBillingStreet"];
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sCity"] forKey:@"sBillingCity"];
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sState"] forKey:@"sBillingState"];
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sPincode"] forKey:@"sBillingPostalCode"];
    [dicOrder setObject:[[arrUserDetails objectAtIndex:0] objectForKey:@"sCountry"] forKey:@"sBillingCountry"];
    [dicOrder setObject:paymentMode forKey:@"paymentMode"];
    [dicOrder setObject:_savedPreferences.strCurrency forKey:@"orderCurrency"];
    
    // prepara data for productOrderItemMultipleList
    for (int i = 0; i < [arrProductIds count]; i++) {
        NSMutableDictionary *dicItem = [[NSMutableDictionary alloc] init];
        
        [dicItem setObject:[[arrProductIds objectAtIndex:i] objectForKey:@"id"] forKey:k_ProductID];
        NSString *strAmount = [NSString stringWithFormat:@"%0.2f", [[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue]];
        [dicItem setObject:strAmount forKey:k_fAmount];
        [dicItem setObject:@"0" forKey:@"orderId"];
        [dicItem setObject:[[arrCartItems objectAtIndex:i] valueForKey:@"pOptionId"] forKey:k_ProductOptionId];
        [dicItem setObject:[[arrProductIds objectAtIndex:i] objectForKey:@"quantity"] forKey:k_iQuantity];
        [dicItem setObject:@"0" forKey:@"id"];
        [arrOrderItem addObject:dicItem];
        
        [dicItem release];
    }
    
    // prepare data send server
    [dicData setObject:dicOrder forKey:@"productOrder"];
    [dicData setObject:arrOrderItem forKey:@"productOrderItemMultipleList"];
    
    NSString *dataToSave = [dicData JSONRepresentation];
    
    // 2. Check internet status
    // 2.1 If status is un-available
    NSString *reponseRecieved;
    if (![GlobalPrefrences isInternetAvailable]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDataInShoppingCartQueue"];
        
        // If internet is not available, then save the data into the database, for sending it later
        DDLogInfo(@"INTERNET IS UNAVAILABLE, SAVING DATA IN THE LOCAL DATABASE");
        
        
        [[SqlQuery shared] addToQueue_Shoppingcart:dataToSave sendAtUrl:[NSString stringWithFormat:@"/product-order-multiple-items/save"]];
    }
    // 2.2 If status id available - send data to server
    else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDataInShoppingCartQueue"];
        reponseRecieved = [ServerAPI sendListOrderItemToServer:dataToSave];
    }
    
    if ([reponseRecieved isKindOfClass:[NSString class]])
    {
        NSDictionary *dicReponseRecieved = [reponseRecieved JSONValue];
        int iCurrentOrderId = [[dicReponseRecieved objectForKeyedSubscript:@"order_id"] intValue];
        
        
        if (iCurrentOrderId > 0) {
            [[SqlQuery shared] emptyShoppingCart];
            [ServerAPI product_order_NotifyURLSend:@"Sending Order Number Last Time":iCurrentOrderId];
        }
    }
    else {
        DDLogWarn(@"Error While sending billing details to server (CheckoutViewController)");
    }
    
    [dicData release];
    [dicOrder release];
    [arrOrderItem release];
    
    [pool release];
}
// End

/*
   // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
   - (void)viewDidLoad {
   [super viewDidLoad];
   }
 */



- (void)didReceiveMemoryWarning {
	DDLogInfo(@"did Receive Memory Warning");
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

/*- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   // Overriden to allow any orientation.

   return UIInterfaceOrientationIsLandscape(interfaceOrientation);
   }
 */
- (void)receivedRotate:(NSNotification *)notification {
	DDLogInfo(@"received Rotate");
	//UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];

	//if(interfaceOrientation != UIDeviceOrientationUnknown)
	//[self deviceInterfaceOrientationChanged:interfaceOrientation];
}

- (void)viewDidUnload {
	DDLogInfo(@"View did unload");
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	DDLogInfo(@"should Autorotate To Interface Orientation");
	// Return YES for supported orientations
	return YES;
}

- (void)dealloc {
	DDLogInfo(@"Dealloc");
	//	[contentView release];
	//contentView=nil;
	//[super dealloc];

	// 05/8/2014 Tuyen new code
	[super dealloc];
	// End
}

#pragma mark - Utils
- (NSString *)getTimeStamp {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	NSLocale *locale = [[NSLocale alloc]
	                    initWithLocaleIdentifier:@"en_US_POSIX"];

	[formatter setLocale:locale];

	NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
	[formatter setTimeZone:gmt];

	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	return [formatter stringFromDate:[NSDate date]];
}

- (void)processPaymentSucces:(NSString *)paymentIDType {
	//Send the order information/details to the server
	[self performSelectorInBackground:@selector(sendDataToServer:) withObject:paymentIDType];

	NSString *strTitle = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.title"]];

	NSString *strMessage = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.text"]];

	NSString *strCancelButton = [[NSString alloc] initWithFormat:@"%@", [[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.cancelbutton"]];

	if ([strTitle length] > 0 && [strMessage length] > 0 && [strCancelButton length] > 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.text"] delegate:self cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

		[alert show];

		[alert release];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Order Approved" message:@"Thank you, your order has been completed successfully. Please visit the 'Account' tab for further details." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];

		[alert show];

		[alert release];
	}
	[strTitle release];
	[strMessage release];
	[strCancelButton release];
	/*[self performSelectorInBackground:@selector(sendDataToServers:) withObject:paymentIDType];

	   NSString *strTitle = [[NSString alloc] initWithFormat:@"%@",[[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.title"] ];

	   NSString *strMessage = [[NSString alloc] initWithFormat:@"%@",[[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.text"]];

	   NSString *strCancelButton = [[NSString alloc] initWithFormat:@"%@",[[GlobalPrefrences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.cancelbutton"] ];

	   if ([strTitle length]>0 && [strMessage length]>0 && [strCancelButton length]>0)
	   {
	    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.title"] message:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.text"] delegate:self cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];

	    [alert show];

	    [alert release];
	   }
	   else {
	    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Order Approved" message:@"Thank you, your order has been completed successfully. Please visit the 'Account' tab for further details." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];

	    [alert show];

	    [alert release];
	   }
	   [strTitle release];
	   [strMessage release];
	   [strCancelButton release];*/
}

- (void)errorMessage:(NSString *)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.title"] message:message delegate:nil cancelButtonTitle:[[GlobalPrefrences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
	[alert show];
	[alert release];
}

@end
