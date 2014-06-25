# Twitter client
==============

A Twitter client using Oauth 1.0a. Uses BDBOAuth1RequestOperationManager. Mantle has been used to extract twitter data to create models for Users and Tweets. Auto layout and dynamic sizing is used to control the height of the Table rows.


Time Spent: 20 Hours

**Completed all required features**
- User can sign in using OAuth login flow
- User can view last 20 tweets from their home timeline
- The current signed in user will be persisted across restarts
- In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.
- User can pull to refresh
- User can compose a new tweet by tapping on a compose button.
- User can tap on a tweet to view it, with controls to retweet, favorite, and reply.

**Optional features implemented**
- When composing, you should have a countdown in the upper right for the tweet limit.
- After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- Retweeting and favoriting should increment the retweet and favorite count.
- User should be able to -unretweet- / unfavorite and should decrement the -retweet- and favorite count. Unretweet not implemented.
- Replies should be prefixed with the username and the reply_id should be set when posting the tweet,
- User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.

     
     
Here are the screen shots

![Twitter Client Demo](https://github.com/tasveer/Yelp/blob/master/YelpDemo.gif?raw=true)
