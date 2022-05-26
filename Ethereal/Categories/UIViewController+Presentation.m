//
//  UIViewController+Presentation.m
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import "UIViewController+Presentation.h"
#import "KBPlayerViewController.h"
#import "VLCViewController.h"
@implementation UIViewController (Presentation)
- (void)safePresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^__nullable)(void))completion {
    if ([self isKindOfClass:KBPlayerViewController.class] || [self isKindOfClass:VLCViewController.class]){
        ELog(@"this should never be presenting another view...., bail");
        return;
    }
    if (self.presentedViewController == viewControllerToPresent) {
        ELog(@"hey dummy: %@ is already presenting", viewControllerToPresent);
    } else {
        if ([NSThread isMainThread]) {
            [self presentViewController:viewControllerToPresent animated:true completion:completion];
        } else {
            ELog(@"not on the main thread!!");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:viewControllerToPresent animated:true completion:completion];
            });
        }
    }
}

@end
