//
//  CheckoutViewController.m
//  MobiCart
//

//`

#import "CheckoutViewController.h"
#import "Constants.h"
#import "PayPalPayment.h"
#import "PayPalAdvancedPayment.h"
#import "PayPalAmounts.h"
#import "PayPalReceiverAmounts.h"
#import "PayPalAddress.h"
#import "PayPalInvoiceItem.h"

extern BOOL isLoadingTableFooter;
extern int controllersCount;
extern   MobicartAppAppDelegate *_objMobicartAppDelegate;
@implementation CheckoutViewController

@synthesize grandTotalValue,fSubTotalAmount,fTaxAmount,arrProductIds, fShippingCharges,sCountry,fSubTotal,arrCartItems,sMerchantPaypayEmail;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
 {
 // Custom initialization
 }
 return self;
 }
 */

-(void)setLabelsForFooter
{
	if([[[dictTax valueForKey:@"tax"] valueForKey:@"fTax"] isKindOfClass:[NSNull class]])
        shippingtax=0.0;
	else
	    shippingtax=[[[dictTax valueForKey:@"tax"] valueForKey:@"fTax"] floatValue];
    
	
	fSubTotalAmount = grandTotalValue;
	
	
	
	if([[dicSettings valueForKey:@"bTaxShipping"]intValue]==1)
		lblShippingTax.text= [NSString stringWithFormat:@"%@%0.2f",_savedPreferences.strCurrencySymbol,(fShippingCharges*shippingtax)/100];
	else
		lblShippingTax.text= [NSString stringWithFormat:@"%@0.00",_savedPreferences.strCurrencySymbol];
	
	
	if([[dicSettings valueForKey:@"bTaxShipping"]intValue]==1)
	{
		
		taxOnShipping=((fShippingCharges *shippingtax)/100);
	}
    else
	{
		taxOnShipping=0;
		shippingtax=0;
	}
	
	taxOnShipping=[GlobalPreferences getRoundedOffValue:taxOnShipping];
	//fTaxAmount=(grandTotalValue*shippingtax)/100;
	grandTotalValue=priceWithoutTax+fShippingCharges+taxOnShipping+fTaxAmount;
	
	
	
	lblShippingCharges.text = [NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, fShippingCharges ];
	
	
	
	
	lblTaxAmount.text = [NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol,[GlobalPreferences getRoundedOffValue:fTaxAmount]];
	
	
	lblSubTotalCharges.text = [NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, priceWithoutTax];
	
	lblGrandTotal.text = [NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, grandTotalValue];
	
	
}
- (void) tableView:(UITableView*)tableview didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	
	[tableview deselectRowAtIndexPath:indexPath animated:YES];
	
}



- (UITableViewCell*) tableView:(UITableView*)tableview cellForRowAtIndexPath:(NSIndexPath*) indexPath
{
	NSString *SimpleTableIdentifier = [NSString stringWithFormat:@"SimpleTableIdentifier%d", indexPath.row];
	UITableViewCell *cell= (UITableViewCell *)[tableview dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
	
	float optionPrice=0;
	if(cell==nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier] autorelease];
		
		int yValue=0;
		if (!([[[arrCartItems objectAtIndex:indexPath.row] valueForKey:@"pOptionId"] intValue]==0))
		{
			
			NSArray *arrSelectedOptions=[[[arrCartItems objectAtIndex:indexPath.row] valueForKey:@"pOptionId"] componentsSeparatedByString:@","];
			
			int optionsCount=[arrSelectedOptions count];
			yValue=50+(optionsCount-1)*15;
		}
		else
        {
			yValue=50;
		}
        
		
		UIImageView *imgCellBackground=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 342,yValue)];
		[imgCellBackground setImage:[UIImage imageNamed:@"shoppingcart_bar_stan.png"]];
		[cell setBackgroundView:imgCellBackground];
		[imgCellBackground release];
		
		
		
		UILabel *lblProductNames = [[UILabel alloc] init];
		lblProductNames.frame = CGRectMake( 10,1, 100, 30);
		[lblProductNames setBackgroundColor:[UIColor clearColor]];
		lblProductNames.textColor =[UIColor blackColor];
		lblProductNames.font =[UIFont fontWithName:@"Helvetica-Bold" size:13];
		lblProductNames.textAlignment = UITextAlignmentLeft;
		lblProductNames.lineBreakMode = UILineBreakModeTailTruncation;
		lblProductNames.text = [NSString stringWithFormat:@"%@", [[arrProductIds objectAtIndex:indexPath.row] valueForKey:@"sName"]];
		[cell.contentView addSubview:lblProductNames];
		[lblProductNames release];
		
		UILabel *lblProductQuantity = [[UILabel alloc] init];
		lblProductQuantity.frame = CGRectMake( 120, 1, 40, 30);
		[lblProductQuantity setBackgroundColor:[UIColor clearColor]];
		lblProductQuantity.textColor =[UIColor blackColor];
		lblProductQuantity.font =[UIFont fontWithName:@"Helvetica-Bold" size:12];
		lblProductQuantity.textAlignment = UITextAlignmentLeft;
		lblProductQuantity.lineBreakMode = UILineBreakModeTailTruncation;
		lblProductQuantity.text = [NSString stringWithFormat:@"%@", [[arrProductIds objectAtIndex:indexPath.row] valueForKey:@"quantity"]];
		[cell.contentView addSubview:lblProductQuantity];
		[lblProductQuantity release];
		
		
		UILabel *lblOptionTitle[100];
		UILabel *lblOptionName[100];
		int optionSizesIndex[100]={};
		
		if (!([[[arrProductIds objectAtIndex:indexPath.row] valueForKey:@"pOptionId"] intValue]==0))
		{
			
			NSMutableArray *dictOption = [[arrProductIds objectAtIndex:indexPath.row] objectForKey:@"productOptions"];
			
			NSMutableArray *arrProductOptionSize = [[[NSMutableArray alloc] init] autorelease];
			
			for (int i=0; i<[dictOption count]; i++)
			{
				[arrProductOptionSize addObject:[[dictOption objectAtIndex:i] valueForKey:@"id"]];
			}
			
			NSArray *arrSelectedOptions=[[[arrCartItems objectAtIndex:indexPath.row] valueForKey:@"pOptionId"] componentsSeparatedByString:@","];
			
			if([arrProductOptionSize count]!=0 && [arrSelectedOptions count]!=0)
			{
				for(int count=0;count<[arrSelectedOptions count];count++)
				{
					if ([arrProductOptionSize containsObject: [NSNumber numberWithInt:[[arrSelectedOptions objectAtIndex:count] integerValue]]])
					{
						optionSizesIndex[count] = [arrProductOptionSize indexOfObject:[NSNumber numberWithInt:[[arrSelectedOptions objectAtIndex:count]  intValue]]];
					}
				}
			}
			
			
			int yValue=1;
			
			for(int count=0;count<[arrSelectedOptions count];count++)
			{
				
				
				optionPrice+=[[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"pPrice"]floatValue];
                
                NSString *tempStr=nil;
                
                if([[NSString stringWithFormat:@"%@",[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sTitle"]] length ]>8)
                {
                    tempStr=[[NSString stringWithFormat:@"%@",[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sTitle"]] substringToIndex:7];
                    tempStr=[NSString stringWithFormat:@"%@..:",tempStr];
                }
                else{
                    tempStr=[NSString stringWithFormat:@"%@:",[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sTitle"]] ;
                }
                
                CGSize size=[tempStr sizeWithFont:[UIFont boldSystemFontOfSize:10]];
				int width=size.width;
				if(width>45)
					width=45;
				lblOptionTitle[count] = [[UILabel alloc]initWithFrame:CGRectMake(lblProductQuantity.frame.origin.x+45,yValue,width+3,30)];
				lblOptionTitle[count].backgroundColor=[UIColor clearColor];
				[lblOptionTitle[count] setTextAlignment:UITextAlignmentLeft];
				lblOptionTitle[count].textColor=[UIColor darkGrayColor];
				[lblOptionTitle[count] setText:tempStr] ;
				lblOptionTitle[count].font=[UIFont boldSystemFontOfSize:10];
				[cell.contentView addSubview:lblOptionTitle[count]];
				[lblOptionTitle[count] release];
				
                
				
				CGSize size1=[[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sName"] sizeWithFont:[UIFont boldSystemFontOfSize:12] constrainedToSize:CGSizeMake(1000, 20)];
				int width1=size1.width;
				if(width1>38)
					width1=38;
				lblOptionName[count] = [[UILabel alloc]initWithFrame:CGRectMake(lblOptionTitle[count].frame.size.width+lblOptionTitle[count].frame.origin.x,yValue,width1, 30)];
				lblOptionName[count].backgroundColor=[UIColor clearColor];
				[lblOptionName[count] setTextAlignment:UITextAlignmentLeft];
				lblOptionName[count].textColor=[UIColor blackColor];
				[lblOptionName[count] setText: [NSString stringWithFormat:@"%@",[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sName"]]];
				lblOptionName[count].lineBreakMode = UILineBreakModeWordWrap;
				lblOptionName[count].lineBreakMode = UILineBreakModeTailTruncation;
				lblOptionName[count].font=[UIFont boldSystemFontOfSize:12];
				[cell.contentView addSubview:lblOptionName[count]];
				[lblOptionName[count] release];
				
				yValue=yValue+15;
			}
			
			
			
		}
		
		float productCost=0, productTax=0;
        
        
        
		
		NSString *discount = [NSString stringWithFormat:@"%@", [[arrProductIds objectAtIndex:indexPath.row]valueForKey:@"fDiscountedPrice"]];
		
		if((![discount isEqual:[NSNull null]]) && (![discount isEqualToString:@"<null>"]) && ([discount length]!=0))
		{
			if([[[arrProductIds objectAtIndex:indexPath.row]valueForKey:@"fPrice"] floatValue]>[discount floatValue])
				productCost=[discount floatValue];
			else
				productCost=[discount floatValue];
			
		}
		else
			productCost=[[[arrProductIds objectAtIndex:indexPath.row]valueForKey:@"fPrice"] floatValue];
		
		productCost=[GlobalPreferences getRoundedOffValue:productCost];
        
		priceWithoutTax+=((productCost+optionPrice)*[[[arrProductIds objectAtIndex:indexPath.row] valueForKey:@"quantity"] intValue]);
		
		
		if([[dicSettings valueForKey:@"bIncludeTax"]intValue]==1)
			productCost+=optionPrice+[[[arrProductIds objectAtIndex:indexPath.row]valueForKey:@"fTax"]floatValue];
        
		float productTotal = [[[arrProductIds objectAtIndex:indexPath.row] valueForKey:@"quantity"] intValue] * (productCost);
        
		productTotal=[GlobalPreferences getRoundedOffValue:productTotal];
		_fSubTotal+=productTotal;
		_fSubTotal=[GlobalPreferences getRoundedOffValue:_fSubTotal];
        
		fTaxAmount=[GlobalPreferences getRoundedOffValue:fTaxAmount];
		if([[dicSettings valueForKey:@"bIncludeTax"]intValue]==1)
		{
			taxPercent = [[[dictTax valueForKey:@"tax"] valueForKey:@"fTax"] floatValue];
			if(countryID==0)
			{
				istaxToBeApplied=NO;
				productTax = 0;
				fTaxAmount = 0;
				productTotal = productTotal;
				fShippingCharges=0;
			}
			else
			{
				istaxToBeApplied=YES;
				
				if([[[arrProductIds objectAtIndex:indexPath.row]valueForKey:@"fPrice"] floatValue]>[discount floatValue])
					productTax=(([discount floatValue]+0)*taxPercent)/100;
				else
					productTax=(([[[arrProductIds objectAtIndex:indexPath.row]valueForKey:@"fPrice"] floatValue]+0)*taxPercent)/100;
				productTax = (productTax * [[[arrProductIds objectAtIndex:indexPath.row] valueForKey:@"quantity"] intValue]);
				fTaxAmount += productTax;
				productTotal = productTotal;
			}
		}
		else {
			istaxToBeApplied=NO;
		}
		
		grandTotalValue += productTotal;
		
		//[pool release];
		
		UILabel *lblProductSubTotal = [[UILabel alloc] init];
		lblProductSubTotal.frame = CGRectMake( 250,1, 70, 30);
		[lblProductSubTotal setBackgroundColor:[UIColor clearColor]];
		lblProductSubTotal.textColor =[UIColor blackColor];
		lblProductSubTotal.font =[UIFont fontWithName:@"Helvetica-Bold" size:10];
		lblProductSubTotal.textAlignment = UITextAlignmentLeft;
        
        DLog(@"Currencyyy %@",_savedPreferences.strCurrencySymbol);
        lblProductSubTotal.text = [NSString stringWithFormat:@"%@%0.2f",_savedPreferences.strCurrencySymbol,productCost];
		[cell.contentView addSubview:lblProductSubTotal];
		[lblProductSubTotal release];
		
		
		
		
		UILabel *lblProductTax = [[UILabel alloc] init];
		lblProductTax.frame = CGRectMake( 205,1, 53, 30);
		[lblProductTax setBackgroundColor:[UIColor clearColor]];
		lblProductTax.textColor = navBarColor;
		lblProductTax.font=[UIFont boldSystemFontOfSize:10];
		lblProductTax.textAlignment = UITextAlignmentCenter;
		lblProductTax.lineBreakMode = UILineBreakModeTailTruncation;
		lblProductTax.text = [NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, [GlobalPreferences getRoundedOffValue:productTax]];
		[lblProductTax release];
		
		UILabel *lblProductTotal = [[UILabel alloc] init];
		lblProductTotal.frame = CGRectMake( 245,1, 68, 40);
		[lblProductTotal setBackgroundColor:[UIColor clearColor]];
		lblProductTotal.textColor =[UIColor blackColor];
		lblProductTotal.font = [UIFont boldSystemFontOfSize:10];
		lblProductTotal.textAlignment = UITextAlignmentRight;
		lblProductTotal.numberOfLines=2;
		lblProductTotal.lineBreakMode = UILineBreakModeTailTruncation;
		
		NSString *strTemptaxType=[[dictTax valueForKey:@"tax"] valueForKey:@"sType"];
		
		if([strTemptaxType isEqualToString:@"default"])
			strTemptaxType=@"tax";
		
		
		if(istaxToBeApplied==YES)
			//	if ([[dictProductDetails valueForKey:@"bTaxable"] intValue]==1)
			lblProductTotal.text = [NSString stringWithFormat:@"%@%0.2f\n(inc. %@)", _savedPreferences.strCurrencySymbol, productTotal,strTemptaxType];
		else
			lblProductTotal.text = [NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, productTotal];
		
		DLog(@"Currency label----- %@",lblProductTotal.text);
		//[contentScrollView addSubview:lblProductTotal];
		[lblProductTotal release];
		
		
		
		
	}
	
	if(indexPath.row==[arrProductIds count]-1)
	{
		[self setLabelsForFooter];
		
	}
    
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	return  cell;
}


- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (!([[[arrCartItems objectAtIndex:indexPath.row] valueForKey:@"pOptionId"] intValue]==0))
	{
		
		NSArray *arrSelectedOptions=[[[arrCartItems objectAtIndex:indexPath.row] valueForKey:@"pOptionId"] componentsSeparatedByString:@","];
		
		int optionsCount=[arrSelectedOptions count];
		return 50+(optionsCount-1)*15;
		//return optionsCount*35;
	}
	
	
	else {
		return 50;
	}
	
	
	
	
	
}
- (NSInteger) tableView:(UITableView*) _tableView numberOfRowsInSection:(NSInteger) section
{
	
	return [arrProductIds count];
}

-(void)createTableView
{
	UIView *viewFooter = [[UIView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0, 0, 300,350) chageHieght:YES]];
    viewFooter.backgroundColor = [UIColor colorWithRed:88.6/100 green:88.6/100 blue:88.6/100 alpha:1];
	UIImageView *imgFooterView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"check_out_bottom.png"]];
	
    [viewFooter addSubview:imgFooterView];
    [imgFooterView release];
    NSString *strTemp=[NSString stringWithFormat:@"%@: ",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.checkout.sub-total"]];
    
    CGSize size =[strTemp sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(1000, 20)];
    
    int width=size.width;
    
    if(width>90)
        width=90;
   	
	UILabel *lblSubTotalChargesTitle = [[UILabel alloc] init];
	lblSubTotalChargesTitle.frame = CGRectMake(165, 19,width, 20);
	[lblSubTotalChargesTitle setBackgroundColor:[UIColor clearColor]];
	lblSubTotalChargesTitle.textColor = [UIColor darkGrayColor];
	lblSubTotalChargesTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:13.0];
	lblSubTotalChargesTitle.textAlignment = UITextAlignmentLeft;
	lblSubTotalChargesTitle.text =[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.checkout.sub-total"]];
	[viewFooter addSubview:lblSubTotalChargesTitle];
	[lblSubTotalChargesTitle release];
	int xCoord=lblSubTotalChargesTitle.frame.size.width+lblSubTotalChargesTitle.frame.origin.x+2;
	lblSubTotalCharges = [[UILabel alloc] init];
	lblSubTotalCharges.frame = CGRectMake(xCoord, 19,320-xCoord, 20);
	[lblSubTotalCharges setBackgroundColor:[UIColor clearColor]];
    lblSubTotalCharges.textColor=[UIColor blackColor];
	lblSubTotalCharges.font =[UIFont fontWithName:@"Helvetica-Bold" size:10.0];
	lblSubTotalCharges.textAlignment = UITextAlignmentLeft;
	[viewFooter addSubview:lblSubTotalCharges];
	
	
    strTemp=[NSString stringWithFormat:@"%@: ",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.tax"]];
    size =[strTemp sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(1000, 20)];
    
    width=size.width;
    
    if(width>90)
        width=90;
	UILabel *lblTaxAmountTitle = [[UILabel alloc] init];
	lblTaxAmountTitle.frame = CGRectMake(165, 37,width, 20);
	lblTaxAmountTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:13.0];
    [lblTaxAmountTitle setBackgroundColor:[UIColor clearColor]];
	lblTaxAmountTitle.textColor =[UIColor darkGrayColor];
	lblTaxAmountTitle.textAlignment = UITextAlignmentLeft;
	lblTaxAmountTitle.text =[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.tax"]];
	[viewFooter addSubview:lblTaxAmountTitle];
	[lblTaxAmountTitle release];
	
	xCoord=lblTaxAmountTitle.frame.size.width+lblTaxAmountTitle.frame.origin.x+2;
	
	lblTaxAmount = [[UILabel alloc] init];
	lblTaxAmount.frame = CGRectMake(xCoord, 37,320-xCoord, 20);
	[lblTaxAmount setBackgroundColor:[UIColor clearColor]];
	lblTaxAmount.textColor = [UIColor blackColor];
	lblTaxAmount.font =[UIFont fontWithName:@"Helvetica-Bold" size:10.0];
	lblTaxAmount.textAlignment = UITextAlignmentLeft;
	[viewFooter addSubview:lblTaxAmount];
	
    strTemp=[NSString stringWithFormat:@"%@: ",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.shipping"]];
    size =[strTemp sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(1000, 20)];
    
    width=size.width;
    
    if(width>90)
        width=90;
	UILabel *lblShippingChargesTitle = [[UILabel alloc] init];
	lblShippingChargesTitle.frame = CGRectMake( 165, 55,width, 20);
	[lblShippingChargesTitle setBackgroundColor:[UIColor clearColor]];
	lblShippingChargesTitle.textColor =[UIColor darkGrayColor];
	lblShippingChargesTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:13.0];
	lblShippingChargesTitle.textAlignment = UITextAlignmentLeft;
	lblShippingChargesTitle.text =[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.shipping"]];
	[viewFooter addSubview:lblShippingChargesTitle];
	[lblShippingChargesTitle release];
	
    xCoord=lblShippingChargesTitle.frame.size.width+lblShippingChargesTitle.frame.origin.x+2;
	lblShippingCharges = [[UILabel alloc] init];
	lblShippingCharges.frame = CGRectMake(xCoord, 55,320-xCoord, 20);
	[lblShippingCharges setBackgroundColor:[UIColor clearColor]];
	lblShippingCharges.textColor =[UIColor blackColor];
	lblShippingCharges.font =[UIFont fontWithName:@"Helvetica-Bold" size:10.0];
	lblShippingCharges.textAlignment = UITextAlignmentLeft;
	[viewFooter addSubview:lblShippingCharges];
	
    
    strTemp=[NSString stringWithFormat:@"%@: ",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.tax.shipping"]];
    size =[strTemp sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(1000, 20)];
    
    width=size.width;
    
    if(width>90)
        width=90;
	UILabel *lblShippingTaxTitle= [[UILabel alloc] init];
	lblShippingTaxTitle.frame = CGRectMake(165,74,width, 20);
	[lblShippingTaxTitle setBackgroundColor:[UIColor clearColor]];
	lblShippingTaxTitle.textColor =[UIColor darkGrayColor];		//lblGrandTotal.font = [UIFont systemFontOfSize:14];
	
	lblShippingTaxTitle.textAlignment = UITextAlignmentLeft;
	[viewFooter addSubview:lblShippingTaxTitle];
	[lblShippingTaxTitle setText:[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.tax.shipping"]]];
	lblShippingTaxTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:13.0];
	
	[lblShippingTaxTitle release];
	
	xCoord=lblShippingTaxTitle.frame.size.width+lblShippingTaxTitle.frame.origin.x+2;
	lblShippingTax= [[UILabel alloc] init];
	lblShippingTax.frame = CGRectMake(xCoord,74,320-xCoord, 20);
	[lblShippingTax setBackgroundColor:[UIColor clearColor]];
	lblShippingTax.textColor =[UIColor blackColor];
	lblShippingTax.font =[UIFont fontWithName:@"Helvetica-Bold" size:10.0];
	lblShippingTax.textAlignment = UITextAlignmentLeft;
    [viewFooter addSubview:lblShippingTax];
	
	
	UILabel *lblStars=[[UILabel alloc]initWithFrame:CGRectMake(165, lblShippingTax.frame.origin.y+lblShippingTax.frame.size.height
															   ,179, 20)];
	[lblStars setBackgroundColor:[UIColor clearColor]];
	[lblStars setText:@"***********************"];
	[lblStars setTextColor:[UIColor blackColor]];
	[viewFooter
	 addSubview:lblStars];
	[lblStars release];
	
    strTemp=[NSString stringWithFormat:@"%@: ",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.checkout.total"]];
    size =[strTemp sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0] constrainedToSize:CGSizeMake(1000, 20)];
    
    width=size.width;
    
    if(width>90)
        width=90;
	UILabel *lblGrandTotalTitle = [[UILabel alloc] init];
	lblGrandTotalTitle.frame = CGRectMake(165, 112,width, 20);
	[lblGrandTotalTitle setBackgroundColor:[UIColor clearColor]];
	lblGrandTotalTitle.textColor = [UIColor darkGrayColor];
	lblGrandTotalTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:15.0];
	
	lblGrandTotalTitle.textAlignment = UITextAlignmentLeft;
	lblGrandTotalTitle.text = [NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.checkout.total"]];
	[viewFooter addSubview:lblGrandTotalTitle];
	[lblGrandTotalTitle release];
	
    xCoord=lblGrandTotalTitle.frame.size.width+lblGrandTotalTitle.frame.origin.x+2;
	lblGrandTotal = [[UILabel alloc] init];
	lblGrandTotal.frame = CGRectMake( xCoord, 112,320-xCoord, 20);
	[lblGrandTotal setBackgroundColor:[UIColor clearColor]];
	lblGrandTotal.textColor = [UIColor blackColor];	;
   	lblGrandTotal.font =[UIFont fontWithName:@"Helvetica-Bold" size:13.0];
    lblGrandTotal.textAlignment = UITextAlignmentLeft;
	[viewFooter addSubview:lblGrandTotal];
    
    
    int yAxis=190;
	/**************************PayAPl Gatway*******************************************************/
    if([[GlobalPreferences getPaypalModeEnable] intValue]==1 && ([GlobalPreferences getPaypalLiveToken].length!=0))
    {
//        NSLog(@"*****************************PayPal Token/PayPal Mode******************************");
//        NSLog(@"PayPalToken: %@",[GlobalPreferences getPaypalLiveToken]);
//        NSLog(@"PayPalMode:  %@",[GlobalPreferences getPaypalModeIsLive]);
//        NSLog(@"*******************************************************************************");
//        
        if([[GlobalPreferences getPaypalModeIsLive] intValue]==1)
        {
            [PayPal initializeWithAppID:[GlobalPreferences getPaypalLiveToken] forEnvironment:ENV_LIVE];
        }
        else
        {
            [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];
        }
        
        
        UIButton * btn = [[PayPal getPayPalInst] getPayButtonWithTarget:self andAction:@selector(payWithPayPal) andButtonType:BUTTON_278x43];
        btn.frame = CGRectMake(20, 180, 278, 34);
        //[viewFooter addSubview:btn];
        
        
        UIButton *btnPayPal=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnPayPal addTarget:self action:@selector(payWithPayPal) forControlEvents:UIControlEventTouchUpInside];
        [btnPayPal setTitle:[NSString stringWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.paybypaypalnew"]] forState:UIControlStateNormal];
        [btnPayPal setBackgroundImage:[UIImage imageNamed:@"checkout_btn.png"] forState:UIControlStateNormal];
        btnPayPal.backgroundColor=navBarColor;
        [btnPayPal layer].cornerRadius=5.0;
        [btnPayPal.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
        btnPayPal.frame=CGRectMake(20, yAxis, 278, 34);
        [viewFooter addSubview:btnPayPal];
        yAxis=yAxis+50;
        
        
        
    }
    /**************************ZOOZ Gatway*******************************************************/
    
    
    
    if([[GlobalPreferences getZoozModeEnable] intValue]==1 && ([GlobalPreferences getZoozPaymentToken].length!=0))
    {
        
        
//        NSLog(@"*****************************ZooZ AppUnique ID/Zooz Mode******************************");
//        NSLog(@"iPhone ZooZ App Unique ID:  %@",[[NSBundle mainBundle] bundleIdentifier]);
//        NSLog(@"iPhone ZooZ key:  %@",[GlobalPreferences getZoozPaymentToken]);
//        NSLog(@"ZooZ Mode:  %@",[GlobalPreferences getZoozModeIsLive]);
//        NSLog(@"*******************************************************************************");
//        
        
        
        UIButton *btnPaywithZooZ=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnPaywithZooZ addTarget:self action:@selector(payWithZooz) forControlEvents:UIControlEventTouchUpInside];
        [btnPaywithZooZ setTitle:[NSString stringWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.PayWithPaypal"]] forState:UIControlStateNormal];
        [btnPaywithZooZ setBackgroundImage:[UIImage imageNamed:@"checkout_btn.png"] forState:UIControlStateNormal];
        btnPaywithZooZ.backgroundColor=navBarColor;
        [btnPaywithZooZ layer].cornerRadius=5.0;
        [btnPaywithZooZ.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
        
        
        btnPaywithZooZ.frame=CGRectMake(20, yAxis, 278, 34);
        
        yAxis=yAxis+50;
        
        
        [viewFooter addSubview:btnPaywithZooZ];
        
    }
    
    /**************************Cash On Delivery*******************************************************/
    
    if(![[dicSettings valueForKey:@"codEnabled"]isEqual:[NSNull null]])
    {
        if([[dicSettings  valueForKey:@"codEnabled"]intValue]==1)
        {
            
            UIButton *cashOnDBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            [cashOnDBtn addTarget:self action:@selector(cashOnDeveliery) forControlEvents:UIControlEventTouchUpInside];
            cashOnDBtn.userInteractionEnabled=YES;
            [cashOnDBtn setTitle:[NSString stringWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.CashOnDelivery"]] forState:UIControlStateNormal];
            [cashOnDBtn setBackgroundImage:[UIImage imageNamed:@"checkout_btn.png"] forState:UIControlStateNormal];
            cashOnDBtn.backgroundColor=navBarColor;
            [cashOnDBtn layer].cornerRadius=5.0;
            [cashOnDBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15.0]];
            
            cashOnDBtn.frame=CGRectMake(20, yAxis, 278, 34);
            
            [viewFooter addSubview:cashOnDBtn];
        }
    }
    
    
	UILabel*lblCountryTitle=[[UILabel alloc] initWithFrame:CGRectMake(10, 19,100,25)];
	[lblCountryTitle setText:[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.checkout.country"]]];
	[lblCountryTitle setBackgroundColor:[UIColor clearColor]];
	[lblCountryTitle setTextColor:[UIColor darkGrayColor]];
	lblCountryTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
	[viewFooter addSubview:lblCountryTitle];
	[lblCountryTitle release];
	
	
	UILabel*lblCountryFooter=[[UILabel alloc] initWithFrame:CGRectMake(10,36,100, 25)];
	[lblCountryFooter setText:[arrInfoAccount objectAtIndex:10]];
	[lblCountryFooter setBackgroundColor:[UIColor clearColor]];
	[lblCountryFooter setTextColor:[UIColor blackColor]];
	lblCountryFooter.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
	[viewFooter addSubview:lblCountryFooter];
	[lblCountryFooter release];
	
	UILabel*lblStateTitle=[[UILabel alloc] initWithFrame:CGRectMake(10,61,100,25)];
	[lblStateTitle setText:[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.signup.state"]]];
	[lblStateTitle setBackgroundColor:[UIColor clearColor]];
	[lblStateTitle setTextColor:[UIColor darkGrayColor]];
	lblStateTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
	[viewFooter addSubview:lblStateTitle];
	[lblStateTitle release];
	
	
	UILabel*lblStateFooter=[[UILabel alloc] initWithFrame:CGRectMake(10,77,100, 25)];
	[lblStateFooter setText:[arrInfoAccount objectAtIndex:8]];
	[lblStateFooter setBackgroundColor:[UIColor clearColor]];
	[lblStateFooter setTextColor:[UIColor blackColor]];
	lblStateFooter.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
	[viewFooter addSubview:lblStateFooter];
	[lblStateFooter release];
	
	
    
	
	if(tableView)
	{
		[tableView removeFromSuperview];
		[tableView release];
		tableView=nil;
	}
	
	
	
	tableView=[[UITableView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0,62, 320,305) chageHieght:YES] style:UITableViewStylePlain];	tableView.delegate=self;
	tableView.dataSource=self;
    tableView.backgroundView=nil;
	[tableView setHidden:NO];
	[tableView setTableFooterView:viewFooter];
	[tableView setBackgroundColor:[UIColor clearColor]];
	[contentView addSubview:tableView];
	
	[viewFooter release];
}



-(void)viewDidLoad
{
    
    [super viewDidLoad];
    
    isLoadingTableFooter = TRUE;
	self.navigationItem.titleView = [GlobalPreferences createLogoImage];
	arrInfoAccount=[[NSMutableArray alloc]init];
	arrInfoAccount=[[SqlQuery shared] getAccountData:[GlobalPreferences getUserDefault_Preferences:@"userEmail"]];
	
	contentView = [[UIView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0,0,320,480) chageHieght:YES]];
	contentView.backgroundColor=[UIColor colorWithRed:200.0/256 green:200.0/256 blue:200.0/256 alpha:1];
	contentView.tag = 101010;
	[GlobalPreferences setGradientEffectOnView:contentView :[UIColor whiteColor] :contentView.backgroundColor];
	self.view = contentView;
	
	UIImageView *imgContentView=[[UIImageView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0,0,320,480) chageHieght:YES]];
	[imgContentView setBackgroundColor:[UIColor clearColor]];
	[imgContentView setImage:[UIImage imageNamed:@"shoppingcart_bar_stan.png"]];
	
	[contentView addSubview:imgContentView];
	[imgContentView release];
	
	
	
	UIView *viewTopBar=[[UIView alloc]initWithFrame:CGRectMake(0,-1
															   , 320,31)];
	[viewTopBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"barNews.png"]]];
    [viewTopBar setTag:1100110011];
	[contentView addSubview:viewTopBar];
	
	
	UIImageView *imgViewCheckout=[[UIImageView alloc]initWithFrame:CGRectMake(11,5,28,20)];
	[imgViewCheckout setImage:[UIImage imageNamed:@"cart_icon.png"]];
    [viewTopBar addSubview:imgViewCheckout];
    [imgViewCheckout release];
	
    UILabel *aboutLbl=[[UILabel alloc]initWithFrame:CGRectMake(44,8,100,14)];
    [aboutLbl setBackgroundColor:[UIColor clearColor]];
	[aboutLbl setText:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.checkout.checkout"]];
    [aboutLbl setTextColor:[UIColor whiteColor]];
	[aboutLbl setFont:[UIFont boldSystemFontOfSize:13]];
	[viewTopBar addSubview:aboutLbl];
	[aboutLbl release];
    [viewTopBar release];
    
	
	int yValue=30;
	
    UILabel *lblProductNames = [[UILabel alloc] init];
	lblProductNames.frame = CGRectMake( 10, yValue, 100, 30);
	[lblProductNames setBackgroundColor:[UIColor clearColor]];
	[lblProductNames setTextColor:[UIColor darkGrayColor]];
	lblProductNames.font =[UIFont fontWithName:@"Helvetica-Bold" size:13];
	
	lblProductNames.textAlignment = UITextAlignmentLeft;
	lblProductNames.lineBreakMode = UILineBreakModeTailTruncation;
	lblProductNames.text = [NSString stringWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.checkout.name"]];
	[contentView addSubview:lblProductNames];
	[lblProductNames release];
	
	UILabel *lblProductQuantity = [[UILabel alloc] init];
	lblProductQuantity.frame = CGRectMake( 115, yValue, 40, 30);
	[lblProductQuantity setBackgroundColor:[UIColor clearColor]];
	lblProductQuantity.textColor = [UIColor colorWithRed:0.0/256.0 green:51/256.0 blue:101/256.0 alpha:1.0];
	lblProductQuantity.font =[UIFont fontWithName:@"Helvetica-Bold" size:13];
	[lblProductQuantity setTextColor:[UIColor darkGrayColor]];
	lblProductQuantity.textAlignment = UITextAlignmentLeft;
	lblProductQuantity.lineBreakMode = UILineBreakModeTailTruncation;
	lblProductQuantity.text = [NSString stringWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.checkout.qty"]];
	[contentView addSubview:lblProductQuantity];
	[lblProductQuantity release];
	
	UILabel *lblProductSize = [[UILabel alloc] init];
	lblProductSize.frame = CGRectMake( 162, yValue, 50, 30);
	[lblProductSize setBackgroundColor:[UIColor clearColor]];
	lblProductSize.textColor = [UIColor colorWithRed:0.0/256.0 green:51/256.0 blue:101/256.0 alpha:1.0];
	lblProductSize.font =[UIFont fontWithName:@"Helvetica-Bold" size:13];
	
	[lblProductSize setTextColor:[UIColor darkGrayColor]];
	lblProductSize.textAlignment = UITextAlignmentLeft;
	lblProductSize.lineBreakMode = UILineBreakModeTailTruncation;
	lblProductSize.text = [NSString stringWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.checkout.options"]];
	[contentView addSubview:lblProductSize];
	[lblProductSize release];
	
	UILabel *lblProductSubTotal = [[UILabel alloc] init];
	lblProductSubTotal.frame = CGRectMake( 248, yValue, 65, 30);
	[lblProductSubTotal setBackgroundColor:[UIColor clearColor]];
	lblProductSubTotal.textColor = [UIColor colorWithRed:0.0/256.0 green:51/256.0 blue:101/256.0 alpha:1.0];
	lblProductSubTotal.font =[UIFont fontWithName:@"Helvetica-Bold" size:13];
	
	[lblProductSubTotal setTextColor:[UIColor darkGrayColor]];
	lblProductSubTotal.textAlignment = UITextAlignmentLeft;
	lblProductSubTotal.lineBreakMode = UILineBreakModeTailTruncation;
	lblProductSubTotal.text = [NSString stringWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.checkout.totalcost"]];
	[contentView addSubview:lblProductSubTotal];
	[lblProductSubTotal release];
	
	
	
   	UIImageView *imgLineView=[[UIImageView alloc]initWithFrame:CGRectMake(0,60,320,2)];
	[imgLineView setImage:[UIImage imageNamed:@"seperatorCheckOut.png"]];
	[contentView addSubview:imgLineView];
	[imgLineView release];
	
	dicSettings = [[NSDictionary alloc]init];
	dicSettings = [GlobalPreferences getSettingsOfUserAndOtherDetails];
	[dicSettings retain];
	
	NSMutableArray *interShippingDict = nil;
	NSDictionary *contentDict = dicSettings;//[dicSettings objectForKey:@"store"];
	NSArray *arrShipping = [contentDict objectForKey:@"shippingList"];
	[interShippingDict retain];
	
	NSArray *arrTax = [contentDict objectForKey:@"taxList"];
    
	for (int index=0;index<[arrShipping count]; index++)
	{
		[interShippingDict addObject:[arrShipping objectAtIndex:index]];
	}
	
	for (int index=0;index<[arrTax count]; index++)
	{
		[interShippingDict addObject:[arrTax objectAtIndex:index]];
	}
	countryID=0;
	stateID=0;
	if([arrInfoAccount count]>0)
	{
		countryID=[[[NSUserDefaults standardUserDefaults] valueForKey:@"countryID"]intValue];
		stateID=[[[NSUserDefaults standardUserDefaults] valueForKey:@"stateID"]intValue];
		
	}
	
	
	if(stateID==0)
	{
		NSDictionary *dicStates;
		
		dicStates = [ServerAPI fetchStatesOfCountryWithID:countryID];
		
		for (int	 index=0;	index<[dicStates count]; index++)
		{
			if([[[dicStates valueForKey:@"sName"] objectAtIndex:index]isEqualToString:@"Other"])
				stateID=[[[dicStates valueForKey:@"id"]objectAtIndex:index]intValue];
		}
		
		
	}
	
	
	
	[dicSettings release];
	[interShippingDict release];
	
	
	dictTax =[ServerAPI fetchTaxShippingDetails:countryID :stateID :iCurrentStoreId];
    
	[dictTax retain];
	
	
	
	
	if([arrProductIds count]==1)
	{
		
		if ([[[arrProductIds objectAtIndex:0]valueForKey:@"quantity"]intValue]==1)
		{
			fShippingCharges = [[[dictTax valueForKey:@"shipping"] valueForKey:@"fAlone"] floatValue];
		}
		else
		{
			fShippingCharges = [[[dictTax valueForKey:@"shipping"] valueForKey:@"fOthers"] floatValue];
		}
	}
	else
	{
		fShippingCharges = [[[dictTax valueForKey:@"shipping"] valueForKey:@"fOthers"] floatValue];
	}
	
	
	
	
	
	[self fetchDataFromLocalDB];
    //[self performSelectorInBackground:@selector(fetchDataFromLocalDB) withObject:nil];
    [self createTableView];
    
	
	
	
    
    
}
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	
    
}
- (void)hideLoadingBar
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    int x=1;
    if([[GlobalPreferences getPaypalModeEnable] intValue]==1 && ([GlobalPreferences getPaypalLiveToken].length!=0))
    {
        x=4;
        
    }else{
        x=1;
    }
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:x target:self selector:@selector(runScheduledTask) userInfo:nil repeats:NO];
    aTimer=nil;
	
	[pool release];
}
/* runScheduledTask */

- (void)runScheduledTask {
    // Do whatever u want
    
    [GlobalPreferences dismissLoadingBar_AtBottom];
    // Set the timer to nil as it has been fired
    
    
    
    
}




-(void)viewWillAppear:(BOOL)animated
{
	
	[super viewWillAppear:animated];
    //self.title=@"Checkout";
	//[GlobalPreferences performSelector:@selector(dismissLoadingBar_AtBottom)];
	
	if(controllersCount>5&&_objMobicartAppDelegate.tabController.selectedIndex>3)
	{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removedPoweredByMobicart" object:nil];
	}
	for (UIView *view in [self.navigationController.navigationBar subviews])
	{
		if ([view isKindOfClass:[UIButton class]])
			view.hidden =TRUE;
		if ([view isKindOfClass:[UILabel class]])
			view.hidden =TRUE;
	}
	
	[self performSelectorOnMainThread:@selector(hideLoadingBar) withObject:nil waitUntilDone:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.title=[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.home.back"];
	for (UIView *view in [self.navigationController.navigationBar subviews]) {
		
		if ([view isKindOfClass:[UIButton class]])
			view.hidden =FALSE;
		
		
		if ([view isKindOfClass:[UILabel class]])
			view.hidden =FALSE;
	}
}









#pragma mark -Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	iNumOfItemsInShoppingCart = 0;
	[self.navigationController popToRootViewControllerAnimated:YES];
	
}

#pragma mark Fetch Data From SQLite DB

-(void)fetchDataFromLocalDB
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if(!arrUserDetails)
		arrUserDetails = [[NSArray alloc] init];
	
	arrUserDetails = [[SqlQuery shared] getBuyerData:[GlobalPreferences getUserDefault_Preferences:@"userEmail"]];
    
	NSDictionary *dictAppDetails = [GlobalPreferences getSettingsOfUserAndOtherDetails];//[[GlobalPreferences getSettingsOfUserAndOtherDetails] objectForKey:@"store"];
	if(dictAppDetails)
        
	{
		sMerchantPaypayEmail=[[NSString alloc]initWithFormat:@"%@",[dictAppDetails objectForKey:@"sPaypalEmail"]];
		//sMerchantPaypayEmail = [dictAppDetails objectForKey:@"sPaypalEmail"];
		if(([sMerchantPaypayEmail isEqual:[NSNull null]]) || ([sMerchantPaypayEmail isEqualToString:@"null"]) ||  ([sMerchantPaypayEmail isEqualToString:@""]))
            
        {
            self.sMerchantPaypayEmail = [[[NSString alloc] initWithFormat:@"%@",[dictAppDetails objectForKey:@"sPaypalEmail"]] autorelease];
            if(([self.sMerchantPaypayEmail isEqual:[NSNull null]]) || ([self.sMerchantPaypayEmail isEqualToString:@"null"]) ||  ([self.sMerchantPaypayEmail isEqualToString:@""]))
                
            {
                //use the the merchant email ID as his paypal email ID
                
                //DLog(@"%@",merchantEmailId);
                //DLog(@"%@",[GlobalPreferences getMerchantEmailId]);
                self.sMerchantPaypayEmail = merchantEmailId;
            }
            
            
        }
        
        
        [sMerchantPaypayEmail retain];
        
        
        [pool release];
	}
}
/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	//isLoadingTableFooter = NO;
	
	//[contentView release];
	//contentView=nil;
    [super dealloc];
}

#pragma mark PayPal Integration
-(void)payWithPayPal
{
    NSLog(@"PayPal");
    NSString *strCode =[_savedPreferences.strCurrency substringFromIndex:3];
    NSDictionary *dicAppSettings = [GlobalPreferences getSettingsOfUserAndOtherDetails];
    NSLog(@"%@",[PayPal buildVersion]);
    
    [PayPal getPayPalInst].shippingEnabled = TRUE;
	
	//optional, set dynamicAmountUpdateEnabled to TRUE if you want to compute
	//shipping and tax based on the user's address choice, default: FALSE
	[PayPal getPayPalInst].dynamicAmountUpdateEnabled = FALSE;
	
    //optional, choose who pays the fee, default: FEEPAYER_EACHRECEIVER
	[PayPal getPayPalInst].feePayer = FEEPAYER_EACHRECEIVER;
	
	//for a payment with a single recipient, use a PayPalPayment object
    
    
    PayPalPayment *payment = [[[PayPalPayment alloc] init] autorelease];
    payment.recipient=[GlobalPreferences getPaypalRecipient_Email];
    
    payment.paymentCurrency=strCode;
	//payment.subTotal=[NSString stringWithFormat:@"%0.2f",priceWithoutTax];
    payment.description = [NSString stringWithFormat:@"Total Amount"];
	payment.merchantName = [NSString stringWithFormat:@"%@", [dicAppSettings  objectForKey:@"sSName"]];
    
	payment.paymentType=TYPE_GOODS;
    NSString *subToatal;
    NSString *totalShiping;
    NSString *tax;
   	totalShippingAmount=0.0;
	
	float shipping = fShippingCharges + taxOnShipping;
	totalShippingAmount=shipping;
    
    totalShiping =  [NSString stringWithFormat:@"%0.2f", totalShippingAmount] ;
	tax=[NSString stringWithFormat:@"%0.2f",[GlobalPreferences getRoundedOffValue:fTaxAmount]];
    
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


}

#pragma mark PayPal delegates Integration
-(void)RetryInitialization
{
    if([[GlobalPreferences getPaypalLiveToken] length]==0)
		[PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];
	else
    {
        if([[GlobalPreferences getPaypalModeIsLive] intValue]==1)
        {
            [PayPal initializeWithAppID:[GlobalPreferences getPaypalLiveToken] forEnvironment:ENV_LIVE];
        }
        else
        {
            [PayPal initializeWithAppID:@"APP-80W284485P519543T" forEnvironment:ENV_SANDBOX];
        }
    }
	
    
    
    //DEVPACKAGE
    //	[PayPal initializeWithAppID:@"your live app id" forEnvironment:ENV_LIVE];
    //	[PayPal initializeWithAppID:@"anything" forEnvironment:ENV_NONE];
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
    
    
}

//paymentCanceled is a required method. in it, you should record that the payment was canceled by
//the user and perform any desired bookkeeping. you should not do any user interface updates.
- (void)paymentCanceled
{
	status = PAYMENTSTATUS_CANCELED;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.title"] message:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.text"] delegate:nil cancelButtonTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
	
	[alert show];
	
	[alert release];
    
    
}

//paymentLibraryExit is a required method. this is called when the library is finished with the display
//and is returning control back to your app. you should now do any user interface updates such as
//displaying a success/failure/canceled message.

- (void)paymentLibraryExit {
	UIAlertView *alert = nil;
    
    
	switch (status) {
		case PAYMENTSTATUS_SUCCESS:
        {
			
            //Send the order information/details to the server
            [self performSelectorInBackground:@selector(sendDataToServers:) withObject:@"2"];
            
            NSString *strTitle = [[NSString alloc] initWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.title"] ];
            
            NSString *strMessage = [[NSString alloc] initWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.text"]];
            
            NSString *strCancelButton = [[NSString alloc] initWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.cancelbutton"] ];
            
            if ([strTitle length]>0 && [strMessage length]>0 && [strCancelButton length]>0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.title"] message:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.text"] delegate:self cancelButtonTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
                
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
			alert = [[UIAlertView alloc] initWithTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.title"] message:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.text"] delegate:nil cancelButtonTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
            
            
			break;
		case PAYMENTSTATUS_CANCELED:
			//alert = [[UIAlertView alloc] initWithTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.title"] message:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.text"] delegate:nil cancelButtonTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
            
			break;
	}
	[alert show];
	[alert release];
}






#pragma mark Zooz/PayPal Integration


-(void)payWithZooz
{
    
    NSLog(@"%@", [[NSBundle mainBundle] bundleIdentifier]); // this is the bundle ID value that you need to register in ZooZ portal
    NSString *strCode =[_savedPreferences.strCurrency substringFromIndex:3];
    NSString *invRef;//=[NSString new];
    invRef=[NSString stringWithFormat:@"INV-%@", [NSDate new]] ;
    
	totalShippingAmount=0.0;
	
	float shipping = fShippingCharges + taxOnShipping;
	totalShippingAmount=shipping;
    
    
    
    float totalAmount=priceWithoutTax+totalShippingAmount+[GlobalPreferences getRoundedOffValue:fTaxAmount];
    
	ZooZ * zooz = [ZooZ sharedInstance];
    zooz.rootView=_objMobicartAppDelegate.tabController.view;
    zooz.tintColor=navBarColor;
	ZooZPaymentRequest * req = [zooz createPaymentRequestWithTotal:totalAmount invoiceRefNumber:invRef  delegate:self];
	req.currencyCode = strCode;
    
    /* Optional - recommended */
    
    
    req.payerDetails.firstName = [[arrUserDetails objectAtIndex:0] objectForKey:@"sUserName"];
    req.payerDetails.lastName = @"";
    req.payerDetails.email = [[arrUserDetails objectAtIndex:0] objectForKey:@"sEmailAddress"];
    req.payerDetails.billingAddress.zipCode=[[arrUserDetails objectAtIndex:0] objectForKey:@"sPincode"];
    
    req.payerDetails.billingAddress.country=[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryCountry"];
    req.payerDetails.billingAddress.state=[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryState"];
    req.payerDetails.billingAddress.streetAddress=[[arrUserDetails objectAtIndex:0] objectForKey:@"sStreetAddress"];
    req.payerDetails.billingAddress.city=[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryCity"];
    req.requireAddress=NO;
    
    
    for (int i =0; i<[arrProductIds count];i++)
    {
        float price;
        NSString *nameOption;
        NSMutableArray * productNameOpt;
        productNameOpt=  [self fetchNameOptionProduct:i];
        nameOption= [productNameOpt objectAtIndex:0];
        if ([[[arrProductIds objectAtIndex:i] objectForKey:@"fPrice"] floatValue]>[[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue])
        {
            price=[[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue];
            price+=[[productNameOpt objectAtIndex:1] floatValue];
        }
        else
        {
            price=[[[arrProductIds objectAtIndex:i] objectForKey:@"fPrice"] floatValue];
            price+=[[productNameOpt objectAtIndex:1] floatValue];
        }
        
        ZooZInvoiceItem * item = [ZooZInvoiceItem invoiceItem:price quantity:[[[arrProductIds objectAtIndex:i] objectForKey:@"quantity"] intValue] name:[NSString stringWithFormat:@"%@", nameOption ]];
        
        item.itemId =[NSString stringWithFormat:@"%d", [[[arrProductIds objectAtIndex:i] objectForKey:@"id"] intValue]]; // optional
        
        
        [req addItem:item];
        
    }
    /* End of optional */
    
    if(([[GlobalPreferences getZoozPaymentToken] isEqual:[NSNull null]]) || ([GlobalPreferences getZoozPaymentToken]==nil) || ([[GlobalPreferences getZoozPaymentToken] length]==0))
    {
		
        zooz.sandbox = YES;
        [zooz openPayment:req forAppKey:@""];
        
    }
    else
    {
        if([[GlobalPreferences getZoozModeIsLive] intValue]==1)
        {
            zooz.sandbox = NO;
            [zooz openPayment:req forAppKey:[GlobalPreferences getZoozPaymentToken]];
        }
        else
        {
            zooz.sandbox = YES;
            [zooz openPayment:req forAppKey:[GlobalPreferences getZoozPaymentToken]];
        }
    }
    
    
    
}
- (void)openPaymentRequestFailed:(ZooZPaymentRequest *)request withErrorCode:(int)errorCode andErrorMessage:(NSString *)errorMessage
{
	NSLog(@"failed: %@", errorMessage);
    UIAlertView*  alert = [[UIAlertView alloc] initWithTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.title"] message:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.text"] delegate:nil cancelButtonTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
    [alert show];
    [alert release ];
    //this is a network / integration failure, not a payment processing failure.
    // [GlobalPreferences createAlertWithTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.title"] message:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.failed.text"] delegate:self cancelButtonTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
}

- (void)paymentSuccessWithResponse:(ZooZPaymentResponse *)response{
	NSLog(@"payment success with payment Id: %@, %@, %@, %f", response.fundSourceType, response.lastFourDigits, response.transactionDisplayID, response.paidAmount);
    
}

-(void)paymentSuccessDialogClosed
{
    NSLog(@"Payment dialog closed after success");
    //see paymentSuccessWithResponse: for the response transaction ID.
    [self performSelectorInBackground:@selector(sendDataToServers:) withObject:@"0"];
	
	NSString *strTitle = [[NSString alloc] initWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.title"] ];
	
	NSString *strMessage = [[NSString alloc] initWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.text"]];
	
	NSString *strCancelButton = [[NSString alloc] initWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.cancelbutton"] ];
	
	if ([strTitle length]>0 && [strMessage length]>0 && [strCancelButton length]>0)
	{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.title"] message:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.text"] delegate:self cancelButtonTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
		
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

/*
 - (void)paymentCanceled
 {
 NSLog(@"payment cancelled");
 
 [GlobalPreferences createAlertWithTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.title"] message:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.cancel.text"] delegate:nil cancelButtonTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
 
 //dialog closed without payment completed
 }
 */
#pragma mark fetching option and name of product

-(NSMutableArray *) fetchNameOptionProduct:(int)k
{
    NSMutableString * newproductName ;
    
    NSMutableArray *test=nil;
    
    NSMutableArray * strArray=nil;
    float optionPrice=0;
    
    newproductName = [NSString stringWithFormat:@"%@", [[arrProductIds objectAtIndex:k] valueForKey:@"sName"]];
    
    
    
    int optionSizesIndex[100]={};
    
    if (!([[[arrProductIds objectAtIndex:k] valueForKey:@"pOptionId"] intValue]==0))
    {
        
        NSMutableArray *dictOption = [[arrProductIds objectAtIndex:k] objectForKey:@"productOptions"];
        
        NSMutableArray *arrProductOptionSize = [[[NSMutableArray alloc] init] autorelease];
        
        for (int i=0; i<[dictOption count]; i++)
        {
            [arrProductOptionSize addObject:[[dictOption objectAtIndex:i] valueForKey:@"id"]];
        }
        
        NSArray *arrSelectedOptions=[[[arrCartItems objectAtIndex:k] valueForKey:@"pOptionId"] componentsSeparatedByString:@","];
        
        if([arrProductOptionSize count]!=0 && [arrSelectedOptions count]!=0)
        {
            for(int count=0;count<[arrSelectedOptions count];count++)
            {
                if ([arrProductOptionSize containsObject: [NSNumber numberWithInt:[[arrSelectedOptions objectAtIndex:count] integerValue]]])
                {
                    optionSizesIndex[count] = [arrProductOptionSize indexOfObject:[NSNumber numberWithInt:[[arrSelectedOptions objectAtIndex:count]  intValue]]];
                }
            }
        }
        
        
        
        
        for(int count=0;count<[arrSelectedOptions count];count++)
        {
            
            
            
            optionPrice+=[[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"pPrice"]floatValue];
            
            
            [test addObject: [NSString stringWithFormat:@"%@: %@",[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sTitle"],[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sName"]]] ;
            
            //DLog(@"%@",[test componentsJoinedByString:@"," ]);
        }
        //  DLog(@"%@",[NSString stringWithFormat:@"%@ %@",newproductName,[test componentsJoinedByString:@"," ]]);
        
        [strArray addObject:[NSString stringWithFormat:@"%@ [%@]",newproductName,[test componentsJoinedByString:@"," ]]];
        [strArray addObject:[NSString stringWithFormat:@"%f",optionPrice]];
        
        return strArray;
    }
    else
    {
        [strArray addObject:[NSString stringWithFormat:@"%@",newproductName]];
        [strArray addObject:[NSString stringWithFormat:@"%f",optionPrice]];
        return strArray;
    }
}

#pragma mark Cash on delivery
-(void)cashOnDeveliery
{
    
    
    [self performSelectorInBackground:@selector(sendDataToServers:)  withObject:@"1"];
    
	NSString *strTitle = [[NSString alloc] initWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.title"] ];
	
	NSString *strMessage = [[NSString alloc] initWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.order.completed.sucess.text"]];
	
	NSString *strCancelButton = [[NSString alloc] initWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.nointernet.cancelbutton"] ];
	
	if ([strTitle length]>0 && [strMessage length]>0 && [strCancelButton length]>0)
	{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.title"] message:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.order.completed.sucess.text"] delegate:self cancelButtonTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.nointernet.cancelbutton"] otherButtonTitles:nil];
        
        [alert show];
        
        [alert release];
	}
	else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Order Approved" message:@"Thank you, your order has been completed successfully. Please visit the 'Account' tab for further details." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		
		[alert show];
		
		[alert release];
	}
	[strTitle release];
	[strMessage release];
	[strCancelButton release];
    
}
#pragma mark Send Data To Server

-(void) sendDataToServers:(NSString *)paymentMode
{
    NSString *strCode =_savedPreferences.strCurrency;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *strDataToPost = [NSString stringWithFormat:@"{\"storeId\":%d,\"appId\":%d,\"merchantId\":%d,\"fAmount\":%0.2f,\"sMerchantPaypalEmail\":\"%@\",\"fTaxAmount\":%0.2f,\"fShippingAmount\":%0.2f,\"fTotalAmount\":%0.2f,\"sBuyerName\":\"%@\",\"sBuyerEmail\":\"%@\",\"iBuyerPhone\":null,\"sShippingStreet\":\"%@\",\"sShippingCity\":\"%@\",\"sShippingState\":\"%@\",\"sShippingPostalCode\":\"%@\",\"sShippingCountry\":\"%@\",\"sBillingStreet\":\"%@\",\"sBillingCity\":\"%@\",\"sBillingState\":\"%@\",\"sBillingPostalCode\":\"%@\",\"sBillingCountry\":\"%@\",\"paymentMode\":%@,\"orderCurrency\":\"%@\"}",iCurrentStoreId,iCurrentAppId,iCurrentMerchantId, priceWithoutTax,[GlobalPreferences getPaypalRecipient_Email],[GlobalPreferences getRoundedOffValue:fTaxAmount], totalShippingAmount,grandTotalValue, [[arrUserDetails objectAtIndex:0] objectForKey:@"sUserName"],[[arrUserDetails objectAtIndex:0] objectForKey:@"sEmailAddress"], [[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryAddress"],[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryCity"],[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryState"],[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryPincode"],[[arrUserDetails objectAtIndex:0] objectForKey:@"sDeliveryCountry"],[[arrUserDetails objectAtIndex:0] objectForKey:@"sStreetAddress"],[[arrUserDetails objectAtIndex:0] objectForKey:@"sCity"],[[arrUserDetails objectAtIndex:0] objectForKey:@"sState"],[[arrUserDetails objectAtIndex:0] objectForKey:@"sPincode"],[[arrUserDetails objectAtIndex:0] objectForKey:@"sCountry"],paymentMode ,strCode];
    
	if (![GlobalPreferences isInternetAvailable])
	{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDataInShoppingCartQueue"];
		
        // If internet is not available, then save the data into the database, for sending it later
		
		DLog(@"INTERNET IS UNAVAILABLE, SAVING DATA IN THE LOCAL DATABASE");
		
		[[SqlQuery shared] addToQueue_Shoppingcart:strDataToPost sendAtUrl:[NSString stringWithFormat:@"/product-order/save"]];
		for (int i =0; i<[arrProductIds count];i++)
		{
			float price;
            
			if ([[[arrProductIds objectAtIndex:i] objectForKey:@"fPrice"] floatValue]>[[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue])
            {
                price=[[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue];
            }
			else
            {
				price=[[[arrProductIds objectAtIndex:i] objectForKey:@"fPrice"] floatValue];
			}
			
			NSString *dataToSave = [NSString stringWithFormat:@"{\"productId\":%d,\"fAmount\":%0.2f,\"orderId\":0,\"productOptionId\":%@,\"iQuantity\":%d,\"id\":null}",[[[arrProductIds objectAtIndex:i] objectForKey:@"id"] intValue],price, [[arrCartItems objectAtIndex:i] objectForKey:@"pOptionsId"], [[[arrProductIds objectAtIndex:i] objectForKey:@"quantity"] intValue]];
			
			
			[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDataInIndividualProductsQueue"];
			
            [[SqlQuery shared] addToQueue_IndividualProducts:[GlobalPreferences getCurrentShoppingCartNum] dataToSend:dataToSave sendAtUrl:[NSString stringWithFormat:@"/product-order-item-multiple/save"]];
		}
	}
	
	else
	{
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDataInShoppingCartQueue"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDataInIndividualProductsQueue"];
		
		NSString *reponseRecieved = [ServerAPI product_orderSaveURLSend:strDataToPost];
		
		// Now send data to the server for this recently made order
		if ([reponseRecieved isKindOfClass:[NSString class]])
		{
			int iCurrentOrderId = [[[[[reponseRecieved componentsSeparatedByString:@":"] objectAtIndex:1] componentsSeparatedByString:@"}"] objectAtIndex:0] intValue];
			
			for (int i =0; i<[arrProductIds count];i++)
			{
				NSString *dataToSave = [NSString stringWithFormat:@"{\"productId\":%d,\"fAmount\":%0.2f,\"orderId\":%d,\"productOptionId\":\"%@\",\"iQuantity\":%d,\"id\":null}",[[[arrProductIds objectAtIndex:i] objectForKey:@"id"] intValue],[[[arrProductIds objectAtIndex:i] objectForKey:@"fDiscountedPrice"] floatValue], iCurrentOrderId, [[arrCartItems objectAtIndex:i] valueForKey:@"pOptionId"], [[[arrProductIds objectAtIndex:i] objectForKey:@"quantity"] intValue]];
				
				if (![GlobalPreferences isInternetAvailable])
				{
					// If internet is not available, then save the data into the database, for sending it later
					
					DLog(@"INTERNET IS UNAVAILABLE, SAVING DATA IN THE LOCAL DATABASE");
					
					[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isDataInIndividualProductsQueue"];
					
					[[SqlQuery shared] addToQueue_IndividualProducts:iCurrentOrderId dataToSend:dataToSave sendAtUrl:[NSString stringWithFormat:@"/product-order-item-multiple/save"]];
				}
				
				else
				{
					[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isDataInIndividualProductsQueue"];
					[ServerAPI product_order_ItemSaveURLSend:dataToSave];
				}
				
				[[SqlQuery shared] deleteItemFromShoppingCart:[[[arrProductIds objectAtIndex:i] valueForKey:@"id"]integerValue] :[[arrCartItems objectAtIndex:i] valueForKey:@"pOptionId"]];
			}
			
			if (iCurrentOrderId>0)
			{
				[ServerAPI product_order_NotifyURLSend:@"Sending Order Number Last Time":iCurrentOrderId];
			}
		}
		else
        {
            DLog(@"Error While sending billing details to server (CheckoutViewController)");
        }
	}
	
	[pool release];
	
}


-(NSString *) sendDataToServer:(NSURL *)_url withData:(NSString *)strDataToPost
{
	NSData *postData = [strDataToPost dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:_url];
	[request setHTTPMethod:@"POST"];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	
	[request setHTTPBody:postData];
	
	NSError *error;
	NSURLResponse *response;
	NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *data=nil;
    data=[[[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding] autorelease];
	return data;
	
}
- (IBAction)checkboxButton:(UIButton *)button{
    
    for (UIButton *but in [self.view subviews]) {
        if ([but isKindOfClass:[UIButton class]] && ![but isEqual:button]) {
            [but setSelected:NO];
        }
    }
    if (!button.selected) {
        button.selected = !button.selected;
    }
}

@end
