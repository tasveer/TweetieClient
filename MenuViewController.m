//
//  MenuViewController.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/28/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "MenuViewController.h"
#import "MenuTableCell.h"
#import "ProfileTableCell.h"
#import "User.h"
#import "TwitterClient.h"
#import "MBProgressHUD.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *menuContents;

@property (strong, nonatomic) UIViewController *selectedController;
@property (strong, nonatomic) User *signedInUser;

@end

@implementation MenuViewController

ProfileTableCell   *_stubProfile;
MenuTableCell *_stubMenuCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[User currentUser];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"Menu view did appear");
    //User *user = [User currentUser];
    if (self.signedInUser == nil)
        [self getUser];
}

- (void)viewDidLoad
{
    //NSLog(@"Menu view load tableview: %@", self.tableView);
    [super viewDidLoad];
    
    self.menuContents = @[@"Profile", @"Timeline", @"Mentions", @"Sign Off"];
    
    UINib *profileNib = [UINib nibWithNibName:@"ProfileTableCell" bundle:nil];
    [self.tableView registerNib:profileNib forCellReuseIdentifier:@"ProfileTableCell"];
    
    UINib *menuTableNib = [UINib nibWithNibName:@"MenuTableCell" bundle:nil];
    [self.tableView registerNib:menuTableNib forCellReuseIdentifier:@"MenuTableCell"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getUser {
    if (self.signedInUser == nil) {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[TwitterClient instance] currentUserWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Got current User %@", responseObject);
            
            self.signedInUser = [ User initFromJson:responseObject];
            
            
            [self.tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"response error %@", [error description]);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
        }];
        
    }
}


#pragma Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.menuContents count];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self.menuContents[indexPath.row] isEqualToString:@"Profile"]) {
        ProfileTableCell *profileTableCell = (ProfileTableCell *)cell;
        [profileTableCell loadProfileForUser:self.signedInUser ];
    } else {
        MenuTableCell *menuTableCell = (MenuTableCell *)cell;
        [menuTableCell loadMenuWithTitle:self.menuContents[indexPath.row] ];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = 0;
    
    if ([self.menuContents[indexPath.row] isEqualToString:@"Profile"]) {
        return 120;
        [self configureCell:_stubProfile atIndexPath:indexPath];
        [_stubProfile layoutSubviews];
        height = [_stubProfile.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //NSLog(@"hieght for cell at row %d ------> %f  %@", indexPath.row, height+1, _stubProfile.userName.text);
    } else {
        return 44;
        [self configureCell:_stubMenuCell atIndexPath:indexPath];
        [_stubMenuCell layoutSubviews];
        height = [_stubMenuCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //NSLog(@"hieght for cell at row %d ------> %f  %@", indexPath.row, height+1, _stubMenuCell.optionName.text);
    }
    
    return height + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.menuContents[indexPath.row] isEqualToString:@"Profile"]) {
        ProfileTableCell *profileTableCell = [ tableView dequeueReusableCellWithIdentifier:@"ProfileTableCell" ];
        [profileTableCell loadProfileForUser:self.signedInUser];
        return profileTableCell;
    } else {
        MenuTableCell *menuTableCell = [ tableView dequeueReusableCellWithIdentifier:@"MenuTableCell" ];
        [menuTableCell loadMenuWithTitle:self.menuContents[indexPath.row]];
        return menuTableCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.menuContents[indexPath.row] isEqualToString:@"Timeline"]) {
        //NSLog(@"Timeline selected");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Timeline" object:self];
    } else if ([self.menuContents[indexPath.row] isEqualToString:@"Mentions"]) {
        //NSLog(@"Mentions selected");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Mentions" object:self];
    } else if ([self.menuContents[indexPath.row] isEqualToString:@"Profile"]) {
        //NSLog(@"Profile selected");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Profile" object:self];
    } else if ([self.menuContents[indexPath.row] isEqualToString:@"Sign Off"]) {
        //NSLog(@"Sign Off selected");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Sign Off" object:self];
    }
    
    [tableView  deselectRowAtIndexPath:indexPath  animated:YES];


}


@end
