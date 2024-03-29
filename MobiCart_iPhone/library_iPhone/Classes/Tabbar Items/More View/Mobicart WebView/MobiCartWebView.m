    //
//  MobiCartWebView.m
//  MobicartApp
//
//  Created by Mobicart on 12/11/10.
//  Copyright 2010 Mobicart. All rights reserved.
//

#import "MobiCartWebView.h"

@implementation MobiCartWebView

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
    {
        // Custom initialization
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"copyright_logo.png"]];
	self.navigationItem.titleView = imgView;
	[imgView release];
	
	UIWebView *mobiCartWebView = [[[UIWebView alloc]initWithFrame:[GlobalPreferences setDimensionsAsPerScreenSize:CGRectMake(0, 0, 320, 380) chageHieght:YES]] autorelease];
	[mobiCartWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.mobi-cart.com"]]];
	[mobiCartWebView setScalesPageToFit:YES];
	[mobiCartWebView setDelegate:self];
	[self.view addSubview:mobiCartWebView];
	
	[GlobalPreferences addLoadingIndicator_OnView:self.view];
	[GlobalPreferences startLoadingIndicator];
	
    [super viewDidLoad];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[GlobalPreferences stopLoadingIndicator];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[GlobalPreferences stopLoadingIndicator];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if([[UIApplication sharedApplication] isNetworkActivityIndicatorVisible])
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"poweredByMobicart" object:nil];
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
	
    [super dealloc];
}


@end
