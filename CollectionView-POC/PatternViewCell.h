//
//  PatternViewCell.h
//  CollectionView-POC
//
//  Created by Sonny Back on 3/27/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PatternViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *patternImageView;
@property (weak, nonatomic) IBOutlet UILabel *patternLabel;

@end
