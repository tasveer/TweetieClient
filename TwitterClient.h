//
//  TwitterClient.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/19/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"


@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)instance;

- (void)login;

- (AFHTTPRequestOperation *)getRecentTweet:(int) limit success:(void (^)(AFHTTPRequestOperation *operation, id  responseObject))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Load more tweets at the bottom for unlimited scrolling
- (AFHTTPRequestOperation *)getMoreTweets:(int) limit until:(NSString *) lastTweetId success:(void (^)(AFHTTPRequestOperation *operation, id  responseObject))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Get current logged in user
-(AFHTTPRequestOperation *) currentUserWithSuccess:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Tweet a status
-(AFHTTPRequestOperation *) tweetStatus:(NSString *)status replyStatusId:(NSString *) statusId success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Favorite a tweet
-(AFHTTPRequestOperation *) makeFavorite:(NSString *)tweetId success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Un-Favorite a tweet
-(AFHTTPRequestOperation *) UnFavorite:(NSString *)tweetId success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Retweet a tweet
-(AFHTTPRequestOperation *) retweet:(NSString *)tweetId success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

// Remove a tweet
-(AFHTTPRequestOperation *) removeTweet:(NSString *)tweetId success:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
