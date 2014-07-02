//
//  TweetViewCell.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/20/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "TweetViewCell.h"
#import "UIImageView+AFNetworking.h"
//#import "ComposeViewController.h"
#import "ProfileViewController.h"

@interface TweetViewCell()
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UILabel *numOfFavLabel;

@property (weak, nonatomic) IBOutlet UILabel *numOfRetweetLabel;
@property (strong, nonatomic)        Tweet    *tweet;
@property (nonatomic)                BOOL     favorited;

- (IBAction)onImageTap:(UITapGestureRecognizer *)sender;

@end

@implementation TweetViewCell



- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) loadTweetCellWithTweet:(Tweet *) tweet {
 
    self.screenName.text = [[tweet creator] name];
    self.userHandle.text = [NSString stringWithFormat:@"@%@", [[tweet creator] screenName] ];
    
    // Bug in iOS-7 UiTextView displays all text as a link
    //http://stackoverflow.com/questions/19121367/uitextviews-in-a-uitableview-link-detection-bug-in-ios-7
    
    self.tweetText.text = nil;
    self.tweetText.attributedText = [[NSAttributedString alloc] initWithString:[tweet tweetText]];
    self.tweetText.linkTextAttributes  = @{NSForegroundColorAttributeName:[UIColor blueColor]};

    //NSLog(@"Loading tweet with text: %@", self.tweetText.text);
    self.timeSince.text  = [tweet timeSinceNow];

    self.numOfFavLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[tweet favoriteCount]];
    self.numOfRetweetLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[tweet numOfRetweets]];

    
    NSURLRequest *request = [NSURLRequest requestWithURL:[[tweet creator] profileImageUrl]];
    
    __weak TweetViewCell *weakCell = self;
    
    [self.profileImageView setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              
                                              [UIView transitionWithView:weakCell.profileImageView
                                                                duration:0.3
                                                                 options:UIViewAnimationOptionTransitionCrossDissolve
                                                              animations:^{
                                                                  weakCell.profileImageView.image = image;
                                                              }
                                                              completion:NULL];
                                              
                                              [weakCell setNeedsLayout];
                                              
                                          } failure:nil];
    self.tweet = tweet;
    
    if ([self.tweet favorited]) {
        [self.favButton setSelected:YES];
    } else {
        [self.favButton setSelected:NO];
    }
        
    if ([self.tweet checkAndRecordIfRetweeted]) {
        [self.retweetButton setEnabled:NO];
    } else {
        [self.retweetButton setEnabled:YES];
    }
    
    UITapGestureRecognizer *tapGesturerecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageTap:)];
    
    tapGesturerecognizer.numberOfTapsRequired = 1;
    [self.profileImageView addGestureRecognizer:tapGesturerecognizer];

}

- (void) configureTweetCellWithTweet:(Tweet *) tweet {
    
    self.screenName.text = [[tweet creator] name];
    self.userHandle.text = [[tweet creator] screenName];
    
    // Bug in iOS-7 UiTextView displays all text as a link
    //http://stackoverflow.com/questions/19121367/uitextviews-in-a-uitableview-link-detection-bug-in-ios-7
    
    self.tweetText.text = nil;
    self.tweetText.attributedText = [[NSAttributedString alloc] initWithString:[tweet tweetText]];
    //NSLog(@"Configuring tweet with text: %@", self.tweetText.text);

    self.timeSince.text  = [tweet timeSinceNow];
    self.numOfFavLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[tweet favoriteCount]];
    self.numOfRetweetLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[tweet numOfRetweets]];
    
    return;
}

- (IBAction)doFavorite:(id)sender {
    UIButton *favButton = (UIButton *) sender;
    //BOOL wasFavorited = [self.tweet favorited];
    //NSLog(@"Calling fav");
    
    [self.tweet makeFavoritesWithsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Mark the tweet as favorited by changing the state of the passed button
        Tweet *responseTweet = [Tweet tweetFromJson:responseObject];
        // Check if the response is favorited/unfavorited
        if ([responseTweet favorited]) {
            self.tweet.favorited = YES;
            [favButton setSelected:YES];
        } else {
            [favButton setSelected:NO];
            self.tweet.favorited = NO;
        }
        self.tweet.rawTweet = [responseTweet rawTweet];
        self.numOfFavLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[responseTweet favoriteCount]];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"Tweet Favorited" object:self];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Throw an error or perhaps do nothing
        NSLog(@"Could not perform fav/unfav %@", [error description]);
    }];
}

- (IBAction)doRetweet:(id)sender {
    UIButton *retweetButton = (UIButton *) sender;
    
    [self.tweet retweetWithsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Mark the tweet as favorited by changing the state of the passed button
        Tweet *responseTweet = [Tweet tweetFromJson:responseObject];
        // Check if the response is favorited/unfavorited
        [retweetButton setEnabled:NO];
        self.tweet.retweetCount = responseTweet.retweetCount;
        self.tweet.rawTweet = [responseTweet rawTweet];
        NSLog(@"Retweet count %d", [responseTweet retweetCount]);

        self.numOfRetweetLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[responseTweet numOfRetweets]];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"Retweetted" object:self];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Throw an error or perhaps do nothing
        NSLog(@"Could not retweet %@", [error description]);
    }];
}

- (IBAction)doReply:(id)sender {
    
    NSString *replyTo = self.tweet.retweetedAt ?
    [NSString stringWithFormat:@"@%@ @%@", [[self.tweet creator] screenName], [[self.tweet retweeter] screenName]] :
    [NSString stringWithFormat:@"@%@",[[self.tweet creator] screenName]];
    //NSLog(@"Replying to tweet with %@", replyTo);
    
    NSString *tweetId;
    
    if (self.tweet.retweetedAt == nil) {
        tweetId = self.tweet.rawTweet[@"id_str"];
    } else {
        NSDictionary *retweetedStatus = self.tweet.rawTweet[@"retweeted_status"];
        tweetId = retweetedStatus[@"id_str"];
    }
    
    NSDictionary *replyDetails = @{@"replyTo": replyTo, @"tweetId": tweetId};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Tweet Reply" object:self userInfo:replyDetails];
}

- (void)onImageTap:(UITapGestureRecognizer *)tapGesture {
    
    NSDictionary *tweeterDetail = @{@"Tweeter": self.tweet.creator};

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Show Tweeters Profile" object:self userInfo:tweeterDetail];
}
@end
