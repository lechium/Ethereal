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
    unsigned long long _style;
    UIImageView *_leadingImageView;
    UIImageView *_trailingImageView;
    UIStackView *_stackView;
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
        [self.contentView addSubview:_stackView];
        [_stackView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    return self;
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
    
    [coordinator addCoordinatedAnimations:^{
        if (self.focused) {
            self.backgroundColor = [UIColor whiteColor];
            self.label.textColor = [UIColor colorWithWhite:0 alpha:0.6];
            self.trailingImageView.tintColor = [UIColor colorWithWhite:0 alpha:0.6];
            self.transform = CGAffineTransformMakeScale(1.05, 1.05);
            
        } else {
            self.transform = CGAffineTransformIdentity;
            self.label.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
            self.trailingImageView.tintColor = [UIColor colorWithWhite:1.0 alpha:0.6];
            self.backgroundColor = nil;
        }
    } completion:nil];
   
}


@end
