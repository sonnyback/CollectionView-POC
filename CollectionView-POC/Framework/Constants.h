//
//  Constants.h
//  CollectionView-POC
//
//  Created by Sonny Back on 7/27/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

extern NSString *const NAME_SPACE_IMAGE_CACHE;
extern NSString *const JPEG;
extern NSString *const COFFEE_CELL;
extern NSString *const CAFES;
extern NSString *const IMAGES_SEGMENTED_CTRL;
extern NSString *const RECIPES_SEGMENTED_CTRL;
extern NSString *const CAMERA;
extern NSString *const PHOTO_LIBRARY;
extern NSString *const SPACE;
extern NSString *const BLANK;

// Ingredients
extern NSString *const SELECT_INGREDIENTS;
extern NSString *const ESPRESSO;
extern NSString *const MILK;
extern NSString *const SYRUP;
extern NSString *const SINGLE_SHOT;
extern NSString *const DOUBLE_SHOT;
extern NSString *const ONE_THIRD;
extern NSString *const STEAMED_MILK;
extern NSString *const MILK_FOAM;
extern NSString *const WHITE_CHOCOLATE;
extern NSString *const CARAMEL;
extern NSString *const VANILLA;
extern NSString *const HAZELNUT;
extern NSString *const MOCHA;
extern NSString *const CHOCOLATE;
extern NSString *const PEPPERMINT;

// Images
extern NSString *const PLACE_HOLDER;
extern NSString *const HEART_BLUE;
extern NSString *const HEART_BLUE_SOLID;

// Search
extern NSString *const SEARCH_FOR_COFFEE;

// CoffeeImageData
extern NSString *const IMAGE_NAME;
extern NSString *const IMAGE_BELONGS_TO_USER;
extern NSString *const IMAGE_DESCRIPTION;
extern NSString *const USER_ID;
extern NSString *const RECIPE;
extern NSString *const IMAGE;
extern NSString *const LIKED;
extern NSString *const COFFEE_IMAGE_DATA_RECORD_TYPE;
extern NSString *const USER_ACTIVITY_RECORD_TYPE;
extern NSString *const USER_ACTIVITY_IMAGES_RECORD_TYPE;
extern NSString *const RECORD_ID;
extern NSString *const LOCATION;
extern NSString *const DEFAULT_NAME;

// RecipeImageData
extern NSString *const RECIPE_IMAGE_DATA_RECORD_TYPE;
extern NSString *const USER_ACTIVITY_RECIPES_RECORD_TYPE;

// Segue
extern NSString *const ADD_NEW_PHOTO_SEGUE;
extern NSString *const DO_ADD_PHOTO_SEGUE;
extern NSString *const SHOW_RECIPE_SEGUE;

// messages, errors and titles
extern NSString *const YIKES_TITLE;
extern NSString *const YAY_TITLE;
extern NSString *const NO_SAVED_DATA_TITLE;
extern NSString *const ERROR_LOADING_SAVED_DATA_MSG;
extern NSString *const ERROR_LOADING_CK_DATA_MSG;
extern NSString *const ERROR_SAVING_LIKED_IMAGE_MSG;
extern NSString *const CANCEL_BUTTON;
extern NSString *const TRY_AGAIN_BUTTON;
extern NSString *const ICLOUD_LOGIN_REQ_TITLE;
extern NSString *const ICLOUD_LOGIN_REQ_MSG;
extern NSString *const ICLOUD_STATUS_RESTRICTED_TITLE;
extern NSString *const ICLOUD_STATUS_RESTRICTED_MSG;
extern NSString *const ICLOUD_STATUS_UNDETERMINED_TITLE;
extern NSString *const ICLOUD_STATUS_UNDETERMINED_MSG;
extern NSString *const ERROR_SAVING_PHOTO_MSG;
extern NSString *const UPLOADING_COFFEE_MSG;
extern NSString *const COFFEE_UPLOAD_SUCCESS_MSG;

// Actions
extern NSString *const PHOTO_BRANCH_ACTION;
@end
