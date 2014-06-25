//
//  Tweet.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/20/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "Tweet.h"
#import "User.h"
#import "NSDate+DateTools.h"
#import "TwitterClient.h"

@interface Tweet()

@property (nonatomic) BOOL retweet;


@end

@implementation Tweet

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"creator":                    @"user",
             @"retweeter":                  @"retweeted_status.user",
             @"tweetText":                  @"text",
             @"retweetText":                @"retweeted_status.text",
             @"createdAt":                  @"created_at",
             @"retweetedAt":                @"retweeted_status.created_at",
             @"retweetFavCount":            @"retweeted_status.favorite_count",
             @"retweetersRetweetCount":     @"retweeted_status.retweet_count",
             @"favCount":                   @"favorite_count",
             @"retweetCount":               @"retweet_count",
            };
}

// To do create reversible transformer
+ (NSValueTransformer *)creatorJSONTransformer {

    return [MTLValueTransformer transformerWithBlock:^(NSDictionary *dictionary) {
        
        NSError *error = nil;

        //NSLog(@"Creating user with dictionary %@", dictionary);
        //NSLog(@"keys of dictionary %@", [dictionary allKeys]);
        User *createdBy = [MTLJSONAdapter modelOfClass: User.class fromJSONDictionary:dictionary error: &error];
        
        return createdBy;
        
    }];
}

// To do create reversible transformer
+ (NSValueTransformer *)retweeterJSONTransformer {
    
    return [MTLValueTransformer transformerWithBlock:^(NSDictionary *dictionary) {
        
        NSError *error = nil;
        //NSLog(@"Creating retweeter with dictionary %@", dictionary);

        User *retweetedBy = [MTLJSONAdapter modelOfClass: User.class fromJSONDictionary:dictionary error: &error];
        
        return retweetedBy;
        
    }];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        //NSLog(@"create at str: %@ date: %@", str, [self.dateFormatter dateFromString:str]);
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (NSValueTransformer *)retweetedAtJSONTransformer {
    
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        //NSLog(@"retweeted at str: %@ date: %@", str, [self.dateFormatter dateFromString:str]);
        return [self.dateFormatter dateFromString:str];
    } reverseBlock:^(NSDate *date) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

+ (Tweet *) tweetFromJson:(NSDictionary *) dictionary {
    
    NSError *error = nil;
    
    Tweet *aTweet = [MTLJSONAdapter modelOfClass: Tweet.class fromJSONDictionary: dictionary error: &error];
    
    aTweet.rawTweet = dictionary;
    
    [aTweet checkAndRecordIfFav];

    return aTweet;
}

+ (NSDateFormatter *)dateFormatter {
    
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        //dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        dateFormatter.dateFormat = @"EEE LLL dd HH:mm:ss Z yyyy";

    });
    
    return dateFormatter;
}

- (NSString *)timeSinceNow
{
    NSTimeInterval timeSince;
    
    //NSLog(@"retweetedAt: %@", self.retweetedAt);
    //NSLog(@"createdAt: %@", self.createdAt);
    if (self.retweetedAt) {
        //NSLog(@"retweetedAt: %@", self.retweetedAt);
        timeSince = [self.retweetedAt timeIntervalSinceNow];
    } else {
        //NSLog(@"createdAt: %@", self.createdAt);
        timeSince = [self.createdAt timeIntervalSinceNow];
    }
    
    //NSLog(@"created at %@ tineSince %f", self.createdAt, timeSince);

    NSDate *timeAgoDate = [NSDate dateWithTimeIntervalSinceNow:timeSince];
    
    return timeAgoDate.shortTimeAgoSinceNow;

}

- (BOOL) checkAndRecordIfFav {
    
    if (self.retweetedAt == nil) {
        self.favorited = [self.rawTweet[@"favorited"] boolValue];
    } else {
        NSDictionary *retweetedStatus = self.rawTweet[@"retweeted_status"];
        self.favorited = [retweetedStatus[@"favorited"] boolValue];
    }
    return self.favorited;
}

- (BOOL) checkAndRecordIfRetweeted {
    if (self.retweetedAt == nil) {
        self.retweet = [self.rawTweet[@"retweeted"] boolValue];
    } else {
        NSDictionary *retweetedStatus = self.rawTweet[@"retweeted_status"];
        self.retweet = [retweetedStatus[@"retweeted"] boolValue];
    }
    return self.retweet;
}

- (BOOL) didRetweet {
    
    return self.retweet;
}

- (NSUInteger) favoriteCount {
    
    if (self.retweetedAt == nil) {
        return self.favCount;
    } else {
        return self.retweetFavCount;
    }

}

- (NSUInteger) numOfRetweets {
    
    if (self.retweetedAt == nil) {
        return self.retweetCount;
    } else {
        return self.retweetersRetweetCount;
    }
}

- (NSString *) getTweetId {
    return self.rawTweet[@"id_str"];
}

- (AFHTTPRequestOperation *) makeFavoritesWithsuccess:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
 
    NSString *tweetId;
    
    [self checkAndRecordIfFav];
    
    if (self.retweetedAt == nil) {
        tweetId = self.rawTweet[@"id_str"];
    } else {
        NSDictionary *retweetedStatus = self.rawTweet[@"retweeted_status"];
        tweetId = retweetedStatus[@"id_str"];
    }
    //NSLog(@"Current state Favorited: %d", self.favorited);
    
    if (self.favorited) {
        //NSLog(@"Going to Unfav");
        return [[TwitterClient instance] UnFavorite:tweetId success:success failure:failure];
    } else {
        //NSLog(@"Going to fav");
        return [[TwitterClient instance] makeFavorite:tweetId success:success failure:failure];
    }
}

- (AFHTTPRequestOperation *) retweetWithsuccess:(void (^)(AFHTTPRequestOperation *, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    NSString *tweetId;
    BOOL isAlreadyRetweeted = [self checkAndRecordIfRetweeted];
    //NSLog(@"isAlreadyRetweeted %hhd", isAlreadyRetweeted);
    
    if (self.retweetedAt == nil) {
        tweetId = self.rawTweet[@"id_str"];
    } else {
        NSDictionary *retweetedStatus = self.rawTweet[@"retweeted_status"];
        tweetId = retweetedStatus[@"id_str"];
    }
    
    if (!isAlreadyRetweeted) {
        return [[TwitterClient instance] retweet:tweetId success:success failure:failure];
    } else {
        //NSLog(@"Calling unretweet on twitter");
        return [[TwitterClient instance] removeTweet:tweetId success:success failure:failure];
    }
}

- (void) dumpTweetInfo {
    
    NSLog(@"------------------------------------------------------------------------------------");
    //NSLog(@"creator: %@", self.creator);
    if (self.creator) {
        NSLog(@"creator:");
        [self.creator dumpUserInfo];
    }
    if (self.retweeter) {
        NSLog(@"Retweeter:");
        [self.retweeter dumpUserInfo];
    }
    
    if (self.tweetText) {
        NSLog(@"Tweet: %@", self.tweetText);
    } else if (self.retweetText) {
        NSLog(@"retweet: %@", self.retweetText);
    }
    
    if (self.retweetedAt) {
        NSLog(@"retweeted At: %@", self.retweetedAt);
        NSLog(@"retweet count %d, favorite count %d", self.retweetersRetweetCount, self.retweetFavCount);
        NSLog(@"date format MM/dd/yy : %@", [self.retweetedAt formattedDateWithFormat:@"MM/dd/yy"]);
        NSLog(@"date format hh:mm a : %@", [self.retweetedAt formattedDateWithFormat:@"hh:mm a"]);
        
    } else {
        NSLog(@"created At: %@", self.createdAt);
        NSLog(@"retweet count %d, favorite count %d", self.retweetCount, self.favCount);
        NSLog(@"date format MM/dd/yy : %@", [self.createdAt formattedDateWithFormat:@"MM/dd/yy"]);
        NSLog(@"date format hh:mm a : %@", [self.createdAt formattedDateWithFormat:@"hh:mm a"]);
    }
    NSLog(@"------------------------------------------------------------------------------------");
    NSLog(@"\n");


}

@end
