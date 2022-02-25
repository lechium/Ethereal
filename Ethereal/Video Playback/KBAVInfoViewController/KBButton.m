#import "KBButton.h"
#import "UIView+AL.h"

@interface KBButton() {
    KBButtonType _buttonType;
    BOOL _selected;
    UIView *_selectedView;
    BOOL _opened;
}

@end

@implementation KBButton

- (void)setOpened:(BOOL)opened {
    _opened = opened;
    if (opened) {
        _selectedView.alpha = 1.0;
        _selectedView.backgroundColor = [UIColor darkGrayColor];
        if (self.buttonImageView){
            self.buttonImageView.tintColor = [UIColor whiteColor];
        }
        if ([self isFocused]){
            _selectedView.backgroundColor = [UIColor whiteColor];
            if (self.buttonImageView){
                self.buttonImageView.tintColor = [UIColor darkGrayColor];
            }
        }
    } else {
        _selectedView.alpha = 0.0;
        if (self.isFocused){
            _selectedView.alpha = 1.0;
        }
        _selectedView.backgroundColor = [UIColor whiteColor];
        if (self.buttonImageView){
            self.buttonImageView.tintColor = [UIColor darkGrayColor];
        }
    }
}

- (BOOL)opened {
    return _opened;
}

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    [super pressesEnded:presses withEvent:event];
    //DLog(@"subtype: %lu type: %lu", event.subtype, event.type);
    UIPress *first = [presses.allObjects firstObject];
    if (first.type == UIPressTypeSelect){
        [self sendActionsForControlEvents:UIControlEventPrimaryActionTriggered];
    }
}

- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state {
    _titleLabel.text = title;
}

- (BOOL)isEnabled {
    return true;
}

- (BOOL)canBecomeFirstResponder {
    return true;
}

- (BOOL)canFocus {
    return true;
}

- (BOOL)canBecomeFocused {
    return true;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    [coordinator addCoordinatedAnimations:^{
        //BOOL contains = (context.focusHeading & UIFocusHeadingDown) != 0;
        //DLog(@"direction: %lu", context.focusHeading);
        if (self.isFocused) {
            if (self.focusChanged){
                self.focusChanged(true, context.focusHeading);
            }
            [self setSelected:true];
        } else {
            if (self.focusChanged){
                self.focusChanged(false, context.focusHeading);
            }
            [self setSelected:false];
        }
        
    } completion:^{
        
    }];
    
}


+(instancetype)buttonWithType:(KBButtonType)buttonType {
    KBButton *button = [[KBButton alloc] init];
    button.opened = false;
    if (buttonType == KBButtonTypeText){
        [button _setupLabelView];
    } else if (buttonType == KBButtonTypeImage) {
        [button _setupImageView];
    }
    return button;
}

- (void)_setupSelectedView {
    _selectedView = [[UIView alloc] initForAutoLayout];
    [self addSubview:_selectedView];
    [_selectedView autoPinEdgesToSuperviewEdges];
    _selectedView.alpha = 0;
    _selectedView.backgroundColor = [UIColor whiteColor];
}

- (void)_setupLabelView {
    [self _setupSelectedView];
    _titleLabel = [[UILabel alloc] initForAutoLayout];
    [self addSubview:_titleLabel];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleLabel autoCenterInSuperview];
    [_titleLabel.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.8].active = true;
    [_titleLabel.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.8].active = true;
    _selectedView.layer.cornerRadius = 20;
}

- (void)_setupImageView {
    [self _setupSelectedView];
    _buttonImageView = [[UIImageView alloc] initForAutoLayout];
    [self addSubview:_buttonImageView];
    _buttonImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_buttonImageView autoCenterInSuperview];
    [_buttonImageView.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.6].active = true;
    [_buttonImageView.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.6].active = true;
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    if (selected){
        _selectedView.alpha = 1.0;
        _selectedView.backgroundColor = [UIColor whiteColor];
        if (self.buttonImageView){
            self.buttonImageView.tintColor = [UIColor darkGrayColor];
        }
    } else {
        _selectedView.alpha = 0;
        if (self.buttonImageView){
            self.buttonImageView.tintColor = [UIColor whiteColor];
        }
        if (self.opened){
            self.opened = true; //hacky but might work
        }
    }
}

- (BOOL)selected {
    return _selected;
}

- (void)setButtonType:(KBButtonType)buttonType {
    _buttonType = buttonType;
}

- (KBButtonType)buttonType {
    return _buttonType;
}

@end
