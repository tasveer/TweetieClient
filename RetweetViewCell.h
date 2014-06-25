//
//  RetweetViewCell.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/21/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface RetweetViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView  *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel      *screenName;
@property (weak, nonatomic) IBOutlet UILabel      *userHandle;
@property (weak, nonatomic) IBOutlet UITextView   *tweetText;
@property (weak, nonatomic) IBOutlet UILabel      *retweeterName;
@property (weak, nonatomic) IBOutlet UILabel      *timeSince;

- (void) loadTweetCellWithTweet:(Tweet *) tweet;
- (void) configureTweetCellWithTweet:(Tweet *) tweet;

- (IBAction)doFavorite:(id)sender;
- (IBAction)doRetweet:(id)sender;
- (IBAction)doReply:(id)sender;

@end
