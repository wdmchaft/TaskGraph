//
//  NMGAppDelegate.m
//  GraphTasks
//
//  Created by Mephi Skib on 21.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NMGAppDelegate.h"
#import "NMTaskGraphManager.h"
#import "NMGRootViewController.h"

@implementation NMGAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UINavigationController* nvc =   [[UINavigationController    alloc]  initWithRootViewController:[[NMGRootViewController  alloc]  init]];
    [nvc.navigationBar  setBarStyle:UIBarStyleBlack];
    [self.window    setRootViewController:nvc];
    
    
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];

    UILocalNotification* notification = [UILocalNotification new];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:7];
    notification.timeZone = [NSTimeZone systemTimeZone];
    notification.alertBody = @"IT WORKED!";
    
    [UIApplication sharedApplication]. applicationIconBadgeNumber = 10;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [[NMTaskGraphManager sharedManager]saveContext];
}



@end
