//
//  CustomFlowLayout.m
//  CollectionView-POC
//
//  Created by Sonny Back on 4/14/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "CustomFlowLayout.h"

@implementation CustomFlowLayout

// over ride this method to make scrolling stop in the center of each image
/*- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    NSLog(@"targetContentOffsetForProposedContentOffset");
    CGFloat offsetAdjustment = CGFLOAT_MAX;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0f);
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0f, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    for (UICollectionViewLayoutAttributes* layoutAttributes in array){
        CGFloat distanceFromCenter = layoutAttributes.center.x - horizontalCenter;
        if (ABS(distanceFromCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = distanceFromCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}*/

/**
 * Override method to set the size of the scrollable content, not just what's visiable.
 * Right now this is not needed, but works if uncommented.
 *
 * CGSize - height/width of the scrollable viewing area
 */
/*- (CGSize)collectionViewContentSize {
    NSLog(@"Entered collectionViewContentSize...");
    CGSize superSize = [super collectionViewContentSize];
    CGRect frame = self.collectionView.frame;
    // 290 value will need to match the cell height - need to make this a #define/constant so it's not hardcoded
    return CGSizeMake(fmaxf(superSize.width, CGRectGetWidth(frame)), 290);
}*/

/**
 * May be needed to resolve issues of disappearing cells in collectionview
 *
 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    //NSLog(@"shouldInvalidateLayoutForBoundsChange"); // commenting out to eliminate excessive logging
    return YES;
}

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *layoutRect = [super layoutAttributesForElementsInRect:rect];
    
    for(int i = 1; i < [layoutRect count]; ++i) {
        UICollectionViewLayoutAttributes *currentLayoutAttributes = layoutRect[i];
        UICollectionViewLayoutAttributes *prevLayoutAttributes = layoutRect[i - 1];
        NSInteger maximumSpacing = 5;
        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
        
        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
            CGRect frame = currentLayoutAttributes.frame;
            frame.origin.x = origin + maximumSpacing;
            currentLayoutAttributes.frame = frame;
        }
    }
    return layoutRect;
}

/**
 * This implementation is specific to the *horizontal* layout
 * My implementation, modified from code taken from the web
 *
 */
/*- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSLog(@"Entered layoutAttributesForElementsInRect...");
    NSArray *attribs = [super layoutAttributesForElementsInRect:rect];
    
    CGRect visibleRect;
    //visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes *attributes in attribs) {
        
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            //CGFloat distanceFromCenter = CGRectGetMidX(visibleRect) - attributes.center.x;
            //CGFloat normalizedDistance = distanceFromCenter / 100.0f;
            CGRect rect = attributes.frame;
            //rect.origin.y = sinf(normalizedDistance) * 100.0f + 150.0f;
            
            //rect.origin.y = self.collectionView.frame.size.height/2 - self.collectionView.frame.size.height/2;
            //rect.origin.y = self.collectionView.frame.size.height/2 - (self.collectionView.frame.size.height/2) - 25;
            rect.origin.y = self.collectionView.bounds.size.height/2 - self.collectionView.bounds.size.height * (1.0 - .40);
            //rect.origin.y = self.collectionView.bounds.size.height/2 - (self.collectionView.bounds.size.height/2) - (1 * .50);
            attributes.frame = rect;
        }
    }
    
    return attribs;
}*/

/*- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSLog(@"Entered layoutAttributesForElementsInRect...");
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[attributes count]];
    CGRect visibleRect;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (int i=0; i< [attributes count]; i++) {
        UICollectionViewLayoutAttributes *attr = (UICollectionViewLayoutAttributes *)attributes[i];
        
        // the key code "attr.frame.origin.y - 63"
        [attr setFrame:CGRectMake(attr.frame.origin.x, attr.frame.origin.y - 60, attr.bounds.size.width, attr.bounds.size.height)];
        
        //NSLog(@"attr h=%f w=%f x=%f y=%f", attr.bounds.size.height, attr.bounds.size.width, attr.frame.origin.x, attr.frame.origin.y);
        
        [result addObject:attr];
        
    }
    
    return result;
}*/

/**
 * This version is supposed to fix the bug of disappearing collectionview cells.
 * Take from - http://stackoverflow.com/questions/12927027/uicollectionview-flowlayout-not-wrapping-cells-correctly-ios
 *
 */
/*- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSLog(@"Entered layoutAttributesForElementsInRect...");
    
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *newAttributes = [NSMutableArray arrayWithCapacity:attributes.count];
    
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        if ((attribute.frame.origin.x + attribute.frame.size.width <= self.collectionViewContentSize.width) &&
            (attribute.frame.origin.y + attribute.frame.size.height <= self.collectionViewContentSize.height)) {
            
            [newAttributes addObject:attribute];
        }
    }
    return newAttributes;
}*/

/*- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"layoutAttributesForItemAtIndexPath");
    UICollectionViewLayoutAttributes *currentItemAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    
    return currentItemAttributes;
}*/

@end
