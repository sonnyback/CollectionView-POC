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
    
    //NSString *space = @", ";
    return [NSString stringWithFormat:@"CID reference recordID: UserActivity recordID: %@%@", self.cidReference.recordID, self.recordID];
}
@end
