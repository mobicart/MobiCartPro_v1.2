//
//  StoreModel.h
//  MobicartApp
//
//  Created by Surbhi Handa on 17/08/12.
//  Copyright (c) 2012 Net Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreModel : UIViewController<UISearchBarDelegate>
{
    UIView *contentView;
	UITableView *tableView;
	NSMutableArray *showArray;
	NSMutableArray *showNoArray, *arrDeptIDs, *showArray_Searched, *showNoArray_Searched, *arrDeptIDs_Searched,*arrNumberofProducts,*arrNumberofProducts_Search;
	UISearchBar *_searchBar;
	UILabel *lblCart;
}
- (void)fetchDataFromServer;

@end
