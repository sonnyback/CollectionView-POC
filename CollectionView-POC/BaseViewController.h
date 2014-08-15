//
//  BaseViewController.h
//  CollectionView-POC
//
//  Created by Sonny Back on 3/27/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIGestureRecognizerDelegate> {
    
    //UITapGestureRecognizer *tap;
    CGRect prevFrame;
}

@property (nonatomic) BOOL isFullScreen;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
- (void)updateUI;

@end
