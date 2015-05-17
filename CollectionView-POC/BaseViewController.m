//
//  BaseViewController.m
//  CollectionView-POC
//
//  Created by Sonny Back on 3/27/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import "BaseViewController.h"
#import "CoffeeViewCell.h"
#import "CustomFlowLayout.h"
#import "NewPhotoResultsViewController.h"
#import "CafeLocatorTableViewController.h"
#import "ImageLoadManager.h"
#import "CoffeeImageData.h"
#import "Helper.h"
#import "UIImage+CS193p.h"
#import <QuartzCore/QuartzCore.h>
#import <CloudKit/CloudKit.h>
#import "SDImageCache.h"
#import "CKManager.h"
#import "UserActivity.h"
#import "CustomActionSheet.h"
#import "MRProgress.h"
#import "RecipeImageData.h"
#import "RecipeDetailsViewController.h"

@interface BaseViewController()
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *imageRecipeSegmentedControl;
@property (strong, nonatomic) ImageLoadManager *imageLoadManager;
@property (weak, nonatomic) UIColor const *globalColor;
/** replaced 2 buttons below with segmented control
@property (weak, nonatomic) IBOutlet UIButton *coffeeImagesButton;
@property (weak, nonatomic) IBOutlet UIButton *recipeImagesButton;*/
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) UIImageView *fullScreenImage;
@property (strong, nonatomic) CustomFlowLayout *flowLayout;
@property (strong, nonatomic) CoffeeImageData *coffeeImageDataAddedFromCamera;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic) NSInteger numberOfItemsInSection; // property for number of items in collectionview
@property (strong, nonatomic) SDImageCache *imageCache;
@property (strong, nonatomic) NSMutableArray *cidCacheKeys; // holds all the image URL strings from the cache for CID objects
@property (strong, nonatomic) NSMutableArray *ridCacheKeys; // holds all the image URL strings from the cache for RID objects
@property (strong, nonatomic) CKManager *ckManager; // CloudKitManager class
@property (nonatomic) CKAccountStatus userAccountStatus; // for tracking user's iCloud login status
@property (strong, nonatomic) CustomActionSheet *customActionSheet;
@property (strong, nonatomic) MRProgressOverlayView *hud;
@property (nonatomic) BOOL displayImages; // based on selection of imageRecipeSegmentedControl
@end

@implementation BaseViewController

NSInteger const CellWidth = 140; // width of cell
NSInteger const CellHeight = 140; // height of cell
dispatch_queue_t queue;

//#define ITEM_SIZE 290.0 // item size for the cell **SHOULD ALWAYS MATCH CellWidth constant!
//#define ITEM_SIZE 140.0 // item size for the cell - use this size for 2 columns of cells
#define ITEM_SIZE 90.0 // item size for the cell - use this for 3 columns of cells

#pragma mark - Lazy Instantiation

// lazy instantiate imageLoadManager
- (ImageLoadManager *)imageLoadManager {
    
    if (!_imageLoadManager) {
        //NSLog(@"Loading ImageLoadManager...");
        /*IMPORTANT: below line commented out while doing CK calls from this VC */
        //_imageLoadManager = [[ImageLoadManager alloc] initImagesForSelection:[self getSelectedSegmentTitle]];
        _imageLoadManager = [[ImageLoadManager alloc] init];
        //NSLog(@"Finished loading ImageLoadManager...");
    }
    return _imageLoadManager;
}

// lazy instantiate CKManager
- (CKManager *)ckManager {
    
    if (!_ckManager) {
        _ckManager = [[CKManager alloc] init];
    }
    
    return _ckManager;
}

// lazy instantiate coffeeImageData
/*- (CoffeeImageData *)coffeeImageData {
    
    if (!_coffeeImageData) {
        _coffeeImageData = [[CoffeeImageData alloc] init];
    }
    
    return _coffeeImageData;
}*/

#define ONE_HOUR_IN_SECONDS 3600

// lazy instantiate imageCache
- (SDImageCache *)imageCache {
    
    if (!_imageCache) {
        _imageCache = [[SDImageCache alloc] initWithNamespace:NAME_SPACE_IMAGE_CACHE];
        [_imageCache setMaxCacheAge:ONE_HOUR_IN_SECONDS * 3]; // cache age limit set to 3 hours (in seconds)
    }
    
    return _imageCache;
}

// lazy instantiate cidCacheKeys
- (NSMutableArray *)cidCacheKeys {
    
    if (!_cidCacheKeys) {
        _cidCacheKeys = [[NSMutableArray alloc] init];
    }
    
    return _cidCacheKeys;
}

// lazy instantiate ridCacheKeys
- (NSMutableArray *)ridCacheKeys {
    
    if (!_ridCacheKeys) {
        _ridCacheKeys = [[NSMutableArray alloc] init];
    }
    
    return _ridCacheKeys;
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

#pragma mark - UIImagePickerControllerDelegate

// handles photos taken with camera
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSLog(@"INFO: didFinishPickingMediaWithInfo... ");
    
    UIImage *image = info[UIImagePickerControllerEditedImage]; // see if the image was edited
    if (!image) image = info[UIImagePickerControllerOriginalImage]; // use original if image not edited
    
    // set the CID info for the new image
    self.coffeeImageDataAddedFromCamera = [[CoffeeImageData alloc] init];
    self.coffeeImageDataAddedFromCamera.image = image;
    self.coffeeImageDataAddedFromCamera.imageName = DEFAULT_NAME; // i think this will be an image file URL
    self.coffeeImageDataAddedFromCamera.imageDescription = @"description";
    self.coffeeImageDataAddedFromCamera.userID = self.ckManager.userRecordID.recordName;
    self.coffeeImageDataAddedFromCamera.imageBelongsToCurrentUser = NO; // user took this photo but should be set to NO initially
    self.coffeeImageDataAddedFromCamera.liked = NO; // should always be NO for the public data. Will only be set to YES in code if there is a reference in user's data
    /*CoffeeImageData *dataForNewImage = [[CoffeeImageData alloc] init];
    dataForNewImage.image = image;
    dataForNewImage.imageName = @"temporary name"; // i think this will be an image file URL
    dataForNewImage.imageDescription = @"description";
    dataForNewImage.userID = self.ckManager.userRecordID.recordName;
    dataForNewImage.imageBelongsToCurrentUser = NO; // user took this photo but should be set to NO initially
    dataForNewImage.liked = NO; // should always be NO for the public data. Will only be set to YES in code if there is a reference in user's data
     */
    /** THIS IS NULL. NEED TO USE SDWEBIMAGE cache **/
    //dataForNewImage.imageURL = info[UIImagePickerControllerReferenceURL];
    //NSLog(@"CID.imageURL: %@", dataForNewImage.imageURL);
    
    // write the image to local cache directory - will later convert this to SDWebImage cache
    NSData *data = UIImageJPEGRepresentation(image, 1.0); // 1.0 = no compression
    NSURL *cacheDirectory = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSString *temporaryName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:JPEG];
    NSURL *localURL = [cacheDirectory URLByAppendingPathComponent:temporaryName];
    [data writeToURL:localURL atomically:YES];
    
    //dataForNewImage.imageURL = localURL;
    //NSLog(@"CID.imageURL: %@", dataForNewImage.imageURL);
    self.coffeeImageDataAddedFromCamera.imageURL = localURL;
    NSLog(@"CIDAddedFromCamera.imageURL: %@", self.coffeeImageDataAddedFromCamera.imageURL);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self performSegueWithIdentifier:@"Add New Photo" sender:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    NSLog(@"Cancelling camera...");
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    return 1; // only one section
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSLog(@"INFO: numberOfItemsInSection: %ld", (long)self.numberOfItemsInSection);
    return self.numberOfItemsInSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CoffeeCell"; // string value identifier for cell reuse
    CoffeeViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSLog(@"INFO: cellForItemAtIndexPath: section:%ld row:%ld", (long)indexPath.section, (long)indexPath.row);
    /*Uncomment below 2 lines if lag issues with scrolling the collectionview*/
    //cell.layer.shouldRasterize = YES;
    //cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    if (cell) {
        
        [self.spinner stopAnimating]; // images should be loaded, so stop spinner
        //cell.backgroundColor = [UIColor whiteColor];
        //cell.layer.cornerRadius = 3;
        cell.layer.borderWidth = 1.0;
        cell.layer.borderColor = [UIColor grayColor].CGColor;
        
        /* UIViewContentMode options from here....*/
        //cell.coffeeImageView.contentMode = UIViewContentModeScaleToFill; // distorts the image
        cell.coffeeImageView.contentMode = UIViewContentModeScaleAspectFill; // fills out image area, but image is cropped
        //cell.coffeeImageView.contentMode = UIViewContentModeScaleAspectFit; // maintains aspect, but does not always fill image area
        /*...to here...*/
        
        // load placeholder image. will only been seen if loading from very weak signal or during scrolling after being idle
        cell.coffeeImageView.image = [UIImage imageNamed:PLACE_HOLDER];
        
        /** Render cells for Images selection (CoffeeImageData) **/
        if ([[self getSelectedSegmentTitle] isEqualToString:IMAGES_SEGMENTED_CTRL]) {
            NSLog(@"INFO: Displaying images for Images selection!");
            CoffeeImageData *coffeeImageData = self.imageLoadManager.coffeeImageDataArray[indexPath.row];
            
            if (coffeeImageData) {
                // check to see if the recordID of the current CID is userActivityDictionary. If so, it's in the user's private
                // data so set liked value = YES
                if ([self.imageLoadManager lookupRecordIDInUserData:coffeeImageData.recordID]) {
                    //NSLog(@"RecordID found in userActivityDictiontary!");
                    coffeeImageData.liked = YES;
                }
                // check to see if this image was submitted by the current user
                if ([self.ckManager.userRecordID.recordName isEqualToString:coffeeImageData.userID]) {
                    NSLog(@"This image belongs to user: %@", self.ckManager.userRecordID.recordName);
                    coffeeImageData.imageBelongsToCurrentUser = YES;
                }
                
                if ([self.cidCacheKeys count] > 0) { // check to see if the cacheKeys arrays contains any keys (URLs)
                    // get the URL of the current indexes images from cache
                    NSString *cacheKey = self.cidCacheKeys[indexPath.row];
                    if (cacheKey) {
                        NSLog(@"cacheKey found!");
                        [self.imageCache queryDiskCacheForKey:cacheKey done:^(UIImage *image, SDImageCacheType cacheType) {
                            if (image) { // image is found in the cache
                                NSLog(@"Image found in cache!");
                                //UIImage *thumbnail = [Helper imageWithImage:image scaledToWidth:ITEM_SIZE];
                                //cell.coffeeImageView.image = thumbnail;
                                cell.coffeeImageView.image = image;
                            } else {
                                NSLog(@"Image not found in cache, getting image from CID!");
                                if (coffeeImageData.imageURL.path) {
                                    cell.coffeeImageView.image = [UIImage imageWithContentsOfFile:coffeeImageData.imageURL.path];
                                }
                            }
                        }];
                    } else {
                        NSLog(@"cacheKey NOT found!");
                        if (coffeeImageData.imageURL.path) {
                            cell.coffeeImageView.image = [UIImage imageWithContentsOfFile:coffeeImageData.imageURL.path];
                        }
                    }
                } else { // if not, get the image data from the CID object
                    NSLog(@"allCacheKeys array is empty, getting image from CID!");
                    if (coffeeImageData.imageURL.path) {
                        cell.coffeeImageView.image = [UIImage imageWithContentsOfFile:coffeeImageData.imageURL.path];
                    }
                }
            }
        } else { /** Render cells for Recipes selection (RecipesImageData) **/
            NSLog(@"INFO: Displaying images for Recipes selection!");
            RecipeImageData *recipeImageData = self.imageLoadManager.recipeImageDataArray[indexPath.row];
            
            if (recipeImageData) {
                // check to see if the recordID of the current RID is userActivityDictionary. If so, it's in the user's private
                // data so set liked value = YES
                if ([self.imageLoadManager lookupRecordIDInUserData:recipeImageData.recordID]) {
                    //NSLog(@"RecordID found in userActivityDictiontary!");
                    recipeImageData.liked = YES;
                }
                // check to see if this image was submitted by the current user
                if ([self.ckManager.userRecordID.recordName isEqualToString:recipeImageData.userID]) {
                    NSLog(@"This image belongs to user: %@", self.ckManager.userRecordID.recordName);
                    recipeImageData.imageBelongsToCurrentUser = YES;
                }
                // check to see if the cacheKeys arrays contains any keys (URLs)
                if ([self.ridCacheKeys count] > 0) {
                    // get the URL of the current indexes images from cache
                    NSString *cacheKey = self.ridCacheKeys[indexPath.row];
                    if (cacheKey) {
                        NSLog(@"cacheKey found!");
                        [self.imageCache queryDiskCacheForKey:cacheKey done:^(UIImage *image, SDImageCacheType cacheType) {
                            if (image) { // image is found in the cache
                                NSLog(@"Image found in cache!");
                                //UIImage *thumbnail = [Helper imageWithImage:image scaledToWidth:ITEM_SIZE];
                                //cell.coffeeImageView.image = thumbnail;
                                cell.coffeeImageView.image = image;
                            } else {
                                NSLog(@"Image not found in cache, getting image from RID!");
                                if (recipeImageData.imageURL.path) {
                                    cell.coffeeImageView.image = [UIImage imageWithContentsOfFile:recipeImageData.imageURL.path];
                                }
                            }
                        }];
                    } else {
                        NSLog(@"cacheKey NOT found!");
                        if (recipeImageData.imageURL.path) {
                            cell.coffeeImageView.image = [UIImage imageWithContentsOfFile:recipeImageData.imageURL.path];
                        }
                    }
                }
            }
        }
        
        cell.coffeeImageView.clipsToBounds = YES;
        //cell.coffeeImageLabel.text = imageNameForLabel;
        
        cell.coffeeImageLabel.alpha = 0.3; // set the label to be semi transparent
        cell.coffeeImageLabel.hidden = YES; // just for toggling on/off until this label is completely removed
    }
    
    return cell;
}

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSLog(@"Collectionview is scrolling.");
}*/

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
    // below coded used only for horizontal layout, which was the initial layout
    //NSInteger numberOfCells = self.view.frame.size.width / CellWidth;
    //NSInteger edgeInsets = (self.view.frame.size.width - (numberOfCells * CellWidth)) / (numberOfCells + 1);
    
    //return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
    return UIEdgeInsetsMake(10, 12, 10, 12);
}

#define LIKE_BUTTON_WIDTH 38.0
#define LIKE_BUTTON_HEIGHT 38.0
#define RECIPE_BUTTON_HEIGHT 20
#define RECIPE_BUTTON_WIDTH 60
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CoffeeViewCell *selectedCell = (CoffeeViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"INFO: didSelectItemAtIndexPath");
    CoffeeImageData *coffeeImageData;
    RecipeImageData *recipeImageData;
    self.fullScreenImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-10, self.view.bounds.size.height-15)];
    self.fullScreenImage.contentMode = UIViewContentModeScaleAspectFit;
    self.fullScreenImage.tag = 1000; // set it to this value so it will never conflict with likeButton.tag value
    /** REQUIRED for likeButton to work. Otherwise, button is visible but doesn't respond */
    [self.fullScreenImage setUserInteractionEnabled:YES];
    
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeFullScreenImageView:)];
    self.tap.delegate = self;
    self.tap.numberOfTapsRequired = 1;
    [self.fullScreenImage addGestureRecognizer:self.tap];
    
    CGFloat xCoord = self.fullScreenImage.bounds.size.width;
    CGFloat yCoord = self.fullScreenImage.bounds.size.height;
    CGFloat yPoint = self.fullScreenImage.bounds.origin.y;
    
    UIButton *likeButton = [[UIButton alloc] init]; // button for liking image and storing in profile
    likeButton.tag = indexPath.row; // set the tag of the button to the indexpath.row so we know which cell/image is selected
    UIButton *recipeButton = [[UIButton alloc] init]; // button for viewing recipe if image is of a recipe
    
    
    // place button in lower left corner of image
    //[likeButton setFrame:CGRectMake(xCoord - (xCoord * .97), yCoord - (yCoord * .08), LIKE_BUTTON_WIDTH, LIKE_BUTTON_HEIGHT)];
    //[likeButton setFrame:CGRectMake(xCoord - xCoord, yCoord - (yCoord * .07), LIKE_BUTTON_WIDTH, LIKE_BUTTON_HEIGHT)];
    
    [likeButton setFrame:CGRectMake(xCoord - xCoord, yPoint + (yCoord-LIKE_BUTTON_HEIGHT), LIKE_BUTTON_WIDTH, LIKE_BUTTON_HEIGHT)];
    [likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //[recipeButton setFrame:CGRectMake(xCoord + xCoord, yPoint + (yCoord-LIKE_BUTTON_HEIGHT), LIKE_BUTTON_WIDTH, LIKE_BUTTON_HEIGHT)];
    [recipeButton setFrame:CGRectMake(xCoord - RECIPE_BUTTON_WIDTH, yPoint + (yCoord - RECIPE_BUTTON_HEIGHT), RECIPE_BUTTON_WIDTH, RECIPE_BUTTON_HEIGHT)];
    [recipeButton setTitle:RECIPE forState:UIControlStateNormal];
    [recipeButton addTarget:self action:@selector(recipeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // get the CID or RID object for this cell based on the segmented ctrl selected, i.e. Images=CID, Recipes=RID
    if (self.displayImages)
        coffeeImageData = [self.imageLoadManager coffeeImageDataForCell:indexPath.row];
    else
        recipeImageData = [self.imageLoadManager recipeImageDataForCell:indexPath.row];
    
    // get the CoffeeImageData object for this cell
    //CoffeeImageData *coffeeImageData = [self.imageLoadManager coffeeImageDataForCell:indexPath.row];
    //CoffeeImageData *coffeeImageData = self.imageLoadManager.coffeeImageDataArray[indexPath.row];
    //NSLog(@"DEBUG: Image selected for recordID: %@", coffeeImageData.recordID);
    NSLog(@"DEBUG: Image selected for recordID: %@", (self.displayImages) ? coffeeImageData.recordID : recipeImageData.recordID);
    
    /*selectedCell.imageIsLiked = coffeeImageData.isLiked;
    //likeButton.selected = selectedCell.imageIsLiked;
    likeButton.selected = coffeeImageData.isLiked;*/
    
    selectedCell.imageIsLiked = (coffeeImageData) ? coffeeImageData.isLiked : recipeImageData.isLiked;
    likeButton.selected = (coffeeImageData) ? coffeeImageData.isLiked : recipeImageData.isLiked;
    
    // Check to see if image is currently liked or not and display the correct heart image
    if (selectedCell.imageIsLiked) {
        //[likeButton setImage:[UIImage imageNamed:@"heart_blue_solid"] forState:UIControlStateNormal|UIControlStateSelected];
        // above line caused bug
        [likeButton setImage:[UIImage imageNamed:HEART_BLUE_SOLID] forState:UIControlStateNormal];
    } else {
        [likeButton setImage:[UIImage imageNamed:HEART_BLUE] forState:UIControlStateNormal];
    }
    
    // if ! isFullScreen, then not yet viewing fullscreen image, so animate to fullScreen view
    if (!self.isFullScreen) {
        self.fullScreenImage.transform = CGAffineTransformMakeScale(0.1, 0.1);
        __weak BaseViewController *weakSelf = self; // to make sure we don't have retain cycles. is this really needed here?
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            NSLog(@"Starting animiation!");
            /** NOTE: replaced "self" with "weakSelf below to avoid retain cycles! **/
            weakSelf.view.backgroundColor = [UIColor blackColor];
            weakSelf.myCollectionView.backgroundColor = [UIColor blackColor];
            weakSelf.searchBar.hidden = YES;
            weakSelf.toolBar.hidden = YES;
            weakSelf.imageRecipeSegmentedControl.hidden = YES;
            weakSelf.navigationController.navigationBarHidden = YES;
            weakSelf.fullScreenImage.center = self.view.center;
            weakSelf.fullScreenImage.backgroundColor = [UIColor blackColor];
            if (coffeeImageData) // display image for CID if we're looking at images
                weakSelf.fullScreenImage.image = [UIImage imageWithContentsOfFile:coffeeImageData.imageURL.path];
            else // display image for RID if we're looking at recipes
                weakSelf.fullScreenImage.image = [UIImage imageWithContentsOfFile:recipeImageData.imageURL.path];
            //weakSelf.fullScreenImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:coffeeImageData.imageURL]];
            //self.fullScreenImage.transform = CGAffineTransformMakeScale(1.0, 1.0); // zoom in effect
            weakSelf.fullScreenImage.transform = CGAffineTransformIdentity; // zoom in effect
            [weakSelf.view addSubview:self.fullScreenImage];
            [weakSelf.fullScreenImage addSubview:likeButton]; // add the button to the view
            // only add the recipe button if we're looking at recipes
            if (recipeImageData) [weakSelf.fullScreenImage addSubview:recipeButton];
        }completion:^(BOOL finished){
            if (finished) {
                NSLog(@"Animation finished!");
                weakSelf.isFullScreen = YES;
            }
        }];
        return;
    }
}

/*- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}*/

/*- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didEndDisplayingCell");
    PatternViewCell *currentCell = ([[collectionView visibleCells] count] > 0) ? [[collectionView visibleCells] objectAtIndex:0] : nil;
    if (cell != nil){
        NSInteger index = [collectionView indexPathForCell:currentCell].row;
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
    
    [self.myCollectionView reloadData]; // reload data for new user taken images
    // make sure collectionview is automatically scrolled back to the top
    [self.myCollectionView setContentOffset:CGPointZero animated:YES];
}

/**
 * Method to setup the collectionview attributes

 * @return void
 */
- (void)setupCollectionView {
    NSLog(@"setupCollectionView");
    [self.spinner startAnimating];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    //CustomFlowLayout *flowLayout = [[CustomFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE); // globally sets the item (cell) size
    //self.flowLayout = [[CustomFlowLayout alloc] init];
    //self.flowLayout.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
    
    
    //flowLayout.itemSize = CGSizeMake(80, 100);
    //flowLayout.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
    self.myCollectionView.userInteractionEnabled = YES;
    self.myCollectionView.delaysContentTouches = NO;
    [self.myCollectionView setShowsVerticalScrollIndicator:YES];
    //[self.myCollectionView setBackgroundColor:[UIColor colorWithRed:0.227 green:0.349 blue:0.478 alpha:1]]; // ok color
    [self.myCollectionView setBackgroundColor:[UIColor colorWithRed:0.62 green:0.651 blue:0.686 alpha:1]];
    //[self.myCollectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"blue_gradient_3_iphone6.jpg"]]];
    //[self.myCollectionView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"orange_gradient_iphone6.jpg"]]];
    self.myCollectionView.multipleTouchEnabled = NO; // don't allow multiple cells to be selected at the same time
    //[self.myCollectionView setBackgroundColor:[UIColor whiteColor]];
    //[self.myCollectionView setPagingEnabled:YES]; // don't use since using CustomFlowLayout.targetContentOffsetForProposedContentOffset
    //self.myCollectionView.clipsToBounds = YES;
    
    //self.myCollectionView.delegate = self; // not needed since done in storyboard
    //self.myCollectionView.dataSource = self; // not needed since done in storyboard
    
    [self.myCollectionView setCollectionViewLayout:flowLayout];
    
    //[self.myCollectionView setCollectionViewLayout:self.flowLayout];
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
    self.searchBar.placeholder = SEARCH_FOR_COFFEE;
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
 * Method to do the initial loading of CK records to populate the CV.
 * This will eventually be moved out of the ViewController and back into ImageLoadManager
 * CKManager.
 * @return void
 */
- (void)beginLoadingCloudKitData {
    
    NSLog(@"INFO: beginLoadingCloudKitData...started!");
    
    dispatch_async(queue, ^{
        [self.ckManager loadCloudKitDataWithCompletionHandler:^(NSArray *results, CKQueryCursor *cursor, NSError *error) {
            if (!error) {
                if ([results count] > 0) {
                    self.numberOfItemsInSection = [results count];
                    NSLog(@"INFO: Success querying the cloud for %lu results!!!", (unsigned long)[results count]);
                    // fetch the recipe images from CloudKit
                    [self loadRecipeDataFromCloudKit];
                    for (CKRecord *record in results) {
                        // create CoffeeImageData object to store data in the array for each image
                        CoffeeImageData *coffeeImageData = [[CoffeeImageData alloc] init];
                        CKAsset *imageAsset = record[IMAGE];
                        coffeeImageData.imageURL = imageAsset.fileURL;
                        //NSLog(@"asset URL: %@", coffeeImageData.imageURL);
                        coffeeImageData.imageName = record[IMAGE_NAME];
                        //NSLog(@"Image name: %@", coffeeImageData.imageName);
                        coffeeImageData.imageDescription = record[IMAGE_DESCRIPTION];
                        coffeeImageData.userID = record[USER_ID];
                        coffeeImageData.imageBelongsToCurrentUser = [record[IMAGE_BELONGS_TO_USER] boolValue];
                        coffeeImageData.recipe = [record[RECIPE] boolValue];
                        coffeeImageData.liked = [record[LIKED] boolValue]; // 0 = No, 1 = Yes
                        coffeeImageData.recordID = record.recordID.recordName;
                        // add the CID object to the array
                        [self.imageLoadManager.coffeeImageDataArray addObject:coffeeImageData];
                        
                        // cache the image with the string representation of the absolute URL as the cache key
                        if (coffeeImageData.imageURL) { // make sure there's an image URL to cache
                            if (self.imageCache) {
                                [self.imageCache storeImage:[UIImage imageWithContentsOfFile:coffeeImageData.imageURL.path] forKey:coffeeImageData.imageURL.absoluteString toDisk:YES];
                                //NSLog(@"Printing cache: %@", [[SDImageCache sharedImageCache] description]);
                            }
                        } else {
                            NSLog(@"WARN: CID imageURL is nil...cannot cache.");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //[self alertWithTitle:@"Yikes!" andMessage:@"There was an error trying to load the coffee images from the Cloud. Please try again."];
                                UIAlertView *reloadAlert = [[UIAlertView alloc] initWithTitle:YIKES_TITLE message:ERROR_LOADING_CK_DATA_MSG delegate:nil cancelButtonTitle:CANCEL_BUTTON otherButtonTitles:TRY_AGAIN_BUTTON, nil];
                                reloadAlert.delegate = self;
                                [reloadAlert show];
                            });
                        }
                    }
                    // update the UI on the main queue
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self updateUI]; // reload the collectionview after getting all the data from CK
                    });
                    NSLog(@"CoffeeImageDataArray size %lu", (unsigned long)[self.imageLoadManager.coffeeImageDataArray count]);
                }
                // load the keys to be used for cache look up
                [self getCIDCacheKeys];
            } else {
                NSLog(@"Error: there was an error fetching cloud data... %@", error.localizedDescription);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self alertWithTitle:@"Yikes!" andMessage:@"There was an error trying to load the coffee images from the Cloud. Please try again."];
                    UIAlertView *reloadAlert = [[UIAlertView alloc] initWithTitle:YIKES_TITLE message:ERROR_LOADING_CK_DATA_MSG delegate:nil cancelButtonTitle:CANCEL_BUTTON otherButtonTitles:TRY_AGAIN_BUTTON, nil];
                    reloadAlert.delegate = self;
                    [reloadAlert show];
                });
            }
        }];
    });
    
    NSLog(@"INFO: beginLoadingCloudKitData...ended!");
}

- (void)loadRecipeDataFromCloudKit {
    
    NSLog(@"INFO: loadRecipeDataFromCloudKit...started!");
    [self.ckManager loadRecipeDataWithCompletionHandler:^(NSArray *results, CKQueryCursor *cursor, NSError *error) {
        if (!error) {
            if ([results count] > 0) {
                NSLog(@"INFO: Successfully fetched RecipeImageData for %lu record!", (unsigned long)[results count]);
                for (CKRecord *record in results) {
                    RecipeImageData *recipeImageData = [[RecipeImageData alloc] init];
                    CKAsset *imageAsset = record[IMAGE];
                    recipeImageData.imageURL = imageAsset.fileURL;
                    //NSLog(@"RID image URL: %@", recipeImageData.imageURL);
                    recipeImageData.imageName = record[IMAGE_NAME];
                    //NSLog(@"RID image name: %@", recipeImageData.imageName);
                    recipeImageData.imageDescription = record[IMAGE_DESCRIPTION];
                    //NSLog(@"RID image description: %@", recipeImageData.imageDescription);
                    recipeImageData.userID = record[USER_ID];
                    //NSLog(@"RID user id: %@", recipeImageData.userID);
                    recipeImageData.recipe = [record[RECIPE] boolValue]; // 0 = No, 1 = Yes
                    //NSLog(@"RID isRecipe %d", recipeImageData.isRecipe);
                    recipeImageData.recordID = record.recordID.recordName;
                    //NSLog(@"RID recordID: %@", recipeImageData.recordID);
                    // add the RID object to the array
                    [self.imageLoadManager.recipeImageDataArray addObject:recipeImageData];
                    
                    // cache the image with the string representation of the absolute URL as the cache key
                    if (recipeImageData.imageURL) { // make sure there's an image URL to cache
                        if (self.imageCache) {
                            [self.imageCache storeImage:[UIImage imageWithContentsOfFile:recipeImageData.imageURL.path] forKey:recipeImageData.imageURL.absoluteString toDisk:YES];
                            //NSLog(@"Printing cache: %@", [[SDImageCache sharedImageCache] description]);
                        }
                    } else {
                        NSLog(@"WARN: RID imageURL is nil...cannot cache.");
                    }
                }
            }
            // load the keys to be used for cache look up
            [self getRIDCacheKeys];
        } else {
            NSLog(@"Error trying to fetch the RecipeImageData records...%@", error.localizedDescription);
        }
    }];
}

- (void)getUserActivityPrivateData {
    
    NSLog(@"INFO: Entered getUserActivityPrivateData");
    
    // clear all objects before (re)loading it
    if ([self.imageLoadManager.userActivityDictionary count] > 0) {
        NSLog(@"INFO: Removing all objects user userActivityDictionary!");
        [self.imageLoadManager.userActivityDictionary removeAllObjects];
    }
    
    // get the user's data for Images (CoffeeImageData)
    [self.ckManager getUserActivityPrivateDataForCIDWithCompletionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"Error: there was an error fetching user's private data... %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertWithTitle:NO_SAVED_DATA_TITLE andMessage:ERROR_LOADING_SAVED_DATA_MSG];
            });
        } else {
            if ([results count] > 0) { // if results, we have user activity from their private database
                @synchronized(self){
                    NSLog(@"INFO: Data found in user's private CK database.");
                    for (CKRecord *record in results) {
                        UserActivity *userActivity = [[UserActivity alloc] init];
                        CKReference *cidReference = [[CKReference alloc] initWithRecord:record[COFFEE_IMAGE_DATA_RECORD_TYPE] action:CKReferenceActionNone];
                        //NSLog(@"RecordID of cidReference: %@", cidReference.recordID.recordName);
                        CoffeeImageData *coffeeImageData = (CoffeeImageData *)cidReference;
                        userActivity.cidReference = coffeeImageData;
                        //userActivity.recordID = cidReference.recordID.recordName;
                        userActivity.recordID = record.recordID.recordName;
                        NSLog(@"INFO: Reference recordID %@, UA recordID: %@", cidReference.recordID.recordName, userActivity.recordID);
                        [self.imageLoadManager.userActivityDictionary setObject:userActivity forKey:cidReference.recordID.recordName];
                    }
                }
            } else {
                NSLog(@"INFO: User has no private data!");
            }
        }
    }];
    
    // get the user's data for Recipes (RecipeImageData)
    [self.ckManager getUserActivityPrivateDataForRIDWithCompletionHandler:^(NSArray *results, NSError *error) {
        if (error) {
            NSLog(@"Error: there was an error fetching user's private data... %@", error.localizedDescription);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertWithTitle:NO_SAVED_DATA_TITLE andMessage:ERROR_LOADING_SAVED_DATA_MSG];
            });
        } else {
            if ([results count] > 0) { // if results, we have user activity from their private database
                @synchronized(self){
                    NSLog(@"INFO: Data found in user's private CK database.");
                    for (CKRecord *record in results) {
                        UserActivity *userActivity = [[UserActivity alloc] init];
                        CKReference *ridReference = [[CKReference alloc] initWithRecord:record[RECIPE_IMAGE_DATA_RECORD_TYPE] action:CKReferenceActionNone];
                        //NSLog(@"RecordID of cidReference: %@", cidReference.recordID.recordName);
                        RecipeImageData *recipeImageData = (RecipeImageData *)ridReference;
                        userActivity.ridReference = recipeImageData;
                        userActivity.recordID = record.recordID.recordName;
                        NSLog(@"INFO: Reference recordID %@, UA recordID: %@", ridReference.recordID.recordName, userActivity.recordID);
                        [self.imageLoadManager.userActivityDictionary setObject:userActivity forKey:ridReference.recordID.recordName];
                    }
                }
            } else {
                NSLog(@"INFO: User has no private data!");
            }
        }
    }];
}

/**
 * Method to determine the selected segment from the UISegmentedControl and get the
 * corresponded title. Also sets the displayImages property based on the selection
 *
 * @return NSString* Selected Title
 */
- (NSString *)getSelectedSegmentTitle {
    
    NSLog(@"INFO: Entered getSelectedSegmentTitle...");
    NSInteger segmentedIndex = self.imageRecipeSegmentedControl.selectedSegmentIndex;
    NSString *segmentTitle = [self.imageRecipeSegmentedControl titleForSegmentAtIndex:segmentedIndex];
    if ([segmentTitle isEqualToString:IMAGES_SEGMENTED_CTRL]) {
        NSLog(@"Images selected!");
        self.displayImages = YES;
    } else {
        NSLog(@"Recipes selected!");
        self.displayImages = NO;
    }
    return [self.imageRecipeSegmentedControl titleForSegmentAtIndex:segmentedIndex];
}

/**
 * Method to take all the URL strings corresponding to each CID image and uses it for cache
 * storage and lookup. This array should always be empty when called. Should only be
 * called right after beginLoadingCloudKitData is called.
 *
 * @return void
 */
- (void)getCIDCacheKeys {
    
    //NSLog(@"INFO: Entered getCidCacheKeys...");
    
    if (self.cidCacheKeys) {
        //NSLog(@"Ready to set the cache keys!");
        // go through the CID objecs in the array and get the URL string for each corresponding image
        for (CoffeeImageData *cid in self.imageLoadManager.coffeeImageDataArray) {
            NSString *url = cid.imageURL.absoluteString;
            if (url) {
                //NSLog(@"INFO: CID URL key being stored: %@", url);
                // check to make sure the URL is not already in the array
                if (![self.cidCacheKeys containsObject:url]) {
                    //NSLog(@"INFO: Adding URL to cacheKeys array...");
                    [self.cidCacheKeys addObject:url];
                }
            } else {
                NSLog(@"ERROR: URL is nil");
            }
        }
        NSLog(@"INFO: cidCacheKeys array size: %lu", (unsigned long)[self.cidCacheKeys count]);
    }
}

/**
 * Method to take all the URL strings corresponding to each RID image and uses it for cache
 * storage and lookup. This array should always be empty when called. Should only be
 * called right after beginLoadingCloudKitData is called.
 *
 * @return void
 */
- (void)getRIDCacheKeys {
    
    //NSLog(@"INFO: Entered getRidCacheKeys...");
    if (self.ridCacheKeys) {
        // go through the RID objecs in the array and get the URL string for each corresponding image
        for (RecipeImageData *rid in self.imageLoadManager.recipeImageDataArray) {
            NSString *url = rid.imageURL.absoluteString;
            if (url) {
                //NSLog(@"INFO: RID URL key being stored: %@", url);
                // check to make sure the URL is not already in the array
                if (![self.ridCacheKeys containsObject:url]) {
                    //NSLog(@"INFO: Adding URL to cacheKeys array...");
                    [self.ridCacheKeys addObject:url];
                }
            } else {
                NSLog(@"ERROR: URL is nil");
            }
        }
        NSLog(@"INFO: ridCacheKeys array size: %lu", (unsigned long)[self.ridCacheKeys count]);
    }
}


#pragma mark - Action Methods

/**
 * Helper method to alert user of info and errors. Takes a title and message parameters.
 *
 * @param NSString *title - title of the error/info
 * @param NSString *msg - message to be displayed to user
 * @return void
 */
- (void)alertWithTitle:(NSString *)title andMessage:(NSString *)msg {
    
    [[[UIAlertView alloc] initWithTitle:title
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
    
    /* NOTE: This is the iOS 8 way of handling alerts. UIAlertView has been deprecated for iOS 8*/
    /*UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];*/
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [alertView cancelButtonIndex]) {
        NSLog(@"INFO: Attempting to reload coffee images from CloudKit...");
        [self beginLoadingCloudKitData];
    } else {
        NSLog(@"Do nothing");
        [self.spinner stopAnimating];
    }
}

/**
 * Action Method to track the segmented control being changed
 *
 * @param UISegmentedControl* sender
 * @return void
 */
- (IBAction)segmentedControlSelected:(UISegmentedControl *)sender {
    NSLog(@"segmentedControlSelected: index - %ld", (long)sender.selectedSegmentIndex);
    if (sender.selectedSegmentIndex == 0) { // Images
        // update the number of items in section for the correct data
        self.numberOfItemsInSection = [self.imageLoadManager.coffeeImageDataArray count];
        [self updateUI]; // reload the collectionview
    } else if (sender.selectedSegmentIndex == 1) { // Recipes
        // update the number of items in section for the correct data
        self.numberOfItemsInSection = [self.imageLoadManager.recipeImageDataArray count];
        [self updateUI]; // reload the collectionview
    }
    else if (sender.selectedSegmentIndex == 2)  { // Cafes
        [self performSegueWithIdentifier:CAFES sender:self];
    }
}

/**
 * Method to close the fullscreen image from the tap gesture. This logic was originally in
 * the else block of the animation in didSelectItemAtIndexPath. However, while visible, the
 * button would not activate. Issue seemed to be related to some view/bounds issue.
 *
 * @param UITapGestureRecognizer *sender
 * @return void
 */
- (void)closeFullScreenImageView:(UITapGestureRecognizer*)sender {
    NSLog(@"closeFullScreenImageView");
    
    if (self.isFullScreen) {
        NSLog(@"Ending animiation!");
        //self.navigationController.navigationBarHidden = NO;
        //self.searchBar.hidden = NO;
        self.view.backgroundColor = [UIColor whiteColor];
        self.myCollectionView.backgroundColor = [UIColor colorWithRed:0.62 green:0.651 blue:0.686 alpha:1];
        __weak BaseViewController *weakSelf = self;
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
            weakSelf.navigationController.navigationBarHidden = NO;
            weakSelf.searchBar.hidden = NO;
            weakSelf.toolBar.hidden = NO;
            weakSelf.imageRecipeSegmentedControl.hidden = NO;
            /*for (UIView *subView in self.view.subviews) {
                if (subView.tag == (int)self.fullScreenImage.tag) {
                    [subView removeFromSuperview];
                    break;
                }
            }*/
            weakSelf.fullScreenImage.transform = CGAffineTransformMakeScale(0.1, 0.1); // animate zooming out effect
            weakSelf.fullScreenImage.alpha = 0.0;
        }completion:^(BOOL finished){
            if (finished) {
                // remove the fullscreen view from the screen
                [weakSelf.fullScreenImage removeFromSuperview];
                weakSelf.isFullScreen = NO;
            }
        }];
        return;
    }
}

/**
 * Method to toggle liked button. Also updates the model for the CID object. For liked images,
 * it will also call CKManager to save the record to the user's private database in CloudKit.
 *
 * @param sender (UIButton)
 * @return void
 */
- (IBAction)likeButtonPressed:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    CoffeeViewCell *selectedCell = (CoffeeViewCell *)[self.myCollectionView cellForItemAtIndexPath:indexPath];
    CoffeeImageData *coffeeImageData;
    RecipeImageData *recipeImageData;
    
    selectedCell.imageIsLiked = !selectedCell.imageIsLiked; // toggle this based on button being pressed
    
    // get the CID or RID object for this cell based on the segmented ctrl selected, i.e. Images=CID, Recipes=RID
    if (self.displayImages)
        coffeeImageData = [self.imageLoadManager coffeeImageDataForCell:indexPath.row];
    else
        recipeImageData = [self.imageLoadManager recipeImageDataForCell:indexPath.row];
    
    //CoffeeImageData *currentImageData = [self.imageLoadManager coffeeImageDataForCell:indexPath.row];
    //CoffeeImageData *currentImageData = self.imageLoadManager.coffeeImageDataArray[indexPath.row];
    
    //NSLog(@"likeButtonPressed for image name: %@", currentImageData.imageName);
    NSLog(@"likeButtonPressed for: section:%ld row:%ld", (long)indexPath.section, (long)indexPath.row);
    
    // update the liked value in the model based on the user hitting the like button on the image
    //currentImageData.liked = selectedCell.imageIsLiked;
    
    if (coffeeImageData) coffeeImageData.liked = selectedCell.imageIsLiked;
    else recipeImageData.liked = selectedCell.imageIsLiked;
    
    // branch logic for images being liked
    if (coffeeImageData.isLiked || recipeImageData.isLiked) {
        NSLog(@"INFO: image is liked for an image or recipe!");
        [button setImage:[UIImage imageNamed:HEART_BLUE_SOLID] forState:UIControlStateNormal];
        // branching logic for CID...
        if (coffeeImageData) {
            // look up the recordID in userActivityDictionary. If it's already there, we do not need to save it user's private data as it already exists
            // in this scenario, the user must have already liked it and saved the record, then unliked it and reliked it in the same session
            if (![self.imageLoadManager lookupRecordIDInUserData:coffeeImageData.recordID]) {
                UserActivity *newUserActivity = [[UserActivity alloc] init];
                newUserActivity.cidReference = coffeeImageData;
                // add current UserActivity to userActivityDictionary so we can keep track of it
                //[self.imageLoadManager.userActivityDictionary setObject:newUserActivity forKey:currentImageData.recordID];
                NSLog(@"INFO: Added liked image to userActivity!");
                // save the liked image to the user's private database in iCloud
                [self.ckManager saveRecordForPrivateData:[self.ckManager createCKRecordForUserActivity:newUserActivity] withCompletionHandler:^(CKRecord *record, NSError *error) {
                    if (!error && record) {
                        NSLog(@"INFO: Private UserActivity Record saved successfully for recordID: %@!", record.recordID.recordName);
                        // delay refreshing UA data to allow time for UA record to be saved first
                        double delayInSeconds = 3.0;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC), queue, ^{
                            NSLog(@"INFO: Refreshing UA data...");
                            [self getUserActivityPrivateData];
                        });
                    } else {
                        NSLog(@"ERROR: Error saving record to user's private database...%@", error.localizedDescription);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertWithTitle:YIKES_TITLE andMessage:ERROR_SAVING_LIKED_IMAGE_MSG];
                        });
                    }
                }];
            }
        } else if (recipeImageData) { // branching logic for RID...
            NSLog(@"Oh snap! Liking a Recipe!");
            if (![self.imageLoadManager lookupRecordIDInUserData:recipeImageData.recordID]) {
                UserActivity *newUserActivity = [[UserActivity alloc] init];
                newUserActivity.ridReference = recipeImageData;
                [self.ckManager saveRecordForPrivateData:[self.ckManager createCKRecordForUserActivity:newUserActivity] withCompletionHandler:^(CKRecord *record, NSError *error) {
                    if (!error && record) {
                        NSLog(@"YAY!!!! Saved a recipe record!");
                    } else {
                        NSLog(@"ERROR!!!! Saving a recipe record!");
                    }
                }];
            }
        }
    } else { // branch logic for images being un-liked
        NSLog(@"INFO: image is NOT liked");
        [button setImage:[UIImage imageNamed:HEART_BLUE] forState:UIControlStateNormal];
        // branch logic for images (CoffeeImageData)
        if (coffeeImageData) {
            // if the user is unliking the image, check to see if it's currently in userActivity. If so, remove it
            if ([self.imageLoadManager lookupRecordIDInUserData:coffeeImageData.recordID]) {
                UserActivity *currentUARecord = [self.imageLoadManager.userActivityDictionary objectForKey:coffeeImageData.recordID];
                NSLog(@"INFO: User is unliking an image. Preparing to delete recordID: %@", currentUARecord.recordID);
                if ([currentUARecord isKindOfClass:[UserActivity class]]) {
                    NSLog(@"INFO: UserActivity record for deletion!");
                    // delete the record from the user's private database
                    [self.ckManager deleteUserActivityRecord:[self.imageLoadManager.userActivityDictionary objectForKey:coffeeImageData.recordID]];
                    // remove this record from the userActivityDictionary. *NOTE: Move this to CKManager once ILM object is there!
                    [self.imageLoadManager removeUserActivityDataFromDictionary:coffeeImageData.recordID];
                } else {
                    NSLog(@"INFO: Object passed is NOT a UserActivity record!");
                }
            }
        } else if (recipeImageData) { // branch logic for recipes (RecipeImageData)
            // if the user is unliking the image, check to see if it's currently in userActivity. If so, remove it
            if ([self.imageLoadManager lookupRecordIDInUserData:recipeImageData.recordID]) {
                UserActivity *currentUARecord = [self.imageLoadManager.userActivityDictionary objectForKey:recipeImageData.recordID];
                NSLog(@"INFO: User is unliking an recipe. Preparing to delete recordID: %@", currentUARecord.recordID);
                if ([currentUARecord isKindOfClass:[UserActivity class]]) {
                    NSLog(@"INFO: UserActivity record for deletion!");
                    // delete the record from the user's private database
                    [self.ckManager deleteUserActivityRecord:[self.imageLoadManager.userActivityDictionary objectForKey:recipeImageData.recordID]];
                    // remove this record from the userActivityDictionary. *NOTE: Move this to CKManager once ILM object is there!
                    [self.imageLoadManager removeUserActivityDataFromDictionary:recipeImageData.recordID];
                } else {
                    NSLog(@"INFO: Object passed is NOT a UserActivity record!");
                }
            }
        }
    }
}

/**
 * Action method that invokes the camera after making sure the user is authorized to take photos.
 * 
 * @param UIBarButtonItem *sender
 * @return void
 */
- (IBAction)cameraBarButtonPressed:(UIBarButtonItem *)sender {
    NSLog(@"INFO: Entered cameraBarButtonPressed");
    
    // need to check user's iCloud status before allowing the camera in case they logged out of iCloud
    self.userAccountStatus = [self.ckManager getUsersCKStatus]; // will return values 0-3. 1 is what we're looking for
    NSLog(@"INFO: cameraBarButtonPressed userAccountStatus: %ld", self.userAccountStatus);
    
    if (self.userAccountStatus == CKAccountStatusAvailable) { // status = 1
        //NSLog(@"User is logged into CK - user can upload pics!");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self; // set the deleage for the ImagePickerController
        self.customActionSheet = [[CustomActionSheet alloc] initWithTitle:PHOTO_BRANCH_ACTION delegate:nil cancelButtonTitle:CANCEL_BUTTON destructiveButtonTitle:nil otherButtonTitles:CAMERA, PHOTO_LIBRARY, nil];
        
        [self.customActionSheet showInView:self.view withCompletionHandler:^(NSString *buttonTitle, NSInteger buttonIndex) {
            //NSLog(@"You tapped button in index %ld", (long)buttonIndex);
            //NSLog(@"Your selection is %@", buttonTitle);
            if ([buttonTitle isEqualToString:CAMERA]) {
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [picker setAllowsEditing:YES]; // let the user edit the photo
                // set the camera presentation style
                picker.modalPresentationStyle = UIModalPresentationCurrentContext;
                
                dispatch_async(dispatch_get_main_queue(), ^{ // show the camera on main thread to avoid latency
                    [self presentViewController:picker animated:YES completion:nil]; // show the camera with animation
                });
            } else if ([buttonTitle isEqualToString:PHOTO_LIBRARY]) {
                picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                [picker setAllowsEditing:YES]; // let the user edit the photo
                picker.modalPresentationStyle = UIModalPresentationCurrentContext;
                
                dispatch_async(dispatch_get_main_queue(), ^{ // show the camera on main thread to avoid latency
                    [self presentViewController:picker animated:YES completion:nil]; // show the camera with animation
                });
            }
        }];
    } else if (self.userAccountStatus == CKAccountStatusNoAccount) { // status = 3
        NSLog(@"INFO: User is not logged into CK - Camera not available!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertWithTitle:ICLOUD_LOGIN_REQ_TITLE andMessage:ICLOUD_LOGIN_REQ_MSG];
        });
    } else if (self.userAccountStatus == CKAccountStatusRestricted) { // status = 2
        NSLog(@"INFO: User CK account is RESTRICTED!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertWithTitle:ICLOUD_STATUS_RESTRICTED_TITLE andMessage:ICLOUD_STATUS_RESTRICTED_MSG];
        });
    } else if (self.userAccountStatus == CKAccountStatusCouldNotDetermine) { // status = 0
        NSLog(@"INFO: User CK status could not be determined!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertWithTitle:ICLOUD_STATUS_UNDETERMINED_TITLE andMessage:ICLOUD_STATUS_UNDETERMINED_MSG];
        });
    } else { // did not get back one of the above values so show the Could Not Determine message
        NSLog(@"INFO: User CK status could not be determined!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertWithTitle:ICLOUD_STATUS_UNDETERMINED_TITLE andMessage:ICLOUD_STATUS_UNDETERMINED_MSG];
        });
    }
}

- (IBAction)recipeButtonPressed:(id)sender {
    
    NSLog(@"INFO: recipeButtonPressed...");
    [self performSegueWithIdentifier:SHOW_RECIPE_SEGUE sender:self];
}

#pragma mark - VC Lifecyle Methods
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //NSLog(@"viewDidLayoutSubviews");
}

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad...");
    [super viewDidLoad];
    
    // create the queue
    queue = dispatch_queue_create("com.drivethruu.CollectionView-POC",nil);
    
    // clear the cache
    [self.imageCache clearMemory];
    [self.imageCache clearDisk];
    
    self.userAccountStatus = [self.ckManager getUsersCKStatus]; // get the user's iCloud login status
    // check to see if user has any user activity data saved in their private database if they're logged into iCloud
    if (self.userAccountStatus == 1) {
        [self getUserActivityPrivateData];
    }
    
    [self beginLoadingCloudKitData]; // call method to trigger CK query
    
    [self setupCollectionView]; // setup the collectionview parameters
    [self setupSearchBar]; // setup the search bar in the navigation bar
    //self.toolBar.barTintColor = [UIColor colorWithRed:0.112 green:0.234 blue:0.4 alpha:1];
    //self.navigationController.navigationBar.barTintColor = self.globalColor; // set the background color of the navigation bar
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.112 green:0.234 blue:0.4 alpha:1];
    //self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    //self.navigationController.navigationBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"orange_gradient.jpg"]];
    // below is just a test. colors provided by Otha and are displaying correct color through helper method
    //self.navigationController.navigationBar.barTintColor = [Helper colorFromRed:112.0 Green:234.0 Blue:4.0 Alpha:1.0];
    //[self setupButtons]; // setup the buttons - not needed since changed to uisegmentedcontrol
    //NSLog(@"imageLoadManager description %@", [self.imageLoadManager description]); // just to initialize IML for testing
    
    // Set this in every view controller so that the back button displays back instead of the root view controller name
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    /** IMPORTANT: Without this line, the cells are offset by several points on the Y axis!! **/
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //[self updateUI]; // not needed...for now at least
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    /* Need to make sure when coming *back* from CafeLocatorTableVC segue that Cafes does not stay selected.
     * Otherwise, user has to manually tap another segment control, then tap Cafes again to go back to cafe
     * locator. Will make this go back to Images segment. However, this may be better handled by a delegate -
     * need to investigate.
     */
    if ([[self getSelectedSegmentTitle] isEqualToString:CAFES]) {
        NSLog(@"ViewDidAppear - Cafes!!");
        self.imageRecipeSegmentedControl.selectedSegmentIndex = 0;
        //[self.myCollectionView reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    //NSLog(@"viewWillDisappear");
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    //NSLog(@"viewDidDisappear");
}

#pragma mark - Segue Methods

/**
 * Method for unwinding segue from NewPhotoResultsVC. This method will receive the CID object
 * passed back and should add it to the CIDArray and display it in the collectionview. It will also
 * call the CKManager class to prepare the record and save it to CloudKit.
 *
 * @param UIStoryboardSegue *segue (from NewPhotoResultsVC)
 */
- (IBAction)addedPhoto:(UIStoryboardSegue *)segue {
    
    NSLog(@"INFO: Entered addedPhoto ");
    //self.coffeeImageDataAddedFromCamera = nil; // wipe out the previous object
    if ([segue.sourceViewController isKindOfClass:[NewPhotoResultsViewController class]]) {
        NSLog(@"SourceVC is correct! ");
        NewPhotoResultsViewController *newPhotoResultsVC = (NewPhotoResultsViewController *)segue.sourceViewController;
        //CoffeeImageData *coffeeImageData = newPhotoResultsVC.coffeeImageData;
        self.coffeeImageDataAddedFromCamera = newPhotoResultsVC.coffeeImageData;
        
        if (self.coffeeImageDataAddedFromCamera) {
            NSLog(@"Yay! We have a CID from Unwinding!");
            //NSLog(@"image url %@", self.coffeeImageDataAddedFromCamera.imageURL);
            self.hud = [MRProgressOverlayView showOverlayAddedTo:self.myCollectionView animated:YES];
            self.hud.mode = MRProgressOverlayViewModeDeterminateCircular;
            self.hud.titleLabelText = UPLOADING_COFFEE_MSG;

            // prepare the CKRecord and save it
            [self.ckManager saveRecord:@[[self.ckManager createCKRecordForImage:self.coffeeImageDataAddedFromCamera]] withCompletionHandler:^(NSArray *records, NSError *error) {
                if (!error && records) {
                    NSLog(@"INFO: Size of records array returned: %lu", (unsigned long)[records count]);
                    CKRecord *record = [records lastObject];
                    self.coffeeImageDataAddedFromCamera.recordID = record.recordID.recordName;
                    NSLog(@"INFO: Record saved successfully for recordID: %@", self.coffeeImageDataAddedFromCamera.recordID);
                    [self.imageLoadManager addCIDForNewUserImage:self.coffeeImageDataAddedFromCamera]; // update the model with the new image
                    // update number of items since array set has increased from new photo taken
                    self.numberOfItemsInSection = [self.imageLoadManager.coffeeImageDataArray count];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.hud dismiss:YES];
                        [self.hud removeFromSuperview];
                        [self updateUI];
                        [self alertWithTitle:YAY_TITLE andMessage:COFFEE_UPLOAD_SUCCESS_MSG];
                    });
                    self.coffeeImageDataAddedFromCamera = nil; // destroy this property after it's been used
                } else {
                    NSLog(@"ERROR: Error saving record to cloud...%@", error.localizedDescription);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.hud dismiss:YES];
                        [self.hud removeFromSuperview];
                        [self alertWithTitle:YIKES_TITLE andMessage:ERROR_SAVING_PHOTO_MSG];
                    });
                }
                self.coffeeImageDataAddedFromCamera = nil; // destroy this property after it's been used
            } recordProgressHandler:^(double progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSLog(@"Updating hud display...");
                    [self.hud setProgress:progress animated:YES];
                });
            }];
            /*[self.imageLoadManager addCIDForNewUserImage:self.coffeeImageDataAddedFromCamera]; // update the model with the new image
            // update number of items since array set has increased from new photo taken
            self.numberOfItemsInSection = [self.imageLoadManager.coffeeImageDataArray count];*/
             
            // store the image in SDWebImage cache
            [self.imageCache storeImage:self.coffeeImageDataAddedFromCamera.image forKey:self.coffeeImageDataAddedFromCamera.imageURL.absoluteString];
            // insert the new key (image URL) into the cacheKeys array
            [self.cidCacheKeys insertObject:self.coffeeImageDataAddedFromCamera.imageURL.absoluteString atIndex:0];
            
            //[self alertWithTitle:@"Coffee Photo Added!" andMessage:@"Your coffee was successfully added!"];
            //[self updateUI];
        } else {
            NSLog(@"Unwinding did not work properly :(");
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"PrepareForSegue!");
    if ([segue.identifier isEqualToString:[self getSelectedSegmentTitle]]) { // identifer & segment tile = "Cafes"
        NSLog(@"Segue to Cafe locator!");
    } else if ([segue.identifier isEqualToString:ADD_NEW_PHOTO_SEGUE] &&
               [segue.destinationViewController isKindOfClass:[NewPhotoResultsViewController class]]) {
        NSLog(@"Segueing to view photo results!");
        NewPhotoResultsViewController *newPhotoResultsVC = (NewPhotoResultsViewController *)segue.destinationViewController;
        newPhotoResultsVC.coffeeImageData = self.coffeeImageDataAddedFromCamera;
    } else if ([segue.identifier isEqualToString:SHOW_RECIPE_SEGUE] /*&&
               [segue.destinationViewController isKindOfClass:[RecipeDetailsViewController class]]*/) {
        NSLog(@"Seguing to Recipe Details!");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"Did Receive Memory Warning...clearing cache!");
    [self.imageCache clearMemory];
}

@end
