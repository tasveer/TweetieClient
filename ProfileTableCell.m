//
//  ProfileTableCell.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/28/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "ProfileTableCell.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileTableCell ()

//@property(strong, nonatomic) User *user;

@end

@implementation ProfileTableCell

- (void)awakeFromNib
{
    // Initialization code
    //NSLog(@"profile cell awake from nib");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) loadProfileForUser:(User *) user {
    
    //NSLog(@"calling current user");
    
    self.userName.text = [user name];
    self.userScreenName.text = [user screenName];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[user profileImageUrl]];
    
    __weak UIImageView *weakImageView = self.profileImageView;
    
    [self.profileImageView setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              
                                              weakImageView.image = image;
                                              [weakImageView setNeedsLayout];
                                              
                                          } failure:nil];
}

@end
