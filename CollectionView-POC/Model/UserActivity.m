//
//  UserActivity.m
//  CollectionView-POC
//
//  Created by Sonny Back on 3/6/15.
//  Copyright (c) 2015 Sonny Back. All rights reserved.
//

#import "UserActivity.h"
#import "CoffeeImageData.h"

@implementation UserActivity

- (NSString *)description {
    
    NSString *space = @", ";
    return [NSString stringWithFormat:self.cidReference.imageName, space, self.cidReference.imageDescription, self.cidReference.recordID, space, self.cidReference.userID, space, self.cidReference.imageBelongsToCurrentUser, space, self.cidReference.isLiked, space, self.cidReference.isRecipe];
}
@end
