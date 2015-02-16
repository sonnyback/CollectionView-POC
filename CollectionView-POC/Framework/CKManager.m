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

@property (readonly) CKContainer *container;
@property (readonly) CKDatabase *publicDatabase;
@property (readonly) CKDatabase *privateDatabase;

@end

@implementation CKManager

NSString *const ImageName = @"ImageName";
NSString *const ImageBelongsToUser = @"ImageBelongsToUser";
NSString *const ImageDescription = @"ImageDescription";
NSString *const UserID = @"UserID";
NSString *const Recipe = @"Recipe";
NSString *const Image = @"Image";
NSString *const CoffeeImageDataRecordType = @"CoffeeImageData";

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
    CKRecord *CIDRecord = [[CKRecord alloc] initWithRecordType:CoffeeImageDataRecordType];
    
    CIDRecord[ImageBelongsToUser] = [NSNumber numberWithBool:coffeeImageData.imageBelongsToCurrentUser];
    //CIDRecord[@"ImageName"] = [NSString stringWithFormat:coffeeImageData.imageName, @"%d", randomNumber];
    CIDRecord[ImageName] = coffeeImageData.imageName;
    CIDRecord[ImageDescription] = coffeeImageData.imageDescription;
    CIDRecord[UserID] = coffeeImageData.userID;
    CIDRecord[Recipe] = [NSNumber numberWithBool:coffeeImageData.isRecipe];
    CKAsset *photoAsset = [[CKAsset alloc] initWithFileURL:coffeeImageData.imageURL];
    CIDRecord[Image] = photoAsset;
    
    return CIDRecord;
}

/**
 * Method to save a CKRecord to CloudKit
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
 * Method to get the user's current iCloud status.
 *
 * @return CKAccountStatus typedef enum
 * CKAccountStatusAvailable = 1
 * CKAccountStatusRestricted = 2
 * CKAccountStatusNoAccount  = 3
 * CKAccountStatusCouldNotDetermine = 0
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
                if (accountStatus == CKAccountStatusAvailable) {
                    NSLog(@"Info: User is logged into CK - camera is available!");
                    userAccountStatus = CKAccountStatusAvailable;
                } else if (accountStatus == CKAccountStatusNoAccount) {
                    NSLog(@"Info: User is not logged into CK - Camera not available!");
                    userAccountStatus = CKAccountStatusNoAccount;
                } else if (accountStatus == CKAccountStatusRestricted) {
                    NSLog(@"Info: User CK account is RESTRICTED - what does that mean!?");
                    userAccountStatus = CKAccountStatusRestricted;
                } else if (accountStatus == CKAccountStatusCouldNotDetermine) {
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
