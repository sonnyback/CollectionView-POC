//
//  ImageLoadManager.m
//  CollectionView-POC
//
//  Created by Sonny Back on 6/23/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "ImageLoadManager.h"

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

- (instancetype)initImagesForSelection:(NSString *)selectionType {
    
    self = [super init]; // must always call superclass' initializer from our designated initializer. always.
    
    if (self) {
        NSLog(@"ImageLoadManager: selectionType: %@", selectionType);
        // get the default container and the public database for the container
        CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
        // predicate query for the userID - this is just for inital testing
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ImageDescription = 'description'"];
        //create the query
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"CoffeeImageData" predicate:predicate];
        
        dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
            // execute the queary
            [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
                // handle the error
                if (error) {
                    NSLog(@"Error: there was an error querying the cloud... %@", error);
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
        });
    }
    
    return self;
}

- (void)addCIDForNewUserImage:(CoffeeImageData *)newImageData {
    
    NSLog(@"Entered addCIDForNewUserImage...");
    //[self.coffeeImageDataArray addObject:newImageData];
    // add the new object on top so it will appear at the top of the collection view
    [self.coffeeImageDataArray insertObject:newImageData atIndex:0];
    
    NSLog(@"CoffeeImageDataArray size %lu", (unsigned long)[self.coffeeImageDataArray count]);
}

/**
 * Method for getting a specific CoffeeImageData object in the array via the index passed
 *
 * @param NSUInteger index
 * @return CoffeeImageData *
 */
- (CoffeeImageData *)coffeeImageDataForCell:(NSUInteger)index {
    NSLog(@"coffeeImageDataForCell for cell %lu", (unsigned long)index);
    
    // if the index value is < then array size, get the card, else return nil
    return (index < [self.coffeeImageDataArray count] ? self.coffeeImageDataArray[index] : nil);
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
