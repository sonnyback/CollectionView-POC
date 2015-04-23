//
//  RecipeDetailsViewController.m
//  CollectionView-POC
//
//  Created by Sonny Back on 4/17/15.
//  Copyright (c) 2015 Sonny Back. All rights reserved.
//

#import "RecipeDetailsViewController.h"
#import "CupView.h"

@interface RecipeDetailsViewController()
@property (weak, nonatomic) IBOutlet UINavigationBar *navBarOutlet;
@property (weak, nonatomic) IBOutlet CupView *cupView;

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
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad...");
    // hide the status bar
    /*[[UIApplication sharedApplication] setStatusBarHidden:YES
                                              withAnimation:UIStatusBarAnimationFade];*/
    // set the size of the text in the navbar
    //self.navBarOutlet.titleTextAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14]};
    //self.navBarOutlet.barTintColor = [UIColor colorWithRed:0.112 green:0.234 blue:0.4 alpha:1];
    //self.view.backgroundColor = [UIColor blackColor];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
