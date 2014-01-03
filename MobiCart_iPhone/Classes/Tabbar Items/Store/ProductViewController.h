//
//  ProductViewController.h
//  MobiCart
//
//  Created by Mobicart on 8/4/10.
//  Copyright 2010 Mobicart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "IconDownloader.h"
#import "AppRecord.h"
extern BOOL isCatogeryEmpty;

@interface ProductViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIScrollViewDelegate,IconDownloaderDelegate>{
    
	UIView *contentView;
	UITableView *productTableView;
	UISearchBar *_searchBar;
    UIButton *loadMoreProducts;
	
	NSArray *arrAllData; // Array to store all dictionaries
	
    
	NSMutableDictionary *dictProductNames;
	
	// Sort Descriptors
	NSSortDescriptor *nameDescriptor,*priceDescriptor,*statusDescriptor;
	NSMutableDictionary *dict;
	NSMutableArray* arrSearch;
	NSString *sTaxType;
	
	NSMutableArray *arrAppRecordsAllEntries;
	NSMutableDictionary *imageDownloadsInProgress;
    UIButton *loadMoreProductsBtn;
	
	NSMutableArray *arrTempProducts;
	UIImageView *imgRatingsTemp[5], *imgRatings[5];
	UIView *viewRatingBG[5];
	UIButton *btnStore;
    UIActivityIndicatorView *loadingIndicator;
}

@property (nonatomic, retain) NSMutableArray *arrAppRecordsAllEntries;
@property (nonatomic, retain) NSString *sTaxType;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSMutableArray *arrTempProducts;
@property (nonatomic, retain) UIButton *loadMoreProductsBtn;
@property (nonatomic, retain)UITableView *productTableView;
@property (nonatomic, retain)UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain)UIImageView *loadingView;

- (void)markStarRating:(UITableViewCell *)cell :(int)index;
- (void)startIconDownload:(AppRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath;
- (void)appImageDidLoad:(NSIndexPath *)indexPath;

- (void)createSubViewsAndControls;
- (void)createTableView;
- (void)allocateMemoryToObjects;
- (void)sortingHandlers;
- (void)fetchDataFromServer;



-(void)showLoadingIndicator;
-(void)hideLoadingIndicator;

@end
