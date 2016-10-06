//
//  ImageLoadManager.m
//  CollectionView-POC
//
//  Created by Sonny Back on 6/23/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "ImageLoadManager.h"
#import "Constants.h"

@interface ImageLoadManager()

@end

@implementation ImageLoadManager

// lazy instantiate coffeeImageDataArray getter
- (NSMutableArray *)coffeeImageDataArray {
    
    if (!_coffeeImageDataArray) {
        _coffeeImageDataArray = [[NSMutableArray alloc] init];
    }
    
    return _coffeeImageDataArray;
}

- (NSMutableArray *)recipeImageDataArray {
    
    if (!_recipeImageDataArray) {
        _recipeImageDataArray = [[NSMutableArray alloc] init];
    }
    
    return _recipeImageDataArray;
}

// lazy instantiate userActivityDictionary
- (NSMutableDictionary *)userActivityDictionary {
    
    if (!_userActivityDictionary) {
        _userActivityDictionary = [[NSMutableDictionary alloc] init];
    }
    return _userActivityDictionary;
}

// lazy instantiate userSavedImages
- (NSMutableArray *)userSavedImages {
    
    if (!_userSavedImages) {
        _userSavedImages = [[NSMutableArray alloc] init];
    }
    
    return _userSavedImages;
}

// lazy instantiate recordIDsArray
- (NSMutableArray *)recordIDsArray {
    
    if (!_recordIDsArray) {
        _recordIDsArray = [[NSMutableArray alloc] init];
    }
    
    return _recordIDsArray;
}

- (instancetype)init {
    NSLog(@"Loading ImageLoadManager...");
    self = [super init];
    NSLog(@"Finished loading ImageLoadManager...");
    return self;
}

/**
 * Designated Initializer: loads the images based on the selection type from the 
 * segmentedControl in the VC. This is based on testing of local images. Will change 
 * when online backend is in place - images will be pulled from internet based storage.
 *
 * @param NSString *selectionType - passed from title of the selected UISegmentedControl
 * @return instancetype - self
 */
/*- (instancetype)initImagesForSelection:(NSString *)selectionType {
    
    self = [super init]; // must always call superclass' initializer from our designated initializer. always.
    
    if (self) {
        NSLog(@"selectionType: %@", selectionType);
        NSMutableArray *arrayOfUIImages = [[NSMutableArray alloc] init];
        NSMutableArray *arrayOfImageNames = [[NSMutableArray alloc] init];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *directoryFilePath = @"/Users/Sonny/Desktop/images/";
        BOOL success = [fileManager fileExistsAtPath:directoryFilePath];
        
        if (success) {
            NSLog(@"Directory exists!");
            NSArray *imageNamesFromDirectory = [fileManager contentsOfDirectoryAtPath:directoryFilePath error:nil];
            NSString *searchString = @".png";
            
            for (int i = 0; i < [imageNamesFromDirectory count]; i++) {
                //NSLog(@"contents from directory %@", imageNamesFromDirectory[i]);
                // file name creation requires full path to create the UIImage based off the file name
                NSString *nameOfImageFromFile = [directoryFilePath stringByAppendingString:[imageNamesFromDirectory[i] description]];
                NSLog(@"file name:%@", nameOfImageFromFile);
                NSRange range = [nameOfImageFromFile rangeOfString:searchString];
                if (range.location != NSNotFound) {
                    NSLog(@"found search string!");
                    UIImage *image = [UIImage imageWithContentsOfFile:nameOfImageFromFile];
                    NSLog(@"Image size: width:%f, height:%f", image.size.width, image.size.height
                          );
                    [arrayOfUIImages addObject:image];
                    // remove the directory path from the file name and add image name to the imageNames array
                    NSString *fileNameWithoutPath = [self removePathFromFileName:nameOfImageFromFile forPath:directoryFilePath];
                    //[self.imageNames addObject:fileNameWithoutPath];
                    [arrayOfImageNames addObject:fileNameWithoutPath];
                }
            }
            // add the images from the private, mutable array to public non-mutale array of images
            self.imagesArray = [arrayOfUIImages copy];
            // add the image names from the private, mutable array to public non-mutale array of images
            self.imageNames = [arrayOfImageNames copy];
            NSLog(@"initImagesForSelection - imagesArry size: %lu", (unsigned long)[self.imagesArray count]);
            
            arrayOfUIImages = nil; // get rid of the temporary array
            arrayOfImageNames = nil; // get rid of the temporary array
        }
    }
    
    return self;
}*/

/**
 * Designated Initializer: loads the images based on the selection type from the
 * segmentedControl in the VC. This is based on testing of local images. Will change
 * when online backend is in place - images will be pulled from internet based storage.
 *
 * @param NSString *selectionType - passed from title of the selected UISegmentedControl
 * @return instancetype - self
 */
/*- (instancetype)initImagesForSelection:(NSString *)selectionType {
    
    self = [super init]; // must always call superclass' initializer from our designated initializer. always.
    
    if (self) {
        NSLog(@"ImageLoadManager: selectionType: %@", selectionType);
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSString *directoryFilePath = @"/Users/Sonny/Desktop/images/";
        BOOL success = [fileManager fileExistsAtPath:directoryFilePath];
        
        if (success) {
            NSLog(@"Directory exists!");
            NSArray *imageNamesFromDirectory = [fileManager contentsOfDirectoryAtPath:directoryFilePath error:nil];
            NSString *searchString = @".png";
            
            for (int i = 0; i < [imageNamesFromDirectory count]; i++) {
                // create CoffeeImageData object to store data in the array for each image
                CoffeeImageData *coffeeImageData = [[CoffeeImageData alloc] init];
                //NSLog(@"contents from directory %@", imageNamesFromDirectory[i]);
                // file name creation requires full path to create the UIImage based off the file name
                NSString *nameOfImageFromFile = [directoryFilePath stringByAppendingString:[imageNamesFromDirectory[i] description]];
                NSLog(@"file name:%@", nameOfImageFromFile);
                NSRange range = [nameOfImageFromFile rangeOfString:searchString];
                if (range.location != NSNotFound) {
                    NSLog(@"found search string!");
                    UIImage *image = [UIImage imageWithContentsOfFile:nameOfImageFromFile];
                    coffeeImageData.image = image;
                    //NSLog(@"Image size: width:%f, height:%f", image.size.width, image.size.height);
                    //[arrayOfUIImages addObject:image];
                    // remove the directory path from the file name and add image name to the imageNames array
                    NSString *fileNameWithoutPath = [self removePathFromFileName:nameOfImageFromFile forPath:directoryFilePath];
                    coffeeImageData.imageName = fileNameWithoutPath;
                    coffeeImageData.imageURL = [NSURL fileURLWithPath:nameOfImageFromFile isDirectory:YES];
                    NSLog(@"Image name:: %@", coffeeImageData.imageName);
                    [self.coffeeImageDataArray addObject:coffeeImageData];
                }
            }
            
            NSLog(@"CoffeeImageDataArray size %lu", (unsigned long)[self.coffeeImageDataArray count]);
        } else { // temporary for testing on local device until cloudkit is setup
            NSLog(@"Directory not found...looking for local images");
            for (int i = 1; i <= 11; i++) { //
                CoffeeImageData *coffeeImageData = [[CoffeeImageData alloc] init];
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"image%d", i]];
                NSString *imageName = [NSString stringWithFormat:@"image%d", i];
                NSLog(@"Image name:: %@", coffeeImageData.imageName);
                coffeeImageData.image = image;
                coffeeImageData.imageName = imageName;
                coffeeImageData.imageURL = [NSURL fileURLWithPath:imageName];
                [self.coffeeImageDataArray addObject:coffeeImageData];
            }
            NSLog(@"CoffeeImageDataArray size %lu", (unsigned long)[self.coffeeImageDataArray count]);
            NSLog(@"CoffeeImageDataArray: %@", self.coffeeImageDataArray);
        }
    }
    
    return self;
}*/

/*- (instancetype)initImagesForSelection:(NSString *)selectionType {
    
    self = [super init]; // must always call superclass' initializer from our designated initializer. always.
    
    if (self) {
        NSLog(@"ImageLoadManager: selectionType: %@", selectionType);
        // get the default container and the public database for the container
        CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
        // predicate query for the userID - this is just for inital testing
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ImageDescription = 'description'"];
        //create the query
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"CoffeeImageData" predicate:predicate];
        
        // execute the queary
        [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
            // handle the error
            if (error) {
                NSLog(@"Error: there was an error fetching cloud data... %@", error);
            } else {
                // any results?
                if ([results count] > 0) {
                    NSLog(@"Success querying the cloud for %lu results!!!", (unsigned long)[results count]);
                    for (CKRecord *record in results) {
                        NSLog(@"Image: %@", record[@"Image"]);
                        NSLog(@"Image belongs to user? %@", record[@"ImageBelongsToUser"]);
                        NSLog(@"Image name: %@", record[@"ImageName"]);
                        NSLog(@"userid: %@", record[@"UserID"]);
                        NSLog(@"Image description: %@", record[@"ImageDescription"]);
                        // create CoffeeImageData object to store data in the array for each image
                        CoffeeImageData *coffeeImageData = [[CoffeeImageData alloc] init];
                        CKAsset *imageAsset = record[@"Image"];
                        coffeeImageData.imageURL = imageAsset.fileURL;
                        NSLog(@"asset URL: %@", coffeeImageData.imageURL);
                        coffeeImageData.imageName = record[@"ImageName"];
                        //coffeeImageData.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageAsset.fileURL]];
                        coffeeImageData.image = [UIImage imageWithContentsOfFile:imageAsset.fileURL.path];
                        NSLog(@"image size height:%f, width:%f", coffeeImageData.image.size.height, coffeeImageData.image.size.width);
                        [self.coffeeImageDataArray addObject:coffeeImageData];
                    }
                    NSLog(@"CoffeeImageDataArray size %lu", (unsigned long)[self.coffeeImageDataArray count]);
                }
            }
        }];
    }
        
    NSLog(@"Finishing loading data from the cloud!");
    return self;
}*/

/**
 * Method for adding a new CID object on the top of the CIDArray. This is so
 * the collectionview can be updated when the user adds a new phot from the camera
 * or library.
 *
 * @param CoffeeImageData *
 */
- (void)addCIDForNewUserImage:(CoffeeImageData *)newImageData {
    
    NSLog(@"Entered addCIDForNewUserImage...");
    //[self.coffeeImageDataArray addObject:newImageData];
    // add the new object on top so it will appear at the top of the collection view
    [self.coffeeImageDataArray insertObject:newImageData atIndex:0];
    
    NSLog(@"CoffeeImageDataArray size %lu", (unsigned long)[self.coffeeImageDataArray count]);
}


- (BOOL)lookupRecordIDInUserData:(NSString *)recordID {
    
    NSLog(@"Entered lookupRecordIDInUserData for recordID: %@", recordID);
    
    if ([self.userActivityDictionary objectForKey:recordID]) {
        NSLog(@"RecordID %@ found in userActivityDictionary!", recordID);
        return TRUE;
    } else {
        NSLog(@"RecordID %@ NOT found in userActivityDictionary!", recordID);
        return FALSE;
    }
        
}

- (void)updateUserLikeActivityAtIndex:(NSUInteger)index {
    
    NSLog(@"Entered updateUserLikeActivity...");
    CoffeeImageData *cid = [self coffeeImageDataForCell:index];
    NSLog(@"Like value for current CID %d", cid.isLiked);
}

/**
 * Method that removes a CID or RID object from the UADictionary based on recordID
 * when a user unlikes an image.
 *
 * @param NSString *recordID
 */
- (void)removeUserActivityDataFromDictionary:(NSString *)recordID {
    
    NSLog(@"Entered removeUserActivityDataFromDictionary...");
    if ([self lookupRecordIDInUserData:recordID]) {
        [self.userActivityDictionary removeObjectForKey:recordID];
        if (![self lookupRecordIDInUserData:recordID]) {
            NSLog(@"Successfully removed data from userActivityDictionary for recordID: %@", recordID);
        }
    }
}

/**
 * Returns the index in the array for the corresponding CID object at
 * for the given recordID.
 *
 * @param NSString *recordID
 * @return NSUInteger index
 */
- (NSUInteger)getIndexForCIDRecordID:(NSString *)recordID {
    
    NSUInteger index = 0;
    
    for (CoffeeImageData *cid in self.coffeeImageDataArray) {
        if ([recordID isEqualToString:cid.recordID]) {
            NSLog(@"DEBUG: CID found for recordID: %@", recordID);
            index = [self.coffeeImageDataArray indexOfObject:cid];
            break; // found what we're looking for so break out
        }
    }
    
    return index;
}

/**
 * Returns the index in the array for the corresponding RID object at
 * for the given recordID.
 *
 * @param NSString *recordID
 * @return NSUInteger index
 */
- (NSUInteger)getIndexForRIDRecordID:(NSString *)recordID {
    
    NSUInteger index = 0;
    
    for (RecipeImageData *rid in self.recipeImageDataArray) {
        if ([recordID isEqualToString:rid.recordID]) {
            NSLog(@"DEBUG: RID found for recordID: %@", recordID);
            index = [self.recipeImageDataArray indexOfObject:rid];
            break; // found what we're looking for so break out
        }
    }
    
    return index;
}

- (NSUInteger)getCIDIndexFromUserSavedImages:(NSString *)recordID {
    
    NSUInteger index = 0;
    
    for (CoffeeImageData *cid in self.userSavedImages) {
        if ([recordID isEqualToString:cid.recordID]) {
            index = [self.userSavedImages indexOfObject:cid];
            break; // found what we're looking for so break out
        }
    }
    
    return index;
}

- (NSUInteger)getRIDIndexFromUserSavedImages:(NSString *)recordID {
    
    NSUInteger index = 0;
    
    for (RecipeImageData *rid in self.userSavedImages) {
        if ([recordID isEqualToString:rid.recordID]) {
            index = [self.userSavedImages indexOfObject:rid];
            break; // found what we're looking for so break out
        }
    }
    
    return index;
}

/**
 * Method for getting a specific CoffeeImageData object in the array via the index passed
 *
 * @param NSUInteger index
 * @return CoffeeImageData *
 */
- (CoffeeImageData *)coffeeImageDataForCell:(NSUInteger)index {
    NSLog(@"INFO: coffeeImageDataForCell for cell %lu", (unsigned long)index);
    
    // if the index value is < then array size, get the object, else return nil
    return (index < [self.coffeeImageDataArray count] ? self.coffeeImageDataArray[index] : nil);
}

/**
 * Method for getting a specific RecipeImageData object in the array via the index passed
 *
 * @param NSUInteger index
 * @return RecipeImageData *
 */
- (RecipeImageData *)recipeImageDataForCell:(NSUInteger)index {
    NSLog(@"INFO: RecipeImageDataForCell for cell %lu", (unsigned long)index);
    
    // if the index value is < then array size, get the object, else return nil
    return (index < [self.recipeImageDataArray count] ? self.recipeImageDataArray[index] : nil);
}

- (CoffeeImageData *)createCIDFromCKRecord:(CKRecord *)record {
    
    CoffeeImageData *coffeeImageData = [[CoffeeImageData alloc] init];
    
    CKAsset *imageAsset = record[IMAGE];
    coffeeImageData.imageURL = imageAsset.fileURL;
    //NSLog(@"asset URL: %@", coffeeImageData.imageURL);
    coffeeImageData.imageName = record[IMAGE_NAME];
    //NSLog(@"Image name: %@", coffeeImageData.imageName);
    coffeeImageData.imageDescription = record[IMAGE_DESCRIPTION];
    coffeeImageData.userID = record[USER_ID];
    coffeeImageData.imageBelongsToCurrentUser = [record[IMAGE_BELONGS_TO_USER] boolValue];
    coffeeImageData.recipe = [record[RECIPE] boolValue];
    coffeeImageData.liked = [record[LIKED] boolValue]; // 0 = No, 1 = Yes
    coffeeImageData.recordID = record.recordID.recordName;
    coffeeImageData.likeCount = record[LIKE_COUNT];
    
    if ([self lookupRecordIDInUserData:coffeeImageData.recordID]) {
        //NSLog(@"RecordID %@ found in userActivityDictiontary!", coffeeImageData.recordID);
        coffeeImageData.liked = YES;
    }
    
    return coffeeImageData;
}

- (RecipeImageData *)createRIDFromCKRecord:(CKRecord *)record {
    
    RecipeImageData *recipeImageData = [[RecipeImageData alloc] init];
    
    CKAsset *imageAsset = record[IMAGE];
    recipeImageData.imageURL = imageAsset.fileURL;
    recipeImageData.imageName = record[IMAGE_NAME];
    recipeImageData.imageDescription = record[IMAGE_DESCRIPTION];
    recipeImageData.userID = record[USER_ID];
    recipeImageData.recipe = [record[RECIPE] boolValue]; // 0 = No, 1 = Yes
    recipeImageData.recordID = record.recordID.recordName;
    recipeImageData.likeCount = record[LIKE_COUNT];
    // check to see if the recordID of the current RID is userActivityDictionary. If so, it's in the user's private
    // data so set liked value = YES
    if ([self lookupRecordIDInUserData:recipeImageData.recordID]) {
        //NSLog(@"RecordID found in userActivityDictiontary!");
        recipeImageData.liked = YES;
    }
    
    return recipeImageData;
}

/**
 * Method that takes all of the images from CID and RID arrays based on selected segment
 * and filters them out for only the liked images. Does this via a predicate
 *
 * @param NSString *selection (selected segment)
 */
/*- (void)getUserSavedImagesForSelection:(NSString *)selection {
 
    NSLog(@"INFO: getUserSavedImagesForSelection: %@", selection);
    
    // clear out the array before populating it
    if ([self.userSavedImages count] > 0) {
        [self.userSavedImages removeAllObjects];
    }
    
    if ([selection isEqualToString:IMAGES_SEGMENTED_CTRL]) {
        // copy the data from the CID array to the userSavedImages array before filtering
        self.userSavedImages = [self.coffeeImageDataArray mutableCopy];
        // predicate to filter out non-saved (liked) images
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:PREDICATE_IS_LIKED_YES];
        [self.userSavedImages filterUsingPredicate:filterPredicate]; // filter based on predicate
    } else if ([selection isEqualToString:RECIPES_SEGMENTED_CTRL]) {
        // copy the data from the CID array to the userSavedImages array before filtering
        self.userSavedImages = [self.recipeImageDataArray mutableCopy];
        // predicate to filter out non-saved (liked) images
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:PREDICATE_IS_LIKED_YES];
        [self.userSavedImages filterUsingPredicate:filterPredicate]; // filter based on predicate
    }
}*/

- (void)getUserSavedImagesForSelection:(NSString *)selection {
    
    NSLog(@"INFO: getUserSavedImagesForSelection: %@", selection);
    
    // clear out the array before populating it
    if ([self.recordIDsArray count] > 0) {
        [self.recordIDsArray removeAllObjects];
    }
    
    NSArray *keys = [self.userActivityDictionary allKeys];
    //NSLog(@"DEBUG: number of keys: %lul", (unsigned long)[keys count]);
    for (NSString *key in keys) {
        //NSLog(@"INFO: Current key: %@", key);
        UserActivity *ua = self.userActivityDictionary[key];
        //NSLog(@"UA object: %@", ua.description);
        // check to see if it's a CID or RID reference as well as what segmented control is selected
        if (ua.cidReference != NULL && [selection isEqualToString:IMAGES_SEGMENTED_CTRL]) {
            NSLog(@"CKReference CID recordID: %@", ua.cidReference.recordID);
            [self.recordIDsArray addObject:key];
        } else if (ua.ridReference != NULL && [selection isEqualToString:RECIPES_SEGMENTED_CTRL]) {
            NSLog(@"CKReference RID recordID: %@", ua.ridReference.recordID);
            [self.recordIDsArray addObject:key];
        }
    }
    
    NSLog(@"DEBUG: recordIDsArray size: %lu", (unsigned long)[self.recordIDsArray count]);
}

/**
 * Method to remove preceeding directory path from the file name.
 *
 * @param NSString *fileName
 * @param NSString *path
 * @return NSString *string filename without path
 */
- (NSString *)removePathFromFileName:(NSString *)fileName forPath:(NSString *)path {
    
    NSLog(@"Entered removePathFromFileName - filename: %@", fileName);
    NSString *returnString = @"";
    
    returnString = [fileName stringByReplacingOccurrencesOfString:path withString:@""];
    
    //NSLog(@"returnString:%@", returnString);
    
    return returnString;
}

@end
