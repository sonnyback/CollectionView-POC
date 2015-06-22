//
//  Constants.m
//  CollectionView-POC
//
//  Created by Sonny Back on 7/27/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString *const NAME_SPACE_IMAGE_CACHE              = @"nameSpaceImageCacheCID";
NSString *const JPEG                                = @"jpeg";
NSString *const COFFEE_CELL                         = @"CoffeeCell";
NSString *const CAFES                               = @"Cafes";
NSString *const IMAGES_SEGMENTED_CTRL               = @"Images";
NSString *const RECIPES_SEGMENTED_CTRL              = @"Recipes";
NSString *const CAMERA                              = @"Camera";
NSString *const PHOTO_LIBRARY                       = @"Photo Library";
NSString *const SPACE                               = @" ";
NSString *const BLANK                               = @"";
NSString *const NAME_YOUR_DRINK                     = @"Name your drink";

// Ingredients
NSString *const SELECT_INGREDIENTS                  = @"Select Ingredients Below:";
NSString *const ESPRESSO                            = @"Espresso";
NSString *const MILK                                = @"Milk";
NSString *const SYRUP                               = @"Syrup";
NSString *const SINGLE_SHOT                         = @"Single Shot";
NSString *const DOUBLE_SHOT                         = @"Double Shot";
NSString *const ONE_THIRD                           = @"1/3";
NSString *const STEAMED_MILK                        = @"Steamed Milk";
NSString *const MILK_FOAM                           = @"Milk Foam";
NSString *const WHITE_CHOCOLATE                     = @"White Chocolate";
NSString *const CARAMEL                             = @"Caramel";
NSString *const VANILLA                             = @"Vanilla";
NSString *const HAZELNUT                            = @"Hazelnut";
NSString *const MOCHA                               = @"Mocha";
NSString *const CHOCOLATE                           = @"Chocolate";
NSString *const PEPPERMINT                          = @"Peppermint";

// Images
NSString *const PLACE_HOLDER                        = @"placeholder";
NSString *const HEART_BLUE                          = @"heart_blue";
NSString *const HEART_BLUE_SOLID                    = @"heart_blue_solid";
NSString *const PLUS_25                             = @"Plus-25";
NSString *const USER_MALE_25                        = @"User_Male_25";
NSString *const USER_MALE_FILLED_25                 = @"User_Male_Filled_25";

// Search
NSString *const SEARCH_FOR_COFFEE                   = @"Search for coffee";

// CoffeeImageData
NSString *const IMAGE_NAME                          = @"ImageName";
NSString *const IMAGE_BELONGS_TO_USER               = @"ImageBelongsToUser";
NSString *const IMAGE_DESCRIPTION                   = @"ImageDescription";
NSString *const USER_ID                             = @"UserID";
NSString *const RECIPE                              = @"Recipe";
NSString *const IMAGE                               = @"Image";
NSString *const LIKED                               = @"Liked";
NSString *const COFFEE_IMAGE_DATA_RECORD_TYPE       = @"CoffeeImageData";
NSString *const USER_ACTIVITY_RECORD_TYPE           = @"UserActivity";
NSString *const USER_ACTIVITY_IMAGES_RECORD_TYPE    = @"UserActivityImages";
NSString *const RECORD_ID                           = @"RecordID";
NSString *const LOCATION                            = @"Location";
NSString *const DEFAULT_NAME                        = @"Default Name";

// RecipeImageData
NSString *const RECIPE_IMAGE_DATA_RECORD_TYPE       = @"RecipeImageData";
NSString *const USER_ACTIVITY_RECIPES_RECORD_TYPE   = @"UserActivityRecipes";

// Segue
NSString *const ADD_NEW_PHOTO_SEGUE                 = @"Add New Photo";
NSString *const DO_ADD_PHOTO_SEGUE                  = @"Do Add Photo";
NSString *const SHOW_RECIPE_SEGUE                   = @"Show Recipe Details";

// messages, errors and titles
NSString *const YIKES_TITLE                         = @"Yikes!";
NSString *const YAY_TITLE                           = @"Yay!";
NSString *const NO_SAVED_DATA_TITLE                 = @"Saved Data Not Available";
NSString *const ERROR_LOADING_SAVED_DATA_MSG        = @"There was an error trying to load your saved coffee. We will not be able to show which images and recipes you liked.";
NSString *const ERROR_LOADING_CK_DATA_MSG           = @"We encountered an error trying to load the coffee images from the Cloud. Let's try this again, shall we?";
NSString *const ERROR_SAVING_LIKED_IMAGE_MSG        = @"Whoops! We encountered a problem while trying to save this coffee drink to your profile. Try clicking the heart button again, please.";
NSString *const CANCEL_BUTTON                       = @"Cancel";
NSString *const TRY_AGAIN_BUTTON                    = @"Try Again";
NSString *const ICLOUD_LOGIN_REQ_TITLE              = @"iCloud Login Required";
NSString *const ICLOUD_LOGIN_REQ_MSG                = @"You must be logged into your iCloud account to submit photos and recipes. Go into iCloud under Settings on your device to login.";
NSString *const ICLOUD_STATUS_RESTRICTED_TITLE      = @"iCloud Status Restricted";
NSString *const ICLOUD_STATUS_RESTRICTED_MSG        = @"Your iCloud account is listed as Restricted. Saving to CloudKit databases is not allowed on restricted accounts. Try a different iCloud account if you have one or contact your system administrator.";
NSString *const ICLOUD_STATUS_UNDETERMINED_TITLE    = @"iCloud Status Undetermined";
NSString *const ICLOUD_STATUS_UNDETERMINED_MSG      = @"We could not determine your iCloud status. You must be logged into your iCloud account to submit photos and recipes. Go into iCloud under Settings on your device to login.";
NSString *const ERROR_SAVING_PHOTO_MSG              = @"We encountered an issue trying to upload your photo to the cloud. It was probably one of those pesky network errors. Would you mind trying to submit it again?";
NSString *const UPLOADING_COFFEE_MSG                = @"Uploading your coffee...";
NSString *const COFFEE_UPLOAD_SUCCESS_MSG           = @"Your coffee photo was successfully sent up to the clouds for everyone to see!";

// Actions
NSString *const PHOTO_BRANCH_ACTION                 = @"How would you like to submit your coffee photo?";
@end
