//
//  KBBulletinView.h
//  Ethereal
//
//  Created by Kevin Bradley on 2/1/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (Additions)
- (UIViewController *)bulletin_visibleViewController;
@end

@interface UIFont (Size)
- (UIFont *)copiedFontWithSize:(CGFloat)fontSize;
@end

@interface KBBulletinView : UIView

@property (nonatomic, strong) NSString *bulletinTitle;
@property (nonatomic, strong) NSString *bulletinDescription;
@property (nonatomic, strong) UIImage *bulletinImage;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIFont *descriptionFont;

+ (instancetype)bulletinWithTitle:(NSString *)title description:(NSString *_Nullable)desc image:(UIImage * _Nullable)image;
- (instancetype)initWithTitle:(NSString *)title description:(NSString *_Nullable)desc image:(UIImage * _Nullable )image;
- (void)show; //will show for 3 seconds
- (void)showForTime:(CGFloat)duration;
- (void)showFromController:(UIViewController *_Nullable)controller forTime:(CGFloat)duration;
- (void)hideView;
@end

NS_ASSUME_NONNULL_END
