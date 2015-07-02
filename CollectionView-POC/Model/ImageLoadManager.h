//
//  ImageLoadManager.h
//  CollectionView-POC
//
//  Created by Sonny Back on 6/23/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>
#import "CoffeeImageData.h"
#import "CKManager.h"
#import "RecipeImageData.h"

@interface ImageLoadManager : NSObject

// designated Initializer
- (instancetype)initImagesForSelection:(NSString *)selectionType;
- (CoffeeImageData *)coffeeImageDataForCell:(NSUInteger)index;
- (RecipeImageData *)recipeImageDataForCell:(NSUInteger)index;
- (void)addCIDForNewUserImage:(CoffeeImageData *)newImageData;
- (void)updateUserLikeActivityAtIndex:(NSUInteger)index;
- (BOOL)lookupRecordIDInUserData:(NSString *)recordID;
- (void)removeUserActivityDataFromDictionary:(NSString *)recordID;
- (void)getUserSavedImagesForSelection:(NSString *)selection;
// imagesArray and imageNames array will go away. Replaced by coffeeImageDataArray
//@property (strong, nonatomic) NSArray *imagesArray; // of UIImage (array of images)
//@property (strong, nonatomic) NSArray *imageNames; // of NSString (name of the images)
//@property (strong, nonatomic) CoffeeImageData *coffeeImageData;
@property (strong, nonatomic) NSMutableArray *coffeeImageDataArray; // of CoffeeImageData
@property (strong, nonatomic) NSMutableArray *recipeImageDataArray; // of RecipeImageData
@property (strong, nonatomic) NSMutableDictionary *userActivityDictionary;
@property (strong, nonatomic) NSMutableArray *userSavedImages; // only stores the images the user has liked
@end
