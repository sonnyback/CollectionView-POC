//
//  CustomActionSheet.h
//  CollectionView-POC
//
//  Created by Sonny Back on 3/23/15.
//  Copyright (c) 2015 Sonny Back. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomActionSheet : NSObject <UIActionSheetDelegate>

-(id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

-(void)showInView:(UIView *)view withCompletionHandler:(void(^)(NSString *buttonTitle, NSInteger buttonIndex))handler;
@end
