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
#import "ImageLoadManager.h"
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
@property (strong, nonatomic) NSArray *cellIndexes;
@end

@implementation BaseViewController

NSInteger const CellWidth = 290; // width of cell

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

// lazy instantiate cellIndexes
- (NSArray *)cellIndexes {
    
    if (!_cellIndexes) {
        _cellIndexes = [[NSArray alloc] init];
    }
    
    return _cellIndexes;
}

// return the value for globalColor ro
- (UIColor *)globalColor {
    
    return [UIColor colorWithRed:0.5 green:0.6 blue:0.8 alpha:1.0];
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
    NSLog(@"cellForItemAtIndexPath: section: row: %d %d", indexPath.section, indexPath.row);
    //cell.backgroundColor = [UIColor whiteColor];
    //cell.layer.cornerRadius = 3;
    cell.layer.borderWidth = 1.0;
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    
    NSString *myPatternString = [self.imageNames objectAtIndex:indexPath.row];
    //[self updateDrinkNameLabel:indexPath.row];
    //cell.patternImageView.image = [UIImage imageNamed:myPatternString];
    cell.patternImageView.image = [self.imagesArray objectAtIndex:indexPath.row];
    
    /* UIViewContentMode options from here....*/
    //cell.patternImageView.contentMode = UIViewContentModeScaleToFill; // distorts the image
    //cell.patternImageView.contentMode = UIViewContentModeScaleAspectFill; // fills out image area, but image is cropped
    cell.patternImageView.contentMode = UIViewContentModeScaleAspectFit; // maintains aspect, but does not always fill image area
    /*...to here...*/
    
    cell.patternImageView.clipsToBounds = YES;
    cell.patternLabel.text = myPatternString;
    
    /** Below lines intended to place cell in right location without having to use custom flow layout, but 
     did not work correctly. */
    //cell.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height/2 * .15)+indexPath.row*10);
    //cell.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height/2 * .15));
    //cell.patternImageView.center = CGPointMake(cell.contentView.bounds.size.width/2, (cell.contentView.bounds.size.height/2 * .10));
    
    cell.patternLabel.alpha = 0.3; // set the label to be semi transparent
    
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
    
    return CGSizeMake(250, 250);
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
    selectedCell.patternLabel.backgroundColor = [UIColor blueColor];
    selectedCell.patternLabel.textColor = [UIColor whiteColor];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CoffeeViewCell *selectedCell = (CoffeeViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
     NSLog(@"didDeSelectItemAtIndexPath");
    selectedCell.patternLabel.backgroundColor = [UIColor whiteColor];
    selectedCell.patternLabel.textColor = [UIColor blackColor];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
    
    static NSString *FooterCellIdentifier = @"FooterView"; // string value identifier for cell reuse
    FooterViewCell *footerView;
    if (kind == UICollectionElementKindSectionFooter) {
        NSLog(@"*******Element Kind is a footer!*******");
        footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                        withReuseIdentifier:FooterCellIdentifier forIndexPath:indexPath];
        UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.myCollectionView.frame.origin.x/2, self.myCollectionView.frame.origin.y/2, CellWidth, 20)];
        testLabel.text = @"Hello";
        [self.myCollectionView addSubview:testLabel];
         return footerView;
    } else {
        NSLog(@"*******Element Kind is NOT a footer!*******");
        return nil;
    }
    
    /*UICollectionReusableView *reusableview = nil;
    static NSString *FooterCellIdentifier = @"FooterView"; // string value identifier for cell reuse
    
    if (kind == UICollectionElementKindSectionFooter) {
        NSLog(@"*******Element Kind is a footer!*******");
        FooterViewCell *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:FooterCellIdentifier forIndexPath:indexPath];
        
        reusableview = footerView;
    } else {
        NSLog(@"*******Element Kind is NOT a footer!*******");
    }
    
    return reusableview;*/
}

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
    CustomFlowLayout *flowLayout = [[CustomFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE); // globally sets the item (cell) size
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal]; // set scroll direction to horizontal
    
    [self.myCollectionView setBackgroundColor:self.globalColor];
    self.myCollectionView.multipleTouchEnabled = NO; // don't allow multiple cells to be selected at the same time
    //[self.myCollectionView setBackgroundColor:[UIColor whiteColor]];
    //[self.myCollectionView setPagingEnabled:YES]; // don't use since using CustomFlowLayout.targetContentOffsetForProposedContentOffset
    //self.myCollectionView.clipsToBounds = YES;
    
    //self.myCollectionView.delegate = self; // not needed since done in storyboard
    //self.myCollectionView.dataSource = self; // not needed since done in storyboard
    
    /*** NEXT 2 LINES ARE FOR THE SUPPLEMENTAL VIEW FOR THE FOOTER ***/
    //[self.myCollectionView registerClass:[FooterViewCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"]; // not needed since set in storyboard
    flowLayout.footerReferenceSize = CGSizeMake(CellWidth, 20); // needed for supplemental view (footer)
    
    [self.myCollectionView setCollectionViewLayout:flowLayout];
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
    //self.cellIndexes = [self.myCollectionView indexPathsForVisibleItems];
    //NSLog(@"cellIndexes count %d", [self.cellIndexes count]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupCollectionView]; // setup the collectionview parameters
    [self setupSearchBar]; // setup the search bar in the navigation bar
    self.navigationController.navigationBar.barTintColor = self.globalColor; // set the background color of the navigation bar
    //[self setupButtons]; // setup the buttons - not needed since changed to uisegmentedcontrol
    //NSLog(@"imageLoadManager description %@", [self.imageLoadManager description]); // just to initialize IML for testing
    
    // Set this in every view controller so that the back button displays back instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self updateUI];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"PrepareForSegue!");
    if ([segue.identifier isEqualToString:@"Drink Details"]) {
        NSLog(@"Drink Details!");
        CoffeeViewCell *cell = (CoffeeViewCell *)sender;
        NSIndexPath *indexPath = [self.myCollectionView indexPathForCell:cell];
        
        DrinkDetailViewController *ddvc = (DrinkDetailViewController *)[segue destinationViewController];
        ddvc.drinkImage = [self.imagesArray objectAtIndex:indexPath.row];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
