//
//  Tweet.h
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/20/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import <Mantle.h>
#import "User.h"
#import "TwitterClient.h"


@interface Tweet : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) User          *creator;
@property (strong, nonatomic) User          *retweeter;
@property (strong, nonatomic) NSString      *tweetText;
@property (strong, nonatomic) NSString      *retweetText;
@property (strong, nonatomic) NSDate        *createdAt;
@property (strong, nonatomic) NSDate        *retweetedAt;
@property (nonatomic)         NSUInteger    favCount;
@property (nonatomic)         NSUInteger    retweetFavCount;
@property (nonatomic)         NSUInteger    retweetCount;
@property (nonatomic)         NSUInteger    retweetersRetweetCount;  // Number of times a retweeted tweet has already been retweeted.
@property (strong, nonatomic) NSDictionary  *rawTweet;
@property (nonatomic)         BOOL          favorited;

+ (Tweet *)tweetFromJson:(NSDictionary *) dictionary;

- (NSString *)timeSinceNow;

//- (Tweet *)makeFavorite:(UIButton *)sender; // Toggles a Twitter client Fav and optionally highlights the fav button and return the modified tweet
//- (Tweet *)retweet:(UIButton *)sender;     // Retweets and return the new Tweet object

- (AFHTTPRequestOperation *)makeFavoritesWithsuccess:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)retweetWithsuccess:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


- (BOOL) checkAndRecordIfFav; // Checks if this tweet has been favorited by the user
- (BOOL) checkAndRecordIfRetweeted;
- (NSUInteger) favoriteCount;
- (NSUInteger) numOfRetweets;
- (NSString *) getTweetId;


- (void) dumpTweetInfo;

@end
