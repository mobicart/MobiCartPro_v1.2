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
    
    //UITableViewCell *cell = [originalDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    
    //NSString *title = cell.textLabel.text;
    
    UITableViewCell *cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
    
    UIImageView *iconView = [[[UIImageView alloc] init] autorelease];
    [cell.contentView addSubview:iconView];
    
    UILabel *lblTitle = [[[UILabel alloc] init] autorelease];
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor=_savedPreferences.headerColor;
    [lblTitle setFont:[UIFont boldSystemFontOfSize:15]];

    [cell.contentView addSubview:lblTitle];
    
    cell.backgroundColor=cellBackColor;
    
    //Sa Vo fix bug display wrong titles of More pages on iOS 7.0
    lblTitle.text = [appDelegate.arrMoreTitles objectAtIndex:indexPath.row];

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

    UIImage *icon = nil;
    if(indexPath.row < 4)
    {
        //Sa Vo fix bug display wrong titles of More pages
        
        if([lblTitle.text isEqualToString:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.more.aboutus"]])
        {
            icon = [UIImage imageNamed:@"more_icon_01.png"];
        }
        else if([lblTitle.text isEqualToString:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.more.contactus"]])
        {
            icon = [UIImage imageNamed:@"more_icon_02.png"];

            
        }
        else if([lblTitle.text isEqualToString:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.more.tandc"]])
        {
            icon = [UIImage imageNamed:@"more_icon_03.png"];
            
        }
        else if([lblTitle.text isEqualToString:[[GlobalPreferences getLangaugeLabels] valueForKey:@"key.iphone.more.privacy"]])
        {
            icon = [UIImage imageNamed:@"more_icon_04.png"];
            
        }
        else
        {
            icon = [UIImage imageNamed:@"info.png"];
            
        }
    }
    else
    {
        icon = [UIImage imageNamed:[NSString stringWithFormat:@"info.png"]];
    }
    
    [iconView setImage:icon];
    
    iconView.frame = CGRectMake(15.0, 20.0, icon.size.width, icon.size.height);
    
    lblTitle.frame = CGRectMake(60.0, 20.0, 200.0, 20);
    
	UIImageView *imgViewCellAcccesory=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mobicart-arrow.png"]];
	[cell setAccessoryView:imgViewCellAcccesory];
	[imgViewCellAcccesory release];
    
    /*
    cell.textLabel.textColor=_savedPreferences.headerColor;
   [cell.textLabel setFont:[UIFont boldSystemFontOfSize:15]];
    
    cell.backgroundColor=cellBackColor;
    
   //Sa Vo fix bug display wrong titles of More pages on iOS 7.0
    cell.textLabel.text = [appDelegate.arrMoreTitles objectAtIndex:indexPath.row];
    
    
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
	*/
    
	[cell setAccessoryType:UITableViewCellAccessoryNone];
    

	return cell;
}

@end
