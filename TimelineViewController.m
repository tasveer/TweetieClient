//
//  TimelineViewController.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/20/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "TimelineViewController.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TweetViewCell.h"
#import "RetweetViewCell.h"
#import "RetweetViewCell.h"
#import "MBProgressHUD.h"
#import "TweetViewController.h"
#import "ComposeViewController.h"
#import "LoginViewController.h"
#import "ProfileViewController.h"

#define kMaxTweets 100

@interface TimelineViewController ()

@property (strong, nonatomic)        NSMutableArray   *tweets;
@property (weak, nonatomic) IBOutlet UITableView      *tableView;
@property (nonatomic, strong)        UIRefreshControl *refreshControl;
@property (nonatomic)                BOOL             noRefreshREquired;
@end

@implementation TimelineViewController

TweetViewCell   *_stubTweetCell;
RetweetViewCell *_stubRetweetCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[self getTimeline];
        [self initializeData];
    }
    return self;
}

- (void)viewDidLoad
{
    //NSLog(@"Timeline view did load");
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createViewElements];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getTimeline)
                                                 name:@"Tweet Favorited"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(replyToTweet:)
                                                 name:@"Tweet Reply"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getTimeline)
                                                 name:@"Retweetted"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doNotRefreshTable)
                                                 name:@"No Activity"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTweetersProfile:)
                                                 name:@"Show Tweeters Profile"
                                               object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    
    if (self.noRefreshREquired == NO) {
        [self getTimeline];
    } else {
        //NSLog(@"No refresh required!!");
        self.noRefreshREquired = NO; // reset it
    }
    
    //[User currentUser];

}


- (void) getTimeline {
    
    //NSLog(@"Getting timeline");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Load 20 most recent tweets or if the user has done
    // infinite load then load older tweets upto last 60 only.
    int limit = 20;
    if (self.tweets && [self.tweets count] > 0) {
        limit = [self.tweets count] < kMaxTweets ? [self.tweets count] : limit;
    }
    
    [[TwitterClient instance] getRecentTweet:limit success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"response %@", responseObject);
        
        // clear up the table data for new
        [self.tweets removeAllObjects];

        //NSLog(@"------------------------------------- Got response ------------------------------------------------");
        NSError *error = nil;
        for (NSDictionary *dictionary in responseObject) {
            //NSLog(@"Raw tweet dictionary %@", dictionary);
            Tweet *aTweet = [MTLJSONAdapter modelOfClass: Tweet.class fromJSONDictionary: dictionary error: &error];
            /*
            if (aTweet.retweeter) {
                NSLog(@"Retweet raw dictionary %@", dictionary);
            }
             */
            aTweet.rawTweet = dictionary;
            [self.tweets addObject:aTweet];
            //[aTweet dumpTweetInfo];
        }
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response error %@", [error description]);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

-(void) fetchMoreTimeline {
    
    //NSLog(@"Getting timeline for infifnte scroll");
    
    if (self.tweets == nil || [self.tweets count] == 0) {
        [self getTimeline];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    Tweet *lastTweet = self.tweets[[self.tweets count] - 1 ];
    
    // Get 20 more tweets after the lastTweet with its tweetId
    
    [[TwitterClient instance] getMoreTweets:20 until:[lastTweet getTweetId] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"response %@", responseObject);
        
        
        //NSLog(@"------------------------------------- Got response ------------------------------------------------");
        NSError *error = nil;
        for (NSDictionary *dictionary in responseObject) {
            //NSLog(@"Raw tweet dictionary %@", dictionary);
            Tweet *aTweet = [MTLJSONAdapter modelOfClass: Tweet.class fromJSONDictionary: dictionary error: &error];
            /*
             if (aTweet.retweeter) {
             NSLog(@"Retweet raw dictionary %@", dictionary);
             }
             */
            aTweet.rawTweet = dictionary;
            
            // Sometimes the last tweet is repeated, so avoid the duplication
            if (![[aTweet getTweetId] isEqualToString:[lastTweet getTweetId]]) {
                [self.tweets addObject:aTweet];
            }
            //[aTweet dumpTweetInfo];
        }
        [self.tableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response error %@", [error description]);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];

}

- (void) initializeData {

    self.tweets = [[NSMutableArray alloc] init];
    self.noRefreshREquired = false;
    
}

- (void) createViewElements {
    
    UINib *tweetCellNib = [UINib nibWithNibName:@"TweetViewCell" bundle:nil];
    [self.tableView registerNib:tweetCellNib forCellReuseIdentifier:@"TweetViewCell"];

    UINib *reTweetCellNib = [UINib nibWithNibName:@"RetweetViewCell" bundle:nil];
    [self.tableView registerNib:reTweetCellNib forCellReuseIdentifier:@"RetweetViewCell"];
    
    _stubTweetCell   = [tweetCellNib instantiateWithOwner:nil options:nil][0];
    _stubRetweetCell = [reTweetCellNib instantiateWithOwner:nil options:nil][0];


    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UILabel *titleLabel = [[UILabel alloc] init];

    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"Home";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    
    UIImageView *tweetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TweetWhite"]];
    //self.navigationItem.titleView = titleLabel;
    self.navigationItem.titleView = tweetImageView;

    [titleLabel sizeToFit];
    
    /*
    UIBarButtonItem *signOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(signOut)];
    [signOutButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = signOutButton;
     */

    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_bar"] style:0 target:self action:@selector(slideBack)];
    [button setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = button;

    
    //UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(composeTweet:)];
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compose_new"] style:0 target:self action:@selector(composeTweet:)];
    [composeButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = composeButton;
    
    [ self addPullToRefresh ];
}

- (void) slideBack {
    NSDictionary *info = @{@"controller": self};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Show Menu" object:self userInfo:info];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = self.tweets[indexPath.row];

    if (tweet.retweeter) {
        RetweetViewCell *retweetCell = (RetweetViewCell *)cell;
        [retweetCell configureTweetCellWithTweet:tweet ];
    } else {
        TweetViewCell *tweetCell = (TweetViewCell *)cell;
        [tweetCell configureTweetCellWithTweet:tweet ];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Tweet *tweet = self.tweets[indexPath.row];
    CGFloat height = 0;

    if (tweet.retweeter) {
        [self configureCell:_stubRetweetCell atIndexPath:indexPath];
        [_stubRetweetCell layoutSubviews];
        height = [_stubRetweetCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //NSLog(@"hieght for cell at row %d ------> %f  %@", indexPath.row, height+1, _stubRetweetCell.screenName.text);
    } else {
        [self configureCell:_stubTweetCell atIndexPath:indexPath];
        [_stubTweetCell layoutSubviews];
        height = [_stubTweetCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //NSLog(@"hieght for cell at row %d ------> %f  %@", indexPath.row, height+1, _stubTweetCell.screenName.text);
    }

    return height + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"total rows %d", [self.tweets count]);
    return [ self.tweets count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    Tweet *tweet = self.tweets[indexPath.row];
    
    if (tweet.retweeter) {
        //NSLog(@"this is a retweet %@ for tweet %@ tweet text %@", [[tweet retweeter] screenName], [tweet retweetText], [tweet tweetText]);
        //[tweet dumpTweetInfo];

        RetweetViewCell *tweetCell = [ tableView dequeueReusableCellWithIdentifier:@"RetweetViewCell" ];
        [tweetCell loadTweetCellWithTweet:tweet];
        return tweetCell;

    } else {
        TweetViewCell *tweetCell = [ tableView dequeueReusableCellWithIdentifier:@"TweetViewCell" ];
        [tweetCell loadTweetCellWithTweet:tweet];
        return tweetCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    TweetViewController *tvc = [[TweetViewController alloc] initWithNibName:@"TweetViewController" bundle:nil];
    
    Tweet *tweet = self.tweets[indexPath.row];

    tvc.tweet = tweet;
    
    [self.navigationController pushViewController:tvc animated:YES];
    
    [tableView  deselectRowAtIndexPath:indexPath  animated:YES];
    
    return;

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= -40) {
        //NSLog(@"reload table, reached bottom");
        [self fetchMoreTimeline];
    }
}

-(void)reloadData
{
    //update table
    //NSLog(@"Reloading after refresh...");
    
    [ self getTimeline ];
    
    [self.refreshControl endRefreshing];
}

-(IBAction)refreshTable:(id)sender
{
    
    [ self reloadData ];
    
}

-(void)addPullToRefresh {
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    
    [self.tableView addSubview:self.refreshControl];
    
    /*
     NSMutableAttributedString *refreshString = [[NSMutableAttributedString alloc] initWithString:@"Pull To Refresh"];
     [refreshString addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(0, refreshString.length)];
     
     self.refreshControl.attributedTitle = refreshString;
     */
    
    [self.refreshControl addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    
    
    return;
}

- (void)composeTweet:(id)sender {
 
    ComposeViewController *composeTweetVc = [[ ComposeViewController alloc] initWithNibName:@"ComposeViewController" bundle:nil];
    //composeTweetVc.delegate = self;
    [self.navigationController pushViewController:composeTweetVc animated:YES];
}

- (void) signOut {
    LoginViewController       *lvc = [[LoginViewController alloc] init];

    [[TwitterClient instance] deauthorize];
    [[TwitterClient instance].requestSerializer removeAccessToken];
    
    [self presentViewController:lvc animated:YES completion:nil];
}


- (void)replyToTweet:(NSNotification *) notification {
    
    NSDictionary *replyToDetails = [notification userInfo];
    //NSLog(@"Reply to tweet %@", replyToDetails);

    ComposeViewController *composeTweetVc = [[ ComposeViewController alloc] initWithNibName:@"ComposeViewController" bundle:nil
                                                                                replyToText:replyToDetails[@"replyTo"] toStatus:replyToDetails[@"tweetId"]];
    //composeTweetVc.delegate = self;
    [self.navigationController pushViewController:composeTweetVc animated:YES];
}

- (void) doNotRefreshTable {
    self.noRefreshREquired = YES;
}

- (void) showTweetersProfile:(NSNotification *)notification {

    NSDictionary *replyToDetails = [notification userInfo];

    User *tweeter = (User *) replyToDetails[@"Tweeter"];
    
    
    ProfileViewController *profileViewcontroller = [[ProfileViewController alloc ] initWithNibName:nil bundle:nil forUser:tweeter];
    
    [self.navigationController pushViewController:profileViewcontroller animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
