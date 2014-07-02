//
//  ProfileHeaderPagingCell.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/30/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"


@interface ProfileHeaderPagingCell : UITableViewCell <UIScrollViewDelegate>

@property (strong, nonatomic) User *userProfile;

- (void) loadProfileHeaderWithUser:(User *) user;

@end
