//
//  RecipeDetailsViewController.m
//  CollectionView-POC
//
//  Created by Sonny Back on 4/17/15.
//  Copyright (c) 2015 Sonny Back. All rights reserved.
//

#import "RecipeDetailsViewController.h"
#import "SWRevealViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CupView.h"

@interface RecipeDetailsViewController()
//@property (weak, nonatomic) IBOutlet UINavigationBar *navBarOutlet;
@property (weak, nonatomic) IBOutlet CupView *cupView;
@property (weak, nonatomic) IBOutlet UITextField *drinkNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *recipeInstructionTextfield;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *addIngredientButton;
@property (nonatomic) NSInteger numberOfTextFields;
@end

@implementation RecipeDetailsViewController

#pragma mark - Action Methods

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    NSLog(@"INFO: RecipeDetailsViewController.cancelButtonPressed...");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)finishButtonPressed:(UIButton *)sender {
    
    NSLog(@"INFO: RecipeDetailsViewController.finishButtonPressed...");
}

- (IBAction)addIngredientsButtonPressed:(UIButton *)sender {
    
    NSLog(@"INFO: addIngredientsButtonPressed");
    self.numberOfTextFields++;
    float x = self.recipeInstructionTextfield.frame.origin.x;
    float y = self.recipeInstructionTextfield.frame.origin.y + (self.recipeInstructionTextfield.frame.size.height+5);
    float width = self.recipeInstructionTextfield.frame.size.width;
    float height = self.recipeInstructionTextfield.frame.size.height;
    CGRect textFieldFrame = CGRectMake(x, y, width, height);
    NSLog(@"recipeInstructionTextfield is x:%f, y:%f, width:%f, height:%f ", self.recipeInstructionTextfield.frame.origin.x, self.recipeInstructionTextfield.frame.origin.y, self.recipeInstructionTextfield.frame.size.width, self.recipeInstructionTextfield.frame.size.height);
    NSLog(@"textFieldFrame is x:%f, y:%f, width:%f, height:%f ", x, y, width, height);
    UITextField *textField = [[UITextField alloc] initWithFrame:textFieldFrame];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [UIFont systemFontOfSize:14];
    textField.placeholder = @"Enter recipe instruction...";
    
    float addButtonX = self.addIngredientButton.frame.origin.x;
    float addButtonY = self.addIngredientButton.frame.origin.y + self.addIngredientButton.frame.origin.y;
    //[self.addIngredientButton.layer setFrame:CGRectMake(addButtonX, addButtonY, self.addIngredientButton.frame.size.width, self.addIngredientButton.frame.size.height)];
    [self.addIngredientButton.layer setFrame:CGRectMake(addButtonX, addButtonY+50, self.addIngredientButton.frame.size.width, self.addIngredientButton.frame.size.height)];
    
    [self.scrollView addSubview:textField];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSLog(@"textFieldShouldReturn");
    [self.drinkNameTextField resignFirstResponder]; // kill the keyboard
    [self.recipeInstructionTextfield resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    NSLog(@"textFieldShouldClear");
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:0.62 green:0.651 blue:0.686 alpha:1]];
    self.numberOfTextFields = 1; // initial number of text fields for recipe instructions
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad...");
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        NSLog(@"INFO: We have a revealVC!");
        [self.sidebarButton setTarget:self.revealViewController];
        [self.sidebarButton setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    } else {
        NSLog(@"DEBUG: No revealVC found!");
    }
    
    [self.scrollView setShowsVerticalScrollIndicator:YES];
    [self.scrollView setShowsHorizontalScrollIndicator:YES];
    [self setupTextFields];
    
    // hide the status bar
    /*[[UIApplication sharedApplication] setStatusBarHidden:YES
                                              withAnimation:UIStatusBarAnimationFade];*/
    // set the size of the text in the navbar
    //self.navBarOutlet.titleTextAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:14]};
    //self.navBarOutlet.barTintColor = [UIColor colorWithRed:0.112 green:0.234 blue:0.4 alpha:1];
    //self.view.backgroundColor = [UIColor blackColor];
}

- (void)setupTextFields {
    
    NSLog(@"INFO: setupTextFields...");
    self.drinkNameTextField.placeholder = NAME_YOUR_DRINK;
    self.recipeInstructionTextfield.placeholder = @"Enter recipe instruction...";
    
    /*for (int i = 0; i < self.numberOfTextFields; i++) {
        
        NSLog(@"Setting up textfield %d", i);
        UITextField *textField = [[UITextField alloc] init];
        textField.tag = i;
        [self.scrollView addSubview:textField];
    }*/
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue isKindOfClass:[SWRevealViewController class]]) {
        NSLog(@"Bingo! Seguing to SWRevealVC!");
    } else {
        NSLog(@"This bullshit didn't work!");
    }
}*/

@end
