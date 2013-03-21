//
//  contentScrollview.m
//  Mobicart
//
//  Copyright (c) 2012 Mobicart. All rights reserved.
//

#import "contentScrollview.h"

@implementation ContentScrollview

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        
        self.zoomScale=1.0;
        self.minimumZoomScale=1.0f;
        self.maximumZoomScale=4.0f;
        self.bounces=NO;
        self.showsHorizontalScrollIndicator=NO;
        self.showsVerticalScrollIndicator=NO;
        self.delegate=self;
        
        //add gesture
        if(!doubleTapGesture)
        {
            doubleTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
            doubleTapGesture.cancelsTouchesInView = NO; 
            doubleTapGesture.delaysTouchesEnded = NO;
            doubleTapGesture.numberOfTouchesRequired = 1; // One finger double tap
            doubleTapGesture.numberOfTapsRequired = 2;   
        }
        [self addGestureRecognizer:doubleTapGesture];
    }
    return self;
}

#pragma mark add imageview to this scrollview
-(void)addImageView:(CustomImageView *)imageView
{
    imgVw=imageView;
    imageView.userInteractionEnabled=YES;
    [self addSubview:imgVw];
}


#pragma mark handleDoubleTap
-(void)handleDoubleTapGesture:(id)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.50]; 
    self.zoomScale=1.0f;
    [UIView commitAnimations];
}


#pragma mark ScrollView Delegates

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imgVw;
}

@end
