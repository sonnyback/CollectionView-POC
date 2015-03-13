//
//  UserActivity.h
//  CollectionView-POC
//
//  Created by Sonny Back on 3/6/15.
//  Copyright (c) 2015 Sonny Back. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoffeeImageData.h"

@interface UserActivity : NSObject

@property (strong, nonatomic) CoffeeImageData *cidReference; // CKReference
@property (strong, nonatomic) NSString *recordID; // recordID of the UA record
//@property (strong, nonatomic) NSString *userActivityRecordID;

@end
