//
//  KBBulletinView.m
//  Ethereal
//
//  Created by Kevin Bradley on 2/1/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import "KBBulletinView.h"

@implementation UIWindow (Additions)

- (UIViewController *)bulletin_visibleViewController {
    UIViewController *rootViewController = self.rootViewController;
    return [UIWindow bulletin_getVisibleViewControllerFrom:rootViewController];
}

+ (UIViewController *) bulletin_getVisibleViewControllerFrom:(UIViewController *) vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = [UIWindow bulletin_getVisibleViewControllerFrom:[((UINavigationController *) vc) visibleViewController]];
        UINavigationController *nav = [visible navigationController];
        return nav ? nav : visible;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [UIWindow bulletin_getVisibleViewControllerFrom:[((UITabBarController *) vc) selectedViewController]];
    } else {
        if (vc.presentedViewController) {
            return [UIWindow bulletin_getVisibleViewControllerFrom:vc.presentedViewController];
        } else {
            return vc;
        }
    }
}

@end

@implementation UIFont (size)

- (UIFont *)copiedFontWithSize:(CGFloat)fontSize {
    return [UIFont fontWithDescriptor:self.fontDescriptor size:fontSize];
}

@end

@interface KBBulletinView() {
    UIImage *_bulletinImage;
    NSString *_bulletinTitle;
    NSString *_bulletinDescription;
    UIFont *_titleFont;
    UIFont *_descriptionFont;
    NSLayoutConstraint *_widthConstraint;
}

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic) UIImageView *imageView;

@end

@implementation KBBulletinView

- (NSString *)bulletinTitle {
    return _bulletinTitle;
}

- (void)setBulletinTitle:(NSString *)bulletinTitle {
    _bulletinTitle = bulletinTitle;
    _titleLabel.text = bulletinTitle;
    [self updateViewWidth];
}

- (NSString *)bulletinDescription {
    return _bulletinDescription;
}

- (void)setBulletinDescription:(NSString *)bulletinDescription {
    _bulletinDescription = bulletinDescription;
    _descriptionLabel.text = bulletinDescription;
    [self updateViewWidth];
}

- (UIFont *)titleFont {
    return _titleFont;
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    _titleLabel.font = titleFont;
    [self updateViewWidth];
}

- (UIFont *)descriptionFont {
    return _descriptionFont;
}

- (void)setDescriptionFont:(UIFont *)descriptionFont {
    _descriptionFont = descriptionFont;
    _descriptionLabel.font = descriptionFont;
    [self updateViewWidth];
}

- (UIImage *)bulletinImage {
    return _bulletinImage;
}

- (void)setBulletinImage:(UIImage *)bulletinImage {
    _bulletinImage = bulletinImage;
    _imageView.image = _bulletinImage;
}

- (void)updateViewWidth {
    _widthConstraint.constant = [self calculatedViewWidth];
}

+ (instancetype)bulletinWithTitle:(NSString *)title description:(NSString *_Nullable)desc image:(UIImage * _Nullable)image {
    return [[KBBulletinView alloc] initWithTitle:title description:desc image:image];
}

- (instancetype)initWithTitle:(NSString *)title description:(NSString *_Nullable)desc image:(UIImage *_Nullable)image {
    self = [super init];
    if (self) {
        _bulletinTitle = title;
        _bulletinDescription = desc;
        _bulletinImage = image;
        [self initDefaults];
        [self setupView];
    }
    return self;
}

- (void)initDefaults {
    _titleFont = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    _descriptionFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

- (CGFloat)imageDimension {
    return 70;
}

- (CGFloat)imageLeading {
    return 25;
}

- (CGFloat)stackLeading {
    return 18;
}

- (CGFloat)stackTrailing {
    return 45;
}

- (CGFloat)maxWidth {
    return 660;
}

- (CGFloat)minWidth {
    return 355;
}

- (CGFloat)calculatedViewWidth {
    CGRect titleBoundingRect = [_bulletinTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 34) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _titleFont} context:nil];
    CGRect descBoundingRect = [_bulletinDescription boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 34) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _descriptionFont} context:nil];
    CGFloat titleBoundingWidth = titleBoundingRect.size.width;
    CGFloat descBoundingWidth = descBoundingRect.size.width;
    CGFloat boundingWidth = MAX(titleBoundingWidth, descBoundingWidth);
    //add width of the image view, its left margin and our space from that to this value + our trailing value and see if its bigger than our size
    CGFloat imageDimension = [self imageDimension];
    CGFloat imageLeading = [self imageLeading];
    CGFloat stackLeading = [self stackLeading];
    CGFloat stackTrailing = [self stackTrailing];
    CGFloat width = imageDimension + imageLeading + stackTrailing + boundingWidth + stackLeading + 5;
    width = MAX([self minWidth], width);
    width = MIN([self maxWidth], width);
    return width;
}

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    UIView *backgroundView = [[UIView alloc] init];
    [self addSubview:backgroundView];
    CGFloat width = [self calculatedViewWidth];
    self.translatesAutoresizingMaskIntoConstraints = false;
    [self.heightAnchor constraintEqualToConstant:130].active = true;
    _widthConstraint = [self.widthAnchor constraintEqualToConstant:width];
    _widthConstraint.active = true;
    backgroundView.translatesAutoresizingMaskIntoConstraints = false;
    [backgroundView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = true;
    [backgroundView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = true;
    [backgroundView.topAnchor constraintEqualToAnchor:self.topAnchor].active = true;
    [backgroundView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = true;
    backgroundView.layer.masksToBounds = true;
    backgroundView.layer.cornerRadius = 27;
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.translatesAutoresizingMaskIntoConstraints = false;
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false;
    [backgroundView addSubview:blurView];
    [blurView.leadingAnchor constraintEqualToAnchor:backgroundView.leadingAnchor].active = true;
    [blurView.trailingAnchor constraintEqualToAnchor:backgroundView.trailingAnchor].active = true;
    [blurView.topAnchor constraintEqualToAnchor:backgroundView.topAnchor].active = true;
    [blurView.bottomAnchor constraintEqualToAnchor:backgroundView.bottomAnchor].active = true;
    [backgroundView addSubview:vibrancyEffectView];
    [vibrancyEffectView.leadingAnchor constraintEqualToAnchor:backgroundView.leadingAnchor].active = true;
    [vibrancyEffectView.trailingAnchor constraintEqualToAnchor:backgroundView.trailingAnchor].active = true;
    [vibrancyEffectView.topAnchor constraintEqualToAnchor:backgroundView.topAnchor].active = true;
    [vibrancyEffectView.bottomAnchor constraintEqualToAnchor:backgroundView.bottomAnchor].active = true;
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = false;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = _titleFont;
    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.translatesAutoresizingMaskIntoConstraints = false;
    _descriptionLabel.textColor = [UIColor whiteColor];
    _descriptionLabel.font = _descriptionFont;
    _descriptionLabel.textColor = [UIColor colorWithWhite:1 alpha:0.6];
    _descriptionLabel.numberOfLines = 2;
    _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    UIStackView *_myStackView = [[UIStackView alloc] initWithArrangedSubviews:@[_titleLabel, _descriptionLabel]];
    _myStackView.axis = UILayoutConstraintAxisVertical;
    _myStackView.translatesAutoresizingMaskIntoConstraints = false;
    _myStackView.spacing = 5;
    [backgroundView addSubview:_myStackView];
    [_myStackView.trailingAnchor constraintEqualToAnchor:backgroundView.trailingAnchor constant:-self.stackTrailing].active = true;
    _imageView = [[UIImageView alloc] init];
    _imageView.translatesAutoresizingMaskIntoConstraints = false;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.translatesAutoresizingMaskIntoConstraints = false;
    [_imageView.heightAnchor constraintEqualToConstant:self.imageDimension].active = true;
    [_imageView.widthAnchor constraintEqualToConstant:self.imageDimension].active = true;
    [backgroundView addSubview:_imageView];
    [_myStackView.leftAnchor constraintEqualToAnchor:_imageView.rightAnchor constant:self.stackLeading].active = true;
    [_imageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = true;
    [_myStackView.centerYAnchor constraintEqualToAnchor:_imageView.centerYAnchor].active = true;
    [_imageView.leftAnchor constraintEqualToAnchor:backgroundView.leftAnchor constant:self.imageLeading].active = true;
    [self _populateData];
    
}

- (void)_populateData {
    _titleLabel.text = _bulletinTitle;
    _descriptionLabel.text = _bulletinDescription;
    _imageView.image = _bulletinImage;
}


- (void)hideView {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformScale(self.transform, 0.01, 0.01);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showFromController:(UIViewController *_Nullable)controller forTime:(CGFloat)duration {
    if (!controller){
        controller = [[[UIApplication sharedApplication] keyWindow] bulletin_visibleViewController];
    }
    if (controller) {
        self.alpha = 0;
        self.transform = CGAffineTransformScale(self.transform, 0.01, 0.01);
        [controller.view addSubview:self];
        [self.rightAnchor constraintEqualToAnchor:controller.view.rightAnchor constant:-80].active = true;
        [self.topAnchor constraintEqualToAnchor:controller.view.topAnchor constant:60].active = true;
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1.0;
            self.transform = CGAffineTransformIdentity;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (duration > 0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf hideView];
                });
            }
        }];
            
    }
}

- (void)showForTime:(CGFloat)duration {
    [self showFromController:nil forTime:duration];
}

- (void)show {
    [self showForTime:3];
}

@end
