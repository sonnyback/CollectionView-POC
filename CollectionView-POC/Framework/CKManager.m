//
//  CKManager.m
//  CollectionView-POC
//
//  Created by Sonny Back on 2/10/15.
//  Copyright (c) 2015 Sonny Back. All rights reserved.
//

#import "CKManager.h"
#import "ImageLoadManager.h"
#import "CoffeeImageData.h"
#import <CoreLocation/CoreLocation.h>

@interface CKManager()

@property (nonatomic, readonly) CKContainer *container;
@property (nonatomic, readonly) CKDatabase *publicDatabase;
@property (nonatomic, readonly) CKDatabase *privateDatabase;
@property (strong, nonatomic) CKQueryCursor *cursorProperty;
@end

@implementation CKManager

// Default initializer - instantiates the public and private databases
- (instancetype)init {
    
    self = [super init];
    if (self) {
        _container = [CKContainer defaultContainer];
        _publicDatabase = [_container publicCloudDatabase];
        _privateDatabase = [_container privateCloudDatabase];
    }
    
    return self;
}

#define TWENTY_FIVE 25
/**
 * Method to load initial data from CloudKit as the app loads. Also, this method is called if
 * the user taps the reload button. It uses CKQueryOperation to be able to load the data in chunks
 * and get per record progress updates.
 * @param NSArray for results set
 * @param CKQueryCursor to mark the cursor point of last record fetched
 * @param NSError if error is returned
 * @param CompletionHandler - will be returned when query/operation is completed
 * @return void
 */
- (void)loadCloudKitDataWithCompletionHandler:(void (^)(NSArray *, CKQueryCursor *, NSError *))completionHandler {
    NSLog(@"INFO: Entered loadInitialCloudKitDataWithCompletionHandler...");
    NSMutableArray *tempResultsSet = [[NSMutableArray alloc] init];
    __block NSArray *results;
    // just for initial testing...give me all records
    NSPredicate *predicate = [NSPredicate predicateWithValue:true];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Recipe != 1"];
    //create the query
    CKQuery *query = [[CKQuery alloc] initWithRecordType:COFFEE_IMAGE_DATA_RECORD_TYPE predicate:predicate];
    CKQueryOperation *ckQueryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    //__weak CKQueryOperation *weakself = ckQueryOperation;
    //ckQueryOperation.resultsLimit = CKQueryOperationMaximumResults; // get all the results
    ckQueryOperation.resultsLimit = TWENTY_FIVE;
    
    // process each record returned
    ckQueryOperation.recordFetchedBlock = ^(CKRecord *record) {
        NSLog(@"RecordFetchBlock returned CID record: %@", record.recordID.recordName);
        [tempResultsSet addObject:record];
    };
    // query has completed
    ckQueryOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
        results = [tempResultsSet copy];
        [tempResultsSet removeAllObjects]; // get rid of the temp results array
        /*if (cursor != nil) {
            NSLog(@"INFO: More records to fetch from CloudKit!");
            //CKQueryOperation *newOperation = [[CKQueryOperation alloc] initWithCursor:cursor];
            //newOperation.recordFetchedBlock = weakself.recordFetchedBlock;
            //newOperation.queryCompletionBlock = weakself.queryCompletionBlock;
            //[self.publicDatabase addOperation:newOperation];
            [self loadCloudKitDataFromCursor:cursor withCompletionHandler:^(NSArray *results, CKQueryCursor *cursor, NSError *error) {
                if (!error) {
                    if ([results count] > 0) {
                        NSLog(@"INFO: loadCloudKitDataWithCompletionHandler - cursor block has %lu results!", (unsigned long)[results count]);
                        results = [tempResultsSet copy];
                        [tempResultsSet removeAllObjects]; // get rid of the temp results array
                        //completionHandler(results, cursor, error);
                    }
                }
            }];
        }*/
        NSLog(@"INFO: loadCloudKitDataWithCompletionHandler - sending back completion handler with %lu results!", (unsigned long)[results count]);
        completionHandler(results, cursor, error);
    };
    
    [self.publicDatabase addOperation:ckQueryOperation];
}

/**
 * Method called by loadCloudKitDataWithCompletionHandler if there is a cursor object. This method is almost identical
 * to it's calling method, but takes a CKQueryCursor in addition.
 * @param CKQueryCursor - cursor marking last record fetched
 * @param NSArray for results set
 * @param CKQueryCursor to mark the cursor point of last record fetched
 * @param NSError if error is returned
 * @param CompletionHandler - will be returned when query/operation is completed
 * @return void
 */
- (void)loadCloudKitDataFromCursor:(CKQueryCursor *)cursor withCompletionHandler:(void (^)(NSArray *, CKQueryCursor *, NSError *))completionHandler {
    NSLog(@"INFO: Entered loadCloudKitDataFromCursorWithCompletionHandler...");
    NSMutableArray *cursorResultSet = [[NSMutableArray alloc] init];
    __block NSArray *results;
    
    if (cursor) { // make sure we have a cursor to continue from
        //NSLog(@"INFO: Preparing to load records from cursor...");
        CKQueryOperation *cursorOperation = [[CKQueryOperation alloc] initWithCursor:cursor];
        cursorOperation.resultsLimit = TWENTY_FIVE;
        
        // processes for each record returned
        cursorOperation.recordFetchedBlock = ^(CKRecord *record) {
            NSLog(@"RecordFetchBlock returned from cursor CID record: %@", record.recordID.recordName);
            [cursorResultSet addObject:record];
        };
        // query has completed
        cursorOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
            results = [cursorResultSet copy];
            [cursorResultSet removeAllObjects]; // get rid of the temp results array
            //completionHandler(results, cursor, error);
            if (cursor) {
                //NSLog(@"INFO: Calling self to fetch more data from cursor point...");
                [self loadCloudKitDataFromCursor:cursor withCompletionHandler:^(NSArray *results, CKQueryCursor *cursor, NSError *error) {
                    results = [cursorResultSet copy];
                    [cursorResultSet removeAllObjects]; // get rid of the temp results array
                    //completionHandler(results, cursor, error);
                }];
            }
            NSLog(@"INFO: loadCloudKitDataFromCursor: WithCompletionHandler - sending back completion handler with %lu results!", (unsigned long)[results count]);
            completionHandler(results, cursor, error);
        };
        
        [self.publicDatabase addOperation:cursorOperation];
    }
    
}

- (void)loadRecipeDataWithCompletionHandler:(void (^)(NSArray *, CKQueryCursor *, NSError *))completionHandler {
    NSLog(@"INFO: Entered loadRecipeDataWithCompletionHandler...");
    
    NSMutableArray *recipeResultSet = [[NSMutableArray alloc] init];
    __block NSArray *recipeResults;
    // get all the results for this Record type
    NSPredicate *recipePredicate = [NSPredicate predicateWithValue:true];
    // create the query
    CKQuery *recipeQuery = [[CKQuery alloc] initWithRecordType:RECIPE_IMAGE_DATA_RECORD_TYPE predicate:recipePredicate];
    CKQueryOperation *recipeQueryOperation = [[CKQueryOperation alloc] initWithQuery:recipeQuery];
    recipeQueryOperation.resultsLimit = CKQueryOperationMaximumResults; // get all the results
    
    // process each record returned
    recipeQueryOperation.recordFetchedBlock = ^(CKRecord *record) {
        NSLog(@"RecordFetchBlock returned RID record: %@", record.recordID.recordName);
        [recipeResultSet addObject:record];
    };
    
    // query has completed
    recipeQueryOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
        recipeResults = [recipeResultSet copy];
        [recipeResultSet removeAllObjects]; // get rid of the temp results array
        completionHandler(recipeResults, cursor, error);
    };
    
    [self.publicDatabase addOperation:recipeQueryOperation];
}

- (void)getUserActivityPrivateDataForCIDWithCompletionHandler:(void (^)(NSArray *results, NSError *error))completionHandler {
    NSLog(@"INFO: Entered getUserActivityPrivateDataForCIDWithCompletionHandler...");
    
    NSPredicate *predicate = [NSPredicate predicateWithValue:true]; // give all results
    //CKQuery *query = [[CKQuery alloc] initWithRecordType:USER_ACTIVITY_RECORD_TYPE predicate:predicate];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:USER_ACTIVITY_IMAGES_RECORD_TYPE predicate:predicate];
    
    // execute the query
    [self.privateDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        completionHandler(results, error);
    }];
}

- (void)getUserActivityPrivateDataForRIDWithCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler {
    NSLog(@"INFO: Entered getUserActivityPrivateDataForRIDWithCompletionHandler...");
    
    NSPredicate *predicate = [NSPredicate predicateWithValue:true]; // give all results
    CKQuery *query = [[CKQuery alloc] initWithRecordType:USER_ACTIVITY_RECIPES_RECORD_TYPE predicate:predicate];
    
    // execute the query
    [self.privateDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        completionHandler(results, error);
    }];
}

/**
 * Method for preparing a CKRecord before saving to CloudKit.
 * CKRecord will contain recent photo taken and prepared as CID object.
 *
 * @param CoffeeImageData*
 * @return CKRecord*
 */
- (CKRecord *)createCKRecordForImage:(CoffeeImageData *)coffeeImageData {
    
    NSLog(@"Entered createCKRecordForImage...");
    //NSUInteger randomNumber = arc4random() % 100;
    //CKRecordID *wellKnownID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"recordID%ld", (long)randomNumber]];
    //CKRecord *CIDRecord = [[CKRecord alloc] initWithRecordType:@"CoffeeImageData" recordID:wellKnownID];
    CKRecord *CIDRecord = [[CKRecord alloc] initWithRecordType:COFFEE_IMAGE_DATA_RECORD_TYPE];
    CLLocation *cidLocation = [[CLLocation alloc] initWithLatitude:[coffeeImageData.latitude doubleValue] longitude:[coffeeImageData.longitude doubleValue]];
    CIDRecord[IMAGE_BELONGS_TO_USER] = [NSNumber numberWithBool:coffeeImageData.imageBelongsToCurrentUser];
    //CIDRecord[@"ImageName"] = [NSString stringWithFormat:coffeeImageData.imageName, @"%d", randomNumber];
    CIDRecord[IMAGE_NAME] = coffeeImageData.imageName;
    CIDRecord[IMAGE_DESCRIPTION] = coffeeImageData.imageDescription;
    CIDRecord[USER_ID] = coffeeImageData.userID;
    CIDRecord[RECIPE] = [NSNumber numberWithBool:coffeeImageData.isRecipe];
    CIDRecord[LIKED] = [NSNumber numberWithBool:coffeeImageData.isLiked];
    CIDRecord[LOCATION] = cidLocation;
    CKAsset *photoAsset = [[CKAsset alloc] initWithFileURL:coffeeImageData.imageURL];
    CIDRecord[IMAGE] = photoAsset;
    
    return CIDRecord;
}

/**
 * Method for preparing a CKRecord before saving to user's private database in CloudKit.
 * Creates a CKReference to the CID record from the public CoffeeImageData record type.
 *
 * @param CoffeeImageData*
 * @return CKRecord*
 */
/*- (CKRecord *)createCKRecordForUserActivity:(CoffeeImageData *)coffeeImageData {
    
    NSLog(@"Entered createCKRecordForUserActivity...");
    CKRecord *userActivityRecord = [[CKRecord alloc] initWithRecordType:USER_ACTIVITY_RECORD_TYPE];
    CKReference *cidReference = [[CKReference alloc] initWithRecordID:[[CKRecordID alloc] initWithRecordName:coffeeImageData.recordID] action:CKReferenceActionDeleteSelf];
    userActivityRecord[COFFEE_IMAGE_DATA_RECORD_TYPE] = cidReference;
    //userActivityRecord[RECORD_ID] = coffeeImageData.recordID;
    
    return userActivityRecord;
}*/

- (CKRecord *)createCKRecordForUserActivity:(UserActivity *)userActivity {
    
    NSLog(@"INFO: Entered createCKRecordForUserActivity...");
    if (userActivity.cidReference) {
        NSLog(@"INFO: Preparing CKRecord for CID!");
        CKRecord *userActivityRecord = [[CKRecord alloc] initWithRecordType:USER_ACTIVITY_IMAGES_RECORD_TYPE];
        CKReference *cidReference = [[CKReference alloc] initWithRecordID:[[CKRecordID alloc] initWithRecordName:userActivity.cidReference.recordID] action:CKReferenceActionDeleteSelf];
        userActivityRecord[COFFEE_IMAGE_DATA_RECORD_TYPE] = cidReference;
        
        return userActivityRecord;
    } else if  (userActivity.ridReference) {
        NSLog(@"INFO: Preparing CKRecord for RID!");
        CKRecord *userActivityRecord = [[CKRecord alloc] initWithRecordType:USER_ACTIVITY_RECIPES_RECORD_TYPE];
        CKReference *ridReference = [[CKReference alloc] initWithRecordID:[[CKRecordID alloc] initWithRecordName:userActivity.ridReference.recordID] action:CKReferenceActionDeleteSelf];
        userActivityRecord[RECIPE_IMAGE_DATA_RECORD_TYPE] = ridReference;
        
        return userActivityRecord;
    } else
        return nil;
}

- (CKRecord *)createCKRecordForUserActivityForRecipe:(UserActivity *)userActivity {
    
    NSLog(@"INFO: Entered createCKRecordForUserActivityForRecipe...");
    CKRecord *userActivityRecord = [[CKRecord alloc] initWithRecordType:USER_ACTIVITY_RECORD_TYPE];
    CKReference *ridReference = [[CKReference alloc] initWithRecordID:[[CKRecordID alloc] initWithRecordName:userActivity.ridReference.recordID] action:CKReferenceActionDeleteSelf];
    userActivityRecord[RECIPE_IMAGE_DATA_RECORD_TYPE] = ridReference;
    
    return userActivityRecord;
}

/**
 * Method to save a public CKRecord to CloudKit
 *
 * @param CKRecord *
 * @return void
 */
/*- (void)saveRecord:(CKRecord *)record withCompletionHandler:(void (^)(CKRecord *record, NSError *error))completionHandler{
    
    NSLog(@"INFO: Entered saveRecord...");
    
    // make sure there is a record to be saved!
    if (record) {
        // save the record
        [self.publicDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
            completionHandler(record, error);
        }];
    } else {
        NSLog(@"WARN: The CKRecord passed was not valid or could not be saved!");
    }
}*/

- (void)saveRecord:(NSArray *)records withCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler recordProgressHandler:(void (^)(double))progressHandler {
    
    NSLog(@"INFO: Entered saveRecord...");
    CKModifyRecordsOperation *saveOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:records recordIDsToDelete:nil];
    
    saveOperation.perRecordProgressBlock = ^(CKRecord *record, double progress) {
        if (progress <= 1) {
            NSLog(@"INFO: Save progress is: %f", progress);
            progressHandler(progress);
        }
    };
    
    saveOperation.perRecordCompletionBlock = ^(CKRecord *record, NSError *error) {
        NSLog(@"INFO: Save operation completed!");
        completionHandler(@[record], error);
    };
    
    [self.publicDatabase addOperation:saveOperation];
}

/**
 * Method to save a private CKRecord to CloudKit in the user's private database.
 *
 * @param CKRecord *
 * @return void
 */
- (void)saveRecordForPrivateData:(CKRecord *)record withCompletionHandler:(void (^)(CKRecord *record, NSError *error))completionHandler {
    
    NSLog(@"INFO: Entered saveRecordForPrivateData...");
    
    if (record) {
        [self.privateDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
            completionHandler(record, error);
            /*if (error) {
                NSLog(@"Error saving record to user's private database...%@", error.localizedDescription);
            } else {
                NSLog(@"Private UserActivity Record saved successfully!");
            }*/
        }];
    } else {
        NSLog(@"WARN: The CKRecord passed was not valid or could not be saved to the user's private database!");
    }
}

- (void)deleteUserActivityRecord:(UserActivity *)userActivityRecord {
    
    NSLog(@"INFO: Entered deleteUserActivityRecord...");
    
    if (userActivityRecord) {
        NSLog(@"INFO: Preparing deletion for UA recordID: %@", userActivityRecord.recordID);
        [self.privateDatabase deleteRecordWithID:[[CKRecordID alloc] initWithRecordName:userActivityRecord.recordID] completionHandler:^(CKRecordID *recordID, NSError *error) {
            if (error) {
                NSLog(@"Error: Error encountered while trying to delete UA record from user's private database: %@", error.localizedDescription);
            } else {
                NSLog(@"INFO: UA record successfully deleted from user's private database!");
            }
        }];
    } else {
        NSLog(@"WARN: UserActivity record for deletion is nil!");
    }
}

/**
 * Method to get the user's current iCloud status. Also fetches userRecordID if logged in and
 * not already retrieved.
 *
 * @return CKAccountStatus typedef enum
 * CKAccountStatusCouldNotDetermine = 0
 * CKAccountStatusAvailable = 1
 * CKAccountStatusRestricted = 2
 * CKAccountStatusNoAccount  = 3
 */
- (CKAccountStatus)getUsersCKStatus {
    
    NSLog(@"INFO: Entered getUsersCKStatus...");
    __block CKAccountStatus userAccountStatus; // assignable in block
    // use semaphore so this will be a synchronous call to get back the user's icloud status to pass back to calling method in VC
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_queue_t fetchQ = dispatch_queue_create("get icloud status", NULL);
    
    dispatch_async(fetchQ, ^{
        [self.container accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
            if (error) {
                NSLog(@"Error: Error encountered while getting user CloudKit status: %@", error.localizedDescription);
            } else {
                if (accountStatus == CKAccountStatusAvailable) { // 1
                    NSLog(@"Info: User is logged into CK - camera is available!");
                    userAccountStatus = CKAccountStatusAvailable;
                    // since user is logged into iCloud, check to see if we already have the userRecordID. if not, fetch it
                    if (self.userRecordID == nil) {
                        //NSLog(@"userRecordID is nil!");
                        [self.container fetchUserRecordIDWithCompletionHandler:^(CKRecordID *recordID, NSError *error) {
                            if (error) {
                                NSLog(@"Error: Error encountered while getting userRecordID: %@", error.localizedDescription);
                            } else {
                                self.userRecordID = recordID;
                                NSLog(@"INFO: userID: %@", self.userRecordID.recordName);
                            }
                        }];
                    } else {
                        NSLog(@"Already obtained userRecordID, no need to fetch...%@", self.userRecordID);
                    }
                } else if (accountStatus == CKAccountStatusNoAccount) { // 3
                    NSLog(@"Info: User is not logged into CK - Camera not available!");
                    userAccountStatus = CKAccountStatusNoAccount;
                } else if (accountStatus == CKAccountStatusRestricted) { // 2
                    NSLog(@"Info: User CK account is RESTRICTED - what does that mean!?");
                    userAccountStatus = CKAccountStatusRestricted;
                } else if (accountStatus == CKAccountStatusCouldNotDetermine) { // 0
                    NSLog(@"Error: Could not determine user CK Account Status: %@", error.localizedDescription);
                    userAccountStatus = CKAccountStatusCouldNotDetermine;
                }
            }
            dispatch_semaphore_signal(sema);
        }];
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    NSLog(@"INFO: CKAccountStatus: %ld", (long)userAccountStatus);
    
    return userAccountStatus;
}

@end
