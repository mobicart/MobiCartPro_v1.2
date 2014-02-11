//
//  MoreTableViewDataSource.m
//  MobicartApp
//
//  Created by Mobicart on 08/04/11.
//  Copyright 2011 Mobicart. All rights reserved.
//

#import "MoreTableViewDataSource.h"
#import "Constants.h"
#import "MobicartAppAppDelegate.h"


@implementation MoreTableViewDataSource
@synthesize originalDataSource;
@synthesize isMobicartBrand;

-(MoreTableViewDataSource *) initWithDataSource:(id<UITableViewDataSource>) dataSource
{
    originalDataSource = dataSource;
    [super init];
    
    return self;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [originalDataSource tableView:table numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MobicartAppAppDelegate *appDelegate = (MobicartAppAppDelegate *)[UIApplication sharedApplication].delegate;
    
    // UITableViewCell *cell = [originalDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    // cell.textLabel.textColor=[UIColor darkGrayColor];
	cell.textLabel.textColor=_savedPreferences.headerColor;
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:15]];
    
    cell.backgroundColor=cellBackColor;
    
    //Sa Vo fix bug display wrong titles of More pages on iOS 7.0
    cell.textLabel.text = [appDelegate.arrMoreTitles objectAtIndex:indexPath.row];
    
    /*
    NSDictionary *dictTemp = [appDelegate.arrAllData objectAtIndex:indexPath.row];
	
	NSString *strBool = [dictTemp objectForKey:@"sTitle"];
    
    cell.textLabel.text = strBool;
     */
    
	UIImageView *imgCellBackground=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320,60)];
	if(isMobicartBrand==YES)
	{
		[imgCellBackground setFrame:CGRectMake(0, 0, 320,50)];
		[imgCellBackground setImage:[UIImage imageNamed:@"320-50.png"]];
	}
	else
	{
		[imgCellBackground setImage:[UIImage imageNamed:@"320-60.png"]];
        
	}
	[cell setBackgroundView:imgCellBackground];
	[imgCellBackground release];
	
    if(indexPath.row < 4)
    {
        //Sa Vo fix bug display wrong titles of More pages

        /*
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"more_icon_0%d.png",indexPath.row + 1]];
         */
        if([cell.textLabel.text isEqualToString:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.more.aboutus"]])
        {
            [cell.imageView setImage:[UIImage imageNamed:@"more_icon_01.png"]];
        }
        else if([cell.textLabel.text isEqualToString:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.more.contactus"]])
        {
            [cell.imageView setImage:[UIImage imageNamed:@"more_icon_02.png"]];
            
        }
        else if([cell.textLabel.text isEqualToString:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.more.tandc"]])
        {
            [cell.imageView setImage:[UIImage imageNamed:@"more_icon_03.png"]];
            
        }
        else if([cell.textLabel.text isEqualToString:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.more.privacy"]])
        {
            [cell.imageView setImage:[UIImage imageNamed:@"more_icon_04.png"]];
            
        }
        else
        {
            [cell.imageView setImage:[UIImage imageNamed:@"info.png"]];
            
        }

    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"info.png"]];
    }
    
	UIImageView *imgViewCellAcccesory=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"arrow.png"]];
	[cell setAccessoryView:imgViewCellAcccesory];
	[imgViewCellAcccesory release];
	
	[cell setAccessoryType:UITableViewCellAccessoryNone];
	return cell;
}

@end
