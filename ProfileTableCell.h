//
//  ProfileTableCell.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/28/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userScreenName;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

- (void) loadProfileForUser:(User *) user;

@end
