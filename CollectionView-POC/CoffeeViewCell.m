//
//  PatternViewCell.m
//  CollectionView-POC
//
//  Created by Sonny Back on 3/27/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "CoffeeViewCell.h"

@implementation CoffeeViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSLog(@"^^^^^^^CoffeeViewCell.initWithFrame^^^^^^^");
    }
    return self;
}

// This method is called since the collectionview is created from storyboard!
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSLog(@"^^^^^^^CoffeeViewCell.initWithCoder^^^^^^^");
        [self setupImageView];
    }
    return self;
}

- (void)setupImageView {
    
    NSLog(@"DEBUG: CoffeeViewCell.setupImageView");
    self.coffeeImageView = [[UIImageView alloc] init];
    [self addSubview:self.coffeeImageView];
}

/**
 * Overridden method. Possibly needed in order for button
 * added to view to trigger.
 *
 */
/*- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    NSLog(@"!!!hitTest!!!");
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
            CGPoint subPoint = [subview convertPoint:point fromView:self];
            UIView *result = [subview hitTest:subPoint withEvent:event];
            if (result != nil) {
                return result;
            }
        }
    }
    // use this to pass the 'touch' onward in case no subviews trigger the touch
    return [super hitTest:point withEvent:event];
}*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
