//
//  DrinkDetailViewController.m
//  CollectionView-POC
//
//  Created by Sonny Back on 5/18/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "NewPhotoResultsViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface NewPhotoResultsViewController() <CLLocationManagerDelegate >
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOutlet;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation NewPhotoResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Lazy Instantiation

- (CLLocationManager *)locationManager {
    
    if (!_locationManager) {
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager requestWhenInUseAuthorization];
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // get the most accurate location
        _locationManager = locationManager;
    }
    
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //NSLog(@"Entered locationManager: didUpdateLocations:");
    self.location = [locations lastObject]; // last object in the array is always the most recent
}

#pragma mark - Action Methods

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    
    NSLog(@"INFO: Cancelling NewPhotoResultsViewController!");
    self.coffeeImageData = nil; // get rid of the CID object
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)useButtonPressed:(UIButton *)sender {
    NSLog(@"useButtonPressed!");
    //self.coffeeImageData.userID = @"SonnyB!"; // just for testing
    //NSLog(@"CID userid from NPRVC: %@", self.coffeeImageData.userID);
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    //self.imageViewOutlet.image = self.drinkImage;
    self.imageViewOutlet.image = [UIImage imageWithContentsOfFile:self.coffeeImageData.imageURL.path];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    NSLog(@"Activating location tracking!");
    // activite location tracking
    [self.locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    NSLog(@"Stopped location tracking!");
    // turn off location tracking
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"NewPhotoResultsViewController.viewDidLoad...");
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    self.imageViewOutlet.contentMode = UIViewContentModeScaleAspectFit;
    //self.imageViewOutlet.contentMode = UIViewContentModeScaleAspectFill;
    //self.imageViewOutlet.contentMode = UIViewContentModeScaleToFill;
    
    // Set this in every view controller so that the back button displays back < instead of the root view controller name
    //self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    NSLog(@"Finished viewDidLoad!");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:DO_ADD_PHOTO_SEGUE]) {
        //CoffeeImageData *addedCID = [[CoffeeImageData alloc] init];
        //self.coffeeImageData.userID = @"SonnyB!"; // just for testing
        //NSLog(@"CID userid from NPRVC: %@", self.coffeeImageData.userID);
        
        // set the CLLocation data
        self.coffeeImageData.latitude = @(self.location.coordinate.latitude);
        self.coffeeImageData.longitude = @(self.location.coordinate.longitude);
        NSLog(@"Location - latitude: %@ longitude: %@", self.coffeeImageData.latitude, self.coffeeImageData.longitude);
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    
    if ([identifier isEqualToString:@"Do Add Photo"]) {
        if (self.coffeeImageData) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

@end
