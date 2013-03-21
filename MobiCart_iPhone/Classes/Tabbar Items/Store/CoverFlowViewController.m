//
//  CoverFlowViewController.m
//  CoverFlow
//
//  Created by Avinash on 4/7/10.
//  Copyright Apple Inc 2010. All rights reserved.
//

#import "CoverFlowViewController.h"
#import "Constants.h"
#import "ProductModel.h"
#import "ProductSingleton.h"
//iProductSingleton *productObj;
@implementation CoverFlowViewController


@synthesize PickerPopover;
@synthesize arrImages, dataForProductImage,tempdic;

//- (void)displayProductImage:(NSMutableArray *)arrImagesUrls picToShowAtAIndex:(NSInteger)_picNum 
//{
//	if ([arrImagesUrls count]==0)
//	{
//		dataForProductImage = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_M" ofType:@"png"]];
//	}
//	else 
//	{
//		dataForProductImage = [ServerAPI fetchBannerImage:[[arrImages objectAtIndex:_picNum] objectForKey:@"productImageCoverFlowIphone4"]];
//	}
//    
//	if (!dataForProductImage)
//	{
//		dataForProductImage = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"noImage_M" ofType:@"png"]];
//	}
//	
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.titleView = [GlobalPreferences createLogoImage];
    
    //    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(callbutton) userInfo:nil repeats:NO];
    
   coverflowBackView=[[UIView alloc] initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0, 0, 320, 400) chageHieght:YES]];
    coverflowBackView.backgroundColor=[UIColor blackColor];
    [self.view addSubview:coverflowBackView];
    
    
    viewAF=[[AFOpenFlowView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0,-15,320,400) chageHieght:YES]];
	viewAF.dataSource=self;
	viewAF.viewDelegate=self;
	[coverflowBackView addSubview:viewAF];
    
    [self LoadCoverflow];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}
#pragma mark LoadCoverflow
-(void)LoadCoverflow
{
    for(int j=0;j<[arrImages  count];j++)
	{
        dataForProductImage= [[iProductSingleton productObj] setProductImage:arrImages picToShowAtAIndex:j];
        UIImage *result=[UIImage  imageWithData:dataForProductImage];
        [viewAF setImage:result forIndex:j];
    }
	[viewAF setNumberOfImages:[arrImages count]];
    
}
-(void)openFlowView: (AFOpenFlowView *)openFlowView selectionDidChange:(int)index
{
    
}

- (void)openFlowView: (AFOpenFlowView *)openFlowView imageSelected:(int)index
{    
    [[iProductSingleton productObj] setProductImage:arrImages picToShowAtAIndex:index];
}

-(void)viewWillAppear:(BOOL)animated
{        
//	[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(hideIndicator) userInfo:nil repeats:YES];	
	[self hideIndicator];
}	
- (void)dealloc 
{
    [super dealloc];
}


-(void)hideIndicator
{
	if (loadingActionSheet1)
    {
        [loadingActionSheet1 dismissWithClickedButtonIndex:0 animated:YES];
    }
}	
@end
