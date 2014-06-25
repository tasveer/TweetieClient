//
//  TweetViewController.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/21/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "TweetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+DateTools.h"
#import "TwitterClient.h"
#import "ComposeViewController.h"


@interface TweetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIView      *retweetView;
@property (weak, nonatomic) IBOutlet UILabel     *retweetLabel;
@property (weak, nonatomic) IBOutlet UILabel     *creatorName;
@property (weak, nonatomic) IBOutlet UILabel     *creatorText;
@property (weak, nonatomic) IBOutlet UITextView  *tweetText;
@property (weak, nonatomic) IBOutlet UILabel     *tweetTime;
@property (weak, nonatomic) IBOutlet UILabel     *tweetDate;
@property (weak, nonatomic) IBOutlet UILabel     *retweetCount;
@property (weak, nonatomic) IBOutlet UILabel     *favCount;
@property (weak, nonatomic) IBOutlet UIButton    *favButton;
@property (nonatomic)                BOOL        favorited;
@property (nonatomic)                BOOL        changed;  // Marks if user made any change, like fav/unfav, or retweet


@end

@implementation TweetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeView];
    [self loadTweetViewWithTweet:self.tweet];
    
}

- (void) initializeView {
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(resignViewController:)];
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *replyButton = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(reply:)];
    [replyButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = replyButton;
    
    self.changed = NO;
    
    return;
}

- (void) resignViewController:(id)sender {
    
    if (self.changed == NO) {
        //NSLog(@"No changes occured in tweet view");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"No Activity" object:self];
    }

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadTweetViewWithTweet:(Tweet *) tweet {
    if (tweet.retweetedAt == nil) {
        [self.retweetView setAlpha:0.0];
        self.creatorName.text = [[tweet creator] name];
        self.creatorText.text = [[tweet creator] screenName];
        self.tweetText.text =   [tweet tweetText];
        self.retweetCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)tweet.retweetCount];
        self.favCount.text     = [NSString stringWithFormat:@"%lu", (unsigned long)tweet.favCount];
        self.tweetTime.text = [tweet.createdAt formattedDateWithFormat:@"hh:mm a"];
        self.tweetDate.text = [tweet.createdAt formattedDateWithFormat:@"MM/dd/yy"];

        
        NSURLRequest *request = [NSURLRequest requestWithURL:[[tweet creator] profileImageUrl]];

        //__weak RetweetViewCell *weakCell = self;
        
        __weak UIImageView *weakImageView = self.profileImageView;

        [self.profileImageView setImageWithURLRequest:request
                                     placeholderImage:nil
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  
                                                  weakImageView.image = image;
                                                  [weakImageView setNeedsLayout];
                                                  
                                              } failure:nil];
    } else {
        [self.retweetView setAlpha:1.0];
        self.retweetLabel.text = [NSString stringWithFormat:@"@%@", [[tweet creator] name] ];
        self.creatorName.text  = [[tweet retweeter] name];
        self.creatorText.text  = [[tweet retweeter] screenName];
        self.tweetText.text    = [tweet retweetText];
        self.retweetCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)tweet.retweetersRetweetCount];
        self.favCount.text     = [NSString stringWithFormat:@"%lu", (unsigned long)tweet.retweetFavCount];
        self.tweetTime.text = [tweet.retweetedAt formattedDateWithFormat:@"hh:mm a"];
        self.tweetDate.text = [tweet.retweetedAt formattedDateWithFormat:@"MM/dd/yy"];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[[tweet retweeter] profileImageUrl]];
        
        __weak UIImageView *weakImageView = self.profileImageView;
        
        [self.profileImageView setImageWithURLRequest:request
                                     placeholderImage:nil
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  
                                                  weakImageView.image = image;
                                                  [weakImageView setNeedsLayout];
                                                  
                                              } failure:nil];
    }
    
    if (self.tweet.retweetedAt == nil) {
        self.favorited = [self.tweet.rawTweet[@"favorited"] boolValue];
        if (self.favorited) {
            [self.favButton setSelected:NO];
            //NSLog(@"Highlighting the fav button for tweet");
        } else {
            //NSLog(@"Tweet not favorited");
        }
    } else {
        NSDictionary *retweetedStatus = self.tweet.rawTweet[@"retweeted_status"];
        self.favorited = [retweetedStatus[@"favorited"] boolValue];
        if (self.favorited) {
            [self.favButton setSelected:NO];
            //NSLog(@"Highlighting the fav button for retweet");
        } else {
            //NSLog(@"Re-Tweet not favorited");
        }
    }
    
}

- (IBAction)favorite:(UIButton *)sender {
    if (sender.selected) {
        //NSLog(@"Button selected");
    }
    
    //NSLog(@"Calling fav");
    
    [self.tweet makeFavoritesWithsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Mark the tweet as favorited by changing the state of the passed button
        Tweet *responseTweet = [Tweet tweetFromJson:responseObject];
        // Check if the response is favorited/unfavorited
        if ([responseTweet favorited]) {
            self.tweet.favorited = YES;
            [sender setSelected:YES];
        } else {
            [sender setSelected:NO];
            self.tweet.favorited = NO;
        }
        self.changed = YES;
        self.favCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)[responseTweet favoriteCount]];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Throw an error or perhaps do nothing
        NSLog(@"Could not perform fav/unfav %@", [error description]);
    }];
}

- (IBAction)retweet:(UIButton *)sender {
    
    
    [self.tweet retweetWithsuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Mark the tweet as favorited by changing the state of the passed button
        Tweet *responseTweet = [Tweet tweetFromJson:responseObject];
        // Check if the response is favorited/unfavorited
        [sender setEnabled:NO];
        //[sender setSelected:YES];
        self.tweet.retweetCount = responseTweet.retweetCount;
        //NSLog(@"Retweet count %lu", (unsigned long)[responseTweet retweetCount]);
        self.changed = YES;
        
        self.retweetCount.text = [NSString stringWithFormat:@"%lu", (unsigned long)[responseTweet numOfRetweets]];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Throw an error or perhaps do nothing
        NSLog(@"Could not retweet %@", [error description]);
    }];
}

- (IBAction) reply:(UIButton *)sender {
    // Get the creator and retweeter's handle for a reply
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
    
    tweetId = [self.tweet getTweetId];
    

    ComposeViewController *composeTweetVc = [[ ComposeViewController alloc]  initWithNibName:@"ComposeViewController" bundle:nil replyToText:replyTo toStatus:tweetId];
    //composeTweetVc.delegate = self;
    [self.navigationController pushViewController:composeTweetVc animated:YES];
    
}

@end
