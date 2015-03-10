//
//  iPay88ViewController.m
//  MobicartApp
//
//  Created by NhanLam on 8/28/14.
//  Copyright (c) 2014 Net Solutions. All rights reserved.
//

#import "iPay88ViewController.h"
#import "GlobalPreferences.h"

@interface iPay88ViewController ()

@end

@implementation iPay88ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btnCancel=[[UIButton alloc]init];
    [btnCancel setTitle:[[GlobalPreferences getLangaugeLabels]valueForKey:@"key.iphone.cancel"] forState:UIControlStateNormal];
    [btnCancel.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelView:) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setFrame:CGRectMake(0, 0, 60,36)];
    
    UIBarButtonItem *btnBack=[[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    [btnBack setStyle:UIBarButtonItemStyleBordered];
    [btnCancel release];
    
    [self.navigationItem setLeftBarButtonItem:btnBack];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelView:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
