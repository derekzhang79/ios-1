//
//  OHMAppDelegate.m
//  ohmage_ios
//
//  Created by Charles Forkish on 3/7/14.
//  Copyright (c) 2014 VPD. All rights reserved.
//

#import "OHMAppDelegate.h"
#import "OHMSurveysViewController.h"
#import "OHMLoginViewController.h"
#import "OHMCreateAccountViewController.h"
#import "OHMReminderManager.h"
#import "OHMLocationManager.h"
#import "OHMUser.h"

#import <GooglePlus/GooglePlus.h>

#import "NSURL+QueryDictionary.h"

@interface OHMAppDelegate ()

@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation OHMAppDelegate

/**
 *  application:didFinishLaunchingWithOptions
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeApplicationState];
    
    if (![[OHMClient sharedClient] hasLoggedInUser]) {
        [self.window.rootViewController presentViewController:[[OHMLoginViewController alloc] init]
                                                     animated:NO
                                                   completion:nil];
    }
    else {
        
        // handle reminder notification
        UILocalNotification *notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (notification != nil) {
            OHMSurveysViewController *vc = [[(UINavigationController *)self.window.rootViewController viewControllers] firstObject];
            [vc handleSurveyReminderNotification:notification];
            [[OHMReminderManager sharedReminderManager] processFiredLocalNotification:notification];
        }
        
        // start tracking location for reminders and survey response metadata
        if ([CLLocationManager locationServicesEnabled]) {
            OHMLocationManager *appLocationManager = [OHMLocationManager sharedLocationManager];
            [appLocationManager.locationManager startUpdatingLocation];
        }
    }
    
    return YES;
}

/**
 *  application:didReceiveLocalNotification
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        // If we're the foreground application, then show an alert view as one would not have been
        // presented to the user via the notification center.
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                            message:notification.alertBody
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        
        [alertView show];
    }
    else {
        UIViewController *vc = self.navigationController.viewControllers.firstObject;
        if ([vc isKindOfClass:[OHMSurveysViewController class]]) {
            [(OHMSurveysViewController *)vc handleSurveyReminderNotification:notification];
        }
    }
    
    [[OHMReminderManager sharedReminderManager] processFiredLocalNotification:notification];
}

/**
 *  application:handleEventsForBackgroundURLSession
 */
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
}

/**
 *  applicationWillResignActive
 */
- (void)applicationWillResignActive:(UIApplication *)application
{
    [[OHMClient sharedClient] saveClientState];
}

/**
 *  applicationDidBecomeActive
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[OHMReminderManager sharedReminderManager] synchronizeReminders];
}

/**
 *  initializeApplicationState
 */
- (void)initializeApplicationState {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    OHMSurveysViewController * vc = [[OHMSurveysViewController alloc] initWithOhmletIndex:0];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    self.navigationController = nav;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}


#pragma mark - URL Handling

- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation
{
    
    NSString *scheme = url.scheme;
    if ([scheme isEqualToString:kGoogleLoginUrlScheme]) {
        NSLog(@"handle google login url: %@", url);
        return [GPPURLHandler handleURL:url
                      sourceApplication:sourceApplication
                             annotation:annotation];
    }
    else if ([scheme isEqualToString:kOhmageUrlScheme]) {
        return [self handleOhmageURL:url];
    }
    
    return NO;
}

- (BOOL)handleOhmageURL:(NSURL *)url
{
    NSLog(@"handle ohmlet invitation url: %@", url);
    if (![url.lastPathComponent isEqualToString:@"invitation"]) {
        return NO;
    }
    
    OHMClient *client = [OHMClient sharedClient];
    
    if (url.uq_queryDictionary[kUserInvitationIdKey] != nil) {
        if (client.hasLoggedInUser) {
            if ([url.uq_queryDictionary[@"email"] isEqualToString:client.loggedInUser.email]) {
                [client handleOhmletInvitationURL:url];
            }
            else {
                [self createUserWithInvitationURL:url];
            }
        }
    }
    else {
        [client handleOhmletInvitationURL:url];
    }
    
    return YES;
}

- (void)createUserWithInvitationURL:(NSURL *)url
{
    OHMClient *client = [OHMClient sharedClient];
    client.pendingInvitationURL = url;
    
    if (client.hasLoggedInUser) {
        if ([url.uq_queryDictionary[@"email"] isEqualToString:client.loggedInUser.email]) {
            [client handleOhmletInvitationURL:url];
            return;
        }
        else {
            [client logout];
        }
    }
    
    [self initializeApplicationState];
    OHMLoginViewController *login = [[OHMLoginViewController alloc] init];
    OHMCreateAccountViewController *create = [[OHMCreateAccountViewController alloc] init];
    [self.window.rootViewController presentViewController:login
                                                 animated:NO
                                               completion:nil];
    [login presentViewController:create animated:NO completion:nil];
}

@end
