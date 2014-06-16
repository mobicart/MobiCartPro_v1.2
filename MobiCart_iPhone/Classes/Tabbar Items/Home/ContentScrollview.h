//
//  contentScrollview.h
//  Mobicart
//
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomImageView.h"

@interface ContentScrollview : UIScrollView<UIScrollViewDelegate>
{
    CustomImageView *imgVw;
    UITapGestureRecognizer *doubleTapGesture;
}

-(void)addImageView:(CustomImageView *)imageView;
-(void)handleDoubleTapGesture:(id)sender;
@end
