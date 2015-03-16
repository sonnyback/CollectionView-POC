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

@interface CKManager()

@property (nonatomic, readonly) CKContainer *container;
@property (nonatomic, readonly) CKDatabase *publicDatabase;
@property (nonatomic, readonly) CKDatabase *privateDatabase;

@end

@implementation CKManager

/*NSString *const ImageName = @"ImageName";
NSString *const ImageBelongsToUser = @"ImageBelongsToUser";
NSString *const ImageDescription = @"ImageDescription";
NSString *const UserID = @"UserID";
NSString *const Recipe = @"Recipe";
NSString *const Image = @"Image";
NSString *const CoffeeImageDataRecordType = @"CoffeeImageData";*/

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

- (void)loadCloudKitDataWithCompletionHandler:(void (^)(NSArray *, NSError *))completionHandler {
    NSLog(@"INFO: Entered loadInitialCloudKitDataWithCompletionHandler...");
    
    // just for initial testing...give me all records
    NSPredicate *predicate = [NSPredicate predicateWithValue:true];
    //create the query
    CKQuery *query = [[CKQuery alloc] initWithRecordType:COFFEE_IMAGE_DATA_RECORD_TYPE predicate:predicate];
    
    // execute the query
    [self.publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
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
    
    CIDRecord[IMAGE_BELONGS_TO_USER] = [NSNumber numberWithBool:coffeeImageData.imageBelongsToCurrentUser];
    //CIDRecord[@"ImageName"] = [NSString stringWithFormat:coffeeImageData.imageName, @"%d", randomNumber];
    CIDRecord[IMAGE_NAME] = coffeeImageData.imageName;
    CIDRecord[IMAGE_DESCRIPTION] = coffeeImageData.imageDescription;
    CIDRecord[USER_ID] = coffeeImageData.userID;
    CIDRecord[RECIPE] = [NSNumber numberWithBool:coffeeImageData.isRecipe];
    CIDRecord[LIKED] = [NSNumber numberWithBool:coffeeImageData.isLiked];
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
    
    NSLog(@"Entered createCKRecordForUserActivity...");
    CKRecord *userActivityRecord = [[CKRecord alloc] initWithRecordType:USER_ACTIVITY_RECORD_TYPE];
    CKReference *cidReference = [[CKReference alloc] initWithRecordID:[[CKRecordID alloc] initWithRecordName:userActivity.cidReference.recordID] action:CKReferenceActionDeleteSelf];
    userActivityRecord[COFFEE_IMAGE_DATA_RECORD_TYPE] = cidReference;
    //userActivityRecord[RECORD_ID] = coffeeImageData.recordID;
    
    return userActivityRecord;
}


/**
 * Method to save a public CKRecord to CloudKit
 *
 * @param CKRecord *
 * @return void
 */
- (void)saveRecord:(CKRecord *)record {
    
    NSLog(@"Entered saveRecord...");
    
    // make sure there is a record to be saved!
    if (record) {
        // save the record
        [self.publicDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
            if (error) {
                NSLog(@"Error saving record to cloud...%@", error.localizedDescription);
            } else {
                NSLog(@"Record saved successfully!");
            }
        }];
    } else {
        NSLog(@"WARN: The CKRecord passed was not valid or could not be saved!");
    }
}

/**
 * Method to save a private CKRecord to CloudKit in the user's private database.
 *
 * @param CKRecord *
 * @return void
 */
- (void)saveRecordForPrivateData:(CKRecord *)record {
    
    NSLog(@"Entered saveRecordForPrivateData...");
    
    if (record) {
        [self.privateDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
            if (error) {
                NSLog(@"Error saving record to user's private database...%@", error.localizedDescription);
            } else {
                NSLog(@"Private UserActivity Record saved successfully!");
            }
        }];
    } else {
        NSLog(@"WARN: The CKRecord passed was not valid or could not be saved to the user's private database!");
    }
}

- (void)deleteUserActivityRecord:(UserActivity *)userActivityRecord {
    
    NSLog(@"Entered deleteUserActivityRecord...");
    
    if (userActivityRecord) {
        NSLog(@"Preparing deletion for UA recordID: %@", userActivityRecord.recordID);
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
    
    NSLog(@"Entered getUsersCKStatus...");
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
    
    NSLog(@"CKAccountStatus: %ld", userAccountStatus);
    
    return userAccountStatus;
}

@end
