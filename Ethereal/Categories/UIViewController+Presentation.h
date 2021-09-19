//
//  UIViewController+Presentation.h
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Presentation)
- (void)safePresentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^__nullable)(void))completion;
@end

NS_ASSUME_NONNULL_END
