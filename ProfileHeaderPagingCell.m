//
//  ProfileHeaderPagingCell.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/30/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "ProfileHeaderPagingCell.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+ImageEffects.h"


@interface ProfileHeaderPagingCell ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageViewOne;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic)        NSMutableArray *pages;
@property (strong, nonatomic)        UILabel *description;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic)                CGRect profileImageFrame;
@property (nonatomic)                CGRect userNameFrame;
@property (nonatomic)                CGRect descriptionFrame;
@property (strong, nonatomic)        UIImage *headerImage;


- (IBAction)changePage:(UIPageControl *)sender;

@end

@implementation ProfileHeaderPagingCell

- (void)awakeFromNib
{
    // Initialization code
    self.scrollView.delegate = self;
    self.pageControl.currentPage = 0;
    //self.description = [[UILabel alloc] initWithFrame:self.containerView.frame];
    self.description = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 220, 99)];
    self.description.font = [UIFont boldSystemFontOfSize:14];
    self.description.numberOfLines = 0;
    self.description.textColor = [ UIColor whiteColor];
    self.description.backgroundColor = [UIColor clearColor];
    self.description.textAlignment = NSTextAlignmentCenter;



}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.pageControl.currentPage = page;
}
 */


- (void) loadProfileHeaderWithUser:(User *) user {
    if (user == nil) {
        self.userName.text = @"Hunaid";
    } else {
        self.userName.text = [user name];
    }
    
    self.userProfile = user;
    
    //self.userScreenName.text = [user screenName];
    
    //NSLog(@"loading user in profile table %@", [user name]);
    NSURLRequest *request = [NSURLRequest requestWithURL:[user profileImageUrl]];
    
    self.scrollView.contentSize = CGSizeMake(640,160);
    __weak UIImageView *weakImageView = self.profileImageView;
    
    [self.profileImageView setImageWithURLRequest:request
                                 placeholderImage:nil
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                              
                                              weakImageView.image = image;
                                              [weakImageView setNeedsLayout];
                                              
                                          } failure:nil];
    
    request = [NSURLRequest requestWithURL:[user profileBannerUrl]];
    
    weakImageView = self.headerImageViewOne;
    
    [self.headerImageViewOne setImageWithURLRequest:request
                                       placeholderImage:nil
                                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                    self.headerImage =    image;
                                                    weakImageView.image = image;
                                                    [weakImageView setNeedsLayout];
                                                    
                                                } failure:nil];
    
    
    //NSLog(@"user description : %@", self.userDescription.text);
}

#pragma Paging of Header View

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
    //NSLog(@"profile header page scrolling end");
    
    NSInteger currentPage = self.pageControl.currentPage;
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    float fractionalPage = self.scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    //NSLog(@"page: %d", page);
    self.pageControl.currentPage = page;
    if (currentPage != page)
        [self changePage:self.pageControl];
}

- (IBAction)changePage:(UIPageControl *)sender {
    CGFloat x = self.pageControl.currentPage * self.scrollView.frame.size.width;
    //NSLog(@"change page %f", x);
    //NSLog(@"contentView frame (%f %f) (%f %f)", self.containerView.frame.origin.x, self.containerView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self.scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
    if (self.pageControl.currentPage == 1) {
        
        //NSLog(@"Changing to page 1");
        
        self.userNameFrame = self.userName.frame;
        self.profileImageFrame = self.profileImageView.frame;

        
        self.description.text = [self.userProfile description];
        self.description.frame = CGRectMake(320, 50, 220, 99);

        self.headerImageViewOne.image = [self.headerImageViewOne.image applyBlurWithRadius:10 tintColor:nil saturationDeltaFactor:1 maskImage:nil];
        //NSLog(@"description %@", [self.userProfile description]);
        
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            
            self.userName.frame = CGRectMake(self.containerView.frame.origin.x-self.userName.frame.size.width, self.userName.frame.origin.y, self.userName.frame.size.width, self.userName.frame.size.height);
            self.profileImageView.frame = CGRectMake(self.containerView.frame.origin.x-self.profileImageFrame.size.width, self.profileImageFrame.origin.y, self.profileImageFrame.size.width, self.profileImageFrame.size.height);
            
            [self.containerView addSubview:self.description];
            [self.containerView bringSubviewToFront:self.description];
            self.description.frame = CGRectMake(50, 50, 220, 99);
        } completion:nil];



        [self.containerView layoutIfNeeded];

     } else if (self.pageControl.currentPage == 0) {
         
         //NSLog(@"Changing to page 0");
         self.headerImageViewOne.image = self.headerImage;
         [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
             
             //NSLog(@"User name frame %f %f", self.userNameFrame.origin.x, self.userNameFrame.origin.y);
             self.userName.frame = self.userNameFrame;
             self.profileImageView.frame = self.profileImageFrame;
             
             [self.containerView addSubview:self.description];
             [self.containerView bringSubviewToFront:self.description];
             self.description.frame = CGRectMake(320, 50, 220, 99);
             
         } completion:nil];

        [self.containerView layoutIfNeeded];
    }
}
@end
