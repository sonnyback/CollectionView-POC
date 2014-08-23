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
@property (weak, nonatomic) NSString *imageName;
@property (nonatomic, getter = isLiked) BOOL liked;

@end
