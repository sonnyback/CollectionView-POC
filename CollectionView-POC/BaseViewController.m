//
//  BaseViewController.m
//  CollectionView-POC
//
//  Created by Sonny Back on 3/27/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "BaseViewController.h"
#import "CoffeeViewCell.h"
#import "FooterViewCell.h"
#import "CustomFlowLayout.h"
#import "DrinkDetailViewController.h"
#import "CafeLocatorTableViewController.h"
#import "ImageLoadManager.h"
#import "Helper.h"
#import <QuartzCore/QuartzCore.h>

@interface BaseViewController()
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (strong, nonatomic) NSArray *imagesArray; // of UIImage (array of images to display)
@property (strong, nonatomic) NSMutableArray *imageNames; // of NSString (name of the images)
@property (weak, nonatomic) IBOutlet UISegmentedControl *imageRecipeSegmentedControl;
@property (strong, nonatomic) ImageLoadManager *imageLoadManager;
@property (weak, nonatomic) UIColor *const globalColor;
/** replaced 2 buttons below with segmented control
@property (weak, nonatomic) IBOutlet UIButton *coffeeImagesButton;
@property (weak, nonatomic) IBOutlet UIButton *recipeImagesButton;*/
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) UIImageView *fullScreenImage;
@property (strong, nonatomic) CustomFlowLayout *flowLayout;
@end

@implementation BaseViewController

NSInteger const CellWidth = 290; // width of cell
NSInteger const CellHeight = 320; // height of cell

#pragma mark - Lazy Instantiation
// lazy instantiate imagesArray
- (NSArray *)imagesArray {
    
    if (!_imagesArray) {
        _imagesArray = [[NSArray alloc] init];
    }
    
    return _imagesArray;
}

// lazy instantiate imageNames
- (NSMutableArray *)imageNames {
    
    if (!_imageNames) {
        _imageNames = [[NSMutableArray alloc] init];
    }
    
    return _imageNames;
}

// lazy instantiate imageLoadManager
- (ImageLoadManager *)imageLoadManager {
    
    if (!_imageLoadManager) {
        _imageLoadManager = [[ImageLoadManager alloc] initImagesForSelection:[self getSelectedSegmentTitle]];
    }
    
    return _imageLoadManager;
}

// return the value for globalColor ro
- (UIColor *)globalColor {
    
    return [UIColor colorWithRed:0.5 green:0.6 blue:0.8 alpha:1.0]; // original color i came up with randonmly
    //return [UIColor colorWithRed:0.112 green:0.234 blue:0.4 alpha:1]; // simulated redbox app color (grayish blue)
}

#pragma mark - Setters

- (void)setImageRecipeSegmentedControl:(UISegmentedControl *)imageRecipeSegmentedControl {
    
    _imageRecipeSegmentedControl = imageRecipeSegmentedControl;
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    //NSLog(@"textFieldShouldReturn");
    [self.searchBar resignFirstResponder]; // kill the keyboard
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    NSLog(@"textFieldShouldClear");
    return YES;
}

#pragma mark - CollectionView Protocol methods

// implementing protocol method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1; // only one cell
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.imagesArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CoffeeCell"; // string value identifier for cell reuse
    CoffeeViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSLog(@"cellForItemAtIndexPath: section: row: %ld %ld", (long)indexPath.section, (long)indexPath.row);
    //cell.backgroundColor = [UIColor whiteColor];
    //cell.layer.cornerRadius = 3;
    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    
    //CGRect originalImageFrame = cell.coffeeImageView.frame;
    
    //cell.coffeeImageView.frame = CGRectMake(originalImageFrame.origin.x, originalImageFrame.origin.y, originalImageFrame.size.width, originalImageFrame.size.height - 25);
    
    NSString *myPatternString = [self.imageNames objectAtIndex:indexPath.row];
    //[self updateDrinkNameLabel:indexPath.row];
    //cell.patternImageView.image = [UIImage imageNamed:myPatternString];
    cell.coffeeImageView.image = [self.imagesArray objectAtIndex:indexPath.row];
    
    /* UIViewContentMode options from here....*/
    //cell.coffeeImageView.contentMode = UIViewContentModeScaleToFill; // distorts the image
    //cell.coffeeImageView.contentMode = UIViewContentModeScaleAspectFill; // fills out image area, but image is cropped
    cell.coffeeImageView.contentMode = UIViewContentModeScaleAspectFit; // maintains aspect, but does not always fill image area
    /*...to here...*/
    
    //cell.coffeeImageView.clipsToBounds = YES;
    cell.coffeeImageLabel.text = myPatternString;
    
    /** Below lines intended to place cell in right location without having to use custom flow layout, but 
     did not work correctly. */
    //cell.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height/2 * .15)+indexPath.row*10);
    //cell.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height/2 * .15));
    //cell.patternImageView.center = CGPointMake(cell.contentView.bounds.size.width/2, (cell.contentView.bounds.size.height/2 * .10));
    
    cell.coffeeImageLabel.alpha = 0.3; // set the label to be semi transparent
    cell.coffeeImageLabel.hidden = YES; // just for toggling on/off until this label is completely removed
    
    /*CGSize labelSize = CGSizeMake(CellWidth, 20);
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.size.width/2, cell.bounds.size.height-labelSize.height, cell.bounds.size.width, labelSize.height)];
    testLabel.text = [NSString stringWithFormat:@"Test%ld", (long)indexPath.row];
    [cell.contentView addSubview:testLabel];*/
    
    return cell;
}

/**
 * Overridden method that sets the size for each item (cell) at the given index.
 * This can be commmented out if Flowlayout.itemSize is set (**NOT NEEDED since set in setupCollectionView method below)
 *
 * @param UICollectionView*, UICollectionViewLayout*, NSIndexPath
 * @return CGSize - size of the item
 */
/*- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //UIImage *currentImage;
    //currentImage = self.imagesArray[indexPath.row];
    //return currentImage.size;
    //return CGSizeMake(250, 250); // fixed size 250x250
}*/

/**
 * Overridden method to provide edge insets for the cells. This implementation's purpose is to center each cell
 * and leave a blank border between the screen edges and the left and right cells when scrolling. Without this, 
 * each cell will be hard aligned with the left border.
 * *NOTE* The below implementation works, but I did not come up with this. Got it from Stackoverflow thread
 *
 * @param UICollectionView*, UICollectionViewLayout*, NSInteger - section
 * @return UIEdgeInsets* - 
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    NSLog(@"insetForSectionAtIndex");
    NSInteger numberOfCells = self.view.frame.size.width / CellWidth;
    NSInteger edgeInsets = (self.view.frame.size.width - (numberOfCells * CellWidth)) / (numberOfCells + 1);
    
    return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CoffeeViewCell *selectedCell = (CoffeeViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"didSelectItemAtIndexPath");
    self.fullScreenImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.fullScreenImage.contentMode = UIViewContentModeScaleAspectFit;
    self.fullScreenImage.tag = 1;

    /*if (!self.isFullScreen) {
        [UIView transitionFromView:selectedCell.contentView toView:self.fullScreenImage duration:0.5 options:0
                        completion:^(BOOL finished){
                            self.fullScreenImage.center = self.view.center;
                            self.fullScreenImage.backgroundColor = [UIColor blackColor];
                            self.fullScreenImage.image = selectedCell.coffeeImageView.image;
                            [self.view addSubview:self.fullScreenImage];
                            self.isFullScreen = YES;
        }];
        return;
    } else {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            for (UIView *subView in self.view.subviews) {
                if (subView.tag == (int)self.fullScreenImage.tag) {
                    [subView removeFromSuperview];
                    break;
                }
            }
        }completion:^(BOOL finished){
            self.isFullScreen = NO;
            //[self.myCollectionView reloadData];
        }];
        return;
    }*/
    
    if (!self.isFullScreen) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            NSLog(@"starting animiation!");
            //prevFrame = selectedCell.coffeeImageView.frame;
            //self.flowLayout.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
            //[selectedCell setFrame:[[UIScreen mainScreen] bounds]];
            //selectedCell.coffeeImageView.center = self.view.center;
            //selectedCell.coffeeImageView.backgroundColor = [UIColor blackColor];
            //[selectedCell.coffeeImageView setFrame:[[UIScreen mainScreen] bounds]];
            self.searchBar.hidden = YES;
            self.fullScreenImage.center = self.view.center;
            self.fullScreenImage.backgroundColor = [UIColor blackColor];
            self.fullScreenImage.image = selectedCell.coffeeImageView.image;
            [self.view addSubview:self.fullScreenImage];
        }completion:^(BOOL finished){
            self.isFullScreen = YES;
        }];
        return;
    } else {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            self.searchBar.hidden = NO;
            //self.flowLayout.itemSize = CGSizeMake(290, 290);
            //[selectedCell.coffeeImageView setFrame:prevFrame];
            selectedCell.coffeeImageView.backgroundColor = [UIColor colorWithRed:0.62 green:0.651 blue:0.686 alpha:1];
            for (UIView *subView in self.view.subviews) {
                if (subView.tag == (int)self.fullScreenImage.tag) {
                    [subView removeFromSuperview];
                    break;
                }
            }
        }completion:^(BOOL finished){
            self.isFullScreen = NO;
        }];
        return;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CoffeeViewCell *selectedCell = (CoffeeViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
     NSLog(@"didDeSelectItemAtIndexPath");
    selectedCell.coffeeImageLabel.backgroundColor = [UIColor whiteColor];
    selectedCell.coffeeImageLabel.textColor = [UIColor blackColor];
}

/*- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didEndDisplayingCell");
    PatternViewCell *currentCell = ([[collectionView visibleCells] count] > 0) ? [[collectionView visibleCells] objectAtIndex:0] : nil;
    if (cell != nil){
        NSInteger index = [collectionView indexPathForCell:currentCell].row;
    }
    
}*/


/*
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    NSLog(@"perform Action!");
    PatternViewCell *selectedCell = (PatternViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"selectedCell: %@", [selectedCell description]);
    
}*/

/*- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"viewForSupplementaryElementOfKind");
    
    static NSString *FooterCellIdentifier = @"FooterView"; // string value identifier for cell reuse
    FooterViewCell *footerView;
    if (kind == UICollectionElementKindSectionFooter) {
        NSLog(@"*******Element Kind is a footer!*******");
        footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                        withReuseIdentifier:FooterCellIdentifier forIndexPath:indexPath];
        for (int i = 0; i < [self.imagesArray count]; i++) {
            UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.myCollectionView.center.x * i,
                                                                           self.myCollectionView.center.y * .85, CellWidth, 20)];
            //testLabel.text = [self.imageNames objectAtIndex:indexPath.row];
            testLabel.text = self.imageNames[i];
            [self.myCollectionView addSubview:testLabel];
        }
        
         return footerView;
    } else {
        NSLog(@"*******Element Kind is NOT a footer!*******");
        return nil;
    }
}*/

#pragma mark - UI Setup

/**
 * Method responsible for updating the UI and mapping from the UI to the model
 *
 * @return void
 */
- (void)updateUI {
    
    NSLog(@"updateUI...");
    /*if (!self.coffeeImagesButton.isSelected) {
     NSLog(@"button is NOT selected");
     [self.coffeeImagesButton setTitle:@"Images" forState:UIControlStateNormal];
     [self.coffeeImagesButton setBackgroundColor:[UIColor whiteColor]];
     } else {
     NSLog(@"button is selected");
     [self.coffeeImagesButton setTitle:@"Recipes" forState:UIControlStateSelected];
     //self.toggleImagesRecipesButton.layer.borderColor = [UIColor blueColor].CGColor;
     }*/
    
    /** USE THE NEXT LINE ONLY WHEN TESTING ON DEVICE SO THAT LOCAL IMAGES WILL LOAD **/
    //self.imagesArray = [self loadImages];
    
    /** This pulls from the model and loads images from local directory - will not load images to the device */
    self.imagesArray = self.imageLoadManager.imagesArray; // calls the model and maps UI to the model (and loads the images)
    NSLog(@"imagesArray size: %lu", (unsigned long)[self.imagesArray count]);
    self.imageNames = [self.imageLoadManager.imageNames copy]; // get the image names from the array in the model
}

#define ITEM_SIZE 290.0 // item size for the cell **SHOULD ALWAYS MATCH CellWidth constant!
#define EDGE_OFFSET 0.5
/**
 * Method to setup the collectionview attributes
 *
 * @return void
 */
- (void)setupCollectionView {
    NSLog(@"setupCollectionView");
    //UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    /*CustomFlowLayout *flowLayout = [[CustomFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE); // globally sets the item (cell) size
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal]; // set scroll direction to horizontal*/
    self.flowLayout = [[CustomFlowLayout alloc] init];
    self.flowLayout.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    //[self.myCollectionView setBackgroundColor:[UIColor colorWithRed:0.227 green:0.349 blue:0.478 alpha:1]]; // ok color
    [self.myCollectionView setBackgroundColor:[UIColor colorWithRed:0.62 green:0.651 blue:0.686 alpha:1]];
    self.myCollectionView.multipleTouchEnabled = NO; // don't allow multiple cells to be selected at the same time
    //[self.myCollectionView setBackgroundColor:[UIColor whiteColor]];
    //[self.myCollectionView setPagingEnabled:YES]; // don't use since using CustomFlowLayout.targetContentOffsetForProposedContentOffset
    //self.myCollectionView.clipsToBounds = YES;
    
    //self.myCollectionView.delegate = self; // not needed since done in storyboard
    //self.myCollectionView.dataSource = self; // not needed since done in storyboard
    
    /*** NEXT 2 LINES ARE FOR THE SUPPLEMENTAL VIEW FOR THE FOOTER ***/
    //[self.myCollectionView registerClass:[FooterViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"]; // not needed since set in storyboard
    //flowLayout.footerReferenceSize = CGSizeMake(20, 20); // needed for supplemental view (footer)
    
    [self.myCollectionView setCollectionViewLayout:self.flowLayout];
}

#define BUTTON_WIDTH 105.0
#define BUTTON_HEIGHT 25.0

/**
 * Method to setup the buttons for toggling between drink images and recipes
 * *NOTE* This is no longer needed since replaced with UISegmentControl
 *
 * @return void
 */
- (void)setupButtons {
    
    NSLog(@"setupButtons");
    UIButton *upperLeftButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *upperRightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    // Quartz/Core properties
    upperLeftButton.layer.cornerRadius = 4.0;
    upperLeftButton.layer.borderWidth = 1.0;
    upperLeftButton.layer.borderColor = [UIColor grayColor].CGColor;
    
    upperRightButton.layer.cornerRadius = 4.0;
    upperRightButton.layer.borderWidth = 1.0;
    upperRightButton.layer.borderColor = [UIColor grayColor].CGColor;
    
    [upperLeftButton setTitle:@"Drink Images" forState:UIControlStateNormal];
    [upperRightButton setTitle:@"Drink Recipes" forState:UIControlStateNormal];
    
    CGFloat xCoord = self.view.frame.size.width;
    CGFloat yCoord = self.view.frame.size.height;
    
    // set the placement in the UI - left button goes in the center, offset by it's length,
    // right button goes directly in center directly butted up against the left button
    [upperLeftButton setFrame:CGRectMake(xCoord/2 - BUTTON_WIDTH, (yCoord * .15), BUTTON_WIDTH, BUTTON_HEIGHT)];
    [upperRightButton setFrame:CGRectMake(xCoord/2, (yCoord * .15), BUTTON_WIDTH, BUTTON_HEIGHT)];
    
    [upperLeftButton setBackgroundColor:[UIColor whiteColor]];
    [upperRightButton setBackgroundColor:[UIColor whiteColor]];
    
    [upperLeftButton setEnabled:YES];
    [upperRightButton setEnabled:YES];
    
    // draw it onscreen
    [self.view addSubview:upperLeftButton];
    [self.view addSubview:upperRightButton];
}

/**
 * Method to setup the UISearchBar in the navigation bar
 *
 * @return void
 */
- (void)setupSearchBar {
    
    /*UISearchBar *searchBar = [[UISearchBar alloc] init];
    //searchBar.backgroundColor = [UIColor colorWithRed:0.5 green:0.6 blue:0.8 alpha:1.0];
    searchBar.placeholder = @"Search for Coffee";
    searchBar.showsCancelButton = YES;
    [searchBar sizeToFit];
    //UIView *barWrapper = [[UIView alloc]initWithFrame:searchBar.bounds];
    //[barWrapper addSubview:searchBar];
    self.navigationItem.titleView = searchBar;*/
    
    /** SWITCHED FROM UISEARCHBAR TO UITEXTFIELD **/
    self.searchBar.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchBar.placeholder = @"Search for coffee";
    //self.searchBar.background = [UIImage imageNamed:@"magnifier_24.png"];
    self.searchBar.delegate = self; // this tells textfield delegate messages to be sent to this VC
    
    // took this from the web and uses unicode based magnifying icon
    UILabel *searchIcon = [[UILabel alloc] init];
    [searchIcon setText:[[NSString alloc] initWithUTF8String:"\xF0\x9F\x94\x8D"]]; // magnifying glass
    //[searchIcon setText:[[NSString alloc] initWithUTF8String:"\xE2\x98\x95"]]; // coffee cup
    [searchIcon sizeToFit];
    
    [self.searchBar setLeftView:searchIcon];
    [self.searchBar setLeftViewMode:UITextFieldViewModeAlways];
    
    /** USE THIS IF USING AN IMAGE **/
    /*UIImageView *myView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"magnifying_glass_32.png"]];
    [self.searchBar  setLeftView:myView];
    [self.searchBar  setLeftViewMode:UITextFieldViewModeAlways];*/
}

#pragma mark - Helper Methods

/**
 * Method to determine the selected segment from the UISegmentedControl and
 * get the corresponded title.
 *
 * @return NSString* Selected Title
 */
- (NSString *)getSelectedSegmentTitle {
    
    NSInteger segmentedIndex = self.imageRecipeSegmentedControl.selectedSegmentIndex;
    //NSString *segmentTitle = [self.imageRecipeSegmentedControl titleForSegmentAtIndex:segmentedIndex];
    return [self.imageRecipeSegmentedControl titleForSegmentAtIndex:segmentedIndex];
}

/**
 * Method to load images from a local directory. This has now been moved to the model -
 * (ImageLoadManager). This should only be used for testing on the device to get loacl images
 * loaded to the device.
 *
 * @return NSMutableArray* of UIImages
 */
- (NSMutableArray *)loadImages {
    
    NSLog(@"Entered loadImages!");
    NSMutableArray *arrayOfUIImages = [[NSMutableArray alloc] init];
    
    /*NSFileManager *fileManager = [[NSFileManager alloc] init];
     NSString *directoryFilePath = @"/Users/Sonny/Desktop/images/";
     BOOL success = [fileManager fileExistsAtPath:directoryFilePath];
     
     if (success) {
     NSLog(@"Directory exists!");
     NSArray *imageNamesFromDirectory = [fileManager contentsOfDirectoryAtPath:directoryFilePath error:nil];
     NSString *searchString = @".png";
     
     for (int i = 0; i < [imageNamesFromDirectory count]; i++) {
     //NSLog(@"contents from directory %@", imageNamesFromDirectory[i]);
     // file name creation requires full path to create the UIImage based off the file name
     NSString *nameOfImageFromFile = [directoryFilePath stringByAppendingString:[imageNamesFromDirectory[i] description]];
     NSLog(@"file name:%@", nameOfImageFromFile);
     NSRange range = [nameOfImageFromFile rangeOfString:searchString];
     if (range.location != NSNotFound) {
     NSLog(@"found search string!");
     UIImage *image = [UIImage imageWithContentsOfFile:nameOfImageFromFile];
     NSLog(@"Image size: width:%f, height:%f", image.size.width, image.size.height
     );
     [arrayOfUIImages addObject:image];
     // remove the directory path from the file name and add image name to the imageNames array
     NSString *fileNameWithoutPath = [self removePathFromFileName:nameOfImageFromFile forPath:directoryFilePath];
     [self.imageNames addObject:fileNameWithoutPath];
     }
     }
     }*/
    /** ONLY USE THIS IF ABOVE CODE IS COMMENTED OUT! THIS IS FOR LOCAL IMAGES TO RUN ON DEVICE ONLY! **/
    for (int i = 1; i <= 5; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"image%d", i]];
        [arrayOfUIImages addObject:image];
        [self.imageNames addObject:[NSString stringWithFormat:@"image%d", i]];
    }
    
    NSLog(@"arrayOfImages size: %d", [self.imagesArray count]);
    //[self updateUI];
    
    return arrayOfUIImages;
}

/**
 * Method to remove preceeding directory path from the file name.
 *
 * @param NSString *fileName
 * @param NSString *path
 * @return NSString *string filename without path
 */
- (NSString *)removePathFromFileName:(NSString *)fileName forPath:(NSString *)path {
    
    NSLog(@"Entered removePathFromFileName - filename: %@", fileName);
    NSString *returnString = @"";
    
    returnString = [fileName stringByReplacingOccurrencesOfString:path withString:@""];
    
    NSLog(@"returnString:%@", returnString);
    
    return returnString;
}

#pragma mark - Action Methods

/**
 * Action Method to track the segmented control being changed
 *
 * @param UISegmentedControl* sender
 * @return void
 */
- (IBAction)segmentedControlSelected:(UISegmentedControl *)sender {
    NSLog(@"segmentedControlSelected: index - %ld", (long)sender.selectedSegmentIndex);
    if (sender.selectedSegmentIndex == 0) { // Images
        // todo
    } else if (sender.selectedSegmentIndex == 1) { // Recipes
        // todo
    }
    else if (sender.selectedSegmentIndex == 2)  { // Cafes
        [self performSegueWithIdentifier:@"Cafes" sender:self];
    }
}

- (void)imgToFullScreen:(UITapGestureRecognizer *)gesture {
    
    NSLog(@"imgToFullScreen");
    
    if (!self.isFullScreen) {
        //self.imageView.backgroundColor = [UIColor blackColor];
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            //prevFrame = self.imageView.frame;
            //self.imageView.backgroundColor = [UIColor blackColor];
            //[self.imageView setFrame:[[UIScreen mainScreen] bounds]];
        }completion:^(BOOL finished){
            self.isFullScreen = YES;
        }];
        return;
    } else {
        //self.imageView.backgroundColor = [UIColor whiteColor];
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            //[self.imageView setFrame:prevFrame];
            //self.imageView.backgroundColor = [UIColor whiteColor];
        }completion:^(BOOL finished){
            self.isFullScreen = NO;
        }];
    }
}

- (IBAction)coffeeImagesButtonPressed:(UIButton *)sender {
    
    NSLog(@"coffeeImagesButtonPressed!");
    //self.coffeeImagesButton.selected = !self.coffeeImagesButton.selected; // toggle selected state
    
    //[self updateUI];
}

#pragma mark - VC Lifecyle Methods
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    NSLog(@"viewDidLayoutSubviews");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCollectionView]; // setup the collectionview parameters
    [self setupSearchBar]; // setup the search bar in the navigation bar
    //self.navigationController.navigationBar.barTintColor = self.globalColor; // set the background color of the navigation bar
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.112 green:0.234 blue:0.4 alpha:1];
    // below is just a test. colors provided by Otha and are displaying correct color through helper method
    //self.navigationController.navigationBar.barTintColor = [Helper colorFromRed:112.0 Green:234.0 Blue:4.0 Alpha:1.0];
    //[self setupButtons]; // setup the buttons - not needed since changed to uisegmentedcontrol
    //NSLog(@"imageLoadManager description %@", [self.imageLoadManager description]); // just to initialize IML for testing
    
    // Set this in every view controller so that the back button displays back instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self updateUI];
}

- (void)viewDidAppear:(BOOL)animated {
    
    /* Need to make sure when coming *back* from CafeLocatorTableVC segue that Cafes does not stay selected.
     * Otherwise, user has to manually tap another segment control, then tap Cafes again to go back to cafe
     * locator. Will make this go back to Images segment. However, this may be better handled by a delegate -
     * need to investigate.
     */
    if ([[self getSelectedSegmentTitle] isEqualToString:@"Cafes"]) {
        NSLog(@"ViewDidAppear - Cafes!!");
        self.imageRecipeSegmentedControl.selectedSegmentIndex = 0;
        [self.myCollectionView reloadData];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"PrepareForSegue!");
    /*if ([segue.identifier isEqualToString:@"Recipes"]) {
    //if ([segue.identifier isEqualToString:[self getSelectedSegmentTitle]]) {
        NSLog(@"Segue to Recipes!");
        CoffeeViewCell *cell = (CoffeeViewCell *)sender;
        NSIndexPath *indexPath = [self.myCollectionView indexPathForCell:cell];
        
        DrinkDetailViewController *ddvc = (DrinkDetailViewController *)[segue destinationViewController];
        ddvc.drinkImage = [self.imagesArray objectAtIndex:indexPath.row];
    } else*/ if ([segue.identifier isEqualToString:[self getSelectedSegmentTitle]]) { // identifer & segment tile = "Cafes"
        NSLog(@"Segue to Cafe locator!");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
