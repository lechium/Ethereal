//
//  UIViewController+Presentation.m
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import "UIViewController+Presentation.h"
#import "KBPlayerViewController.h"
#import "PlayerViewController.h"
@implementation UIViewController (Presentation)
- (void)safePresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^__nullable)(void))completion {
    LOG_SELF;
    if ([self isKindOfClass:KBPlayerViewController.class] || [self isKindOfClass:PlayerViewController.class]){
        NSLog(@"[Ethereal] this should never be presenting another view...., bail");
        return;
    }
    if (self.presentedViewController == viewControllerToPresent) {
        NSLog(@"[Ethereal] hey dummy: %@ is already presenting", viewControllerToPresent);
    } else {
        if ([NSThread isMainThread]) {
            [self presentViewController:viewControllerToPresent animated:true completion:completion];
        } else {
            NSLog(@"[Ethereal] not on the main thread!!");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:viewControllerToPresent animated:true completion:completion];
            });
        }
    }
}

@end
