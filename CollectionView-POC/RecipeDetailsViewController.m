//
//  RecipeDetailsViewController.m
//  CollectionView-POC
//
//  Created by Sonny Back on 4/17/15.
//  Copyright (c) 2015 Sonny Back. All rights reserved.
//

#import "RecipeDetailsViewController.h"

@interface RecipeDetailsViewController()

@end

@implementation RecipeDetailsViewController

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    NSLog(@"INFO: RecipeDetailsViewController.cancelButtonPressed...");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)finishButtonPressed:(UIButton *)sender {
    
    NSLog(@"INFO: RecipeDetailsViewController.finishButtonPressed...");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad...");
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.112 green:0.234 blue:0.4 alpha:1];
    //self.view.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
