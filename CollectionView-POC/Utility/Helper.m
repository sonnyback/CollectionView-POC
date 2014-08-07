//
//  Helper.m
//  CollectionView-POC
//
//  Created by Sonny Back on 7/17/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "Helper.h"

@implementation Helper

/**
 * Class method to get RBG values after dividing them by 255.0.
 * Can use any float number even if it is > 0.
 *
 * @param CGFloat (red) CGFloat (green) CGFloat (blue) CGFloat (alpha)
 * @return UIColor*
 */
+ (UIColor *)colorFromRed:(CGFloat)red Green:(CGFloat)green Blue:(CGFloat)blue Alpha:(CGFloat)alpha{
    CGFloat divisor = 255.0;
    
    return [UIColor colorWithRed:red/divisor green:green/divisor blue:blue/divisor alpha:alpha];
}

@end
