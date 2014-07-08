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

/**
 * Designated Initializer: loads the images based on the selection type from the 
 * segmentedControl in the VC.
 *
 * @param NSString *selectionType - passed from title of the selected UISegmentedControl
 * @return instancetype - self
 */
- (instancetype)initImagesForSelection:(NSString *)selectionType {
    
    self = [super init]; // must always call superclass' initializer from our designated initializer. always.
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
    }
    
    return self;
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
    
    NSLog(@"returnString:%@", returnString);
    
    return returnString;
}

@end
