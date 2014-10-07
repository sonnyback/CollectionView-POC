//
//  main.m
//  CollectionView-POC
//
//  Created by Sonny Back on 3/27/14.
//  Copyright (c) 2014 Sonny Back. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([BaseAppDelegate class]));
    }
    /*int retVal = -1;
    @try
    {
        retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([BaseAppDelegate class]));
    }
    @catch (NSException* exception)
    {
        NSLog(@"Uncaught exception: %@", exception.description);
        NSLog(@"Stack trace: %@", [exception callStackSymbols]);
    }
    return retVal;*/
}
