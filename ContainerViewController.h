//
//  ContainerViewController.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/26/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContainerViewController : UIViewController

@property (strong, nonatomic) UIViewController *menuViewController;
@property (strong, nonatomic) UIViewController *currentViewController;

- (void) addContainerViewController:(UIViewController *) viewController;

@end
