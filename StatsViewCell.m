//
//  StatsViewCell.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/29/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "StatsViewCell.h"
#import "User.h"

@interface StatsViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *tweetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;

@end

@implementation StatsViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) loadStatsForUser:(User *)user {

    if (user) {
        
        int numTweets = [[ user numTweets] intValue];
        NSString *numTweetString = [self abbreviateNumber:numTweets withDecimal:2];
        
        int numFollowers = [[ user numFollowers] intValue];
        NSString *numFollowersString = [self abbreviateNumber:numFollowers withDecimal:2];
        
        //NSLog(@"num following: %@", [user numFollowing]);
        int numFollowing = [[ user numFollowing] intValue];
        
        NSString *numFollowingString = [self abbreviateNumber:numFollowing withDecimal:2];
        
        if (numTweetString == nil) {
            self.tweetsLabel.text =    [NSString stringWithFormat:@"%@", [user numTweets]];
        } else {
            self.tweetsLabel.text =    [NSString stringWithFormat:@"%@",numTweetString ];
        }
        if (numFollowersString == nil) {
            self.followersLabel.text = [NSString stringWithFormat:@"%@", [user numFollowers]];
        } else {
            self.followersLabel.text = [NSString stringWithFormat:@"%@",numFollowersString ];
        }
        if (numFollowingString == nil) {
            self.followingLabel.text = [NSString stringWithFormat:@"%@", [user numFollowing]];
        } else {
            self.followingLabel.text = [NSString stringWithFormat:@"%@",numFollowingString ];
        }
    }
}

#pragma Large Number Abbreviation

-(NSString *)abbreviateNumber:(int)num withDecimal:(int)dec {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    NSArray *abbrev = @[@"K", @"M", @"B"];
    
    for (int i = abbrev.count - 1; i >= 0; i--) {
        
        // Convert array index to "1000", "1000000", etc
        int size = pow(10,(i+1)*3);
        
        if(size <= number) {
            // Here, we multiply by decPlaces, round, and then divide by decPlaces.
            // This gives us nice rounding to a particular decimal place.
            number = round(number*dec/size)/dec;
            
            NSString *numberString = [self floatToString:number];
            
            // Add the letter for the abbreviation
            abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            
            //NSLog(@"%@", abbrevNum);
            
        }
        
    }
    
    
    return abbrevNum;
}

- (NSString *) floatToString:(float) val {
    
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48 || c == 46) { // 0 or .
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
    }
    
    return ret;
}

@end
