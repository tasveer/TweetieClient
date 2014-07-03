//
//  ProfileViewController.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/29/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "ProfileViewController.h"
#import "StatsViewCell.h"
#import "User.h"
#import "TwitterClient.h"
#import "ComposeViewController.h"
#import "MBProgressHUD.h"
#import "Tweet.h"
#import "TweetViewCell.h"
#import "RetweetViewCell.h"
#import "TweetViewController.h"
#import "ProfileHeaderPagingCell.h"


@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)        User        *userForProfile;
@property (strong, nonatomic)        NSMutableArray   *tweets;
@property (nonatomic)                BOOL             signedInUser;
@property (nonatomic, strong)        UIRefreshControl *refreshControl;


@end

@implementation ProfileViewController

ProfileHeaderPagingCell *_stubProfilePaging;
StatsViewCell       *_stubStats;
TweetViewCell       *_stubTweetCell;
TweetViewCell   *_stubTweetCell;
RetweetViewCell *_stubRetweetCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initializeData];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forUser:(User *) user {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.userForProfile = user;
        [self initializeData];
        self.signedInUser   = false;
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    
    if ([self.tweets count] == 0 && self.userForProfile != nil) {
        [self getUserTweets:[NSString stringWithFormat:@"%lu", (unsigned long)[self.userForProfile userId]] showProgress:YES];
    } else {
        [self getUser];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"profile view controller did load");

    [self createViewElements];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma public api

-(void) setProfileUser:(User *)user {

    self.userForProfile = user;
}

- (User *) getProfileUser {
    return self.userForProfile;
}

#pragma View element creation

- (void) createTitleLabelForUser {
    
    NSLog(@"Changing title label");

    if (self.userForProfile) {
        NSLog(@"Creating title label for user %@", [self.userForProfile name]);

        //NSLog(@"Changing title label");
        //self.title = [self.userForProfile name];
        /*
        UILabel *titleLabel = (UILabel *) self.navigationItem.titleView;
        titleLabel.text = [self.userForProfile name];
        self.navigationItem.titleView = titleLabel;
         */
        
        UILabel *titleLabel = [[UILabel alloc] init];
        
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = [self.userForProfile name];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        
        self.navigationItem.titleView = titleLabel;
        [titleLabel sizeToFit];
    }
}

- (void) getUser {
    if (self.userForProfile == nil) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        [[TwitterClient instance] currentUserWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Got current User %@", responseObject);
            
            self.userForProfile = [ User initFromJson:responseObject];
            
            [self getUserTweets:[NSString stringWithFormat:@"%lu", (unsigned long)[self.userForProfile userId]] showProgress:NO];
            
            //[self.tableView reloadData];
            [self createTitleLabelForUser];

            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"response error %@", [error description]);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        }];

    }
}

- (void) getUserTweets:(NSString *) userId showProgress:(BOOL)progress {
    
    //NSLog(@"Getting timeline");
    if (progress) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    // Load 20 most recent tweets or if the user has done
    // infinite load then load older tweets upto last 60 only.
    int limit = 10;
    
    [[TwitterClient instance] getUserStatusWithUserId:userId numTweets:limit success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        if (progress) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response error %@", [error description]);
        if (progress) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

- (void) initializeData {
    
    self.tweets = [[NSMutableArray alloc] init];
    if (self.userForProfile == nil) {
        self.signedInUser = YES;
    }
    //self.noRefreshREquired = false;
    
}


- (void) createViewElements {
        
    UINib *statsNib = [UINib nibWithNibName:@"StatsViewCell" bundle:nil];
    [self.tableView registerNib:statsNib forCellReuseIdentifier:@"StatsViewCell"];
    
    UINib *tweetCellNib = [UINib nibWithNibName:@"TweetViewCell" bundle:nil];
    [self.tableView registerNib:tweetCellNib forCellReuseIdentifier:@"TweetViewCell"];
    
    UINib *reTweetCellNib = [UINib nibWithNibName:@"RetweetViewCell" bundle:nil];
    [self.tableView registerNib:reTweetCellNib forCellReuseIdentifier:@"RetweetViewCell"];
    
    UINib *profilePagingNib = [UINib nibWithNibName:@"ProfileHeaderPagingCell" bundle:nil];
    [self.tableView registerNib:profilePagingNib forCellReuseIdentifier:@"ProfileHeaderPagingCell"];
    
    _stubTweetCell   = [tweetCellNib instantiateWithOwner:nil options:nil][0];
    _stubRetweetCell = [reTweetCellNib instantiateWithOwner:nil options:nil][0];
    _stubStats       = [statsNib instantiateWithOwner:nil options:nil][0];
    _stubProfilePaging  = [profilePagingNib instantiateWithOwner:nil options:nil][0];

    
    [self createTitleLabelForUser];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.scrollsToTop = YES;
    
    //[self.tableView reloadData];
    
    if (self.signedInUser) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:0 target:self action:@selector(slideBack)];
        [button setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = button;
    } else {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(resignViewController:)];
        [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    /*
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(composeTweet:)];
    [composeButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
     */
    
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"compose_new"] style:0 target:self action:@selector(composeTweet:)];
    [composeButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = composeButton;
    
    self.navigationItem.rightBarButtonItem = composeButton;
    
    [ self addPullToRefresh ];

}

#pragma loading Table

-(void) fetchMoreTimeline {
    
    //NSLog(@"Getting timeline for infifnte scroll");
    
    if ([self.tweets count] == 0 && self.userForProfile != nil) {
        [self getUserTweets:[NSString stringWithFormat:@"%lu", (unsigned long)[self.userForProfile userId]] showProgress:YES];
    } else {
        [self getUser];
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    Tweet *lastTweet = self.tweets[[self.tweets count] - 1 ];
    
    // Get 10 more tweets after the lastTweet with its tweetId
    
    [[TwitterClient instance] getMoreTweets:10 until:[lastTweet getTweetId] success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

- (void)reloadData {
 
    NSLog(@"Calling for pull to rfresh");
    if (self.userForProfile != nil) {
        [self getUserTweets:[NSString stringWithFormat:@"%lu", (unsigned long)[self.userForProfile userId]] showProgress:YES];
    } else if (self.userForProfile == nil) {
        [self getUser];
    }
    [self.refreshControl endRefreshing];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= -40) {
        //NSLog(@"reload table, reached bottom");
        [self fetchMoreTimeline];
    }
}

#pragma Table


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1.0f;
    }
        return 80.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 1) {
        return 1.0f;
    }
    return 40.0f;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.tweets count] > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return [self.tweets count];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == 0 && indexPath.row == 0) {
        ProfileHeaderPagingCell *profilePagingCell = (ProfileHeaderPagingCell *)cell;
        [profilePagingCell loadProfileHeaderWithUser:self.userForProfile];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        // display profile header
        StatsViewCell *statsViewCell = (StatsViewCell *)cell;
        [statsViewCell loadStatsForUser:self.userForProfile ];
    } else if (indexPath.section == 1) {
        Tweet *tweet = self.tweets[indexPath.row];
        
        if (tweet.retweeter) {
            RetweetViewCell *retweetCell = (RetweetViewCell *)cell;
            [retweetCell configureTweetCellWithTweet:tweet ];
        } else {
            TweetViewCell *tweetCell = (TweetViewCell *)cell;
            [tweetCell configureTweetCellWithTweet:tweet ];
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    
    if (indexPath.section == 0) {
        if(indexPath.row == 0) {

            [self configureCell:_stubProfilePaging atIndexPath:indexPath];
            [_stubProfilePaging layoutSubviews];

            height = [_stubProfilePaging.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            //NSLog(@"hieght for cell at row %d ------> %f  Profile header", indexPath.row, height+1);
            
            height = 200;
            
        } else if (indexPath.row == 1) {
            [self configureCell:_stubStats atIndexPath:indexPath];
            [_stubStats layoutSubviews];
            height = [_stubStats.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            //NSLog(@"hieght for cell at row %d ------> %f  Stats", indexPath.row, height+1);
        }
    } else if (indexPath.section ==1) {
        Tweet *tweet = self.tweets[indexPath.row];
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

    }

    return height + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        /*
        ProfileHeaderCell *profileHeaderCell = [ tableView dequeueReusableCellWithIdentifier:@"ProfileHeaderCell" ];
        [profileHeaderCell loadProfileForUser:self.userForProfile ];
        return profileHeaderCell;
         */
        ProfileHeaderPagingCell *profilePagingCell = [tableView dequeueReusableCellWithIdentifier:@"ProfileHeaderPagingCell" ];
        [profilePagingCell loadProfileHeaderWithUser:self.userForProfile];
        return profilePagingCell;
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        StatsViewCell *statsViewCell = [ tableView dequeueReusableCellWithIdentifier:@"StatsViewCell" ];
        [statsViewCell loadStatsForUser:self.userForProfile];
        return statsViewCell;
    } else if (indexPath.section == 1) {
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
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        NSLog(@"disabling pan gesture");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Disable Pan" object:self];
    }
    
    if (indexPath.section == 1) {
        TweetViewController *tvc = [[TweetViewController alloc] initWithNibName:@"TweetViewController" bundle:nil];
        
        Tweet *tweet = self.tweets[indexPath.row];
        
        tvc.tweet = tweet;
        
        [self.navigationController pushViewController:tvc animated:YES];
        
        [tableView  deselectRowAtIndexPath:indexPath  animated:YES];
    }
    
    [tableView  deselectRowAtIndexPath:indexPath  animated:YES];
    
    return;
    
}


#pragma Navigation

- (void) slideBack {
    NSDictionary *info = @{@"controller": self};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Slide Menu" object:self userInfo:info];
}

- (void)composeTweet:(id)sender {
    
    ComposeViewController *composeTweetVc = [[ ComposeViewController alloc] initWithNibName:@"ComposeViewController" bundle:nil];
    //composeTweetVc.delegate = self;
    [self.navigationController pushViewController:composeTweetVc animated:YES];
}

- (void) resignViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
