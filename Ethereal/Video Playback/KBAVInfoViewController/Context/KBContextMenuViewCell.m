//
//  KBContextMenuViewCell.m
//  Ethereal
//
//  Created by kevinbradley on 2/23/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import "KBContextMenuViewCell.h"
#import "KBSliderImages.h"
#import "UIView+AL.h"
#import "UIStackView+Helper.h"

@implementation KBContextMenuViewCell {
    BOOL _destructive;
    BOOL _disabled;
    unsigned long long _style;
    UIImageView *_leadingImageView;
    UIImageView *_trailingImageView;
    UIStackView *_stackView;
    UIView *_selectedView;
}

- (UIView *)selectedView {
    return _selectedView;
}

- (void)setAttributes:(KBMenuElementAttributes)attributes {
    if (attributes & KBMenuElementAttributesDestructive) {
        _selectedView.backgroundColor = [UIColor redColor];
        _destructive = true;
    }
    if (attributes & KBMenuElementAttributesDisabled) {
        _selectedView.backgroundColor = [UIColor darkGrayColor];
        _label.textColor = [UIColor colorWithWhite:1 alpha:0.3];
        _disabled = true;
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        _stackView = [[UIStackView alloc] initForAutoLayout];
        _stackView.distribution = UIStackViewDistributionFillProportionally;
        _leadingImageView = [[UIImageView alloc] initForAutoLayout];
        _leadingImageView.contentMode = UIViewContentModeScaleAspectFit;
        _label = [[UILabel alloc] initForAutoLayout];
        _label.textColor = [UIColor colorWithWhite:1 alpha:0.6];
        _label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _trailingImageView = [[UIImageView alloc] initForAutoLayout];
        _trailingImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_trailingImageView autoConstrainToSize:CGSizeMake(28, 26)];
        [_stackView setArrangedViews:@[_leadingImageView, _label, _trailingImageView]];
        [self _setupSelectedView];
        [self.contentView addSubview:_stackView];
        [_stackView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 25, 0, 25)];
        
        
    }
    return self;
}

- (void)_setupSelectedView {
    _selectedView = [[UIView alloc] initForAutoLayout];
    [self.contentView addSubview:_selectedView];
    _selectedView.layer.cornerRadius = 15;
    _selectedView.layer.masksToBounds = true;
    [_selectedView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    _selectedView.alpha = 0;
    if (_destructive){
        _selectedView.backgroundColor = [UIColor redColor];
    } else {
        _selectedView.backgroundColor = [UIColor whiteColor];
    }
    
}

- (UIImageView *)trailingImageView {
    return _trailingImageView;
}

+ (id)_checkmarkImage {
    return [KBSliderImages checkmarkImage];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    self.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    self.selected = selected;
    if (selected) {
        _trailingImageView.image = [KBContextMenuViewCell _checkmarkImage];
        if (self.isFocused){
            self.trailingImageView.tintColor = [UIColor colorWithWhite:0 alpha:0.6];
        } else {
            self.trailingImageView.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        }
    } else {
        _trailingImageView.image = nil;
    }
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    [super didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
    @weakify(self);
    [coordinator addCoordinatedAnimations:^{
        if (self.focused) {
            //self.backgroundColor = [UIColor whiteColor];
            self.label.textColor = [UIColor colorWithWhite:0 alpha:0.6];
            self.trailingImageView.tintColor = [UIColor colorWithWhite:0 alpha:0.6];
            self.transform = CGAffineTransformMakeScale(1.05, 1.05);
            self_weak_.selectedView.alpha = 1.0;
            //_selectedView.alpha = 1.0;
            
        } else {
            self.transform = CGAffineTransformIdentity;
            self.label.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
            self.trailingImageView.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
            //self.backgroundColor = nil;
            self_weak_.selectedView.alpha = 0.0;
        }
    } completion:nil];
   
}


@end
