//
//  CoffeeImageData.m
//  CollectionView-POC
//
//  Created by Sonny Back on 8/15/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "CoffeeImageData.h"

@implementation CoffeeImageData

- (NSString *)description {
    
    NSString *space = @" ";
    return [NSString stringWithFormat:self.imageName, space, self.userID, space, self.imageBelongsToCurrentUser, space, self.isLiked];
}
@end
