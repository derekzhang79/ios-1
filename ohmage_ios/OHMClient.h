//
//  OHMClient.h
//  ohmage_ios
//
//  Created by Charles Forkish on 3/31/14.
//  Copyright (c) 2014 VPD. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@class OHMUser;
@class OHMOhmlet;
@class OHMSurvey;
@class OHMSurveyResponse;
@class OHMSurveyPromptResponse;
@class OHMReminder;
@class OHMReminderLocation;
@class GTMOAuth2Authentication;

@protocol OHMClientDelegate;

@interface OHMClient : AFHTTPSessionManager

+ (OHMClient*)sharedClient;

@property (nonatomic, weak) id<OHMClientDelegate> delegate;
@property (copy) void (^backgroundSessionCompletionHandler)();


// user
- (void)saveClientState;
- (BOOL)hasLoggedInUser;
- (OHMUser *)loggedInUser;
- (void)loginWithEmail:(NSString *)email
              password:(NSString *)password
       completionBlock:(void (^)(BOOL success, NSString *errorString))completionBlock;
- (void)loginWithGoogleAuth:(GTMOAuth2Authentication *)auth completionBlock:(void (^)(BOOL success))completionBlock;
- (void)createAccountWithName:(NSString *)name
                        email:(NSString *)email
                     password:(NSString *)password
              completionBlock:(void (^)(BOOL success, NSString *errorString))completionBlock;
- (void)logout;
- (void)clearUserData;
- (void)submitSurveyResponse:(OHMSurveyResponse *)response;

// Model
- (NSOrderedSet *)ohmlets;
- (NSArray *)reminders;
- (NSArray *)timeReminders;
- (NSArray *)reminderLocations;
- (NSArray *)surveysForOhmlet:(OHMOhmlet *)ohmlet;
- (OHMReminder *)reminderWithOhmID:(NSString *)ohmID;
- (OHMReminderLocation *)insertNewReminderLocation;
- (OHMReminderLocation *)locationWithOhmID:(NSString *)ohmID;
- (OHMSurveyResponse *)buildResponseForSurvey:(OHMSurvey *)survey;
- (OHMReminder *)buildNewReminderForSurvey:(OHMSurvey *)survey;

// Core Data
- (void)deleteObject:(NSManagedObject *)object;
- (NSFetchedResultsController *)fetchedResultsControllerWithEntityName:(NSString *)entityName
                                                               sortKey:(NSString *)sortKey
                                                             predicate:(NSPredicate *)predicate
                                                    sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                             cacheName:(NSString *)cacheName;
- (NSFetchedResultsController *)fetchedResultsControllerWithEntityName:(NSString *)entityName
                                                       sortDescriptors:(NSArray *)sortDescriptors
                                                             predicate:(NSPredicate *)predicate
                                                    sectionNameKeyPath:(NSString *)sectionNameKeyPath
                                                             cacheName:(NSString *)cacheName;

@end

@protocol OHMClientDelegate <NSObject>

- (void)OHMClientDidUpdate:(OHMClient *)client;

@end