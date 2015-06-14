//
//  RecipeDetailsViewController.h
//  CollectionView-POC
//
//  Created by Sonny Back on 4/17/15.
//  Copyright (c) 2015 Sonny Back. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeImageData.h"

@interface RecipeDetailsViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) RecipeImageData *recipeImageData;

@end
