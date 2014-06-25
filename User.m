//
//  User.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/20/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

@implementation User

+ (User *)currentUser {
    
    static User *currentUser = nil;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        
        [[TwitterClient instance] currentUserWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"Got current User %@", responseObject);
            
            currentUser = [ User initFromJson:responseObject];
            //[currentUser dumpUserInfo];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"response error %@", [error description]);
        }];

    });
    
    return currentUser;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"screenName": @"screen_name",
             @"profileImageUrl": @"profile_image_url",
             @"userId": @"id",
             @"description": @"description",
             };
}

+ (NSValueTransformer *)profileImageUrlJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (User*) initFromJson:(NSDictionary *)dictionary {
    
    NSError *error = nil;

    User *aUser = [MTLJSONAdapter modelOfClass: User.class fromJSONDictionary: dictionary error: &error];

    return aUser;
}

- (void) dumpUserInfo {
    NSLog(@"User Name: %@ @%@", self.name, self.screenName);
    NSLog(@"User id: %d", self.userId);
    NSLog(@"Profile Image %@", self.profileImageUrl);
    NSLog(@"Description %@", self.description);
}

@end
