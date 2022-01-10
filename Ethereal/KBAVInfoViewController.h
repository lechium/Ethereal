//
//  KBAVInfoViewController.h
//  Ethereal
//
//  Created by kevinbradley on 1/9/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KBAVInfoViewController : UIViewController <UITabBarDelegate>

@property UITabBar *tempTabBar;
- (void)showFromViewController:(UIViewController *)pvc;
- (void)closeWithCompletion:(void(^_Nullable)(void))block;
@end

NS_ASSUME_NONNULL_END
