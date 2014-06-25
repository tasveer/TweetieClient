//
//  TweetViewCell.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/20/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface TweetViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel     *screenName;
@property (weak, nonatomic) IBOutlet UILabel     *userHandle;
@property (weak, nonatomic) IBOutlet UILabel     *timeSince;
@property (weak, nonatomic) IBOutlet UITextView  *tweetText;

- (void)loadTweetCellWithTweet:(Tweet *) tweet;
- (void)configureTweetCellWithTweet:(Tweet *) tweet;

- (IBAction)doFavorite:(id)sender;
- (IBAction)doRetweet:(id)sender;
- (IBAction)doReply:(id)sender;

@end
