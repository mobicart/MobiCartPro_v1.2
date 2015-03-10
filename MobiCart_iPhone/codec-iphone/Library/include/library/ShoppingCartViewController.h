//
//  ShoppingCartViewController.h
//  MobiCart
//
//  Created by Mobicart on 23/07/10.
//  Copyright 2010 Mobicart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "CustomImageView.h"

BOOL isShoppingCart_TableStyle;
BOOL isCheckForCheckout;
@interface ShoppingCartViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate>
{
	UITableView *tableView,*tblStates,*tblCountries;

	NSMutableArray *arrShoppingCart, *arrDatabaseCart;
	UILabel *lblSubTotalFooter;
	UILabel *lblTax;

	UILabel *lblGrandTotalFooter;

	UILabel *lblCountryName,*lblStateName;
	UIView *contentView;
	UILabel *lblShippingCharges,*lblShippingTax;
	
	NSMutableArray *arrQuantity;
	NSInteger iTagOfCurrentQuantityBtn, iTagOfCurrentQuantityLabel,iTagOfCurrrentQuantityPrice;
	UIActionSheet *actionSheetForPicker;
	
	NSDictionary *dictSettingsDetails;
	NSMutableArray *interDict;
	NSMutableArray *arrCountries;
	NSMutableArray *arrStates;
	
	float mainTotal;
	int	countryID;
	BOOL isEditing;
	NSDictionary *dicStates;
	NSDictionary *dictTaxAndShippingDetails;
	int selectedQuantity;
	NSMutableArray *arrInfoAccount;
	NSMutableArray *arrTempShippingCountries;
	UIBarButtonItem *barBtnEdit;
	int moreTabCount;
	
	NSString *strEditButtonTitle;
	NSString *strDoneButtonTitle;
    CustomImageView * cellProductImageView;
    
    // Sa Vo - NhanTVT -[18/06/2014] -
    // Fix issue related to UIPickerView does not displayed on iOS 8
    UIView *pickerViewContainer;
    NSInteger originalYCoor;
    NSInteger animatedYCoor;
    BOOL isPickerViewShown;
    
    // Sa Vo - NhanTVT - [20/06/2014] -
    // Fix issue wrong calculate Sub Total for each products
    UITableViewCell *editingCell;
	
}
@property(readwrite)int isEditCommit;
@property(readwrite)int isQtyEdit;
@property(nonatomic)BOOL isFomCheckout;
- (void)createTableView;
- (void)hideBottomBar;
//- (void)hideLoadingIndicator;
- (void)hideLoadingBar;
@end
