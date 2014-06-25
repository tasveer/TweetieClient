//
//  ComposeViewController.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/22/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "ComposeViewController.h"
#import "Tweet.h"
#import "UIImageView+AFNetworking.h"
#import "TwitterClient.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel     *userName;
@property (weak, nonatomic) IBOutlet UILabel     *userHandle;
@property (weak, nonatomic) IBOutlet UITextView  *toTweet;
@property (strong, nonatomic)        NSString    *replyTo;
@property (strong, nonatomic)        NSString    *statusId;
@property (nonatomic)                BOOL        changed;  // Marks if user made any change, like fav/unfav, or retweet

@end

@implementation ComposeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.replyTo = @"";
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil replyToText:(NSString *) reply toStatus:(NSString *) statusId
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.replyTo = reply;
        self.statusId = statusId;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {

    [self loadData];
    return;
}

- (void)viewDidAppear:(BOOL)animated {
    
    User *loggednInUser = [User currentUser];

    NSURLRequest *request = [NSURLRequest requestWithURL:[loggednInUser profileImageUrl]];
    
    __weak UIImageView *weakImageView = self.profileImageView;
    
    [self.profileImageView setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              
                                              weakImageView.image = image;
                                              [weakImageView setNeedsLayout];
                                              
                                          } failure:nil];
}

- (void)viewDidLoad
{

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializeView];
    
    [self.toTweet performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.8];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initializeView {
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(resignViewController:)];
    [cancelButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem *tweetButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(tweet:)];
    [tweetButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor whiteColor],  NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = tweetButton;

    return;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

    //NSLog(@"User started typing");
    //textView.delegate = self;
}

- (void)loadData {
    
    User *loggednInUser = [User currentUser];
    
    self.userName.text      = [loggednInUser name];
    self.userHandle.text    = [loggednInUser screenName];
    if ([self.replyTo isEqualToString:@""]) {
        self.toTweet.text       = @"";
        //self.toTweet.text       = self.retweetStatus;
        //self.title = @"140";
        self.title = [NSString stringWithFormat:@"%d", 140-[self.replyTo length]];
    } else {
        self.toTweet.text = self.replyTo;
        self.title = [NSString stringWithFormat:@"%d", 140-[self.replyTo length]];
    }
    
    // This is to repond to user entered tweet.
    self.toTweet.delegate = self;
    
    return;
}

- (void)textViewDidChange:(UITextView *)textView {
    int charCount = 140-[textView.text length];
    
    self.title = [NSString stringWithFormat:@"%d", charCount];
    
    if (charCount <= 0) {
        [textView resignFirstResponder];
    }
}

- (void) resignViewController:(id)sender {
    
    if (self.changed == NO) {
        //NSLog(@"No changes occured in tweet view");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"No Activity" object:self];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) tweet:(id)sender {
    [[TwitterClient instance] tweetStatus:self.toTweet.text replyStatusId:self.statusId success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Succesfully tweeted %@", self.toTweet.text);
        //NSLog(@"response back from tweet %@", responseObject);
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Unable to tweet error: %@", [error description]);
    }];
}

@end
