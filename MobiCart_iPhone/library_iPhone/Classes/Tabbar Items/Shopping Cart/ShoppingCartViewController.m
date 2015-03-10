//
//  ShoppingCartViewController.m
//  MobiCart
//
//  Created by Mobicart on 23/07/10.
//  Copyright 2010 Mobicart. All rights reserved.
//

#import "ShoppingCartViewController.h"
#import "Constants.h"
#import "ProductDetailsViewController.h"
#import "SubtotalCalculation.h"

// Sa Vo - NhanTVT - [18/06/2014] -
// Fix issue related to UIPickerView does not displayed on iOS 8
// Defined the constant
#define kHeightCustomPickerView             self.view.frame.size.height
#define kAnimationDurationCustomPickerView  0.1
#define kAnimationDelayCustomPickerView     0
#define kHeightDefaultPickerView            216

extern   MobicartAppDelegate *_objMobicartAppDelegate;
extern int controllersCount;

extern NSArray *optionArray;

float grandTotal,subTotal;
BOOL isCheckout;
float taxShippingValue;
extern BOOL *isLoadingTableFooter;

@implementation ShoppingCartViewController
BOOL isLoadingTableFooter2ndTime;
BOOL isFirstTime;
@synthesize isEditCommit=_isEditCommit;
@synthesize  isFomCheckout=_isFomCheckout;
@synthesize isQtyEdit=_isQtyEdit;

// Implement loadView to create a view hierarchy programmatically, without using a nib.

- (void)updateDataForCurrent_Navigation_And_View_Controller
{
    DLog(@"Shopping Cart");
}

- (void)viewDidLoad
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    isFirstTime=YES;
    _isFomCheckout=NO;
    _isQtyEdit=NO;
    strEditButtonTitle = [[NSString alloc ]initWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.edit"]];
    strDoneButtonTitle = [[NSString alloc]initWithFormat:@"%@",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.done"]];
    
    
    //DLog(@"%@",self.navigationItem.leftBarButtonItem.title );
    //
    //	if ([self.navigationItem.leftBarButtonItem.title isEqualToString:@"Category"] || [self.navigationItem.leftBarButtonItem.title isEqualToString:@"Products"]) {
    //		self.navigationItem.leftBarButtonItem.title = @"Back";
    //	}
    //	[self.navigationController.navigationItem setHidesBackButton:NO animated:NO];
    
    contentView=[[UIView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake( 0, 0, 320, 396) chageHieght:YES]];
    //contentView.backgroundColor=navBarColor;
    
    UIImageView *imgBg=[[UIImageView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0,30, 320, 396) chageHieght:YES]];
    [imgBg setImage:[UIImage imageNamed:@"product_details_bg.png"]];
    [contentView addSubview:imgBg];
    [imgBg release];
    
    self.view=contentView;
    
    arrStates=[[NSMutableArray alloc]init];
    //Sa Vo - tnlq - fix bug can't see barButton after enter shopping cart
    //    self.navigationController.navigationBar.tintColor = navBarColor;
    
    UIView *viewTopBar=[[UIView alloc]initWithFrame:CGRectMake(0,-1, 320, 31)];
    [viewTopBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"barNews.png"]]];
    [viewTopBar setTag:1100110011];
    [contentView addSubview:viewTopBar];
    
    UIView *viewTopBar1=[[UIView alloc]initWithFrame:CGRectMake(0,43, 320,1)];
    [viewTopBar1 setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar addSubview:viewTopBar1];
    
    UIImageView *imgViewShoppingCart=[[UIImageView alloc]initWithFrame:CGRectMake(12,5,28,20)];
    [imgViewShoppingCart setImage:[UIImage imageNamed:@"cart_icon.png"]];
    [viewTopBar addSubview:imgViewShoppingCart];
    [imgViewShoppingCart release];
    
    UILabel *lblShoppingCart=[[UILabel alloc]initWithFrame:CGRectMake(48,8,100,14)];
    [lblShoppingCart setBackgroundColor:[UIColor clearColor]];
    [lblShoppingCart setText:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.yourcart"]];
    [lblShoppingCart setTextColor:[UIColor whiteColor]];
    [lblShoppingCart setFont:[UIFont boldSystemFontOfSize:13]];
    [viewTopBar addSubview:lblShoppingCart];
    [lblShoppingCart release];
    
    // Adding loading indicator on topBar
    //[GlobalPreferences addLoadingIndicator_OnView:viewTopBar];
    
    [viewTopBar release];
    
    arrShoppingCart = [[NSMutableArray alloc] init];
    arrDatabaseCart = [[NSMutableArray alloc] init];
    
    dictSettingsDetails = [[NSDictionary alloc] init];
    dictSettingsDetails = [[GlobalPreferences getSettingsOfUserAndOtherDetails]retain];
    interDict = [[NSMutableArray alloc]init];
    NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
    arrTempShippingCountries=[[NSMutableArray alloc]init];
    //	NSDictionary *contentDict = [dictSettingsDetails objectForKey:@"store"];
    arrTemp = [dictSettingsDetails objectForKey:@"taxList"];
    arrTempShippingCountries=[[dictSettingsDetails objectForKey:@"shippingList"]retain];
    
    for (int i=0;i<[arrTemp count];i++)
    {
        if (![[interDict valueForKey:@"sCountry"] containsObject:[[arrTemp objectAtIndex:i]valueForKey:@"sCountry"]])
        {
            [interDict addObject:[arrTemp objectAtIndex:i]];
        }
        
    }
    for (int i=0;i<[arrTempShippingCountries count];i++)
    {
        if (![[interDict valueForKey:@"sCountry"] containsObject:[[arrTempShippingCountries objectAtIndex:i]valueForKey:@"sCountry"]])
        {
            [interDict addObject:[arrTempShippingCountries objectAtIndex:i]];
        }
    }
    [arrTempShippingCountries release];
    
    if ([interDict count]>0)
    {
        countryID=[[[interDict valueForKey:@"territoryId"]objectAtIndex:0]intValue];
    }
    
    [arrStates removeAllObjects];
    for (int index=0;index<[arrTemp count];index++)
    {
        if (countryID==[[[arrTemp valueForKey:@"territoryId"]objectAtIndex:index]intValue])
        {
            [arrStates  addObject:[arrTemp objectAtIndex:index]];
        }
    }
    for (int index=0;index<[arrTempShippingCountries count];index++)
    {
        if (countryID==[[[arrTempShippingCountries valueForKey:@"territoryId"]objectAtIndex:index]intValue])
        {
            if (![[arrStates valueForKey:@"sState"]containsObject:[[arrTempShippingCountries valueForKey:@"sState"]objectAtIndex:index]])
            {
                [arrStates  addObject:[arrTempShippingCountries objectAtIndex:index]];
            }
        }
    }
    
    [interDict retain];
    [arrStates retain];
    dicStates=[[NSDictionary alloc]init];
    [dicStates retain];
    dictTaxAndShippingDetails=[[NSDictionary alloc]init];
    [dictTaxAndShippingDetails retain];
    
    // Notification to update the shopping cart controller
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMe) name:@"updateShoppingCart_ViewController" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popViewRoot) name:@"popViewController" object:nil];
    
    arrQuantity = [[NSMutableArray alloc] init];
    //[self performSelector:@selector(hideBottomBar) onThread:[NSThread currentThread] withObject:nil waitUntilDone:NO];
    
    //[GlobalPreferences hideLoadingIndicator];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}
- (void)hideBottomBar
{
    [GlobalPreferences dismissLoadingBar_AtBottom];
}
- (void)popViewRoot
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}



#pragma mark -

- (void)reloadMe
{
    
    [arrShoppingCart removeAllObjects];
    
    arrInfoAccount=[[NSMutableArray alloc]init];
    arrInfoAccount=[[SqlQuery shared] getAccountData:[GlobalPreferences getUserDefault_Preferences:@"userEmail"]];
    
    int lcountryID=0,stateID=0;
    NSMutableArray *arrTemp=[dictSettingsDetails valueForKey:@"taxList" ];
    NSMutableArray *arrTempShppingStates=[dictSettingsDetails valueForKey:@"shippingList" ];
    NSMutableArray *tempDict = [[NSMutableArray alloc] init];
    if ([arrInfoAccount count]>0)
    {
        stateID=[[[NSUserDefaults standardUserDefaults] valueForKey:@"stateID"]intValue];
        lcountryID=[[[NSUserDefaults standardUserDefaults] valueForKey:@"countryID"]intValue];
    }
    else
    {
        for(int i=0;i<[arrTemp count];i++)
        {
            if (![[tempDict valueForKey:@"sCountry"] containsObject:[[arrTemp objectAtIndex:i]valueForKey:@"sCountry"]]) {
                [tempDict addObject:[arrTemp objectAtIndex:i]];
            }
            
        }
        for(int i=0;i<[arrTempShppingStates count];i++)
        {
            if (![[tempDict valueForKey:@"sCountry"] containsObject:[[arrTempShppingStates objectAtIndex:i]valueForKey:@"sCountry"]]) {
                [tempDict addObject:[arrTempShppingStates objectAtIndex:i]];
            }
            
        }
        
        if([tempDict count]>0)
            lcountryID=[[[tempDict valueForKey:@"territoryId"]objectAtIndex:0]intValue];
        
        
        for (int index=0;index<[tempDict count];index++)
        {
            if ([[[tempDict objectAtIndex:index]valueForKey:@"sState"]isEqualToString:@"Other"]&& [[[tempDict objectAtIndex:index]valueForKey:@"territoryId"]intValue]==lcountryID)
            {
                stateID=[[[tempDict objectAtIndex:index]valueForKey:@"id"]intValue];
                break;
            }
        }
        [tempDict release];
    }
    
    countryID=lcountryID;
    [arrStates removeAllObjects];
    
    for (int index=0; index<[arrTemp count]; index++)
    {
        if (countryID==[[[arrTemp valueForKey:@"territoryId"]objectAtIndex:index]intValue])
        {
            [arrStates  addObject:[arrTemp objectAtIndex:index]];
        }
    }
    for (int index=0; index<[arrTempShppingStates count]; index++)
    {
        if (countryID==[[[arrTempShppingStates valueForKey:@"territoryId"]objectAtIndex:index]intValue])
        {
            if (![[arrStates valueForKey:@"sState"] containsObject:[[arrTempShppingStates valueForKey:@"sState"]objectAtIndex:index]])
            {
                [arrStates  addObject:[arrTempShppingStates objectAtIndex:index]];
            }
        }
    }
    
    for(int i=0; i<[arrDatabaseCart count]; i++)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        int productId = [[[arrDatabaseCart objectAtIndex:i] valueForKey:@"id"] intValue];
        
        // Fetch data from server0
        NSDictionary *dictProductDetails = [[ServerAPI fetchProductDetails:productId :lcountryID :stateID] objectForKey:@"product"];
        if([dictProductDetails isKindOfClass:[NSDictionary class]])
        {
            
            if (![[[arrDatabaseCart objectAtIndex:i] valueForKey:@"pOptionId"] isEqual:[NSNull null
                                                                                        ]])
            {
                if ([[[arrDatabaseCart objectAtIndex:i] valueForKey:@"pOptionId"] intValue]==0)
                {
                    if (![[dictProductDetails valueForKey:@"iAggregateQuantity"] isEqual:[NSNull null]])
                    {
                        if ([[dictProductDetails valueForKey:@"iAggregateQuantity"] intValue]!=0)
                        {
                            [arrShoppingCart addObject:dictProductDetails];
                        }
                        else
                        {
                            [[SqlQuery shared] deleteItemFromShoppingCart:productId :[[arrDatabaseCart objectAtIndex:i] valueForKey:@"pOptionId"]];
                            [GlobalPreferences setCurrentItemsInCart:NO];
                            
                        }
                    }
                    else
                    {
                        [arrShoppingCart addObject:dictProductDetails];
                    }
                }
                else
                {
                    NSMutableArray *dictOption = [dictProductDetails objectForKey:@"productOptions"];
                    
                    NSMutableArray *dictOptionID=[[NSMutableArray alloc]init];
                    
                    [dictOptionID removeAllObjects];
                    
                    for (int j=0; j<[dictOption count]; j++)
                    {
                        [dictOptionID addObject:[[dictOption objectAtIndex:j] valueForKey:@"id"]];
                    }
                    NSString *strOptions=[[arrDatabaseCart objectAtIndex:i] valueForKey:@"pOptionId"];
                    NSArray *arrOptions=[strOptions componentsSeparatedByString:@","];
                    
                    int optionIndex[100];
                    
                    for(int count=0;count<[arrOptions count];count++)
                        
                    {
                        optionIndex[count] = [dictOptionID indexOfObject:[NSNumber numberWithInt:[[arrOptions objectAtIndex:count] intValue]]];
                        
                        
                    }
                    BOOL isOutOfStock=NO;
                    for(int i=0;i<[arrOptions count];i++)
                    {
                        
                        if ([[[dictOption objectAtIndex:optionIndex[i]] valueForKey:@"iAvailableQuantity"] intValue]==0)
                        {
                            isOutOfStock=YES;
                            break;
                        }
                        
                        
                    }
                    
                    if(isOutOfStock==NO)
                    {
                        [arrShoppingCart addObject:dictProductDetails];
                    }
                    else
                    {
                        [[SqlQuery shared] deleteItemFromShoppingCart:productId :[[arrDatabaseCart objectAtIndex:i] valueForKey:@"pOptionId"]];
                        [GlobalPreferences setCurrentItemsInCart:NO];
                        
                    }
                    [dictOptionID release];
                }
            }
            
            
            
            
        }
        
        else {
            [[SqlQuery shared] deleteItemFromShoppingCart:productId :[[arrDatabaseCart objectAtIndex:i] valueForKey:@"pOptionId"]];
            [GlobalPreferences setCurrentItemsInCart:NO];
            
        }
        
        
        
        
        [pool release];
    }
    
    arrDatabaseCart = [[SqlQuery shared]getShoppingCartProductIDs:NO];
    
    if([arrDatabaseCart count]>0)
    {
        
        [self createTableView];
    }
    
    
    else
    {
        self.navigationItem.rightBarButtonItem=nil;
        
    }
    
    
}
#pragma mark Edit/Done Handler
- (void)btnEdit_clicked
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:strEditButtonTitle])
    {
        isEditing=YES;
        _isQtyEdit=NO;
        self.navigationItem.rightBarButtonItem.title = strDoneButtonTitle;
        [tableView setEditing:YES animated:YES];
    }
    else if ([self.navigationItem.rightBarButtonItem.title isEqualToString: strDoneButtonTitle])
    {
        isEditing=NO;
        _isQtyEdit=NO;
        self.navigationItem.rightBarButtonItem.title = strEditButtonTitle;
        [self closeCustomPickerView];
        [tableView setEditing:NO animated:YES];
        
        // Sa Vo - NhanTVT - [20/06/2014] -
        // Fix issue wrong calculate sub total price for each product
        // Release memmory used by editingCell
        editingCell = nil;
        
        // Sa Vo - NhanTVT - [19/06/2014] -
        // Fix issue does not display "Delete Icon" on UITableViewCell in editing mode
        // Reload table view just only when finishing editing
        [tableView reloadData];
    }
    
    // Disallowing the viewForFooterInSection to be executed
    (!isLoadingTableFooter2ndTime)?isLoadingTableFooter2ndTime=1:0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // self.title=@"";
    
    [GlobalPreferences showLoadingIndicator];
    _isFomCheckout=NO;
    if(controllersCount>5&&_objMobicartAppDelegate.tabController.selectedIndex>3)
    {
        moreTabCount=[self.navigationController.viewControllers count];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removedPoweredByMobicart" object:nil];
        
    }
    
    for(int i = 0; i < [_objMobicartAppDelegate.tabController.moreNavigationController.view.
                        subviews count]; i++) {
        if([[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i] isKindOfClass:[UIButton class]]) {
            [[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i]removeFromSuperview];
        }
        if([[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i] isKindOfClass:[UILabel class]]) {
            [[_objMobicartAppDelegate.tabController.moreNavigationController.view.subviews objectAtIndex:i]removeFromSuperview];
        }
        
    }
    
    self.navigationItem.titleView = [GlobalPreferences createLogoImage];
    
    // Allowing the viewForFooterInSection to be executed
    (isLoadingTableFooter2ndTime)?isLoadingTableFooter2ndTime=0:0;
    
    if (isLoadingTableFooter)
    {
        isLoadingTableFooter2ndTime = TRUE;
    }
    else
    {
        mainTotal = 0.0f;
        grandTotal = 0.0f;
    }
    
    isShoppingCart_TableStyle = TRUE;
    
    for (UIView *view in [self.navigationController.navigationBar subviews])
    {
        UIButton *btnTemp = (UIButton *)view;
        if (([view isKindOfClass:[UIButton class]]) && !([btnTemp.titleLabel.text isEqualToString:strEditButtonTitle] ||[btnTemp.titleLabel.text isEqualToString:strDoneButtonTitle]))
        {
            view.hidden =TRUE;
        }
        
        if ([view isKindOfClass:[UILabel class]])
        {
            view.hidden =TRUE;
        }
    }
    
    
    self.navigationItem.rightBarButtonItem.title = strEditButtonTitle;
    
    
    if (isCheckout)
    {
        isCheckout = NO;
        
        isCheckForCheckout=NO;
        _isFomCheckout=YES;
        isEditing=NO;
        if ([self.navigationItem.rightBarButtonItem.title isEqualToString: strDoneButtonTitle])
        {
            isEditing=NO;
            self.navigationItem.rightBarButtonItem.title = strEditButtonTitle;
            [tableView setEditing:NO animated:YES];
            // Disallowing the viewForFooterInSection to be executed
            (!isLoadingTableFooter2ndTime)?isLoadingTableFooter2ndTime=1:0;
            
            [tableView reloadData];
        }
        
        CheckoutViewController *objCheckout=[[CheckoutViewController alloc]init];
        
        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
        DLog(@"********* Array database count %d",[arrDatabaseCart count]);
        
        for (int i=0; i<[arrDatabaseCart count]; i++)
        {
            NSDictionary *dictTemp = [arrShoppingCart objectAtIndex:i];
            
            NSMutableDictionary *dictTemp1=[[NSMutableDictionary alloc]initWithDictionary:dictTemp];
            
            [dictTemp1 setValue:[[arrDatabaseCart objectAtIndex:i] objectForKey:@"quantity"] forKey:@"quantity"];
            [dictTemp1 setValue:[[arrDatabaseCart objectAtIndex:i] objectForKey:@"pOptionId"] forKey:@"pOptionId"];
            [arrTemp addObject:dictTemp1];
            [dictTemp1 release];
        }
        
        
        objCheckout.arrCartItems=arrDatabaseCart;
        objCheckout.arrProductIds = arrTemp;
        
        [arrTemp release];
        [self tableView:tableView viewForFooterInSection:1];
        [tableView reloadData];
        [self.navigationController pushViewController:objCheckout animated:NO];
        [objCheckout release];
        
    }
    
    
    else {
        
        
        
        arrDatabaseCart = [[SqlQuery shared]getShoppingCartProductIDs:NO];
        
        if ([arrDatabaseCart count]>0)
        {
            selectedQuantity=[[[arrDatabaseCart objectAtIndex:0]valueForKey:@"quantity"]intValue];
            if(!_isFomCheckout)
                // [self reloadMe];
                [self performSelector:@selector(reloadMe) withObject:nil afterDelay:0.01];
        }
        
        
        else
        {
            [tableView removeFromSuperview];
            [tableView release];
            tableView=nil;
        }
        
        
        
        
        if ([arrDatabaseCart count]>0)
        {
            barBtnEdit = [[UIBarButtonItem alloc] initWithTitle:strEditButtonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(btnEdit_clicked)];
            [self.navigationItem setRightBarButtonItem:barBtnEdit animated:YES];
            if (isEditing==YES)
            {
                [barBtnEdit setTitle:strDoneButtonTitle];
            }
            else
            {
                [barBtnEdit setTitle:strEditButtonTitle];
            }
        }
    }
    [self hideLoadingBar ];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(controllersCount>5&&_objMobicartAppDelegate.tabController.selectedIndex>3&&moreTabCount<3)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"poweredByMobicart" object:nil];
    
    isShoppingCart_TableStyle = FALSE;
    for (UIView *view in [self.navigationController.navigationBar subviews])
    {
        UIButton *btnTemp = (UIButton *)view;
        if (([view isKindOfClass:[UIButton class]]) && !([btnTemp.titleLabel.text isEqualToString:strEditButtonTitle] ||[btnTemp.titleLabel.text isEqualToString:strDoneButtonTitle]))
        {
            view.hidden =FALSE;
        }
        
        if ([view isKindOfClass:[UILabel class]])
        {
            view.hidden =FALSE;
        }
    }
    lblCart.text = [NSString stringWithFormat:@"%d", iNumOfItemsInShoppingCart];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //if(_objMobicartAppDelegate.tabController.selectedIndex>3 &&moreTabCount<3)
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"poweredByMobicart" object:nil];
    
    
    if(!_isFomCheckout)
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addCartButton" object:nil];
    
    isShoppingCart_TableStyle = FALSE;
    isCheckForCheckout=NO;
    // Stoping the loading indicator
    //[GlobalPreferences stopLoadingIndicator];
}


- (void)createTableView
{
    UIView *viewFooter = [[UIView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0, 0, 320,280) chageHieght:YES]];
    viewFooter.backgroundColor = [UIColor colorWithRed:88.6/100 green:88.6/100 blue:88.6/100 alpha:1];
    isLoadingTableFooter2ndTime=NO;
    UIImageView *imgFooterView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"shopping_base_standard.png"]];
    [viewFooter addSubview:imgFooterView];
    [imgFooterView release];
    
    int stateID=0,lcountryID=0;
    
    if ([arrStates count]>0)
    {
        stateID=[[[arrStates valueForKey:@"stateId"]objectAtIndex:0]intValue];
    }
    
    if ([arrInfoAccount count]>0)
    {
        lcountryID=[[[NSUserDefaults standardUserDefaults] valueForKey:@"countryID"]intValue];
        stateID=[[[NSUserDefaults standardUserDefaults] valueForKey:@"stateID"]intValue];
        dicStates=[[ServerAPI fetchStatesOfCountryWithID:lcountryID] retain];
    }
    else
    {
        if ([interDict count]>0)
        {
            NSDictionary *dictTemp = [interDict objectAtIndex:0];
            
            lcountryID=[[dictTemp valueForKey:@"territoryId"]intValue];
            stateID=[[dictTemp valueForKey:@"stateId"]intValue];
        }
    }
    
    dictTaxAndShippingDetails = [[ServerAPI fetchTaxShippingDetails:lcountryID :stateID :iCurrentStoreId] retain];
    
    [dictSettingsDetails retain];
    
    NSString *strTemp=[NSString stringWithFormat:@"%@: ",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.subtotal"]];
    
    CGSize size =[strTemp sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0] constrainedToSize:CGSizeMake(1000, 20)];
    
    int width=size.width;
    
    if(width>75)
        width=75;
    
    UILabel *lblSubTotalFooterTitle=[[UILabel alloc]initWithFrame:CGRectMake(175, 14,width, 20)];
    [lblSubTotalFooterTitle setText:[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.subtotal"]]];
    lblSubTotalFooterTitle.backgroundColor=[UIColor clearColor];
    [lblSubTotalFooterTitle setTextAlignment:UITextAlignmentLeft];
    lblSubTotalFooterTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
    lblSubTotalFooterTitle.lineBreakMode = UILineBreakModeTailTruncation;
    lblSubTotalFooterTitle.textColor=[UIColor darkGrayColor];
    [viewFooter addSubview:lblSubTotalFooterTitle];
    
    int xCoord=lblSubTotalFooterTitle.frame.size.width+lblSubTotalFooterTitle.frame.origin.x+2;
    
    [lblSubTotalFooterTitle release];
    
    
    
    lblSubTotalFooter=[[UILabel alloc]initWithFrame:CGRectMake(xCoord,14,320-xCoord,20)];
    lblSubTotalFooter.backgroundColor=[UIColor clearColor];
    [lblSubTotalFooter setTextAlignment:UITextAlignmentLeft];
    lblSubTotalFooter.textColor=[UIColor blackColor];
    [lblSubTotalFooter setNumberOfLines:0];
    lblSubTotalFooter.lineBreakMode = UILineBreakModeWordWrap;
    lblSubTotalFooter.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
    [viewFooter addSubview:lblSubTotalFooter];
    
    UILabel *lblStars=[[UILabel alloc]initWithFrame:CGRectMake(175,96, 165, 14)];
    [lblStars setBackgroundColor:[UIColor clearColor]];
    [lblStars setText:@"*********************"];
    [lblStars setTextColor:[UIColor blackColor]];
    [viewFooter addSubview:lblStars];
    [lblStars release];
    
    
    strTemp=[NSString stringWithFormat:@"%@: ",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.total"]];
    
    size =[strTemp sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(1000, 20)];
    
    width=size.width;
    
    if(width>55)
        width=55;
    
    
    UILabel *lblGrandTotalFooterTitle=[[UILabel alloc]initWithFrame:CGRectMake(175, 107,width,20)];
    [lblGrandTotalFooterTitle setText:[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.total"]]];
    lblGrandTotalFooterTitle.backgroundColor=[UIColor clearColor];
    [lblGrandTotalFooterTitle setTextAlignment:UITextAlignmentLeft];
    lblGrandTotalFooterTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:13.0];
    lblGrandTotalFooterTitle.lineBreakMode = UILineBreakModeTailTruncation;
    lblGrandTotalFooterTitle.textColor=[UIColor darkGrayColor];
    [viewFooter addSubview:lblGrandTotalFooterTitle];
    
    xCoord=lblGrandTotalFooterTitle.frame.size.width+lblGrandTotalFooterTitle.frame.origin.x+2;
    
    [lblGrandTotalFooterTitle release];
    
    
    lblGrandTotalFooter=[[UILabel alloc]initWithFrame:CGRectMake(xCoord,107,320-xCoord,20)];
    lblGrandTotalFooter.backgroundColor=[UIColor clearColor];
    [lblGrandTotalFooter setTextAlignment:UITextAlignmentLeft];
    lblGrandTotalFooter.textColor=[UIColor blackColor];
    [lblGrandTotalFooter setNumberOfLines:0];
    lblGrandTotalFooter.lineBreakMode = UILineBreakModeTailTruncation;
    lblGrandTotalFooter.font =[UIFont fontWithName:@"Helvetica-Bold" size:13.0];
    [viewFooter addSubview:lblGrandTotalFooter];
    
    UILabel *lblselectCountry=[[UILabel alloc]initWithFrame:CGRectMake(11, 10, 140, 20)];
    lblselectCountry.backgroundColor=[UIColor clearColor];
    [lblselectCountry setTextAlignment:UITextAlignmentLeft];
    lblselectCountry.textColor=[UIColor darkGrayColor];
    [lblselectCountry setNumberOfLines:0];
    [lblselectCountry setText:[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.choosecountry"]]];
    lblselectCountry.lineBreakMode = UILineBreakModeTailTruncation;
    lblselectCountry.font =[UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    [viewFooter addSubview:lblselectCountry];
    [lblselectCountry release];
    
    UIButton *optionBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [optionBtn setBackgroundColor:[UIColor clearColor]];
    [optionBtn setFrame:CGRectMake(10, 27, 140, 35)];
    [optionBtn setImage:[UIImage imageNamed:@"a.png"] forState:UIControlStateNormal];
    [optionBtn addTarget:self action:@selector(getCountryTable) forControlEvents:UIControlEventTouchUpInside];
    [viewFooter addSubview:optionBtn];
    
    UILabel *lblStateSelect=[[UILabel alloc]initWithFrame:CGRectMake(11,69, 140, 20)];
    lblStateSelect.backgroundColor=[UIColor clearColor];
    [lblStateSelect setTextAlignment:UITextAlignmentLeft];
    lblStateSelect.textColor=[UIColor darkGrayColor];
    [lblStateSelect setNumberOfLines:0];
    [lblStateSelect setText:[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.choose.state"]]];
    lblStateSelect.lineBreakMode = UILineBreakModeTailTruncation;
    lblStateSelect.font =[UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    [viewFooter addSubview:lblStateSelect];
    [lblStateSelect release];
    
    UIButton *btnStatesPicker=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnStatesPicker setBackgroundColor:[UIColor clearColor]];
    [btnStatesPicker setFrame:CGRectMake(10,86,140, 35)];
    [btnStatesPicker setImage:[UIImage imageNamed:@"a.png"] forState:UIControlStateNormal];
    [btnStatesPicker addTarget:self action:@selector(getStatesTable:) forControlEvents:UIControlEventTouchUpInside];
    [viewFooter addSubview:btnStatesPicker];
    
    
    
    strTemp=[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.tax"]];
    
    size =[strTemp sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(1000, 20)];
    
    width=size.width;
    
    if(width>35)
        width=35;
    
    UILabel *lblTaxTitle=[[UILabel alloc]initWithFrame:CGRectMake(175, 32,width, 20)];
    [lblTaxTitle setText:[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.tax"]]];
    lblTaxTitle.backgroundColor=[UIColor clearColor];
    [lblTaxTitle setTextAlignment:UITextAlignmentLeft];
    lblTaxTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
    lblTaxTitle.lineBreakMode = UILineBreakModeTailTruncation;
    lblTaxTitle.textColor=[UIColor darkGrayColor];
    [viewFooter addSubview:lblTaxTitle];
    
    xCoord=lblTaxTitle.frame.size.width+lblTaxTitle.frame.origin.x+2;
    
    [lblTaxTitle release];
    
    lblTax=[[UILabel alloc]initWithFrame:CGRectMake(xCoord, 32,320-xCoord,20)];
    lblTax.backgroundColor=[UIColor clearColor];
    [lblTax setTextAlignment:UITextAlignmentLeft];
    lblTax.textColor=[UIColor blackColor];
    [lblTax setNumberOfLines:0];
    lblTax.lineBreakMode = UILineBreakModeTailTruncation;
    lblTax.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
    [viewFooter addSubview:lblTax];
    
    
    
    strTemp=[NSString stringWithFormat:@"%@: ",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.shipping"]];
    
    size =[strTemp sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0] constrainedToSize:CGSizeMake(1000, 20)];
    
    width=size.width;
    
    if(width>65)
        width=65;
    
    
    UILabel *lblShippingChargesTitle=[[UILabel alloc]initWithFrame:CGRectMake(175,50,width, 20)];
    [lblShippingChargesTitle setText:[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.shipping"]]];
    lblShippingChargesTitle.backgroundColor=[UIColor clearColor];
    [lblShippingChargesTitle setTextAlignment:UITextAlignmentLeft];
    lblShippingChargesTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
    lblShippingChargesTitle.lineBreakMode = UILineBreakModeTailTruncation;
    lblShippingChargesTitle.textColor=[UIColor darkGrayColor];
    [viewFooter addSubview:lblShippingChargesTitle];
    
    xCoord=lblShippingChargesTitle.frame.size.width+lblShippingChargesTitle.frame.origin.x+2;
    
    
    [lblShippingChargesTitle release];
    
    lblShippingCharges=[[UILabel alloc]initWithFrame:CGRectMake(xCoord,50,320-xCoord, 20)];
    lblShippingCharges.backgroundColor=[UIColor clearColor];
    [lblShippingCharges setTextAlignment:UITextAlignmentLeft];
    lblShippingCharges.textColor=[UIColor blackColor];
    [lblShippingCharges setNumberOfLines:0];
    lblShippingCharges.lineBreakMode = UILineBreakModeTailTruncation;
    lblShippingCharges.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
    [viewFooter addSubview:lblShippingCharges];
    
    
    strTemp=[NSString stringWithFormat:@"%@: ",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.tax.shipping"]];
    
    size =[strTemp sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0] constrainedToSize:CGSizeMake(1000, 20)];
    
    width=size.width;
    
    if(width>95)
        width=95;
    
    UILabel *lblShippingTaxTitle=[[UILabel alloc]initWithFrame:CGRectMake(175, 69,width, 20)];
    [lblShippingTaxTitle setText:[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.tax.shipping"]]];
    lblShippingTaxTitle.backgroundColor=[UIColor clearColor];
    [lblShippingTaxTitle setTextAlignment:UITextAlignmentLeft];
    lblShippingTaxTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
    lblShippingTaxTitle.lineBreakMode = UILineBreakModeTailTruncation;
    lblShippingTaxTitle.textColor=[UIColor darkGrayColor];
    [viewFooter addSubview:lblShippingTaxTitle];
    
    xCoord=lblShippingTaxTitle.frame.size.width+lblShippingTaxTitle.frame.origin.x+2;
    
    
    [lblShippingTaxTitle release];
    
    lblShippingTax=[[UILabel alloc]initWithFrame:CGRectMake(xCoord, 69,320-xCoord, 20)];
    lblShippingTax.backgroundColor=[UIColor clearColor];
    [lblShippingTax setTextAlignment:UITextAlignmentLeft];
    lblShippingTax.textColor=[UIColor blackColor];
    [lblShippingTax setNumberOfLines:0];
    lblShippingTax.lineBreakMode = UILineBreakModeTailTruncation;
    lblShippingTax.font =[UIFont fontWithName:@"Helvetica-Bold" size:11.0];
    [viewFooter addSubview:lblShippingTax];
    
    lblCountryName=[[UILabel alloc]initWithFrame:CGRectMake(20, 33,99, 20)];
    lblCountryName.backgroundColor=[UIColor clearColor];
    [lblCountryName setTextAlignment:UITextAlignmentCenter];
    lblCountryName.textColor=[UIColor blackColor];
    [lblCountryName setBackgroundColor:[UIColor clearColor]];
    [lblCountryName setNumberOfLines:0];
    [lblCountryName setText:@""];
    lblCountryName.lineBreakMode = UILineBreakModeTailTruncation;
    lblCountryName.font =[UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    [viewFooter addSubview:lblCountryName];
    
    lblStateName=[[UILabel alloc]initWithFrame:CGRectMake(20, 93,99, 20)];
    lblStateName.backgroundColor=[UIColor clearColor];
    [lblStateName setTextAlignment:UITextAlignmentCenter];
    lblStateName.textColor=[UIColor blackColor];
    [lblStateName setBackgroundColor:[UIColor clearColor]];
    [lblStateName setNumberOfLines:0];
    [lblStateName setText:@""];
    lblStateName.lineBreakMode = UILineBreakModeTailTruncation;
    lblStateName.font =[UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    [viewFooter addSubview:lblStateName];
    
    if ([arrInfoAccount count]>0)
    {
        lblStateName.text=[arrInfoAccount objectAtIndex:8];
        lblCountryName.text=[arrInfoAccount objectAtIndex:10];
        
    }
    else
    {
        
        NSString *strCountryname=[[NSString alloc]init];
        
        if ([interDict count]>0)
        {
            NSDictionary *dictTemp = [interDict objectAtIndex:0];
            strCountryname=  [dictTemp objectForKey:@"sCountry"];
            countryID=[[dictTemp valueForKey:@"territoryId"]intValue];
            [lblStateName setText:[dictTemp valueForKey:@"sState"] ];
        }
        else
        {
            strCountryname=@"No Country Defined";
            [lblStateName setText:@"No State Defined"];
        }
        lblCountryName.text=strCountryname;
        [GlobalPreferences setUserCountryAndStateForTax_country:strCountryname countryID:countryID];
    }
    
    UIButton *btnCheckout=[UIButton buttonWithType:UIButtonTypeCustom];
    btnCheckout.backgroundColor=navBarColorPreference;
    [btnCheckout setFrame:CGRectMake(10, 138, 303, 34)];
    [btnCheckout setTitle:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.checkout"] forState:UIControlStateNormal];
    [btnCheckout setBackgroundImage:[UIImage imageNamed:@"checkout_btn.png"] forState:UIControlStateNormal];
    [btnCheckout layer].cornerRadius=5.0;
    [btnCheckout.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [btnCheckout addTarget:self action:@selector(checkoutMethod) forControlEvents:UIControlEventTouchUpInside];
    [viewFooter addSubview:btnCheckout];
    BOOL istblEditing;
    if([tableView isEditing])
        istblEditing=YES;
    else
        istblEditing=NO;
    
    
    if (tableView)
    {
        [tableView removeFromSuperview];
        [tableView release];
        tableView=nil;
    }
    
    
    tableView=[[UITableView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0, 30, 320, 340) chageHieght:YES] style:UITableViewStylePlain];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.backgroundView=nil;
    [tableView setTableFooterView:viewFooter];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [contentView addSubview:tableView];
    
    if(istblEditing)
    {
        [tableView setEditing:YES];
        istblEditing=NO;
    }
    else {
        [tableView setEditing:NO];
    }
    
    
    
    if (tblCountries)
    {
        [tblCountries removeFromSuperview];
        [tblCountries release];
        tblCountries=nil;
    }
    tblCountries=[[UITableView alloc]initWithFrame:CGRectMake(1, 45, 145, 200) style:UITableViewStyleGrouped];
    tblCountries.delegate=self;
    tblCountries.dataSource=self;
    tblCountries.backgroundView=nil;
    [tblCountries setHidden:YES];
    tblCountries.showsVerticalScrollIndicator = FALSE;
    [tblCountries setBackgroundColor:[UIColor clearColor]];
    [viewFooter addSubview:tblCountries];
    
    [viewFooter release];
    
    if (tblStates)
    {
        [tblStates removeFromSuperview];
        [tblStates release];
        tblStates=nil;
    }
    if([arrDatabaseCart count]>1)
    {
        tblStates=[[UITableView alloc]initWithFrame:CGRectMake(1, 103, 145, 70) style:UITableViewStyleGrouped];
    }
    else
    {
        tblStates=[[UITableView alloc]initWithFrame:CGRectMake(1, 103, 145, 140) style:UITableViewStyleGrouped];
    }
    
    tblStates.delegate=self;
    tblStates.dataSource=self;
    tblStates.backgroundView=nil;
    tblStates.tableFooterView.hidden = YES;
    tblStates.showsVerticalScrollIndicator = FALSE;
    [tblStates setBackgroundColor:[UIColor clearColor]];
    [viewFooter addSubview:tblStates];
    [tblStates setHidden:YES];
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
 */
- (void)getCountryTable
{
    [tblStates setHidden:YES];
    
    if (isFirstTime)
    {
        [tblCountries setHidden:NO];
        isFirstTime=NO;
    }
    
    else
    {
        [tblCountries setHidden:YES];
        isFirstTime=YES;
    }
    
}
- (void)getStatesTable:(id)sender
{
    [tblCountries setHidden:YES];
    tblStates.hidden = !tblStates.hidden;
}
-(void)showIndicator
{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    
    if(!loadingActionSheet)
    {
        loadingActionSheet = [[UIActionSheet alloc] initWithTitle:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.LoaderText"] delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    }
    [loadingActionSheet showInView:self.tabBarController.view];
    
    [pool drain];
    
    
}

#pragma mark Checkout Handler
- (void)checkoutMethod
{
    
    isCheckForCheckout=YES;
    _isFomCheckout=YES;
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString: strDoneButtonTitle])
    {
        isEditing=NO;
        self.navigationItem.rightBarButtonItem.title = strEditButtonTitle;
        [tableView setEditing:NO animated:YES];
        // Disallowing the viewForFooterInSection to be executed
        (!isLoadingTableFooter2ndTime)?isLoadingTableFooter2ndTime=1:0;
        
        [tableView reloadData];
    }
    self.title=[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.home.back"];
    if ([[GlobalPreferences getUserDefault_Preferences:@"userEmail"] length]==0)
    {
        DetailsViewController *_details = 	[[DetailsViewController alloc] init];
        [self.navigationController pushViewController:_details animated:NO
         ];
        [_details release];
    }
    else
    {
        
        [self showIndicator];
        
        CheckoutViewController *objCheckout=[[CheckoutViewController alloc]init];
        
        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
        
        for (int i=0; i<[arrDatabaseCart count]; i++)
        {
            NSDictionary *dictTemp = [arrShoppingCart objectAtIndex:i];
            
            NSMutableDictionary *dictTemp1=[[NSMutableDictionary alloc]initWithDictionary:dictTemp];
            
            [dictTemp1 setValue:[[arrDatabaseCart objectAtIndex:i] objectForKey:@"quantity"] forKey:@"quantity"];
            [dictTemp1 setValue:[[arrDatabaseCart objectAtIndex:i] objectForKey:@"pOptionId"] forKey:@"pOptionId"];
            [arrTemp addObject:dictTemp1];
            [dictTemp1 release];
        }
        
        objCheckout.arrProductIds = arrTemp;
        objCheckout.arrCartItems=arrDatabaseCart;
        
        [arrTemp release];
        self.title=[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.home.back"];
        [self.navigationController pushViewController:objCheckout animated:YES];
        [objCheckout release];
    }
}
#pragma mark TableView Delegate Method

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_tableView == tblCountries)
    {
        return 25;
    }
    else if (_tableView == tblStates)
    {
        return 25;
    }
    else
    {
        if (!([[[arrDatabaseCart objectAtIndex:indexPath.row] valueForKey:@"pOptionId"] intValue]==0))
        {
            
            NSArray *arrSelectedOptions=[[[arrDatabaseCart objectAtIndex:indexPath.row] valueForKey:@"pOptionId"] componentsSeparatedByString:@","];
            
            int optionsCount=[arrSelectedOptions count];
            return 81.5+(optionsCount-1)*15;
        }
        else {
            return 81.5;
        }
    }
}

- (NSInteger) tableView:(UITableView*) _tableView numberOfRowsInSection:(NSInteger) section
{
    if (_tableView == tblCountries)
    {
        return [interDict count];
    }
    else if (_tableView == tblStates)
    {
        return [arrStates count];
    }
    else
    {
        return [arrShoppingCart count];
    }
}


- (UITableViewCell*) tableView:(UITableView*)tableview cellForRowAtIndexPath:(NSIndexPath*) indexPath
{
    NSString *SimpleTableIdentifier = [NSString stringWithFormat:@"SimpleTableIdentifier%d", indexPath.row];
    TableViewCell_Common *cell= (TableViewCell_Common *)[tableview dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    
    if (tableview == tblCountries)
    {
        NSDictionary *dictTemp = [interDict objectAtIndex:indexPath.row];
        if (cell==nil)
        {
            cell =[[[TableViewCell_Common alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier]autorelease];
        }
        
        cell.textLabel.text = [dictTemp objectForKey:@"sCountry"];
        [cell.textLabel setTextAlignment:UITextAlignmentCenter];
        cell.textLabel.font =[UIFont fontWithName:@"Helvetica" size:12.0];
        [cell.textLabel setTextColor:[UIColor blackColor]];
    }
    else if (tableview==tblStates)
    {
        if (cell==nil)
        {
            cell = [[[TableViewCell_Common alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier]autorelease];
        }
        
        cell.textLabel.text = [[arrStates valueForKey:@"sState"]objectAtIndex:indexPath.row];
        [cell.textLabel setTextAlignment:UITextAlignmentCenter];
        cell.textLabel.font =[UIFont fontWithName:@"Helvetica" size:12.0];
        [cell.textLabel setTextColor:[UIColor blackColor]];
        
    }
    
    else if (tableview==tableView)
    {
        float productCost = [SubtotalCalculation calculateProductCost:[arrShoppingCart objectAtIndex:indexPath.row]arrDataBase:[arrDatabaseCart objectAtIndex:indexPath.row]];
        
        float productSubTotal = productCost * [[[arrDatabaseCart objectAtIndex:indexPath.row]valueForKey:@"quantity"] intValue];
        productCost=[GlobalPreferences getRoundedOffValue:productCost];
        productSubTotal=[GlobalPreferences getRoundedOffValue:productSubTotal];
        
        if(_isEditCommit){
            cell=nil;
            
        }
        if (cell==nil)
        {
            cell = [[TableViewCell_Common alloc] initWithStyleFor_Store_ProductView:UITableViewCellStyleDefault reuseIdentifier:SimpleTableIdentifier];
            
            UIImageView *imgCellBackground=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 342,81.8)];
            [imgCellBackground setImage:[UIImage imageNamed:@"shoppingcart_bar_stan.png"]];
            [cell setBackgroundView:imgCellBackground];
            [imgCellBackground release];
            cell.textLabel.textColor=_savedPreferences.headerColor;
            cell.textLabel.backgroundColor=[UIColor clearColor];
            
            UILabel *lblOptionTitle[100];
            UILabel *lblOptionName[100];
            int optionSizesIndex[100];
            
            if (!([[[arrDatabaseCart objectAtIndex:indexPath.row] valueForKey:@"pOptionId"] intValue]==0))
            {
                
                NSMutableArray *dictOption = [[arrShoppingCart objectAtIndex:indexPath.row] objectForKey:@"productOptions"];
                
                NSMutableArray *arrProductOptionSize = [[[NSMutableArray alloc] init] autorelease];
                
                for (int i=0; i<[dictOption count]; i++)
                {
                    [arrProductOptionSize addObject:[[dictOption objectAtIndex:i] valueForKey:@"id"]];
                }
                
                NSArray *arrSelectedOptions=[[[arrDatabaseCart objectAtIndex:indexPath.row] valueForKey:@"pOptionId"] componentsSeparatedByString:@","];
                
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
                
                int yValue=55;
                
                for(int count=0;count<[arrSelectedOptions count];count++)
                {
                    
                    
                    
                    NSString *tempStr=[[NSString alloc]init ];
                    
                    if([[NSString stringWithFormat:@"%@",[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sTitle"]] length ]>9)
                    {
                        tempStr=[[NSString stringWithFormat:@"%@",[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sTitle"]] substringToIndex:8];
                        tempStr=[NSString stringWithFormat:@"%@..:",tempStr];
                    }
                    else{
                        tempStr=[NSString stringWithFormat:@"%@:",[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sTitle"]] ;
                    }
                    CGSize size=[tempStr sizeWithFont:[UIFont boldSystemFontOfSize:10]];
                    
                    int width=size.width;
                    if(width>50)
                        width=50;
                    
                    
                    lblOptionTitle[count] = [[UILabel alloc]initWithFrame:CGRectMake(85,yValue,width+3,20)];
                    lblOptionTitle[count].backgroundColor=[UIColor clearColor];
                    [lblOptionTitle[count] setTextAlignment:UITextAlignmentLeft];
                    lblOptionTitle[count].textColor=[UIColor darkGrayColor];
                    [lblOptionTitle[count] setNumberOfLines:0];
                    [lblOptionTitle[count] setText:tempStr];
                    lblOptionTitle[count].font=[UIFont boldSystemFontOfSize:10];
                    [cell addSubview:lblOptionTitle[count]];
                    
                    CGSize size1=[[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sName"] sizeWithFont:[UIFont boldSystemFontOfSize:12] constrainedToSize:CGSizeMake(1000, 20)];
                    int width1=size1.width;
                    if(width1>(50-lblOptionTitle[count].frame.size.width)+50)
                        width1=(50-lblOptionTitle[count].frame.size.width)+50;
                    [lblOptionTitle[count] release];
                    
                    
                    lblOptionName[count] = [[UILabel alloc]initWithFrame:CGRectMake(lblOptionTitle[count].frame.size.width+lblOptionTitle[count].frame.origin.x,yValue,width1,20)];
                    lblOptionName[count].backgroundColor=[UIColor clearColor];
                    [lblOptionName[count] setTextAlignment:UITextAlignmentLeft];
                    lblOptionName[count].textColor=[UIColor blackColor];
                    [lblOptionName[count] setNumberOfLines:0];
                    [lblOptionName[count] setText: [NSString stringWithFormat:@"%@",[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"sName"]]];
                    lblOptionName[count].lineBreakMode = UILineBreakModeWordWrap;
                    lblOptionName[count].lineBreakMode = UILineBreakModeTailTruncation;
                    lblOptionName[count].font=[UIFont boldSystemFontOfSize:12];
                    [cell addSubview:lblOptionName[count]];
                    [lblOptionName[count] release];
                    
                    yValue=yValue+15;
                }
                
                
                
            }
            
            
            
            NSString *strText=[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, productSubTotal];
            CGSize size=[strText sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:11] constrainedToSize:CGSizeMake(500,20) lineBreakMode:UILineBreakModeWordWrap];
            int x=size.width;
            if(x>65)
                x=65;
            
            UILabel *productTotalPrice = [[UILabel alloc]initWithFrame:CGRectMake(295-x,55,x+20,20)];
            productTotalPrice.backgroundColor=[UIColor clearColor];
            [productTotalPrice setTextAlignment:UITextAlignmentLeft];
            productTotalPrice.textColor=[UIColor blackColor];
            [productTotalPrice setNumberOfLines:0];
            productTotalPrice.tag = [[NSString stringWithFormat:@"1000%d",indexPath.row] intValue];
            
            [productTotalPrice setText:[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, productSubTotal]];
            
            productTotalPrice.lineBreakMode=UILineBreakModeTailTruncation;
            productTotalPrice.font =[UIFont fontWithName:@"Helvetica-Bold" size:11];
            [cell addSubview:productTotalPrice];
            
            UILabel *productTotalPriceTitle = [[UILabel alloc]initWithFrame:CGRectMake(productTotalPrice.frame.origin.x-75,55, 70, 20)];
            productTotalPriceTitle.backgroundColor=[UIColor clearColor];
            [productTotalPriceTitle setTextAlignment:UITextAlignmentRight];
            productTotalPriceTitle.textColor=[UIColor darkGrayColor];
            [productTotalPriceTitle setNumberOfLines:0];
            [productTotalPriceTitle setTag:[[NSString stringWithFormat:@"999%d",indexPath.row] intValue]];
            [productTotalPriceTitle setText:[NSString stringWithFormat:@"%@:",[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.subtotal"]]];
            productTotalPriceTitle.lineBreakMode = UILineBreakModeWordWrap;
            productTotalPriceTitle.lineBreakMode=UILineBreakModeTailTruncation;
            productTotalPriceTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:11];
            [cell addSubview:productTotalPriceTitle];
            [productTotalPriceTitle release];
            
            int xTemp;
            xTemp=productTotalPrice.frame.origin.x+productTotalPrice.frame.size.width-25;
            UILabel *lblQuantityTitle = [[UILabel alloc]initWithFrame:CGRectMake(xTemp,2, 25, 25)];
            lblQuantityTitle.backgroundColor=[UIColor clearColor];
            [lblQuantityTitle setTextAlignment:UITextAlignmentRight
             ];
            lblQuantityTitle.textColor=[UIColor darkGrayColor];
            [lblQuantityTitle setNumberOfLines:0];
            lblQuantityTitle.text=[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.shoppingcart.qty"];
            lblQuantityTitle.lineBreakMode = UILineBreakModeWordWrap;
            lblQuantityTitle.tag = [[NSString stringWithFormat:@"88%d0%d",indexPath.row+1,indexPath.row+1] intValue];
            lblQuantityTitle.font =[UIFont fontWithName:@"Helvetica-Bold" size:11];
            [cell addSubview:lblQuantityTitle];
            [lblQuantityTitle release];
            
            UILabel *lblQuantity = [[UILabel alloc]initWithFrame:CGRectMake(xTemp-18, 25, 40, 27)];
            
            // UILabel *lblQuantity = [[UILabel alloc]initWithFrame:CGRectMake(0,3,26,21)];
            lblQuantity.backgroundColor=[UIColor clearColor];
            [lblQuantity setTextAlignment:UITextAlignmentRight];
            lblQuantity.textColor=[UIColor blackColor];
            [lblQuantity setNumberOfLines:0];
            lblQuantity.text = [[arrDatabaseCart objectAtIndex:indexPath.row] valueForKey:@"quantity"];
            lblQuantity.lineBreakMode = UILineBreakModeWordWrap;
            lblQuantity.font=[UIFont fontWithName:@"Helvetica" size:13];
            //lblQuantity.tag = [[NSString stringWithFormat:@"99%d0%d",indexPath.row+1,indexPath.row+1] intValue];
            lblQuantity.tag=700+indexPath.row;
            [cell addSubview:lblQuantity];
            
            [lblQuantity release];
            //[imgQuantity release];
            
            UIButton *btnQuantity = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btnQuantity.frame=CGRectMake(xTemp-16,25, 40, 27);
            btnQuantity.backgroundColor=[UIColor clearColor];
            [btnQuantity setBackgroundImage:[UIImage imageNamed:@"shop_box.png"] forState:UIControlStateNormal];
            [btnQuantity setTitle:[[arrDatabaseCart objectAtIndex:indexPath.row] valueForKey:@"quantity"] forState:UIControlStateNormal];
            [btnQuantity setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnQuantity.titleLabel.font=	[UIFont fontWithName:@"Helvetica" size:13];
            //btnQuantity.tag = [[NSString stringWithFormat:@"%d0%d",indexPath.row+1, indexPath.row+1] intValue];
            btnQuantity.tag=900+indexPath.row;
            [btnQuantity addTarget:self action:@selector(btnQuantity_Clicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btnQuantity];
            btnQuantity.hidden= TRUE;
            
            
            UIImageView *imgPlaceHolder=[[UIImageView alloc]initWithFrame:CGRectMake(10.5, 7, 68, 67)];
            [imgPlaceHolder setImage:[UIImage imageNamed:@"product_list_ph.png"]];
            
            [imgPlaceHolder setTag:[[NSString stringWithFormat:@"9900%d0%d",indexPath.row+1,indexPath.row+1] intValue]];
            [cell addSubview:imgPlaceHolder];
            
            
            NSDictionary *dictTemp=[arrShoppingCart objectAtIndex:indexPath.row];
            NSArray  *arrImagesUrls = [dictTemp objectForKey:@"productImages"];
            
            if ([arrImagesUrls count]!=0)
            {
                NSString* strImage=[[arrImagesUrls objectAtIndex:0] valueForKey:@"productImageSmallIphone4"];
                cellProductImageView=  [[CustomImageView alloc] initWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[ServerAPI getImageUrl],strImage]] frame:CGRectMake(0,0, 67, 67) isFrom:1];
                
                [imgPlaceHolder addSubview:cellProductImageView];
            }
            
            if([tableview isEditing])
                [imgPlaceHolder setHidden:YES];
            else {
                [imgPlaceHolder setHidden:NO];
            }
            
            
            
            NSString *srtTaxType;
            srtTaxType=[[arrShoppingCart objectAtIndex:indexPath.row] valueForKey:@"sTaxType"];
            
            
            if([[[arrShoppingCart objectAtIndex:indexPath.row]valueForKey:@"bTaxable"]intValue]==1)
            {
                if([srtTaxType isEqualToString:@"default"])
                    srtTaxType=@"";
                else
                    srtTaxType=[NSString stringWithFormat:@"(Inc %@)",srtTaxType];
            }
            else
                srtTaxType=@"";
            
            
            
            if([[[arrShoppingCart objectAtIndex:indexPath.row]valueForKey:@"bTaxable"]intValue]==1){
                
                
                [cell setProductName:[[arrShoppingCart objectAtIndex:indexPath.row] valueForKey:@"sName"] :[NSString stringWithFormat:@"%@%0.2f %@", _savedPreferences.strCurrencySymbol, productCost, srtTaxType] :@"" :@"" :nil];
            }
            else
            {
                [cell setProductName:[[arrShoppingCart objectAtIndex:indexPath.row] valueForKey:@"sName"] :[NSString stringWithFormat:@"%@%0.2f ", _savedPreferences.strCurrencySymbol, productCost] :@"" :@"" :nil];
            }
            
            ([tableView isEditing])?(btnQuantity.hidden = FALSE):(btnQuantity.hidden = TRUE);
        }
        
        // Sa Vo - NhanTVT - [20/06/2014] -
        // Fix issue wrong calculate sub total price for each products
        // If cell is already created, update latest sub total price for each products
        else {
            [self updateSubTotalForCell:cell atIndex:indexPath];
        }
        
        if([tableView isEditing])
        {
            [[cell viewWithTag:[[NSString stringWithFormat:@"9900%d0%d",indexPath.row+1,indexPath.row+1] intValue]]setHidden:YES];
            [[cell viewWithTag:[[NSString stringWithFormat:@"9900%d0%d",indexPath.row+1,indexPath.row+1] intValue]]setBackgroundColor:[UIColor whiteColor]];
        }
        else
        {
            [[cell viewWithTag: [[NSString stringWithFormat:@"9900%d0%d",indexPath.row+1,indexPath.row+1] intValue]]setHidden:NO];
            [[cell viewWithTag: [[NSString stringWithFormat:@"9900%d0%d",indexPath.row+1,indexPath.row+1] intValue]]setBackgroundColor:[UIColor clearColor]];
        }
        //  UIButton *btnQuantity_Temp = (UIButton *)[cell viewWithTag:[[NSString stringWithFormat:@"%d0%d",indexPath.row+1, indexPath.row+1] intValue]];
        
        // Sa Vo - NhanTVT - [19/06/2014] -
        // Fix issue does not display "Delete Icon" on UITableViewCell in editing mode
        // Removable code
        //        UIButton *btnQuantity_Temp = (UIButton *)[cell viewWithTag:900+indexPath.row];
        //        ([tableView isEditing])?(btnQuantity_Temp.hidden = FALSE):(btnQuantity_Temp.hidden = TRUE);
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.shouldIndentWhileEditing = NO;
    }
    return  cell;
}

#pragma mark Footer
// Custom view for footer. will be adjusted to default or specified footer height
- (UIView *)tableView:(UITableView *)tableView1 viewForFooterInSection:(NSInteger)section;
{
    
    
    
    if (!isLoadingTableFooter2ndTime)
    {
        // Calcuating the subtotal for all the items, added in the shopping cart
        float subTotal=0;
        mainTotal=0;
        
        float totalTaxApplied=0;
        
        float fShippingCharges=0,fShippingtax=0;
        float tax=[[[dictTaxAndShippingDetails valueForKey:@"tax"]valueForKey:@"fTax"]floatValue];
        
        for (int i=0; i<[arrDatabaseCart count]; i++)
        {
            float optionPrice=0;
            float productCost=0;
            
            
            
            if (!([[[arrDatabaseCart objectAtIndex:i]  valueForKey:@"pOptionId"] intValue]==0))
            {
                NSMutableArray *dictOption = [[arrShoppingCart objectAtIndex:i]  objectForKey:@"productOptions"];
                
                NSMutableArray *arrProductOptionSize = [[[NSMutableArray alloc] init] autorelease];
                
                for (int j=0; j<[dictOption count]; j++)
                {
                    [arrProductOptionSize addObject:[[dictOption objectAtIndex:j] valueForKey:@"id"]];
                    
                    
                }
                
                NSArray *arrSelectedOptions=[[[arrDatabaseCart objectAtIndex:i] valueForKey:@"pOptionId"] componentsSeparatedByString:@","];
                int optionSizesIndex[100];
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
                    
                    optionPrice =optionPrice+[[[dictOption objectAtIndex:optionSizesIndex[count]]valueForKey:@"pPrice"]floatValue];
                    
                }
                
                
            }
            
            DLog(@"%f",optionPrice);
            
            if ([arrShoppingCart count]>0)
            {
                NSString *discount = [NSString stringWithFormat:@"%@",[[arrShoppingCart objectAtIndex:i]valueForKey:@"fDiscountedPrice"]];
                
                float productQuantity=[[[arrDatabaseCart objectAtIndex:i]valueForKey:@"quantity"] intValue];
                if ([[[arrShoppingCart objectAtIndex:i]valueForKey:@"bTaxable"]intValue]==1)
                {
                    if ([[[arrShoppingCart objectAtIndex:i]valueForKey:@"fPrice"] floatValue]>[discount floatValue])
                    {
                        productCost=[discount floatValue];
                        totalTaxApplied+=((([discount floatValue]+0)*productQuantity)*tax)/100;
                    }
                    else
                    {
                        productCost=[[[arrShoppingCart objectAtIndex:i]valueForKey:@"fPrice"] floatValue];
                        totalTaxApplied=(totalTaxApplied+((([[[arrShoppingCart objectAtIndex:i]valueForKey:@"fPrice"] floatValue]+0)*productQuantity)*tax)/100);
                    }
                }
                else
                {
                    if ([[[arrShoppingCart objectAtIndex:i]valueForKey:@"fPrice"] floatValue]>[discount floatValue])
                    {
                        productCost=[discount floatValue];
                    }
                    else
                    {
                        productCost=[[[arrShoppingCart objectAtIndex:i]valueForKey:@"fPrice"] floatValue];
                    }
                }
                
                productCost+=optionPrice;
                subTotal =	(productCost) * [[[arrDatabaseCart objectAtIndex:i]valueForKey:@"quantity"] intValue];
                
                if (!isLoadingTableFooter2ndTime)
                {
                    mainTotal += subTotal;
                    
                }
            }
        }
        
        if (!isLoadingTableFooter2ndTime)
        {
            grandTotal = mainTotal;
            
        }
        // Stopping the viewForFooterInSection delegate call again, when table reload
        isLoadingTableFooter2ndTime = TRUE;
        
        if ([arrShoppingCart count]>1)
        {
            fShippingCharges=[[[dictTaxAndShippingDetails valueForKey:@"shipping"]valueForKey:@"fOthers"]floatValue];
        }
        else
        {
            if (selectedQuantity==1)
            {
                fShippingCharges=[[[dictTaxAndShippingDetails valueForKey:@"shipping"]valueForKey:@"fAlone"]floatValue];
            }
            else
            {
                fShippingCharges=[[[dictTaxAndShippingDetails valueForKey:@"shipping"]valueForKey:@"fOthers"]floatValue];
            }
        }
        
        fShippingtax=(fShippingCharges*tax)/100;
        
        if ([[dictSettingsDetails valueForKey:@"bTaxShipping"]intValue]==0)
        {
            fShippingtax=0;
        }
        if ([[dictSettingsDetails valueForKey:@"bIncludeTax"]intValue]==0)
        {
            totalTaxApplied=0;
        }
        
        fShippingtax=[GlobalPreferences getRoundedOffValue:fShippingtax];
        fShippingCharges=[GlobalPreferences getRoundedOffValue:fShippingCharges];
        totalTaxApplied=[GlobalPreferences getRoundedOffValue:totalTaxApplied];
        //	totalTaxApplied = [GlobalPreferences getRoundedOffValue:[[NSString stringWithFormat:@"%f", totalTaxApplied] floatValue]];
        
        grandTotal=grandTotal+fShippingtax+fShippingCharges+totalTaxApplied;
        
        [lblShippingCharges setText:[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, fShippingCharges]];
        
        [lblShippingTax setText:[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, fShippingtax]];
        
        [lblSubTotalFooter setText:[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, mainTotal]];
        
        [lblTax setText:[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol,totalTaxApplied]];
        
        [lblGrandTotalFooter setText:[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, grandTotal]];
        
    }
    return nil;
}

#pragma mark -
- (void)tableView:(UITableView*)tableview didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    if (tableview==tblCountries)
    {
        NSDictionary *dictTemp = [interDict objectAtIndex:indexPath.row];
        
        countryID=[[dictTemp valueForKey:@"territoryId"]intValue];
        
        //		NSDictionary *contentDict = [dictSettingsDetails objectForKey:@"store"];
        NSArray* arrTemp = [dictSettingsDetails objectForKey:@"taxList"];
        
        [arrStates removeAllObjects];
        for (int index=0;index<[arrTemp count];index++)
        {
            if (countryID==[[[arrTemp valueForKey:@"territoryId"]objectAtIndex:index]intValue])
            {
                [arrStates  addObject:[arrTemp objectAtIndex:index]];
            }
            
        }
        for (int index=0;index<[arrTempShippingCountries count];index++)
        {
            if (countryID==[[[arrTempShippingCountries valueForKey:@"territoryId"]objectAtIndex:index]intValue])
            {
                if (![[arrStates valueForKey:@"sState"]containsObject:[[arrTempShippingCountries valueForKey:@"sState"]objectAtIndex:index]])
                {
                    [arrStates  addObject:[arrTempShippingCountries objectAtIndex:index]];
                }
            }
        }
        
        int stateID=0;
        isLoadingTableFooter2ndTime=NO;
        
        [GlobalPreferences setUserCountryAndStateForTax_country:[dictTemp valueForKey:@"sCountry"] countryID:countryID];
        
        [tblCountries setHidden:YES];
        [lblCountryName setText:[dictTemp valueForKey:@"sCountry"]];
        [lblStateName setText:[[arrStates valueForKey:@"sState"]objectAtIndex:0]];
        stateID=[[[arrStates valueForKey:@"stateId"]objectAtIndex:0]intValue];
        if (dictTaxAndShippingDetails)
        {
            [dictTaxAndShippingDetails release];
            dictTaxAndShippingDetails=nil;
        }
        dictTaxAndShippingDetails = [ServerAPI fetchTaxShippingDetails:countryID:stateID :iCurrentStoreId];
        [tblStates reloadData];
        
        // Sa Vo - NhanTVT - [19/06/2014] -
        // Fix issue does not display "Delete Icon" on UITableViewCell in editing mode
        // Removable code
        //		[tableView reloadData];
        
    }
    else if (tableview==tblStates)
    {
        int stateID=0;
        isLoadingTableFooter2ndTime=NO;
        stateID=[[[arrStates valueForKey:@"stateId"]objectAtIndex:indexPath.row]intValue];
        if (dictTaxAndShippingDetails)
        {
            [dictTaxAndShippingDetails release];
            dictTaxAndShippingDetails=nil;
        }
        dictTaxAndShippingDetails=[ServerAPI fetchTaxShippingDetails:countryID :stateID :iCurrentStoreId];
        [tblStates setHidden:YES];
        [lblStateName setText:[[arrStates valueForKey:@"sState"]objectAtIndex:indexPath.row]];
        // Sa Vo - tnlq - [03/06/2014]
        [tblStates reloadData];
        //
        
        // Sa Vo - NhanTVT - [19/06/2014] -
        // Fix issue does not display "Delete Icon" on UITableViewCell in editing mode
        // Removable code
        //		[tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView1 canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *tblViewCell=(UITableViewCell *)[tableView1 cellForRowAtIndexPath:indexPath];
    editingCell = tblViewCell;
    
    if([tableView isEditing]) {
        [[tblViewCell viewWithTag:[[NSString stringWithFormat:@"9900%d0%d",indexPath.row+1,indexPath.row+1] intValue]]setHidden:YES];
        
    } else {
        [[tblViewCell viewWithTag: [[NSString stringWithFormat:@"9900%d0%d",indexPath.row+1,indexPath.row+1] intValue]]setHidden:NO];
    }
    
    // Sa Vo - NhanTVT - [19/06/2014] -
    // Fix issue does not display "Delete Icon" on UITableViewCell in editing mode
    // Hide or unhide btnQuantity
    UIButton *btnQuantity_Temp = (UIButton *)[tblViewCell viewWithTag:900+indexPath.row];
    ([tableView isEditing])?(btnQuantity_Temp.hidden = FALSE):(btnQuantity_Temp.hidden = TRUE);
    
    return [tableView isEditing];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    
}

static int kAnimationType;
- (void)tableView:(UITableView *)_tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // For changing th animation style for every odd.even row
    (kAnimationType == 6)?kAnimationType = 0:0;
    kAnimationType += 1;
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[SqlQuery shared] deleteItemFromShoppingCart:[[[arrDatabaseCart objectAtIndex:indexPath.row] valueForKey:@"id"]integerValue] :[[arrDatabaseCart objectAtIndex:indexPath.row] valueForKey:@"pOptionId"]];
        [arrShoppingCart removeObjectAtIndex:indexPath.row];
        
        [arrDatabaseCart removeObjectAtIndex:indexPath.row];
        
        if ([arrShoppingCart count]==0)
            self.navigationItem.rightBarButtonItem=nil;
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:kAnimationType];
        
        /// USING "NO" TO REDUCE ONE ELEMENT FROM THE SHOPPING CART's COUNTER
        [GlobalPreferences setCurrentItemsInCart:NO];
        
        // Allowing the viewForFooterInSection to be executed
        (isLoadingTableFooter2ndTime)?isLoadingTableFooter2ndTime=0:0;
        [self tableView:tableView viewForFooterInSection:1];
        // It will be again calculated while reloading the table
        mainTotal =0.0;
        
        if ([arrDatabaseCart count]>0)
        {    _isEditCommit=YES;
            [tableView reloadData];
        }
        else
        {
            [tableView setHidden:YES];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delete";
}

- (void)btnQuantity_Clicked:(id)sender
{
    iTagOfCurrentQuantityBtn=[sender tag];
    _isQtyEdit=YES;
    
    //iTagOfCurrentQuantityLabel = [[NSString stringWithFormat:@"99%d",[sender tag]] intValue];
    iTagOfCurrentQuantityLabel=[sender tag]-200;
    //NSString *strSelectedIndex=[NSString stringWithFormat:@"%d",iTagOfCurrentQuantityBtn];
    
    //NSArray *temp = [strSelectedIndex componentsSeparatedByString:@"0"];
    
    
    [arrQuantity removeAllObjects];
    
    int max=100;
    
    if ([arrDatabaseCart count]>0)
    {
        //int selectedRow = [[temp objectAtIndex:0] intValue] - 1;
        int selectedRow =iTagOfCurrentQuantityLabel-700;
        if ([[[arrDatabaseCart objectAtIndex:selectedRow] valueForKey:@"pOptionId"] intValue]==0)
        {
            max=[[[arrShoppingCart objectAtIndex:selectedRow] objectForKey:@"iAggregateQuantity"] intValue];
            if (max==-1)
            {
                max=100;
            }
        }
        else
        {
            
            NSMutableArray *dictOption = [[arrShoppingCart objectAtIndex:selectedRow] objectForKey:@"productOptions"];
            
            NSMutableArray *arrProductOptionId = [[[NSMutableArray alloc] init] autorelease];
            
            for (int i=0; i<[dictOption count]; i++)
            {
                
                [arrProductOptionId addObject:[[dictOption objectAtIndex:i] valueForKey:@"id"]];
                
            }
            
            NSArray *arrOptions=[[[arrDatabaseCart objectAtIndex:selectedRow] valueForKey:@"pOptionId"] componentsSeparatedByString:@","];
            
            //int optionSizeIndex=555545;
            
            int optionIndexes[100];
            for(int count=0;count<[arrOptions count];count++)
            {
                
                if ([arrProductOptionId containsObject: [NSNumber numberWithInt:[[arrOptions objectAtIndex:count] intValue]]])
                {
                    optionIndexes[count] = [arrProductOptionId indexOfObject:[NSNumber numberWithInt:[[arrOptions objectAtIndex:count]intValue]]];
                }
            }
            
            NSMutableArray * arrSameProductOptions=[[NSMutableArray alloc]init];
            if([arrDatabaseCart count]>0)
            {
                
                for(int count=0;count<[arrDatabaseCart count];count++)
                {
                    if(count!=selectedRow)
                    {
                        
                        if([[[arrDatabaseCart objectAtIndex:count] valueForKey:@"id"]intValue]==[[[arrDatabaseCart objectAtIndex:selectedRow] valueForKey:@"id"]intValue])
                        {
                            [arrSameProductOptions addObject:[arrDatabaseCart objectAtIndex:count]];
                            
                        }
                    }
                    
                }
            }
            
            int quantityAdded[100];
            int minQuantityCheck[100];
            
            for(int i=0;i<=[arrOptions count] ;i++)
            {
                quantityAdded[i]=0;
                minQuantityCheck[i]=100;
                
            }
            
            for(int i=0;i<[arrOptions count];i++)
            {
                for(int j=0;j<[arrSameProductOptions count];j++)
                {
                    
                    NSArray *arrayOptions=[[[arrSameProductOptions objectAtIndex:j]valueForKey:@"pOptionId"] componentsSeparatedByString:@","];
                    
                    for(int k=0;k<[arrayOptions count];k++)
                    {
                        
                        if([[arrOptions objectAtIndex:i] intValue]==[[arrayOptions objectAtIndex:k]intValue])
                        {
                            
                            quantityAdded[i]=quantityAdded[i]+[[[arrSameProductOptions objectAtIndex:j]objectForKey:@"quantity"]intValue];
                            DLog(@"%d",quantityAdded[i]);
                        }
                    }
                    
                }
            }
            if(arrSameProductOptions)
                [arrSameProductOptions release];
            
            for(int count=0;count<[arrOptions count];count++)
            {
                //minQuantityCheck[count]=[[[dictOption objectAtIndex:optionIndexes[count]]objectForKey:@"iAvailableQuantity"]intValue]-[[[arrDatabaseCart objectAtIndex:selectedRow]objectForKey:@"quantity"]intValue]+1;
                
                minQuantityCheck[count]=[[[dictOption objectAtIndex:optionIndexes[count]]objectForKey:@"iAvailableQuantity"]intValue];
                if((quantityAdded[count]<100&&quantityAdded[count]>0))
                {
                    
                    minQuantityCheck[count]=[[[dictOption objectAtIndex:optionIndexes[count]]objectForKey:@"iAvailableQuantity"]intValue]-quantityAdded[count];
                    
                    
                }
                DLog(@"%d", minQuantityCheck[count]);
                
            }
            
            
            if ([arrOptions count]>0)
            {
                if(minQuantityCheck[0]<100&&minQuantityCheck[0]>0)
                    max=minQuantityCheck[0];
            }
            for(int i=1;i<[arrOptions count];i++)
            {
                if(max>minQuantityCheck[i])
                    max=minQuantityCheck[i];
                
            }
            
            if(max<[[[arrDatabaseCart objectAtIndex:selectedRow]objectForKey:@"quantity"]intValue])
            {
                max=[[[arrDatabaseCart objectAtIndex:selectedRow]objectForKey:@"quantity"]intValue];
                
            }
            
            //if(max==-1)
            // max=100;
            
            
        }
        for (int i=0; i<max; i++)
        {
            [arrQuantity addObject:[NSString stringWithFormat:@"%d",i+1]];
        }
        
        if (max==0)
        {
            [arrQuantity addObject:[NSString stringWithFormat:@"%d",1]];
        }
    }
    else
    {
        int i=0;
        [arrQuantity addObject:[NSString stringWithFormat:@"%d",i+1]];
    }
    int pickerRow=0;
    
    UILabel *lblTemp = (UILabel *)[tableView viewWithTag:iTagOfCurrentQuantityLabel];
    
    // Sa Vo - NhanTVT - [20/06/2014] -
    // Fix issue wrong calculate sub total price for each products
    // Check whether superview of label is a cell
    
    // Because of UITableViewCell structure differences
    // iOS 8 beta, iOS 6.x and below will go here
    if ([lblTemp.superview isKindOfClass:[UITableViewCell class]]) {
        editingCell = (UITableViewCell *)lblTemp.superview;
        
        // for only iOS 7.x
    } else if ([lblTemp.superview.superview isKindOfClass:[UITableViewCell class]]) {
        editingCell = (UITableViewCell *)lblTemp.superview.superview;
    }
    
    if (!pickerViewContainer)
    {
        originalYCoor = self.view.frame.size.height + kHeightCustomPickerView;
        animatedYCoor = self.view.frame.size.height - kHeightCustomPickerView;
        
        pickerViewContainer = [[UIView alloc] initWithFrame:
                               CGRectMake(0, originalYCoor, 320, kHeightCustomPickerView)];
        pickerViewContainer.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    }
    
    NSInteger pickerViewYCoor = pickerViewContainer.frame.size.height - kHeightDefaultPickerView;
    NSInteger toolbarYCoor = pickerViewContainer.frame.size.height - kHeightDefaultPickerView - 44;
    
    UIPickerView *pickerViewQuantity = [[UIPickerView alloc]initWithFrame:
                                        CGRectMake(0, pickerViewYCoor, 0.0, 0.0)];
    [pickerViewQuantity setDelegate:self];
    [pickerViewQuantity setDataSource:self];
    [pickerViewQuantity setShowsSelectionIndicator:YES];
    
    // Sa Vo - NhanTVT - [18/06/2014]
    // Optimized code: Casting type string to integer for getting selected row
    // instead of using loop, if exception happend then selected row is be zero
    NSInteger selectedRow = 0;
    
    if (lblTemp.text && ![lblTemp.text isEqualToString:@""])
        selectedRow = lblTemp.text.integerValue - 1;
    
    [pickerViewQuantity selectRow:selectedRow inComponent:0 animated:NO];
    
    [contentView addSubview:pickerViewQuantity];
    
    // Create ToolBar
    UIToolbar *toolbarForPicker = [[UIToolbar alloc] initWithFrame:
                                   CGRectMake(0, toolbarYCoor, 320, 44)];
    toolbarForPicker.barStyle = UIBarStyleBlackOpaque;
    [toolbarForPicker sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    [flexSpace release];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonForActionSheet:)];
    [barItems addObject:doneBtn];
    [doneBtn release];
    
    [toolbarForPicker setItems:barItems animated:YES];
    
    [pickerViewContainer addSubview:toolbarForPicker];
    [pickerViewContainer addSubview:pickerViewQuantity];
    [self.view addSubview:pickerViewContainer];
    
    [pickerViewQuantity release];
    [barItems release];
    
    // Sa Vo - NhanTVT - [18/06/2014] -
    // Fix issue related to UIPickerView does not displayed on iOS 8: using
    // animation with UIView to immitate UIActionSheet animation
    [UIView animateWithDuration:kAnimationDurationCustomPickerView
                          delay:kAnimationDelayCustomPickerView
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         pickerViewContainer.frame =
                         CGRectMake(0, animatedYCoor, 320, kHeightCustomPickerView);
                     }
                     completion:^(BOOL finished){
                         isPickerViewShown = YES;
                     }];
}


// Sa Vo - NhanTVT - [18/06/2014] -
// Fix issue related to UIPickerView does not displayed on iOS 8: using
// Close picker view if it is opening
- (void)closeCustomPickerView {
    
    if (pickerViewContainer && isPickerViewShown) {
        
        [UIView animateWithDuration:kAnimationDurationCustomPickerView
                              delay:kAnimationDelayCustomPickerView
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             pickerViewContainer.frame =
                             CGRectMake(0, originalYCoor, 320, kHeightCustomPickerView);
                         }
                         completion:^(BOOL finished){
                             isPickerViewShown = NO;
                             // Sa Vo - NhanTVT - [23/06/2014]
                             // Fix issue crash while UIPickerView is showing
                             // Remove PickerViewContainer after closing
                             [pickerViewContainer removeFromSuperview];
                         }];
    }
}

// Sa Vo - NhanTVT - [20/06/2014]
// Fix issue wrong calculate Sub Total price for each products
// Updating Sub Total after finishing editing
- (void)updateSubTotalForCell:(UITableViewCell *)cell atIndex:(NSIndexPath *)indexPath {
    
    float productCost = [SubtotalCalculation calculateProductCost:
                         [arrShoppingCart objectAtIndex:indexPath.row]arrDataBase:
                         [arrDatabaseCart objectAtIndex:indexPath.row]];
    
    float productSubTotal = productCost * [[[arrDatabaseCart objectAtIndex:indexPath.row]
                                            valueForKey:@"quantity"] intValue];
    
    productCost=[GlobalPreferences getRoundedOffValue:productCost];
    productSubTotal=[GlobalPreferences getRoundedOffValue:productSubTotal];
    
    NSInteger tagLabelSubPrice = [[NSString stringWithFormat:@"1000%d",indexPath.row] intValue];
    UILabel *lblSubPrice = (UILabel *)[cell viewWithTag:tagLabelSubPrice];
    [lblSubPrice setText:[NSString stringWithFormat:@"%@%0.2f", _savedPreferences.strCurrencySymbol, productSubTotal]];
}


// Sa Vo - tnlq - [03/06/2014] - move change subtotal to PickeQuantity
// didselectRow
- (void)doneButtonForActionSheet:(id)sender
{
    [self closeCustomPickerView];
}
//

// Sa Vo - tnlq - [03/06/2014]
- (void) setValueToRecalculatePrice {
    UIButton *btnTemp = (UIButton *) [tableView viewWithTag:iTagOfCurrentQuantityBtn];
    
    int tagOfClickedButton=iTagOfCurrentQuantityBtn-900;
    
    // Sa Vo - NhanTVT - [19/06/2014] -
    // Fix issue related to wrong calculate total price
    // get quantity from button quantity
    [[SqlQuery shared] updateTblShoppingCart:[[btnTemp titleForState:UIControlStateNormal] intValue] :[[[arrDatabaseCart objectAtIndex:tagOfClickedButton] valueForKey:@"id"] intValue] :[[arrDatabaseCart objectAtIndex:tagOfClickedButton] valueForKey:@"pOptionId"] ];
    
    arrDatabaseCart = [[SqlQuery shared]getShoppingCartProductIDs:NO];
    UILabel *lblTemp = (UILabel *)[tableView viewWithTag:iTagOfCurrentQuantityLabel];
    
    // Sa Vo - NhanTVT - [18/06/2014] -
    // Fix issue related to incorrect selection when pickerView displayed
    // Get quantity from button quantity
    lblTemp.text = [btnTemp titleForState:UIControlStateNormal];
    
    // Allowing the viewForFooterInSection to be executed
    (isLoadingTableFooter2ndTime)?isLoadingTableFooter2ndTime=0:0;
    
    
    [self tableView:tableView viewForFooterInSection:1];
    
    // It will be again calculated in viewForFooterInSection
    mainTotal = 0.0f;
    tableView.delegate=self;
    _isEditCommit=NO;
    
    // Sa Vo - NhanTVT - [19/06/2014] -
    // Fix issue does not display "Delete Icon" on UITableViewCell in editing mode
    // Removable code
    //    UILabel *lblSubPriceTemp = (UILabel *)[tableView viewWithTag:10000];
    //    [tableView reloadData];
}

#pragma mark Picker View Delegates method

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrQuantity count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [arrQuantity objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    UIButton *btnTemp = (UIButton *) [tableView viewWithTag:iTagOfCurrentQuantityBtn];
    UILabel *lblTemp = (UILabel *)[tableView viewWithTag:iTagOfCurrentQuantityLabel];
    selectedQuantity=[[arrQuantity objectAtIndex:row]intValue];
    if ([btnTemp isKindOfClass:[UIButton class]])
    {
        if ([arrQuantity count]>=row)
        {
            [btnTemp setTitle:[arrQuantity objectAtIndex:row] forState:UIControlStateNormal];
        }
        else
        {
            [btnTemp setTitle:@"0" forState:UIControlStateNormal];
        }
    }
    
    if ([lblTemp isKindOfClass:[UILabel class]])
    {
        if ([arrQuantity count]>=row)
        {
            lblTemp.text =[arrQuantity objectAtIndex:row];
        }
        else
        {
            [lblTemp setText:@"0"];
        }
    }
    // Sa Vo - tnlq - [03/06/2014]
    [self setValueToRecalculatePrice];
    //
    
    
    // Sa Vo - NhanTVT - [20/06/2014] -
    // Fix issue wrong calculate sub total price for each products
    // Calculate sub total for edited product
    if (editingCell) {
        NSIndexPath *editingIndexPath = [tableView indexPathForCell:editingCell];
        [self updateSubTotalForCell:editingCell atIndex:editingIndexPath];
    }
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    if (lblSubTotalFooter)
    {
        [lblGrandTotalFooter release];
        lblGrandTotalFooter = nil;
    }
    
    if (lblSubTotalFooter)
    {
        [lblSubTotalFooter release];
        lblSubTotalFooter = nil;
    }
    
    if (tableView)
    {
        [tableView release];
        tableView=nil;
    }
    
    if (arrShoppingCart)
    {
        [arrShoppingCart release];
        arrShoppingCart=nil;
    }
    
    if (arrDatabaseCart)
    {
        [arrDatabaseCart release];
        arrDatabaseCart = nil;
    }
    
    // Sa Vo - NhanTVT - [23/06/2014]
    // Fix issue crash while UIPickerView is showing
    if (pickerViewContainer)
    {
        [pickerViewContainer removeFromSuperview];
        [pickerViewContainer release];
        pickerViewContainer = nil;
    }
    
    [arrInfoAccount release];
    isShoppingCart_TableStyle = FALSE;
    isLoadingTableFooter=NO;
    isLoadingTableFooter2ndTime=NO;
    [[NSNotificationCenter defaultCenter] removeObserver:@"updateShoppingCart_ViewController"];
    
    [super dealloc];
}

//-------------------
- (void)hideLoadingBar
{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc]init];
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(runScheduledTask) userInfo:nil repeats:NO];
    aTimer=nil;
    
    [pool release];
}
/* runScheduledTask */

- (void)runScheduledTask {
    // Do whatever u want
    
    [GlobalPreferences hideLoadingIndicator];
    // Set the timer to nil as it has been fired
}


@end
