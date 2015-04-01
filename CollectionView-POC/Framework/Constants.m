//
//  Constants.m
//  CollectionView-POC
//
//  Created by Sonny Back on 7/27/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString *const NAME_SPACE_IMAGE_CACHE          = @"nameSpaceImageCacheCID";
NSString *const JPEG                            = @"jpeg";
NSString *const COFFEE_CELL                     = @"CoffeeCell";
NSString *const CAFES                           = @"Cafes";
NSString *const CAMERA                          = @"Camera";
NSString *const PHOTO_LIBRARY                   = @"Photo Library";

// images
NSString *const PLACE_HOLDER                    = @"placeholder";
NSString *const HEART_BLUE                      = @"heart_blue";
NSString *const HEART_BLUE_SOLID                = @"heart_blue_solid";

// search
NSString *const SEARCH_FOR_COFFEE               = @"Search for coffee";

// CoffeeImageData
NSString *const IMAGE_NAME                      = @"ImageName";
NSString *const IMAGE_BELONGS_TO_USER           = @"ImageBelongsToUser";
NSString *const IMAGE_DESCRIPTION               = @"ImageDescription";
NSString *const USER_ID                         = @"UserID";
NSString *const RECIPE                          = @"Recipe";
NSString *const IMAGE                           = @"Image";
NSString *const LIKED                           = @"Liked";
NSString *const COFFEE_IMAGE_DATA_RECORD_TYPE   = @"CoffeeImageData";
NSString *const USER_ACTIVITY_RECORD_TYPE       = @"UserActivity";
NSString *const RECORD_ID                       = @"RecordID";
NSString *const LOCATION                        = @"Location";
NSString *const DEFAULT_NAME                    = @"Default Name";

// segue
NSString *const ADD_NEW_PHOTO_SEGUE             = @"Add New Photo";
NSString *const DO_ADD_PHOTO_SEGUE              = @"Do Add Photo";

// messages, errors and titles
NSString *const YIKES_TITLE                     = @"Yikes!";
NSString *const NO_SAVED_DATA_TITLE             = @"Saved Data Not Available";
NSString *const ERROR_LOADING_SAVED_DATA_MSG    = @"There was an error trying to load your saved coffee. We will not be able to show which images and recipes you liked.";
NSString *const ERROR_LOADING_CK_DATA_MSG       = @"We encountered an error trying to load the coffee images from the Cloud. Let's try this again, shall we?";
NSString *const ERROR_SAVING_LIKED_IMAGE_MSG    = @"Whoops! We encountered a problem while trying to save this coffee drink to your profile. Try clicking the heart button again, please.";
NSString *const CANCEL_BUTTON                          = @"Cancel";
NSString *const TRY_AGAIN_BUTTON                       = @"Try Again";
@end
