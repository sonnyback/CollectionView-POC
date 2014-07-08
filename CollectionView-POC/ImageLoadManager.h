//
//  ImageLoadManager.h
//  CollectionView-POC
//
//  Created by Sonny Back on 6/23/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageLoadManager : NSObject

// designated Initializer
- (instancetype)initImagesForSelection:(NSString *)selectionType;

@property (strong, nonatomic) NSArray *imagesArray; // of UIImage (array of images)
@property (strong, nonatomic) NSArray *imageNames; // of NSString (name of the images)

@end
