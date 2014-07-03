//
//  TwitterClient.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/19/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "TwitterClient.h"

#define TWITTER_BASE_URL [NSURL URLWithString:@"https://api.twitter.com/"]

#define TWITTER_CONSUMER_KEY @"EA3gETCfigjYsxy8RVrDbVJai"
#define TWITTER_CONSUMER_SECRET @"GM5s9YRuHbCDd9aaiHdOiYBh7hC2mZHVAaIDOYu464wnx3w5xX"

@implementation TwitterClient

// Singelton
+ (TwitterClient *)instance{
    static TwitterClient *instance = nil;
    
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        instance = [[TwitterClient alloc] initWithBaseURL:TWITTER_BASE_URL consumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_CONSUMER_SECRET];
    });
    
    return instance;
}

/*
- (BOOL)isAuthorized {

    return [self isAuthorized];
}
 */

- (void)login {
    // Request my request token
    [self.requestSerializer removeAccessToken];
    
    [ self fetchRequestTokenWithPath:@"oauth/request_token" method:@"POST" callbackURL:[NSURL URLWithString:@"koltweetie://oauth"] scope:nil success:^(BDBOAuthToken *requestToken) {
        NSLog(@"Got the request token");
        // Now get the access code, this would take the user to a twitter mobile screen for login credentials
        // and would return the control back to this application along with access code.
        NSString *authURL = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURL]];
        
    } failure:^(NSError *error) {
        NSLog(@"failure to get the request token %@", [error description]);
    }];
}

- (AFHTTPRequestOperation *)getRecentTweet:(int) limit success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    
    return [self GET:@"1.1/statuses/home_timeline.json" parameters:@{@"count": @(limit)} success:success failure:failure ];
    
    /*
    return [self GET:@"1.1/statuses/home_timeline.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"timeline: %@", responseObject);
        // Do something to convert response object to an NSarray like what we did for rotten tomatoes.
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"No timeline %@", [error description]);
    }];
     */
}

- (AFHTTPRequestOperation *)getMoreTweets:(int) limit until:(NSString *) lastTweetId success:(void (^)(AFHTTPRequestOperation *operation, id  responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    return [self GET:@"1.1/statuses/home_timeline.json" parameters:@{@"count": @(limit),
                                                                       @"max_id": lastTweetId}  success:success failure:failure ];
}

// Get the current user
-(AFHTTPRequestOperation *) currentUserWithSuccess:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:success failure:failure];

    /*
    return [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        User *currentUser = [User userWithDictionary:responseObject];
        [User setCurrentUser:currentUser];
        NSLog(@"User logged in!!");
    } failure:failure];
     */
}

// Post a status

-(AFHTTPRequestOperation *) tweetStatus:(NSString *)status replyStatusId:(NSString *) statusId success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSDictionary *statusUpdateOptions = statusId ? @{@"status": status, @"in_reply_to_status_id": statusId} : @{@"status": status};
    
    return [self POST:@"1.1/statuses/update.json" parameters:statusUpdateOptions success:success failure:failure];

    //return [self POST:@"1.1/statuses/update.json" parameters:@{@"status": status, @"in_reply_to_status_id": statusId} success:success failure:failure];
    
}

// Favorite a tweet
-(AFHTTPRequestOperation *) makeFavorite:(NSString *)tweetId success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self POST:@"1.1/favorites/create.json" parameters:@{@"id": tweetId} success:success failure:failure];
    
}

// Un-Favorite a tweet
-(AFHTTPRequestOperation *) UnFavorite:(NSString *)tweetId success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self POST:@"1.1/favorites/destroy.json" parameters:@{@"id": tweetId} success:success failure:failure];
    
}

// Retweet a tweet
-(AFHTTPRequestOperation *) retweet:(NSString *)tweetId success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *postCommand = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweetId];
    return [self POST:postCommand parameters:@{@"id": tweetId} success:success failure:failure];
    
}

// Remove a tweet
-(AFHTTPRequestOperation *) removeTweet:(NSString *)tweetId success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *postCommand = [NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", tweetId];
    return [self POST:postCommand parameters:@{@"id": tweetId} success:success failure:failure];
    
}

// Get Mentions
-(AFHTTPRequestOperation *) getMentions:(int) limit success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:@"1.1/statuses/mentions_timeline.json" parameters:@{@"count": @(limit)} success:success failure:failure];
    
}

// Get User Status
-(AFHTTPRequestOperation *) getUserStatusWithUserId:(NSString *)userId numTweets:(int)limit success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:@"1.1/statuses/user_timeline.json" parameters:@{@"user_id": userId, @"count": @(limit)} success:success failure:failure];
    
}

- (AFHTTPRequestOperation *)getMoreUserStatus:(NSString *)userId withLimit:(int) limit until:(NSString *) lastTweetId success:(void (^)(AFHTTPRequestOperation *operation, id  responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    return [self GET:@"1.1/statuses/user_timeline.json" parameters:@{@"user_id": userId, @"count": @(limit),
                                                                     @"max_id": lastTweetId}  success:success failure:failure ];
}

@end
