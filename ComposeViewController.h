//
//  ComposeViewController.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/22/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeViewController : UIViewController <UITextViewDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil replyToText:(NSString *) reply toStatus:(NSString *) statusId;

- (void)tweet:(id)sender;
- (void)resignViewController:(id)sender;

@end
