//
//  ProfileViewController.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/29/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(User *) user;

-(void) setProfileUser:(User *)user;

-(User *)getProfileUser;

@end
