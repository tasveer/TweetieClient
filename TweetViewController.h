//
//  TweetViewController.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/21/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface TweetViewController : UIViewController

@property (strong, nonatomic) Tweet *tweet;

- (void)loadTweetViewWithTweet:(Tweet *) tweet;

- (void)reply:(UIButton *)sender;
- (IBAction)retweet:(UIButton *)sender;
- (IBAction)favorite:(UIButton *)sender;

@end
