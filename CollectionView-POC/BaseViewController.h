//
//  BaseViewController.h
//  CollectionView-POC
//
//  Created by Sonny Back on 3/27/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate> {
    
    CGRect prevFrame;
}

@property (nonatomic) BOOL isFullScreen;
- (void)updateUI;
@end
