//
//  MoreTableViewDelegate.m
//  MobicartApp
//
//  Created by Mobicart on 16/05/11.
//  Copyright 2011 Mobicart. All rights reserved.
//

#import "MoreTableViewDelegate.h"
#import "Constants.h"
extern 	MobicartAppAppDelegate *_objMobicartAppDelegate;

@implementation MoreTableViewDelegate
@synthesize originalDelegate,isPoweredByMobicart;

-(MoreTableViewDelegate *) initWithDelegate:(id<UITableViewDelegate>) delegate
{
    originalDelegate=delegate;
    [super init];
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath

{   
    if(isPoweredByMobicart==YES)
    {
       return 50; 
    }
	else
  
	{
       return 60; 
    }
	
}	

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
	return [originalDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}	

//Sa Vo fix crash bug when tap on More button on iOS 7.1

- (void) _layoutCells
{
    // HACK ALERT: on iOS 7.1, this method will be called from deep within the bowels of iOS.  The problem is that
    // the method is not implemented and it results in an unrecognized selected crash. So we implement it...
    //
    // What could go wrong?
}
@end
