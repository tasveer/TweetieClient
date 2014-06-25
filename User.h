//
//  User.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/20/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <Mantle.h>


@interface User : MTLModel <MTLJSONSerializing>

@property(strong, nonatomic) NSString    *name;
@property(strong, nonatomic) NSString    *screenName;
@property(strong, nonatomic) NSURL       *profileImageUrl;
@property(nonatomic)         NSUInteger  userId;
@property(strong, nonatomic) NSString    *description;

+ (User *)currentUser;

+ (User*) initFromJson:(NSDictionary *)dictionary;

- (void) dumpUserInfo;
@end
