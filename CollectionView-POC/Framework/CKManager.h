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

@interface CKManager : NSObject

// public constants
/*extern NSString *const ImageName;
extern NSString *const ImageBelongsToUser; // will be interpreted as BOOL
extern NSString *const ImageDescription;
extern NSString *const UserID;
extern NSString *const Recipe; // will be interpreted as BOOL
extern NSString *const Image; // CKAsset
extern NSString *const CoffeeImageDataRecordType;*/

// public properties
@property (strong, nonatomic) CKRecordID *userRecordID; // unique user identifier

// public methods
- (CKRecord *)createCKRecordForImage:(CoffeeImageData *)coffeeImageData;
- (CKRecord *)createCKRecordForUserActivity:(CoffeeImageData *)coffeeImageData;
- (void)saveRecord:(CKRecord *)record;
- (void)saveRecordForPrivateData:(CKRecord *)record;
- (void)deleteUserActivityRecord:(UserActivity *)userActivityRecord;
- (CKAccountStatus)getUsersCKStatus;

@end
