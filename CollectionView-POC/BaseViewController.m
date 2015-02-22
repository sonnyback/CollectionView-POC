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
#import "DrinkDetailViewController.h"
#import "CafeLocatorTableViewController.h"
#import "ImageLoadManager.h"
#import "CoffeeImageData.h"
#import "Helper.h"
#import "UIImage+CS193p.h"
#import <QuartzCore/QuartzCore.h>
#import <CloudKit/CloudKit.h>
#import "SDImageCache.h"
#import "CKManager.h"

@interface BaseViewController()
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
//@property (strong, nonatomic) NSArray *imagesArray; // of UIImage (array of images to display)
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
//@property (strong, nonatomic) CoffeeImageData *coffeeImageData;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic) NSInteger numberOfItemsInSection; // property for number of items in collectionview
@property (strong, nonatomic) SDImageCache *imageCache;
@property (strong, nonatomic) NSMutableArray *allCacheKeys; // holds all the image URL strings from the cache
@property (strong, nonatomic) CKManager *ckManager; // CloudKitManager class
@end

@implementation BaseViewController

NSInteger const CellWidth = 140; // width of cell
NSInteger const CellHeight = 140; // height of cell


//#define ITEM_SIZE 290.0 // item size for the cell **SHOULD ALWAYS MATCH CellWidth constant!
#define ITEM_SIZE 140.0 // item size for the cell **SHOULD ALWAYS MATCH CellWidth constant!

#pragma mark - Lazy Instantiation
// lazy instantiate imagesArray
/*- (NSArray *)imagesArray {
    
    if (!_imagesArray) {
        _imagesArray = [[NSArray alloc] init];
    }
    
    return _imagesArray;
}*/

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
        _imageCache = [[SDImageCache alloc] initWithNamespace:@"nameSpaceImageCacheCID"];
        [_imageCache setMaxCacheAge:ONE_HOUR_IN_SECONDS * 3]; // cache age limit set to 3 hours (in seconds)
    }
    
    return _imageCache;
}

// lazy instantiate allCacheKeys
- (NSMutableArray *)allCacheKeys {
    
    if (!_allCacheKeys) {
        _allCacheKeys = [[NSMutableArray alloc] init];
    }
    
    return _allCacheKeys;
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
    
    NSLog(@"didFinishPickingMediaWithInfo");
    
    UIImage *image = info[UIImagePickerControllerEditedImage]; // see if the image was edited
    if (!image) image = info[UIImagePickerControllerOriginalImage]; // use original if image not edited
    
    // set the CID info for the new image
    CoffeeImageData *dataForNewImage = [[CoffeeImageData alloc] init];
    dataForNewImage.image = image;
    dataForNewImage.imageName = @"temporary name"; // i think this will be an image file URL
    dataForNewImage.imageDescription = @"description";
    dataForNewImage.userID = @"current user"; // will come from cloudkit
    dataForNewImage.imageBelongsToCurrentUser = YES; // user took this photo
    dataForNewImage.liked = YES;
    /** THIS IS NULL. NEED TO USE SDWEBIMAGE cache **/
    //dataForNewImage.imageURL = info[UIImagePickerControllerReferenceURL];
    //NSLog(@"CID.imageURL: %@", dataForNewImage.imageURL);
    
    // write the image to local cache directory - will later convert this to SDWebImage cache
    NSData *data = UIImageJPEGRepresentation(image, 0.75);
    NSURL *cacheDirectory = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSString *temporaryName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"jpeg"];
    NSURL *localURL = [cacheDirectory URLByAppendingPathComponent:temporaryName];
    [data writeToURL:localURL atomically:YES];
    
    dataForNewImage.imageURL = localURL;
    NSLog(@"CID.imageURL: %@", dataForNewImage.imageURL);
    
    [self.imageLoadManager addCIDForNewUserImage:dataForNewImage]; // update the model with the new image
    //NSLog(@"Display CID info for new image: %@", dataForNewImage.description);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    // update number of items since array set has increased from new photo taken
    self.numberOfItemsInSection = [self.imageLoadManager.coffeeImageDataArray count];
    
    /* NOTE: This is just for initial testing...will need to segue or use action sheet to confirm the user wants
     * save the image!
     */
    // prepare the CKRecord and save it
    //[self saveRecord:[self createCKRecordForImage:dataForNewImage]];
    [self.ckManager saveRecord:[self.ckManager createCKRecordForImage:dataForNewImage]];
    
    // store the image in SDWebImage cache
    [self.imageCache storeImage:image forKey:dataForNewImage.imageURL.absoluteString];
    // insert the new key (image URL) into the cacheKeys array
    [self.allCacheKeys insertObject:dataForNewImage.imageURL.absoluteString atIndex:0];
    
    [self updateUI]; // updateUI to reload collectionview data
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
    
    NSLog(@"***numberOfItemsInSection***");
    
    // this block will load CV cells without invoking camera, but takes too much time to load and often
    // crashes with BAD_EXC_ACCESS. And numberOfItems property almost always printes 1 less than array count
    /*dispatch_queue_t fetchQ = dispatch_queue_create("load image data", NULL);
    dispatch_async(fetchQ, ^{
        self.numberOfItemsInSection = [self.imageLoadManager.coffeeImageDataArray count];
        //[self.myCollectionView reloadData];
    });*/
    
    // this block will only load the CV data if photo is taken with camera image added to the array. NumberOfItems
    // property always correctly prints the same value as array count
    /*dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    dispatch_queue_t fetchQ = dispatch_queue_create("load image data", NULL);
    dispatch_async(fetchQ, ^{
        NSLog(@"Remote call started...");
        self.numberOfItemsInSection = [self.imageLoadManager.coffeeImageDataArray count];
        NSLog(@"Remote call returned...");
        //[self.myCollectionView reloadData]; // should be done on main thread!
        dispatch_semaphore_signal(sema);
    });
    [self.myCollectionView reloadData];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);*/
    
    //[self.myCollectionView reloadData];
    NSLog(@"numberOfItemsInSection: %ld", (long)self.numberOfItemsInSection);
    return self.numberOfItemsInSection;
    //return [self.imageLoadManager.coffeeImageDataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CoffeeCell"; // string value identifier for cell reuse
    CoffeeViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSLog(@"cellForItemAtIndexPath: section:%ld row:%ld", (long)indexPath.section, (long)indexPath.row);
    if (cell) {
        
        [self.spinner stopAnimating]; // images should be loaded, so stop spinner
        //cell.backgroundColor = [UIColor whiteColor];
        //cell.layer.cornerRadius = 3;
        cell.layer.borderWidth = 1.0;
        cell.layer.borderColor = [UIColor grayColor].CGColor;
        
        /* UIViewContentMode options from here....*/
        //cell.coffeeImageView.contentMode = UIViewContentModeScaleToFill; // distorts the image
        //cell.coffeeImageView.contentMode = UIViewContentModeScaleAspectFill; // fills out image area, but image is cropped
        cell.coffeeImageView.contentMode = UIViewContentModeScaleAspectFit; // maintains aspect, but does not always fill image area
        /*...to here...*/
        
        // load placeholder image. will only been seen if loading from very weak signal or during scrolling after being idle
        cell.coffeeImageView.image = [UIImage imageNamed:@"placeholder"];
        
        /*CoffeeImageData *coffeeImageData = [self.imageLoadManager coffeeImageDataForCell:indexPath.row]; // maps the model to the UI
        dispatch_async(dispatch_get_main_queue(), ^{
            //cell.coffeeImageView.image = coffeeImageData.image;
            if (coffeeImageData.imageURL.path) {
                cell.coffeeImageView.image = [UIImage imageWithContentsOfFile:coffeeImageData.imageURL.path];
                //[cell setNeedsLayout];
            } else {
                // if imageURL is nil, then image is coming in from the camera as opposed to the cloud
                cell.coffeeImageView.image = coffeeImageData.image;
                //[cell setNeedsLayout];
            }
        });*/
        
        /********************************************************/
        CoffeeImageData *coffeeImageData = self.imageLoadManager.coffeeImageDataArray[indexPath.row];
        
        if ([self.allCacheKeys count] > 0) { // check to see if the cacheKeys arrays contains any keys (URLs)
            
            NSString *cacheKey = self.allCacheKeys[indexPath.row];
            if (cacheKey) {
                NSLog(@"cacheKey found!");
                [self.imageCache queryDiskCacheForKey:cacheKey done:^(UIImage *image, SDImageCacheType cacheType) {
                    if (image) { // image is found in the cache
                        NSLog(@"Image found in cache!");
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
        
        
        /*if (coffeeImageData.imageURL.path) {
            cell.coffeeImageView.image = [UIImage imageWithContentsOfFile:coffeeImageData.imageURL.path];
            //[cell setNeedsLayout];
        } else {
            // if imageURL is nil, then image is coming in from the camera as opposed to the cloud
            cell.coffeeImageView.image = coffeeImageData.image;
            //cell.coffeeImageView.image = [UIImage imageNamed:@"placeholder.png"];
            //[cell setNeedsLayout];
        }*/
        /********************************************************/
        //CGRect originalImageFrame = cell.coffeeImageView.frame;
        
        //cell.coffeeImageView.frame = CGRectMake(originalImageFrame.origin.x, originalImageFrame.origin.y, originalImageFrame.size.width, originalImageFrame.size.height - 25);
        
        //NSString *imageNameForLabel = [self.imageNames objectAtIndex:indexPath.row];
        //NSString *imageNameForLabel = coffeeImageData.imageName;
        //NSLog(@"imageNameforLabel %@", imageNameForLabel);
        
        //cell.coffeeImageView.image = coffeeImageData.image; // original code without thumbnail
        //cell.coffeeImageView.image = [UIImage imageWithContentsOfFile:coffeeImageData.imageURL.path];
        
        //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:coffeeImageData.imageURL]];
        //NSLog(@"image size height: %f, %fwidth", cell.coffeeImageView.image.size.height, cell.coffeeImageView.image.size.width);
        /* use the following to scale the image down for a thumbnail image - !!!issue with scroll lag though!!!*/
        //UIImage *thumbnailImage = coffeeImageData.image;
        //cell.coffeeImageView.image = [thumbnailImage imageByScalingToSize:CGSizeMake(ITEM_SIZE, ITEM_SIZE)];
        
        //cell.coffeeImageView.clipsToBounds = YES;
        //cell.coffeeImageLabel.text = imageNameForLabel;
        
        cell.coffeeImageLabel.alpha = 0.3; // set the label to be semi transparent
        cell.coffeeImageLabel.hidden = YES; // just for toggling on/off until this label is completely removed
    }
    
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
    // below coded used only for horizontal layout, which was the initial layout
    //NSInteger numberOfCells = self.view.frame.size.width / CellWidth;
    //NSInteger edgeInsets = (self.view.frame.size.width - (numberOfCells * CellWidth)) / (numberOfCells + 1);
    
    //return UIEdgeInsetsMake(0, edgeInsets, 0, edgeInsets);
    return UIEdgeInsetsMake(10, 12, 10, 12);
}

#define LIKE_BUTTON_WIDTH 38.0
#define LIKE_BUTTON_HEIGHT 38.0
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CoffeeViewCell *selectedCell = (CoffeeViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSLog(@"didSelectItemAtIndexPath");
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
    
    // place button in lower left corner of image
    //[likeButton setFrame:CGRectMake(xCoord - (xCoord * .97), yCoord - (yCoord * .08), LIKE_BUTTON_WIDTH, LIKE_BUTTON_HEIGHT)];
    //[likeButton setFrame:CGRectMake(xCoord - xCoord, yCoord - (yCoord * .07), LIKE_BUTTON_WIDTH, LIKE_BUTTON_HEIGHT)];
    
    [likeButton setFrame:CGRectMake(xCoord - xCoord, yPoint + (yCoord-LIKE_BUTTON_HEIGHT), LIKE_BUTTON_WIDTH, LIKE_BUTTON_HEIGHT)];
    [likeButton addTarget:self action:@selector(likeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // get the CoffeeImageData object for this cell
    CoffeeImageData *coffeeImageData = [self.imageLoadManager coffeeImageDataForCell:indexPath.row];
    //CoffeeImageData *coffeeImageData = self.imageLoadManager.coffeeImageDataArray[indexPath.row];
    
    selectedCell.imageIsLiked = coffeeImageData.isLiked;
    likeButton.selected = selectedCell.imageIsLiked;
    
    // Check to see if image is currently liked or not and display the correct heart image
    if (selectedCell.imageIsLiked) {
        //[likeButton setImage:[UIImage imageNamed:@"heart_blue_solid"] forState:UIControlStateNormal|UIControlStateSelected];
        // above line caused bug
        [likeButton setImage:[UIImage imageNamed:@"heart_blue_solid"] forState:UIControlStateNormal];
    } else {
        [likeButton setImage:[UIImage imageNamed:@"heart_blue"] forState:UIControlStateNormal];
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
            //self.fullScreenImage.image = selectedCell.coffeeImageView.image;
            //weakSelf.fullScreenImage.image = coffeeImageData.image;
            weakSelf.fullScreenImage.image = [UIImage imageWithContentsOfFile:coffeeImageData.imageURL.path];
            //weakSelf.fullScreenImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:coffeeImageData.imageURL]];
            //self.fullScreenImage.transform = CGAffineTransformMakeScale(1.0, 1.0); // zoom in effect
            weakSelf.fullScreenImage.transform = CGAffineTransformIdentity; // zoom in effect
            [weakSelf.view addSubview:self.fullScreenImage];
            [weakSelf.fullScreenImage addSubview:likeButton]; // add the button to the view
        }completion:^(BOOL finished){
            if (finished) {
                NSLog(@"Animation finished!");
                //[self.fullScreenImage bringSubviewToFront:likeButton];
                // hide the following uiview items so they will not be visible or active
                //self.searchBar.hidden = YES;
                //self.toolBar.hidden = YES;
                //self.imageRecipeSegmentedControl.hidden = YES;
                //self.navigationController.navigationBarHidden = YES;
                //self.view.backgroundColor = [UIColor blackColor];
                //self.myCollectionView.backgroundColor = [UIColor blackColor];
                weakSelf.isFullScreen = YES;
            }
        }];
        return;
    } /*else { // Moved this block to closeFullScreenImageView after adding tap gesture
        NSLog(@"Ending animiation!");
        //self.navigationController.navigationBarHidden = NO;
        //self.searchBar.hidden = NO;
        self.view.backgroundColor = [UIColor whiteColor];
        self.myCollectionView.backgroundColor = [UIColor colorWithRed:0.62 green:0.651 blue:0.686 alpha:1];
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.navigationController.navigationBarHidden = NO;
            self.searchBar.hidden = NO;
            self.toolBar.hidden = NO;
            self.imageRecipeSegmentedControl.hidden = NO;
            //self.flowLayout.itemSize = CGSizeMake(290, 290);
            //[selectedCell.coffeeImageView setFrame:prevFrame];
            //selectedCell.coffeeImageView.backgroundColor = [UIColor colorWithRed:0.62 green:0.651 blue:0.686 alpha:1];
            
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
    }*/
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
    //[self.view layoutIfNeeded];
}

/**
 * Method to setup the collectionview attributes

 * @return void
 */
- (void)setupCollectionView {
    NSLog(@"setupCollectionView");
    [self.spinner startAnimating];
    
    //UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    //CustomFlowLayout *flowLayout = [[CustomFlowLayout alloc] init];
    //flowLayout.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE); // globally sets the item (cell) size
    //[flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal]; // set scroll direction to horizontal*/
    self.flowLayout = [[CustomFlowLayout alloc] init];
    self.flowLayout.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
    //[self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    
    //flowLayout.itemSize = CGSizeMake(80, 100);
    //flowLayout.itemSize = CGSizeMake(ITEM_SIZE, ITEM_SIZE);
    self.myCollectionView.userInteractionEnabled = YES;
    self.myCollectionView.delaysContentTouches = NO;
    [self.myCollectionView setShowsVerticalScrollIndicator:YES];
    //[self.myCollectionView setBackgroundColor:[UIColor colorWithRed:0.227 green:0.349 blue:0.478 alpha:1]]; // ok color
    [self.myCollectionView setBackgroundColor:[UIColor colorWithRed:0.62 green:0.651 blue:0.686 alpha:1]];
    self.myCollectionView.multipleTouchEnabled = NO; // don't allow multiple cells to be selected at the same time
    //[self.myCollectionView setBackgroundColor:[UIColor whiteColor]];
    //[self.myCollectionView setPagingEnabled:YES]; // don't use since using CustomFlowLayout.targetContentOffsetForProposedContentOffset
    //self.myCollectionView.clipsToBounds = YES;
    
    //self.myCollectionView.delegate = self; // not needed since done in storyboard
    //self.myCollectionView.dataSource = self; // not needed since done in storyboard
    
    //[self.myCollectionView setCollectionViewLayout:flowLayout];
    
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
 * Method for preparing a CKRecord before saving to CloudKit. 
 * CKRecord will contain recent photo taken and prepared as CID object.
 *
 * @param CoffeeImageData*
 * @return CKRecord*
 */
/*- (CKRecord *)createCKRecordForImage:(CoffeeImageData *)coffeeImageData {
    
    NSLog(@"Entered createCKRecordForImage...");
    //NSUInteger randomNumber = arc4random() % 100;
    //CKRecordID *wellKnownID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"recordID%ld", (long)randomNumber]];
    //CKRecord *CIDRecord = [[CKRecord alloc] initWithRecordType:@"CoffeeImageData" recordID:wellKnownID];
    CKRecord *CIDRecord = [[CKRecord alloc] initWithRecordType:@"CoffeeImageData"];
    
    CIDRecord[@"ImageBelongsToUser"] = [NSNumber numberWithBool:coffeeImageData.imageBelongsToCurrentUser];
    //CIDRecord[@"ImageName"] = [NSString stringWithFormat:coffeeImageData.imageName, @"%d", randomNumber];
    CIDRecord[@"ImageName"] = coffeeImageData.imageName;
    CIDRecord[@"ImageDescription"] = coffeeImageData.imageDescription;
    CIDRecord[@"UserID"] = coffeeImageData.userID;
    CIDRecord[@"Recipe"] = [NSNumber numberWithBool:coffeeImageData.isRecipe];
    CKAsset *photoAsset = [[CKAsset alloc] initWithFileURL:coffeeImageData.imageURL];
    CIDRecord[@"Image"] = photoAsset;
    
    return CIDRecord;
}*/

/**
 * Method to save a CKRecord to CloudKit
 *
 *
 */
/*- (void)saveRecord:(CKRecord *)record {
    
    NSLog(@"Entered saveRecord...");
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    
    // save the record
    [publicDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            NSLog(@"Error saving record to cloud...%@", error.localizedDescription);
        } else {
            NSLog(@"Record saved successfully!");
        }
    }];
}*/

/**
 * Method to do the initial loading of CK records to populate the CV.
 * This will eventually be moved out of the ViewController and back into ImageLoadManager
 * CKManager.
 * @return void
 */
- (void)beginLoadingCloudKitData {
    
    NSLog(@"beginLoadingCloudKitData...started!");
    
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ImageDescription = 'description'"];
    // just for initial testing...give me all records
    NSPredicate *predicate = [NSPredicate predicateWithValue:true];
    //create the query
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"CoffeeImageData" predicate:predicate];
    
    // execute the queary
    [publicDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        // handle the error
        if (error) {
            NSLog(@"Error: there was an error fetching cloud data... %@", error.localizedDescription);
        } else {
            // any results?
            if ([results count] > 0) {
                // number of items is based on number of records returned from CK query
                self.numberOfItemsInSection = [results count];
                @synchronized(self){
                    NSLog(@"Success querying the cloud for %lu results!!!", (unsigned long)[results count]);
                    for (CKRecord *record in results) {
                        //NSLog(@"Image: %@", record[@"Image"]);
                        //NSLog(@"ImageBelongsToUser? %@", record[@"ImageBelongsToUser"]);
                        //NSLog(@"Image name: %@", record[@"ImageName"]);
                        //NSLog(@"userid: %@", record[@"UserID"]);
                        //NSLog(@"Image description: %@", record[@"ImageDescription"]);
                        //NSLog(@"isRecipe? %@", record[@"Recipe"]);
                        //NSLog(@"recordID: %@", record.recordID.recordName);
                        // create CoffeeImageData object to store data in the array for each image
                        CoffeeImageData *coffeeImageData = [[CoffeeImageData alloc] init];
                        CKAsset *imageAsset = record[@"Image"];
                        coffeeImageData.imageURL = imageAsset.fileURL;
                        //NSLog(@"asset URL: %@", coffeeImageData.imageURL);
                        coffeeImageData.imageName = record[@"ImageName"];
                        coffeeImageData.imageDescription = record[@"ImageDescription"];
                        coffeeImageData.userID = record[@"UserID"];
                        coffeeImageData.imageBelongsToCurrentUser = record[@"ImageBelongsToUser"];
                        coffeeImageData.recipe = record[@"Recipe"];
                        coffeeImageData.recordID = record.recordID.recordName;
                        
                        /* below lines is not needed, but not removing it yet */
                        //coffeeImageData.image = [UIImage imageWithContentsOfFile:imageAsset.fileURL.path];
                        //coffeeImageData.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:coffeeImageData.imageURL]];
                        //NSLog(@"image size height:%f, width:%f", coffeeImageData.image.size.height, coffeeImageData.image.size.width);
                        //[self.coffeeImageDataArray addObject:coffeeImageData];
                        [self.imageLoadManager.coffeeImageDataArray addObject:coffeeImageData];
                        
                        // cache the image with the string representation of the absolute URL as the cache key
                        if (coffeeImageData.imageURL) { // make sure there's an image URL to cache
                            if (self.imageCache) {
                                [self.imageCache storeImage:[UIImage imageWithContentsOfFile:coffeeImageData.imageURL.path] forKey:coffeeImageData.imageURL.absoluteString toDisk:YES];
                                //NSLog(@"Printing cache: %@", [[SDImageCache sharedImageCache] description]);
                            }
                        } else {
                            NSLog(@"WARN: CID imageURL is nil...cannot cache.");
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.myCollectionView reloadData]; // reload the collectionview after getting all the data from CK
                    });
                    NSLog(@"CoffeeImageDataArray size %lu", (unsigned long)[self.imageLoadManager.coffeeImageDataArray count]);
                }
                // load the keys to be used for cache look up
                [self getAllCacheKeys];
            }
        }
    }];
    
    NSLog(@"beginLoadingCloudKitData...ended!");
}

/**
 * Method to determine the selected segment from the UISegmentedControl and
 * get the corresponded title.
 *
 * @return NSString* Selected Title
 */
- (NSString *)getSelectedSegmentTitle {
    
    NSLog(@"Entered getSelectedSegmentTitle...");
    NSInteger segmentedIndex = self.imageRecipeSegmentedControl.selectedSegmentIndex;
    //NSString *segmentTitle = [self.imageRecipeSegmentedControl titleForSegmentAtIndex:segmentedIndex];
    return [self.imageRecipeSegmentedControl titleForSegmentAtIndex:segmentedIndex];
}

/**
 * Method to take all the URL strings corresponding to each image and uses it for cache
 * storage and lookup. This array should always be empty when called. Should only be
 * called right after beginLoadingCloudKitData is called.
 *
 * @return void
 */
- (void)getAllCacheKeys {
    
    NSLog(@"Entered getAllCacheKeys...");
    
    if (self.allCacheKeys) {
        NSLog(@"Ready to set the cache keys!");
        // go through the CID objecs in the array and get the URL string for each corresponding image
        for (CoffeeImageData *cid in self.imageLoadManager.coffeeImageDataArray) {
            NSString *url = cid.imageURL.absoluteString;
            NSLog(@"URL key being stored: %@", url);
            // check to make sure the URL is not already in the array
            if (![self.allCacheKeys containsObject:url]) {
                NSLog(@"INFO: Adding URL to cacheKeys array...");
                [self.allCacheKeys addObject:url];
            }
        }
        NSLog(@"allCacheKeys array size: %lu", (unsigned long)[self.allCacheKeys count]);
    }
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
 * Method to toggle liked button and also update liked value in the model
 *
 * @param sender (UIButton)
 * @return void
 */
- (IBAction)likeButtonPressed:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    CoffeeViewCell *selectedCell = (CoffeeViewCell *)[self.myCollectionView cellForItemAtIndexPath:indexPath];
    
    selectedCell.imageIsLiked = !selectedCell.imageIsLiked; // toggle this based on button being pressed
    //CoffeeImageData *currentImageData = [self.imageLoadManager coffeeImageDataForCell:indexPath.row];
    CoffeeImageData *currentImageData = self.imageLoadManager.coffeeImageDataArray[indexPath.row];
    
    //NSLog(@"likeButtonPressed for image name: %@", currentImageData.imageName);
    NSLog(@"likeButtonPressed for: section:%ld row:%ld", (long)indexPath.section, (long)indexPath.row);
    
    // update the liked value in the model based on the user hitting the like button on the image
    currentImageData.liked = selectedCell.imageIsLiked;
    if (currentImageData.isLiked) {
        //NSLog(@"image is liked");
        [button setImage:[UIImage imageNamed:@"heart_blue_solid"] forState:UIControlStateNormal];
    } else {
        //NSLog(@"image is NOT liked");
        [button setImage:[UIImage imageNamed:@"heart_blue"] forState:UIControlStateNormal];
    }
    
    //NSLog(@"image liked for indexpath %ld", (long)indexPath.row);
}

/**
 * Action method that invokes the camera
 * 
 * @param UIBarButtonItem *sender
 * @return void
 */
- (IBAction)cameraBarButtonPressed:(UIBarButtonItem *)sender {
    NSLog(@"Entered cameraBarButtonPressed");
    
    CKAccountStatus userAccountStatus; // will return values 0-3. 1 is what we're looking for
    
    userAccountStatus = [self.ckManager getUsersCKStatus];
    NSLog(@"cameraBarButtonPressed userAccountStatus: %ld", userAccountStatus);
        
    if (userAccountStatus == CKAccountStatusAvailable) { // status = 1
        //NSLog(@"User is logged into CK - user can upload pics!");
        UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
        cameraUI.delegate = self; // set the deleage for the ImagePickerController
            
        // check to see if the camera is available as source type, else check for photo album
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        }
            
        [cameraUI setAllowsEditing:YES]; // let the user edit the photo
        // set the camera presentation style
        //cameraUI.modalPresentationStyle = UIModalPresentationFullScreen;
        cameraUI.modalPresentationStyle = UIModalPresentationCurrentContext;
            
        dispatch_async(dispatch_get_main_queue(), ^{ // show the camera on main thread to avoid latency
            [self presentViewController:cameraUI animated:YES completion:nil]; // show the camera with animation
        });
    } else if (userAccountStatus == CKAccountStatusNoAccount) { // status = 3
        //NSLog(@"User is not logged into CK - Camera not available!");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iCloud Not Available" message:@"You must be logged into your iCloud account to submit photos and recipes. Go into iCloud under Settings on your device to login." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    } else if (userAccountStatus == CKAccountStatusRestricted) { // status = 2
        NSLog(@"User CK account is RESTRICTED !");
    } else if (userAccountStatus == CKAccountStatusCouldNotDetermine) { // status = 0
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iCloud Status Undetermined" message:@"We could not determine your iCloud status. You must be logged into your iCloud account to submit photos and recipes. Go into iCloud under Settings on your device to login." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    } else { // did not get back one of the above values so show the Could Not Determine message
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"iCloud Status Undetermined" message:@"We could not determine your iCloud status. You must be logged into your iCloud account to submit photos and recipes. Go into iCloud under Settings on your device to login." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
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
    
    // clear the cache
    [self.imageCache clearMemory];
    [self.imageCache clearDisk];
    
    [self beginLoadingCloudKitData]; // call method to trigger CK query
    
    [self setupCollectionView]; // setup the collectionview parameters
    [self setupSearchBar]; // setup the search bar in the navigation bar
    //self.toolBar.barTintColor = [UIColor colorWithRed:0.112 green:0.234 blue:0.4 alpha:1];
    //self.navigationController.navigationBar.barTintColor = self.globalColor; // set the background color of the navigation bar
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.112 green:0.234 blue:0.4 alpha:1];
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
    
    /* Need to make sure when coming *back* from CafeLocatorTableVC segue that Cafes does not stay selected.
     * Otherwise, user has to manually tap another segment control, then tap Cafes again to go back to cafe
     * locator. Will make this go back to Images segment. However, this may be better handled by a delegate -
     * need to investigate.
     */
    if ([[self getSelectedSegmentTitle] isEqualToString:@"Cafes"]) {
        NSLog(@"ViewDidAppear - Cafes!!");
        self.imageRecipeSegmentedControl.selectedSegmentIndex = 0;
        //[self.myCollectionView reloadData];
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
    NSLog(@"Did Receive Memory Warning...clearing cache!");
    [self.imageCache clearMemory];
}

@end
