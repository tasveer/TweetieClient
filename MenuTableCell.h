//
//  MenuTableCell.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/28/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *optionName;

- (void) loadMenuWithTitle:(NSString *)title;

@end
