//
//  MobicartViewController.h
//  MobicartApp
//
//  Created by Mobicart on 14/09/10.
//  Copyright Mobicart 2010. All rights reserved.

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

BOOL isNewsSection;
@interface MobicartViewController : UIViewController <CLLocationManagerDelegate>{

   
}

-(void)loadData;
-(void)locateUser;
@end



