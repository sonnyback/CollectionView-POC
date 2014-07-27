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
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
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
}

/**
 * Override method to set the size of the scrollable content, not just what's visiable.
 * Right now this is not needed, but works if uncommented.
 *
 * CGSize - height/width of the scrollable viewing area
 */
- (CGSize)collectionViewContentSize {
    NSLog(@"Entered collectionViewContentSize...");
    CGSize superSize = [super collectionViewContentSize];
    CGRect frame = self.collectionView.frame;
    // 290 value will need to match the cell height - need to make this a #define/constant so it's not hardcoded
    return CGSizeMake(fmaxf(superSize.width, CGRectGetWidth(frame)), 290);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
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
    /*
    //first get a copy of all layout attributes that represent the cells. you will be modifying this collection.
    NSMutableArray *allAttributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    //NSString *FooterCellIdentifier = @"FooterView";
    
    CGRect visibleRect;
    visibleRect.size = self.collectionView.bounds.size;
    
    //go through each cell attribute
    for (UICollectionViewLayoutAttributes *attributes in [super layoutAttributesForElementsInRect:rect])
    {
        //add a title and a detail supp view for each cell attribute to your copy of all attributes
        //[allAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[attributes indexPath]]];
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
    
    //return the updated attributes list along with the layout info for the supp views
    return allAttributes;*/
}

/*- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"layoutAttributesForItemAtIndexPath");
    UICollectionViewLayoutAttributes *currentItemAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    
    return currentItemAttributes;
}*/

@end
