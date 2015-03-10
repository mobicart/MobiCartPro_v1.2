//
//  ReadReviewsViewController.m
//  MobicartApp
//
//  Created by Mobicart on 12/17/10.
//  Copyright 2010 Mobicart. All rights reserved.
//

#import "ReadReviewsViewController.h"
#import "Constants.h"

@implementation ReadReviewsViewController

@synthesize selectedProductId,arrReviews,yValue;



- (void)viewWillAppear:(BOOL)animated
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

	if(yValue)
		[yValue removeAllObjects];
	
	[self performSelectorInBackground:@selector(fetchDataFromServer) withObject:nil];
	
	[self hideBar];
}

- (void)hideBar
{
	[GlobalPreferences performSelector:@selector(dismissLoadingBar_AtBottom)];
}

- (void)removeLoadingLabel
{
	UIView *viewTopBar = (UIView *)[self.view viewWithTag:11111];
	UILabel *lblLoading = (UILabel *)[viewTopBar viewWithTag:123];
	[lblLoading setHidden:TRUE];
}

- (void)addNoReviewLabel
{
	UILabel *lblNoReview=[[UILabel alloc]initWithFrame:CGRectMake(10, 70, 310, 30)];
	[lblNoReview setBackgroundColor:[UIColor clearColor]];
//	[lblNoReview setText:@"No reviews added."];
	[lblNoReview setText:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.read.reviews.no.review"]];
	[lblNoReview setTextColor:[UIColor blackColor]];
	[lblNoReview setTextAlignment:UITextAlignmentCenter];
	[lblNoReview setFont:[UIFont boldSystemFontOfSize:14]];
	[self.view addSubview:lblNoReview];
	[lblNoReview release];
}
	


- (void)setLabelNames:(NSDictionary *)dictProduct
{
	[lblProductName setText:[[dictProduct valueForKey:@"sName"] uppercaseString]];
    if ([[dictProduct valueForKey:@"productReviews"]count]>1)
    {
        [lblReviewCount setText:[NSString stringWithFormat:@"%d %@",[[dictProduct valueForKey:@"productReviews"]count],[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.reviews.reviews"]]];
    }
    else
    {
        [lblReviewCount setText:[NSString stringWithFormat:@"%d %@",[[dictProduct valueForKey:@"productReviews"]count],[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.reviews.reviews"]]];
    }
}

- (void)fetchDataFromServer
{
	NSDictionary *dictProductDetails = [[ServerAPI fetchDetailsOfProductWithID:selectedProductId] objectForKey:@"product"];
    
    productId=[[dictProductDetails valueForKey:@"id"]intValue] ;
    
    [self performSelectorOnMainThread:@selector(markStarRating:) withObject:dictProductDetails waitUntilDone:YES];
	
    [self performSelectorOnMainThread:@selector(setLabelNames:) withObject:dictProductDetails waitUntilDone:YES];
	
    self.arrReviews = [dictProductDetails valueForKey:@"productReviews"];
	
	if ([self.arrReviews count]) 
	{
		if(tblReviews)
			[tblReviews removeFromSuperview];
		
		tblReviews = [[UITableView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(-10,57, 345,296) chageHieght:YES] style:UITableViewStyleGrouped];
		[tblReviews setDelegate:self];
		[tblReviews setDataSource:self];
		[tblReviews setTag:12321];
        tblReviews.backgroundView=nil;
		[tblReviews setBackgroundColor:[UIColor clearColor]];
		[self.view addSubview:tblReviews];
		[tblReviews setSeparatorColor:[UIColor darkGrayColor]];
        [tblReviews reloadData];
		[self.view bringSubviewToFront:[self.view viewWithTag:11111]];
	}
	else 
    {
        [self performSelectorOnMainThread:@selector(addNoReviewLabel) withObject:nil waitUntilDone:YES];
    }
	[GlobalPreferences dismissLoadingBar_AtBottom];
}

- (void)markStarRating:(NSDictionary*)dicProduct
{
	int xValue=9;
	float rating=0.0;
	
	NSDictionary *dictProducts = [ServerAPI fetchDetailsOfProductWithID:[[dicProduct valueForKey:@"id"]intValue]];

	if (![dictProducts isKindOfClass:[NSNull class]])
    {
        if ([[[dictProducts valueForKey:@"product"]valueForKey:@"fAverageRating"] isEqual:[NSNull null]])
        {
            rating = 0.0;
        }
		else
        {
            rating = [[[dictProducts valueForKey:@"product"]valueForKey:@"fAverageRating"] floatValue];
        }
    }
		
	float tempRating;
	tempRating=floor(rating);
	tempRating=rating-tempRating;
	UIView *viewTemp=(UIView *)[self.view viewWithTag:11111];
    
	for(int i=0; i<5; i++)
	{
		imgRatingsTempMain[i] = [[[UIImageView alloc] initWithFrame:CGRectMake( xValue,11, 19, 17)] autorelease];
        imgRatingsTempMain[i].clipsToBounds = TRUE;
		[imgRatingsTempMain[i] setImage:[UIImage imageNamed:@"grey_star1.png"]];
		[imgRatingsTempMain[i] setBackgroundColor:[UIColor clearColor]];
        [viewTemp addSubview:imgRatingsTempMain[i]];
		
		xValue += 20;
	}
	
	int iTemp =0;
	
	for(int i=0; i<abs(rating) ; i++)
	{
		viewRatingBGMain[i] = [[[UIView  alloc] initWithFrame:CGRectMake(0, 0, 20, 20)] autorelease];
		[viewRatingBGMain[i] setBackgroundColor:[UIColor clearColor]];
		[imgRatingsTempMain[i] addSubview:viewRatingBGMain[i]];
		imgRatingsMain[i] = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 17)] autorelease];
		[imgRatingsMain[i] setImage:[UIImage imageNamed:@"yellow_star1.png"]];
		[imgRatingsTempMain[i] addSubview:imgRatingsMain[i]];
		iTemp = i;
	}
	
	if (tempRating>0)
	{
		int iLastStarValue = 0;
		if (rating >=1.0)
        {
            iLastStarValue = iTemp + 1;
        }
			       
        viewRatingBGMain[iLastStarValue] = [[[UIView  alloc] initWithFrame:CGRectMake(0, 0, tempRating * 20, 20)] autorelease];
        viewRatingBGMain[iLastStarValue].clipsToBounds = TRUE;
        [imgRatingsTempMain[iLastStarValue] addSubview:viewRatingBGMain[iLastStarValue]];
        imgRatingsMain[iLastStarValue] = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 19, 17)] autorelease];
        [imgRatingsMain[iLastStarValue] setImage:[UIImage imageNamed:@"yellow_star1.png"]];
        [viewRatingBGMain[iLastStarValue] addSubview:imgRatingsMain[iLastStarValue]];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
	
	isReadReviews=NO;	
}

- (void)popViewRoot
{
	[self.navigationController popToRootViewControllerAnimated:NO];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	self.navigationItem.titleView = [GlobalPreferences createLogoImage];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popViewRoot) name:@"popViewControllerRead" object:nil];
	self.view.backgroundColor=navBarColorPreference;
	
	UIImageView *imgBg=[[UIImageView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0,60, 320,480) chageHieght:YES]];
	[imgBg setImage:[UIImage imageNamed:@"product_details_bg.png"]];
	[self.view addSubview:imgBg];
	[imgBg release];
	
	yValue=[[NSMutableArray alloc] init];
	
	UIView *viewProductNameBar=[[UIView alloc]initWithFrame:CGRectMake(0,0, 320, 31)];
	[viewProductNameBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"barNews.png"]]];
 	[self.view addSubview:viewProductNameBar];	
    
    lblProductName=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 310, 25)];
	[lblProductName setBackgroundColor:[UIColor clearColor]];
	[lblProductName setTextColor:[UIColor whiteColor]];
	[lblProductName setFont:[UIFont boldSystemFontOfSize:12]];
	[viewProductNameBar addSubview:lblProductName];
	[viewProductNameBar release];

    UIView *viewTopBar=[[UIView alloc]initWithFrame:CGRectMake(0,29 ,320 ,40)];
   	[viewTopBar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bottom_bar.png"]]];
    [viewTopBar setTag:11111];
    [self.view addSubview:viewTopBar];
	
	
	UIButton *btnPostReview=[UIButton buttonWithType:UIButtonTypeCustom];
    [btnPostReview setFrame:CGRectMake(232,8, 83,25)];
    [btnPostReview setBackgroundImage:[UIImage imageNamed:@"write_review.png"] forState:UIControlStateNormal];
	[btnPostReview setTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.reviews.writereview"] forState:UIControlStateNormal];
	[btnPostReview.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    [btnPostReview addTarget:self action:@selector(navigateToPostReview) forControlEvents:UIControlEventTouchUpInside];
	[viewTopBar addSubview:btnPostReview];
    
    lblReviewCount=[[UILabel alloc]initWithFrame:CGRectMake(131,8,100, 25)];
	[lblReviewCount setBackgroundColor:[UIColor clearColor]];
	[lblReviewCount setTextColor:[UIColor whiteColor]];
	[lblReviewCount setFont:[UIFont boldSystemFontOfSize:14]];
	[viewTopBar addSubview:lblReviewCount];
    [viewTopBar release];
	[super viewDidLoad];
}

- (void)navigateToPostReview
{
	if ([[GlobalPreferences getUserDefault_Preferences:@"userEmail"] length]==0)
	{
		DetailsViewController *_details = 	[[DetailsViewController alloc] init];
		_details.isReview=YES;
		[self.navigationController pushViewController:_details animated:YES];
		[_details release];
	}
	else 
	{
		PostReviewsViewController *objPost = [[PostReviewsViewController alloc] init];
		[self.navigationController pushViewController:objPost animated:YES];
		objPost.productId =productId;
		[objPost release];
	}
}	

- (void)back
{    
	isReadReviews=NO;
	[[self navigationController]popViewControllerAnimated:YES];
}


#pragma mark tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *titleString = [[self.arrReviews objectAtIndex:indexPath.row] objectForKey:@"sReveiwerName"];
   	NSString *detailString = [[self.arrReviews objectAtIndex:indexPath.row] valueForKey:@"sReview"];
    detailString=[self replaceCharacters:detailString];
	
	CGSize titleSize = [titleString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0] constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
	CGSize detailSize = [detailString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0] constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    NSNumber *yValueTemp=[NSNumber numberWithInt:detailSize.height+titleSize.height+10];
	[yValue addObject:yValueTemp];
    
	return detailSize.height+titleSize.height+38;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.arrReviews count];	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *CellIdentifier =[NSString stringWithFormat:@"Cell%d",indexPath.row];

	TableViewCell_Common *cell =  (TableViewCell_Common *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell==nil)
	{
		cell = [[[TableViewCell_Common alloc] initWithRatingsAndReviewStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		[cell setPosition:CustomCellBackgroundViewPositionMiddle];
		
		
		NSString *titleString = [[self.arrReviews objectAtIndex:indexPath.row] objectForKey:@"sReveiwerName"];
		NSString *detailString = [[self.arrReviews objectAtIndex:indexPath.row] valueForKey:@"sReview"];
        detailString = [self replaceCharacters:detailString];
		
		CGSize titleSize = [titleString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:14.0] constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
		CGSize detailSize = [detailString sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0] constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
		
		UIImageView *imgCellBackground=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0,320,detailSize.height+titleSize.height+37)];
		[imgCellBackground setImage:[UIImage imageNamed:@"shoppingcart_bar_stan.png"]];
		[imgCellBackground setTag:121212];
       [cell setBackgroundView:imgCellBackground];
		[imgCellBackground release];

        
		NSString *strText = [[self.arrReviews objectAtIndex:indexPath.row] valueForKey:@"sReview"];
		if ([strText isEqualToString:@"(null)"])
		{
			strText = @"";
		}
		
        strText=[self replaceCharacters:strText];
		
		CGSize size=[[[self.arrReviews objectAtIndex:indexPath.row] objectForKey:@"sReveiwerName"] sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:13.0] constrainedToSize:CGSizeMake(300, MAXFLOAT)];
		
		UILabel *lblName = [[UILabel alloc]initWithFrame:CGRectMake(20, 9, 300,size.height)];
		[lblName setBackgroundColor:[UIColor clearColor]];
		[lblName setNumberOfLines:0];
		lblName.text = [NSString stringWithFormat:@"%@ %@",[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.read.reviews.by"] , [[self.arrReviews objectAtIndex:indexPath.row] objectForKey:@"sReveiwerName"]];
		lblName.font =[UIFont fontWithName:@"Helvetica-Bold" size:13.0];	
		[cell addSubview:lblName];
		
		CGSize size1=[strText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0] constrainedToSize:CGSizeMake(300, MAXFLOAT)];
		UILabel *lblDetail = [[UILabel alloc]initWithFrame:CGRectMake(20,lblName.frame.size.height+lblName.frame.origin.y-1, 300,size1.height)];
		[lblDetail setBackgroundColor:[UIColor clearColor]];
		lblDetail.text = strText;
		lblDetail.textColor = _savedPreferences.labelColor;
	//	[UIColor colorWithRed:24/100 green:24/100 blue:24/100 alpha:1.0];
		lblDetail.font =[UIFont fontWithName:@"Helvetica" size:12.0];
		
		lblDetail.numberOfLines = ceilf([strText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12.0] constrainedToSize:CGSizeMake(300, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap].height/20.0);
		[cell addSubview:lblDetail];
		
		[lblName release];
		[lblDetail release];
		
		int xValue=19;
		int rate = [[[arrReviews objectAtIndex:indexPath.row] valueForKey:@"iRating"] intValue];
		
		UIImageView *imgRatings[5];
		int yValueCell=0;
		
		for(int i = 0; i < 5; i++)
		{   
			yValueCell=[[yValue objectAtIndex:indexPath.row]intValue];
			imgRatings[i] =[[UIImageView alloc] initWithFrame:CGRectMake(xValue,yValueCell+2,15,15)];
			
			if (i<rate)
			{
				[imgRatings[i] setImage:[UIImage imageNamed:@"yellow_star_review.png"]];
			}
			else
			{
				[imgRatings[i] setImage:[UIImage imageNamed:@"grey_star_review.png"]];
			}
			
			[cell addSubview:imgRatings[i]];
			[imgRatings[i] release];
			
			xValue +=18;
		}
	}		
	return cell;
}

-(NSString *)replaceCharacters:(NSString *)strText
{
    strText = [strText stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    strText = [strText stringByReplacingOccurrencesOfString:@"--" withString:@"%"];
    strText = [strText stringByReplacingOccurrencesOfString:@"__" withString:@"#"];
    strText = [strText stringByReplacingOccurrencesOfString:@"$$$" withString:@"\""];
    strText = [strText stringByReplacingOccurrencesOfString:@"per5B" withString:@"["];
    strText = [strText stringByReplacingOccurrencesOfString:@"per5D" withString:@"]"];
    strText = [strText stringByReplacingOccurrencesOfString:@"per7B" withString:@"{"];
    strText = [strText stringByReplacingOccurrencesOfString:@"per7D" withString:@"}"];
    strText = [strText stringByReplacingOccurrencesOfString:@"%253C" withString:@"<"];
    strText = [strText stringByReplacingOccurrencesOfString:@"%253E" withString:@">"];
    
    return strText;
}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	//[]
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{   
	isReadReviews=NO;

	[lblProductName release];
	[arrReviews release];
    [lblReviewCount release];
    [yValue release];
    [super dealloc];
}


@end
