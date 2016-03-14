//
//  CKManager.h
//  CollectionView-POC
//
//  Created by Sonny Back on 2/10/15.
//  Copyright (c) 2015 Sonny Back. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoffeeImageData.h"
#import "UserActivity.h"
@import CloudKit;
#import "ImageLoadManager.h"
#import "CoffeeImageData.h"

@interface CKManager : NSObject

// public properties
@property (strong, nonatomic) CKRecordID *userRecordID; // unique user identifier

// public methods
- (void)loadCloudKitDataWithCompletionHandler:(void (^)(NSArray *results, CKQueryCursor *cursor, NSError *error))completionHandler;
- (void)loadCloudKitDataFromCursor:(CKQueryCursor *)cursor withCompletionHandler:(void (^)(NSArray *results, CKQueryCursor *cursor, NSError *error))completionHandler;
- (void)loadRecipeDataWithCompletionHandler:(void (^)(NSArray *results, CKQueryCursor *cursor, NSError *error))completionHandler;
- (void)getUserActivityPrivateDataForCIDWithCompletionHandler:(void (^)(NSArray *results, NSError *error))completionHandler;
- (void)getUserActivityPrivateDataForRIDWithCompletionHandler:(void (^)(NSArray *results, NSError *error))completionHandler;
- (CKRecord *)createCKRecordForImage:(CoffeeImageData *)coffeeImageData;
//- (CKRecord *)createCKRecordForUserActivity:(CoffeeImageData *)coffeeImageData;
- (CKRecord *)createCKRecordForUserActivity:(UserActivity *)userActivity;
- (CKRecord *)createCKRecordForUserActivityForRecipe:(UserActivity *)userActivity;
//- (void)saveRecord:(CKRecord *)record withCompletionHandler:(void (^)(CKRecord *record, NSError *error))completionHandler;
- (void)saveRecord:(NSArray *)records withCompletionHandler:(void (^)(NSArray *records, NSError *error))completionHandler recordProgressHandler:(void (^)(double))progressHandler;
- (void)saveRecordForPrivateData:(CKRecord *)record withCompletionHandler:(void (^)(CKRecord *record, NSError *error))completionHandler;
- (void)deleteUserActivityRecord:(UserActivity *)userActivityRecord;
- (CKAccountStatus)getUsersCKStatus;
- (void)updateLikeCountForRecordID:(NSString *)recordID shouldIncrement:(BOOL)indicator withCompletionHandler:(void (^)(NSError *error))completionHandler;
@end

