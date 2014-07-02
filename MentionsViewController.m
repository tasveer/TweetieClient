//
//  MentionsViewController.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/28/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "MentionsViewController.h"
#import "TweetViewCell.h"
#import "MBProgressHUD.h"
#import "TwitterClient.h"
#import "ComposeViewController.h"
#import "TweetViewController.h"



@interface MentionsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong)        UIRefreshControl *refreshControl;
@property (strong, nonatomic)        NSMutableArray   *tweets;


@end

@implementation MentionsViewController

TweetViewCell *_stubTweetCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initializeData];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    
    //NSLog(@"Mentions view did appear");
    [self getMentions];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self createViewElements];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma View Data creation
- (void) initializeData {
    
    self.tweets = [[NSMutableArray alloc] init];
    //self.noRefreshREquired = false;
    
}

- (void) createViewElements {
    
    UINib *tweetCellNib = [UINib nibWithNibName:@"TweetViewCell" bundle:nil];
    [self.tableView registerNib:tweetCellNib forCellReuseIdentifier:@"TweetViewCell"];
    
    UINib *reTweetCellNib = [UINib nibWithNibName:@"RetweetViewCell" bundle:nil];
    [self.tableView registerNib:reTweetCellNib forCellReuseIdentifier:@"RetweetViewCell"];
    
    _stubTweetCell   = [tweetCellNib instantiateWithOwner:nil options:nil][0];
    //_stubRetweetCell = [reTweetCellNib instantiateWithOwner:nil options:nil][0];
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"Home";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    
    self.navigationItem.titleView = titleLabel;
    [titleLabel sizeToFit];
    
    /*
     UIBarButtonItem *signOutButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(signOut)];
     [signOutButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
     self.navigationItem.leftBarButtonItem = signOutButton;
     */
    
    /*
     UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(showMenu:)];
     [menuButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
     self.navigationItem.leftBarButtonItem = menuButton;
     */
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:0 target:self action:@selector(slideBack)];
    [button setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = button;
    
    
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(composeTweet:)];
    [composeButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = composeButton;
    
    [ self addPullToRefresh ];
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

-(void)reloadData
{
    //update table
    //NSLog(@"Reloading after refresh...");
    
    [ self getMentions ];
    
    [self.refreshControl endRefreshing];
}

- (void) getMentions {
    
    //NSLog(@"Getting timeline");
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Load 20 most recent tweets or if the user has done
    // infinite load then load older tweets upto last 60 only.
    int limit = 20;
    if (self.tweets && [self.tweets count] > 0) {
        limit = [self.tweets count] < 60 ? [self.tweets count] : limit;
    }
    
    [[TwitterClient instance] getMentions:20 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"response %@", responseObject);
        
        // clear up the table data for new
        [self.tweets removeAllObjects];
        
        //NSLog(@"------------------------------------- Got response ------------------------------------------------");
        NSError *error = nil;
        for (NSDictionary *dictionary in responseObject) {
            //NSLog(@"Raw tweet dictionary %@", dictionary);
            Tweet *aTweet = [MTLJSONAdapter modelOfClass: Tweet.class fromJSONDictionary: dictionary error: &error];
 
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

#pragma TableView delegate calls

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = self.tweets[indexPath.row];
    
    TweetViewCell *tweetCell = (TweetViewCell *)cell;
    [tweetCell configureTweetCellWithTweet:tweet ];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    
    
    [self configureCell:_stubTweetCell atIndexPath:indexPath];
    [_stubTweetCell layoutSubviews];
    height = [_stubTweetCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    //NSLog(@"hieght for cell at row %d ------> %f  %@", indexPath.row, height+1, _stubTweetCell.screenName.text);
    
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
    
    
    TweetViewCell *tweetCell = [ tableView dequeueReusableCellWithIdentifier:@"TweetViewCell" ];
    [tweetCell loadTweetCellWithTweet:tweet];
    return tweetCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetViewController *tvc = [[TweetViewController alloc] initWithNibName:@"TweetViewController" bundle:nil];
    
    Tweet *tweet = self.tweets[indexPath.row];
    
    tvc.tweet = tweet;
    
    [self.navigationController pushViewController:tvc animated:YES];
    
    [tableView  deselectRowAtIndexPath:indexPath  animated:YES];
    
    return;
    
}

#pragma Navigation

- (void) slideBack {
    //NSLog(@"Posting slide  menu notification");
    NSDictionary *info = @{@"controller": self};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Slide Menu" object:self userInfo:info];
}

- (void)composeTweet:(id)sender {
    
    ComposeViewController *composeTweetVc = [[ ComposeViewController alloc] initWithNibName:@"ComposeViewController" bundle:nil];
    //composeTweetVc.delegate = self;
    [self.navigationController pushViewController:composeTweetVc animated:YES];
}

@end
