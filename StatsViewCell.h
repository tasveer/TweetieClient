//
//  StatsViewCell.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/29/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface StatsViewCell : UITableViewCell

- (void) loadStatsForUser:(User *)use;

@end
