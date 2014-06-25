//
//  RetweetViewCell.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/21/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "RetweetViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface RetweetViewCell()

@property (strong, nonatomic)           Tweet  *tweet;
@property (weak, nonatomic) IBOutlet UIButton  *favButton;
@property (weak, nonatomic) IBOutlet UIButton  *retweetButton;


@end

@implementation RetweetViewCell

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
    
    self.screenName.text = [[tweet retweeter] name];
    self.userHandle.text = [NSString stringWithFormat:@"@%@", [[tweet retweeter] screenName] ];
    
    // Bug in iOS-7 UiTextView displays all text as a link
    //http://stackoverflow.com/questions/19121367/uitextviews-in-a-uitableview-link-detection-bug-in-ios-7

    self.tweetText.attributedText = [[NSAttributedString alloc] initWithString:[tweet tweetText]];
    //self.tweetText.text  = [tweet retweetText];
    
    self.timeSince.text  = [tweet timeSinceNow];
    self.retweeterName.text = [ NSString stringWithFormat:@"%@ retweeted", [[tweet creator] screenName]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[[tweet retweeter] profileImageUrl]];
    
    __weak RetweetViewCell *weakCell = self;
    
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
    
    if ([self.tweet checkAndRecordIfFav]) {
        //NSLog(@"inloading tweet cell selecting fav button for tweet %@", self.tweetText.text);
        [self.favButton setSelected:YES];
    } else {
        //NSLog(@"inloading tweet cell un-selecting fav button %@", self.tweetText.text);
        [self.favButton setSelected:NO
         ];
    }
    
    if ([self.tweet checkAndRecordIfRetweeted]) {
        [self.retweetButton setEnabled:NO];
    } else {
        [self.retweetButton setEnabled:YES];
    }

    
}

- (void) configureTweetCellWithTweet:(Tweet *) tweet {
    
    self.screenName.text = [[tweet creator] name];
    self.userHandle.text = [[tweet creator] screenName];
    self.tweetText.attributedText = [[NSAttributedString alloc] initWithString:[tweet tweetText]];
    //self.tweetText.text  = [tweet tweetText];
    self.timeSince.text  = [tweet timeSinceNow];
    self.retweeterName.text = [ NSString stringWithFormat:@"%@ retweeted", [[tweet creator] screenName]];

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
        if ([responseTweet checkAndRecordIfFav]) {
            self.tweet.favorited = YES;
            [favButton setSelected:YES];
            //NSLog(@"selecting fav button");
        } else {
            [favButton setSelected:NO];
            self.tweet.favorited = NO;
            //NSLog(@"Un-selecting fav button");

        }
        //NSLog(@"response object: %@", responseObject);
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
        //NSLog(@"Retweet count %d", [responseTweet retweetCount]);
        
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
    
    //Implement this with nsnotification //

    NSDictionary *replyDetails = @{@"replyTo": replyTo, @"tweetId": tweetId};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Tweet Reply" object:self userInfo:replyDetails];
}
@end
