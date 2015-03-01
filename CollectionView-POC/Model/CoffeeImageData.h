//
//  CoffeeImageData.h
//  CollectionView-POC
//
//  Created by Sonny Back on 8/15/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoffeeImageData : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *imageDescription;
@property (strong, nonatomic) NSString *userID; // image owner's ID
@property (strong, nonatomic) NSString *recordID; // will come from CloudKit
@property (strong, nonatomic) NSURL *imageURL; // local file on disk
@property (nonatomic, getter = isRecipe) BOOL recipe;
@property (nonatomic, getter = isLiked) BOOL liked;
@property (nonatomic) BOOL imageBelongsToCurrentUser;

- (NSString *)description; // override description to display contents
@end
