//
//  StoreModel.m
//  MobicartApp
//
//  Created by Surbhi Handa on 17/08/12.
//  Copyright (c) 2012 Net Solutions. All rights reserved.
//

#import "StoreModel.h"
#import "Constants.h"
#import "GlobalPreferences.h"
@interface StoreModel ()

@end

@implementation StoreModel

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
BOOL isTryingSecondTime;
- (void)fetchDataFromServer
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    // Fetch data from server
	NSDictionary *dictFeatures = [ServerAPI fetchAllDepartments:iCurrentStoreId];
	
	NSArray *arrTemp  = [dictFeatures objectForKey:@"departments"];
	if (![arrTemp isKindOfClass:[NSNull class]])
	{
		if ([arrTemp count] >0)
		{
			for (NSDictionary *dictFeatures in arrTemp)
            {
				[showArray addObject:[dictFeatures objectForKey:@"sName"]];
				[arrDeptIDs addObject:[dictFeatures objectForKey:@"id"]];
				[showNoArray addObject:[dictFeatures objectForKey:@"iCategoryCount"]];
				[arrNumberofProducts addObject:[dictFeatures objectForKey:@"iProductCount"]];
			}
			
			showArray_Searched = [[NSMutableArray alloc] initWithArray:showArray];
			showNoArray_Searched =[[NSMutableArray alloc] initWithArray:showNoArray];
			arrDeptIDs_Searched = [[NSMutableArray alloc] initWithArray:arrDeptIDs];
			arrNumberofProducts_Search=[[NSMutableArray alloc]initWithArray:arrNumberofProducts];
			
			if(tableView)
            {
                [tableView reloadData];
            }
		}
		else
		{
			if (!isTryingSecondTime)
			{ 
				DLog (@"No Data Available for this Store (StoreViewContoller)  --> TRYING AGAIN TO FETCH DATA ");
				isTryingSecondTime = TRUE;
				[self fetchDataFromServer];
			}
			else
            {
				DLog (@"No Data Available for this Store (StoreViewContoller)");
            }
		}
	}
	else 
	{
		DLog(@"No Data Returned from server (StoreViewContoller)");
	}
	
	[pool release];
	
	// Stoping the loading indicator
	[GlobalPreferences stopLoadingIndicator];
	[GlobalPreferences performSelector:@selector(dismissLoadingBar_AtBottom)];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
