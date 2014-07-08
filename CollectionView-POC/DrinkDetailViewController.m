//
//  DrinkDetailViewController.m
//  CollectionView-POC
//
//  Created by Sonny Back on 5/18/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "DrinkDetailViewController.h"

@interface DrinkDetailViewController()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOutlet;
@end

@implementation DrinkDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
    NSLog(@"viewWillAppear");
    self.imageViewOutlet.image = self.drinkImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageViewOutlet.contentMode = UIViewContentModeScaleAspectFit;
    //self.imageViewOutlet.contentMode = UIViewContentModeScaleAspectFill;
    //self.imageViewOutlet.contentMode = UIViewContentModeScaleToFill;
    
    // Set this in every view controller so that the back button displays back < instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
