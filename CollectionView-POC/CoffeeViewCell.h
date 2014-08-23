//
//  PatternViewCell.h
//  CollectionView-POC
//
//  Created by Sonny Back on 3/27/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoffeeImageData.h"

@interface CoffeeViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *coffeeImageView;
@property (weak, nonatomic) IBOutlet UILabel *coffeeImageLabel;
@property (nonatomic) BOOL imageIsLiked;
@end
