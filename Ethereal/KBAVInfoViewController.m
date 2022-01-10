//
//  KBAVInfoViewController.m
//  Ethereal
//
//  Created by kevinbradley on 1/9/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import "KBAVInfoViewController.h"
#import "ALView+PureLayout.h"
@interface KBAVInfoViewController ()
@property UIView *visibleView;
@property NSLayoutConstraint *heightConstraint;
@property NSLayoutConstraint *topConstraint;
@property UIView *infoView;
@property UIImageView *infoImageView;
@property UILabel *titleLabel;
@property UILabel *durationLabel;
@property UILabel *descriptionLabel;

@end

#define PADDING 40.0

@implementation KBAVInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    _visibleView = [[UIView alloc] initForAutoLayout];
    _visibleView.layer.masksToBounds = true;
    _visibleView.layer.cornerRadius = 27;
    [self.view addSubview:_visibleView];
    _heightConstraint = [_visibleView.heightAnchor constraintEqualToConstant:510];
    _heightConstraint.active = true;
    [_visibleView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:PADDING].active = true;
    _topConstraint = [_visibleView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:-510];
    _topConstraint.active = true;
    [_visibleView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-PADDING].active = true;
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [_visibleView addSubview:blurView];
    [blurView autoPinEdgesToSuperviewEdges];
    [_visibleView addSubview:vibrancyEffectView];
    [vibrancyEffectView autoPinEdgesToSuperviewEdges];
    _tempTabBar = [[UITabBar alloc] initForAutoLayout];
    [_visibleView addSubview:_tempTabBar];
    _tempTabBar.itemSpacing = 20;
    _tempTabBar.delegate = self;
    UITabBarItem *tbi = [[UITabBarItem alloc] initWithTitle:@"Info" image:nil tag:0];
    UITabBarItem *tbt = [[UITabBarItem alloc] initWithTitle:@"Audio" image:nil tag:1];
    _tempTabBar.items = @[tbi, tbt];
    [_tempTabBar.widthAnchor constraintEqualToAnchor:_visibleView.widthAnchor].active = true;
    [_tempTabBar.leadingAnchor constraintEqualToAnchor:_visibleView.leadingAnchor].active = true;
    [_tempTabBar.trailingAnchor constraintEqualToAnchor:_visibleView.trailingAnchor].active = true;
    [_tempTabBar.topAnchor constraintEqualToAnchor:_visibleView.topAnchor constant:10].active = true;
    // Do any additional setup after loading the view.
}

- (void)changeHeight:(CGFloat)height animated:(BOOL)animated {
    if (!animated){
            self->_heightConstraint.constant = height;
            [self.view layoutIfNeeded];
        return;
    }
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self->_heightConstraint.constant = height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)showFromViewController:(UIViewController *)pvc {
    [self.view layoutIfNeeded];
    [pvc addChildViewController:self];
    [pvc.view addSubview:self.view];
    self.view.accessibilityViewIsModal = true;
    _visibleView.alpha = 0;
    [self didMoveToParentViewController:pvc];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self->_topConstraint.constant = PADDING;
        self->_visibleView.alpha = 1;
        [self.view layoutIfNeeded];
        
    }
                     completion:^(BOOL finished) {
        [self.parentViewController.view setNeedsFocusUpdate];
        [self.parentViewController.view updateFocusIfNeeded];
    }];
}

- (void)closeWithCompletion:(void(^_Nullable)(void))block {
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self->_topConstraint.constant = -510;
        self->_visibleView.alpha = 0;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        if (block) {
            block();
        }
    }];
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];

}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSLog(@"[Ethereal] tabBar: %@ didSelectItem: %@", tabBar, item);
}

- (UIView *)_createInfoView {
    if (_infoView) return _infoView;
    return nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
