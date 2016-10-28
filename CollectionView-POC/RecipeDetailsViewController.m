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

/**
 * Helper method to alert user of info and errors. Takes a title and message parameters.
 *
 * @param NSString *title - title of the error/info
 * @param NSString *msg - message to be displayed to user
 * @return void
 */
- (void)alertWithTitle:(NSString *)title andMessage:(NSString *)msg {
    
    /* NOTE: This is the iOS 8 way of handling alerts. UIAlertView has been deprecated for iOS 8*/
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
     [alert addAction:defaultAction];
     [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    NSLog(@"INFO: RecipeDetailsViewController.cancelButtonPressed...");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)finishButtonPressed:(UIButton *)sender {
    
    NSLog(@"INFO: RecipeDetailsViewController.finishButtonPressed...");
}

- (IBAction)addIngredientsButtonPressed:(UIButton *)sender {
    
    NSLog(@"INFO: addIngredientsButtonPressed");
    
    if (self.numberOfTextFields > 11) {
        [self alertWithTitle:@"Too Many Instructions" andMessage:@"Please limit recipe instructions to 12 steps."];
    } else {
        CGFloat x = self.recipeInstructionTextfield.frame.origin.x;
        CGFloat y = self.recipeInstructionTextfield.frame.origin.y + (self.recipeInstructionTextfield.frame.size.height+5);
        CGFloat width = self.recipeInstructionTextfield.frame.size.width;
        CGFloat height = self.recipeInstructionTextfield.frame.size.height;
        CGRect textFieldFrame = CGRectMake(x, y, width, height);
        //NSLog(@"recipeInstructionTextfield is x:%f, y:%f, width:%f, height:%f ", self.recipeInstructionTextfield.frame.origin.x, self.recipeInstructionTextfield.frame.origin.y, self.recipeInstructionTextfield.frame.size.width, self.recipeInstructionTextfield.frame.size.height);
        //NSLog(@"addIngredientButton is x:%f, y:%f, width:%f, height:%f ", self.addIngredientButton.frame.origin.x, self.addIngredientButton.frame.origin.y, self.addIngredientButton.frame.size.width, self.addIngredientButton.frame.size.height);
        //NSLog(@"textFieldFrame is x:%f, y:%f, width:%f, height:%f ", x, y, width, height);
        UITextField *textField = [[UITextField alloc] initWithFrame:textFieldFrame];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.font = [UIFont systemFontOfSize:14];
        textField.placeholder = @"Enter recipe instruction...";
        textField.delegate = self;
        
        [self.scrollView addSubview:textField];
        self.recipeInstructionTextfield = textField;
        [self.addIngredientButton removeFromSuperview];
        
        CGFloat addButtonX = self.addIngredientButton.frame.origin.x;
        CGFloat addButtonY = textField.frame.origin.y + textField.frame.size.height + 5;
        UIButton *newButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        newButton.frame = CGRectMake(addButtonX, addButtonY, self.addIngredientButton.frame.size.width, self.addIngredientButton.frame.size.height);
        [newButton setBackgroundImage:[UIImage imageNamed:PLUS_25] forState:UIControlStateNormal];
        [newButton addTarget:self action:@selector(addIngredientsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        //NSLog(@"addIngredientButton is x:%f, y:%f, width:%f, height:%f ", newButton.frame.origin.x, newButton.frame.origin.y, newButton.frame.size.width, newButton.frame.size.height);
        [self.scrollView addSubview:newButton];
        self.addIngredientButton = newButton;
        
        [self checkForTextFields];
        self.numberOfTextFields++; // increment numberOfTextFields to keep count
    }
}


- (IBAction)actionButtonForHotOrColdCup:(id)sender {
    
    NSLog(@"INFO: actionButtonForHotOrColdCup...");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:HOT_COLD_TITLE message:HOT_COLD_MSG preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *hotAction = [UIAlertAction actionWithTitle:HOT
                                                       style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                           self.cupView.cupType = HOT_DRINK;
                                                           self.cupView.backgroundView.image = [UIImage imageNamed:self.cupView.cupType];
                                                       }];
    
    UIAlertAction *coldAction = [UIAlertAction actionWithTitle:COLD
                                                        style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                            self.cupView.cupType = COLD_DRINK;
                                                            self.cupView.backgroundView.image = [UIImage imageNamed:self.cupView.cupType];
                                                        }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:CANCEL_BUTTON
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                               NSLog(@"INFO: Cancel button, so do nothing...");
                                                           }];
    
    [alert addAction:hotAction];
    [alert addAction:coldAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)checkForTextFields {
    
    NSArray *subViews = [self.scrollView subviews];
    int textfieldCount = 0;
    for (int i = 0; i < [subViews count]; i++) {
        UIView *currentView = subViews[i]; // get the current subview
        if ([currentView isKindOfClass:[UITextField class]]) {
            //NSLog(@"TextField found!");
            textfieldCount++;
        }
    }
    NSLog(@"The scrollView contains %d textfields", textfieldCount);
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
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setBounces:YES];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    //self.scrollView.contentSize = self.view.bounds.size; // may not be exactly correct, but intent is to allow vertical scrolling
    [self setupTextFields];
    
    
    [self actionButtonForHotOrColdCup:self];
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
    self.drinkNameTextField.delegate = self;
    self.recipeInstructionTextfield.delegate = self;
    
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
