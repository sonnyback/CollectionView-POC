//
//  ImageLoadManager.h
//  CollectionView-POC
//
//  Created by Sonny Back on 6/23/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoffeeImageData.h"

@interface ImageLoadManager : NSObject

// designated Initializer
- (instancetype)initImagesForSelection:(NSString *)selectionType;
- (CoffeeImageData *)coffeeImageDataForCell:(NSUInteger)index;
// imagesArray and imageNames array will go away. Replaced by coffeeImageDataArray
//@property (strong, nonatomic) NSArray *imagesArray; // of UIImage (array of images)
//@property (strong, nonatomic) NSArray *imageNames; // of NSString (name of the images)
//@property (strong, nonatomic) CoffeeImageData *coffeeImageData;
@property (strong, nonatomic) NSMutableArray *coffeeImageDataArray; // of CoffeeImageData
@end
