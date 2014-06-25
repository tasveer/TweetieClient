//
//  LoginViewController.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/19/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"


@interface LoginViewController ()
- (IBAction)login:(id)sender;

@end

@implementation LoginViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [[TwitterClient instance] login ];
}
@end
