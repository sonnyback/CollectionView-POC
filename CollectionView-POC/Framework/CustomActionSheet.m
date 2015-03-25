//
//  CustomActionSheet.m
//  CollectionView-POC
//
//  Created by Sonny Back on 3/23/15.
//  Copyright (c) 2015 Sonny Back. All rights reserved.
//

#import "CustomActionSheet.h"

@interface CustomActionSheet()

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) void(^completionHandler)(NSString *, NSInteger);
@end

@implementation CustomActionSheet

// designated initializer
-(id)initWithTitle:(NSString *)title delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...  {
    
    self = [super init];
    if (self) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:destructiveButtonTitle
                                          otherButtonTitles:nil];
        
        va_list arguments;
        va_start(arguments, otherButtonTitles);
        NSString *currentButtonTitle = otherButtonTitles;
        while (currentButtonTitle != nil) {
            [_actionSheet addButtonWithTitle:currentButtonTitle];
            currentButtonTitle = va_arg(arguments, NSString *);
        }
        va_end(arguments);
        
        [_actionSheet addButtonWithTitle:cancelButtonTitle];
        [_actionSheet setCancelButtonIndex:_actionSheet.numberOfButtons - 1];
        
    }
    
    return self;
}

-(void)showInView:(UIView *)view withCompletionHandler:(void (^)(NSString *, NSInteger))handler{
    _completionHandler = handler;
    
    [_actionSheet showInView:view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *buttonTitle = [_actionSheet buttonTitleAtIndex:buttonIndex];
    
    _completionHandler(buttonTitle, buttonIndex);
}
@end
