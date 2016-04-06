//
//  AppDelegate.m
//  SkiApp
//
//  Created by Kovács Kristóf on 19/02/16.
//  Copyright © 2016 Kovács Kristóf. All rights reserved.
//

#import "AppDelegate.h"

#import <SKMaps/SKMaps.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "Backendless.h"
#import "Config.h"

//TODO: (FOC) please re-structure the imports
//TODO: (FOC) e.g.
// class' header
// -new line-
// SDKs
// -new line-
// other model files
// -new line-
// custom view controllers
// -new line-
// custom views/other ui

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [backendless initApp:kBackendlessAppId secret:kBackendlessIosSecretKey version:kBackEndlessVersion];
    
    @try {
        [backendless initAppFault];
    }
    @catch (Fault *fault) {
        NSLog(@"didFinishLaunchingWithOptions: %@", fault);
    }
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    SKMapsInitSettings* settings = [[SKMapsInitSettings alloc]init];
    settings.mapDetailLevel = SKMapDetailLevelLight;
    
    [[SKMapsService sharedInstance] initializeSKMapsWithAPIKey:kSKMapsAppId settings:settings];
     
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    if (!token) {
        NSLog(@"!!! Token = null !!!");
        return false;
    }
    
    NSDictionary *fieldsMapping = @{
                                    @"email" : @"email",
                                    @"id" : @"facebookId",
                                    @"name" : @"name",
                                    @"first_name": @"first_name",
                                    @"last_name" : @"last_name"
                                    };
    
//TODO: (FOC) could use a define instead of these if 0
    
    @try {
        BackendlessUser *user = [backendless.userService loginWithFacebookSDK:token fieldsMapping:fieldsMapping];
        NSLog(@"USER: %@", user);
    }
    @catch (Fault *fault) {
        NSLog(@"openURL: %@", fault);
    }
    
    return handled;
}

/*-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation
{
    BackendlessUser *user = [backendless.userService handleOpenURL:url];
    if (user) {
        // apply your logic for the successful login. For example, switch the view
    }
    return YES;
}*/

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
