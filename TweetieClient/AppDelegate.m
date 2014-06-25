//
//  AppDelegate.m
//  TweetieClient
//
//  Created by Hunaid Hussain on 6/19/14.
//  Copyright (c) 2014 kolekse. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "TimelineViewController.h"
#import "NSURL+dictionaryFromQueryString.h"
#import "TwitterClient.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    TwitterClient *client = [TwitterClient instance];
    
    //[client deauthorize];
    //[client.requestSerializer removeAccessToken];


    if ([client isAuthorized]) {
        NSLog(@"client is authorized");
        TimelineViewController    *tvc = [[TimelineViewController alloc] init ];
        UINavigationController    *nvc = [[ UINavigationController alloc] initWithRootViewController:tvc ];
        self.window.rootViewController = nvc;
        
        nvc.navigationBar.barTintColor = UIColorFromRGB(0x067AB5);

    } else {
        NSLog(@"Not authorized yet...");
        LoginViewController       *lvc = [[LoginViewController alloc] init];
        //TimelineViewController    *tvc = [[TimelineViewController alloc] init ];
        //UINavigationController    *nvc = [[ UINavigationController alloc] initWithRootViewController:tvc ];
        self.window.rootViewController = lvc;
        //[self.window.rootViewController presentModalViewController:lvc animated:YES];

        //TimelineViewController    *tvc = [[TimelineViewController alloc] init ];
        //[self.window.rootViewController addChildViewController:tvc];

    }

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    //NSLog(@"url.scheme %@ url.host %@", url.scheme, url.host);
    if ([url.scheme isEqualToString:@"koltweetie"])
    {
        if ([url.host isEqualToString:@"oauth"])
        {
            NSDictionary *parameters = [url dictionaryFromQueryString];
            //NSLog(@"parameters: %@", parameters);
            if (parameters[@"oauth_token"] && parameters[@"oauth_verifier"]) {
                
                
                /*
                [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
                    self.window.rootViewController = tvc;
                }];
                [self.window makeKeyAndVisible];
                 */
                
                

                TwitterClient *client = [TwitterClient instance];
                [client fetchAccessTokenWithPath:@"/oauth/access_token"
                                          method:@"POST"
                                    requestToken:[BDBOAuthToken tokenWithQueryString:url.query]
                                         success:^(BDBOAuthToken *accessToken) {
                                             NSLog(@"Access token granted");
                                             [client.requestSerializer saveAccessToken:accessToken];
                                             
                                             [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
                                                 TimelineViewController    *tvc = [[TimelineViewController alloc] init ];
                                                 UINavigationController    *nvc = [[ UINavigationController alloc] initWithRootViewController:tvc ];
                                                 self.window.rootViewController = nvc;
                                                 nvc.navigationBar.barTintColor = UIColorFromRGB(0x067AB5);
                                                 NSLog(@"Pushing time line view controller");
                                             }];

                                             /*
                                             TimelineViewController    *tvc = [[TimelineViewController alloc] init ];
                                             UINavigationController    *nvc = [[ UINavigationController alloc] initWithRootViewController:tvc ];
                                             self.window.rootViewController = nvc;
                                             nvc.navigationBar.barTintColor = UIColorFromRGB(0x067AB5);
                                              */

                                             //NSLog(@"Pushing time line view controller");

                                         } failure:^(NSError *error) {
                                             NSLog(@"Access token error %@", [error description]);
                                         }];
                
            }
            return YES;
        }
    }
    return NO;
}

@end
