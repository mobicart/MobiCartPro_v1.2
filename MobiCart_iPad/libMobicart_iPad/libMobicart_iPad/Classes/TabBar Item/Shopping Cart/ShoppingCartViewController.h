//
//  ShoppingCartViewController.h
//  Mobicart
//
//  Created by Mobicart on 11/05/11.
//  Copyright Mobicart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "CustomImageView.h"
extern BOOL isLoadingTableFooter;

// 05/8/2014 Tuyen new code
@class CheckoutViewController;
// End

@interface ShoppingCartViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate> {
    CustomImageView * cellProductImageView;
	UIView *contentView;
	NSMutableArray *arrShoppingCart, *arrDatabaseCart,*arrQuantity;
	NSMutableArray *arrTempShippingCountries;
	UITableView *tableView,*tblStates,*tblCountries;
	UIView *viewFooter;
	
 
    
	int selectedQuantity;
	NSInteger iTagOfCurrentQuantityBtn, iTagOfCurrentQuantityLabel;
	UIActionSheet *actionSheetForPicker;
	BOOL isLoadingTableFooter2ndTime;
	UIPickerView *pickerViewQuantity;
	
	NSDictionary *dictTaxAndShippingDetails,*dictSettingsDetails;
	UIAlertView *alertLogin;
	UILabel *lblSubTotalFooter,*lblGrandTotalFooter,*lblTax,*lblShippingCharges,*lblShippingTax;
	UILabel *lblCountryName,*lblStateName;
	NSMutableArray *interDict;
	int	countryID;
	UIView *rightContentView;
	NSMutableArray *arrCountries,*arrStates,*arrInfoAccount;
    
    // 05/8/2014 Tuyen new code
    CheckoutViewController *_objCheckout;
    // End
    BOOL isEditing;
    
    // Sa Vo - NhanTVT -[23/06/2014] -
    // Making view overlay the view while pickerView is showing
    // Initialize variables
    UIView *maskView;
    BOOL isMaskViewShown;
    
    // Sa Vo - NhanTVT - [23/06/2014] -
    // Fix issue wrong calculate Sub Total for each products
    // Initialize variables
    UITableViewCell *editingCell;
}
@property(readwrite)int isEditCommit;
// 28/11/2014 Tuyen new code to test bug 27828
@property(nonatomic, strong)CheckoutViewController *objCheckout;
// End
-(void)viewForFooter;
-(void)setRightContentView;
-(void)createTableView;
-(void)reloadMe;
-(void)checkoutMethod;

@end
