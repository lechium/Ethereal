//
//  KBSlider.m
//  KBSlider
//
//  Created by Kevin Bradley on 12/25/20.
//  Copyright © 2020 nito. All rights reserved.
//

#import "KBSlider.h"
#import <GameController/GameController.h>

@interface KBSlider() {
    CGFloat _minimumValue;
    CGFloat _maximumValue;
    UIColor *_maximumTrackTintColor;
    UIColor *_minimumTrackTintColor;
    UIColor *_thumbTintColor;
    CGFloat _focusScaleFactor;
    
    BOOL _isEnabled;
    BOOL _isSelected;
    BOOL _isHighlighted;
    
    KBSliderMode _sliderMode;
    UILabel *durationLabel;
    UILabel *currentTimeLabel;
    NSTimeInterval _currentTime;
    NSTimeInterval _totalDuration;
    NSTimer *_fadeOutTimer;
}

@property CGFloat trackViewHeight;
@property CGFloat thumbSize;
@property NSTimeInterval animationDuration;
@property CGFloat defaultValue;
@property CGFloat defaultMinimumValue;
@property CGFloat defaultMaximumValue;
@property BOOL defaultIsContinuous;
@property UIColor *defaultThumbTintColor;
@property UIColor *defaultTrackColor;
@property UIColor *defaultMininumTrackTintColor;
@property CGFloat defaultFocusScaleFactor;
@property CGFloat defaultStepValue;
@property CGFloat decelerationRate;
@property CGFloat decelerationMaxVelocity;
@property CGFloat fineTunningVelocityThreshold;

@property NSMutableDictionary *thumbViewImages; //[UInt: UIImage] - not an allowed dict type in obj-c
@property UIImageView *thumbView;

@property NSMutableDictionary *trackViewImages; //[UInt: UIImage] - not an allowed dict type in obj-c
@property UIImageView *trackView;

@property NSMutableDictionary *minimumTrackViewImages; //[UInt: UIImage] - not an allowed dict type in obj-c
@property UIImageView *minimumTrackView;

@property NSMutableDictionary *maximumTrackViewImages; //[UInt: UIImage] - not an allowed dict type in obj-c
@property UIImageView *maximumTrackView;

@property UIPanGestureRecognizer *panGestureRecognizer;
@property UITapGestureRecognizer *leftTapGestureRecognizer;
@property UITapGestureRecognizer *rightTapGestureRecognizer;
@property NSLayoutConstraint *thumbViewCenterXConstraint;

@property DPadState dPadState; //.select

@property NSTimer *deceleratingTimer;
@property CGFloat deceleratingVelocity;
@property CGFloat thumbViewCenterXConstraintConstant;

@end

@implementation KBSlider

- (void)initializeDefaults {
    _trackViewHeight = 5;
    _thumbSize = 30;
    _animationDuration = 0.3;
    _defaultValue = 0;
    _defaultMinimumValue = 0;
    _defaultMaximumValue = 1;
    _defaultIsContinuous = true;
    _defaultThumbTintColor = [UIColor whiteColor];
    _defaultTrackColor = [UIColor grayColor];
    _defaultMininumTrackTintColor = [UIColor blueColor];
    _defaultFocusScaleFactor = 1.05;
    _defaultStepValue = 0.1;
    _decelerationRate = 0.92;
    _decelerationMaxVelocity = 1000;
    _fineTunningVelocityThreshold = 600;
    
    _storedValue = _defaultValue;
    _dPadState = DPadStateSelect;
    _isContinuous = _defaultIsContinuous;
    
    _minimumTrackViewImages = [NSMutableDictionary new];
    _maximumTrackViewImages = [NSMutableDictionary new];
    _trackViewImages = [NSMutableDictionary new];
    _thumbViewImages = [NSMutableDictionary new];
    
    _thumbTintColor = _defaultThumbTintColor;
    _minimumTrackTintColor = _defaultMininumTrackTintColor;
    _focusScaleFactor = _defaultFocusScaleFactor;
    _minimumValue = _defaultMinimumValue;
    _maximumValue = _defaultMaximumValue;
    _stepValue = _defaultStepValue;
    [self setEnabled:true];
    
}

#pragma mark KBSliderModeTransport exclusives

- (void)_startFadeOutTimer {
    [self stopFadeOutTimer];
    _fadeOutTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:false block:^(NSTimer * _Nonnull timer) {
        [self fadeOut];
    }];
}

- (void)stopFadeOutTimer {
    if (_fadeOutTimer){
        [_fadeOutTimer invalidate];
        _fadeOutTimer = nil;
    }
}

//the views we need to show or hide as necessary
- (NSArray *)_viewsToAdjust {
    if (!self.thumbView){
        return nil;
    }
    if (self.sliderMode == KBSliderModeTransport){
        return @[self.thumbView, self.trackView, self.minimumTrackView, self.maximumTrackView, durationLabel, currentTimeLabel];
    } else {
        return @[self.thumbView, self.trackView, self.minimumTrackView, self.maximumTrackView];
    }
}

- (BOOL)_isVisible {
    NSArray *_views = [self _viewsToAdjust];
    if (_views.count >0){
        UIView *first = [_views lastObject];
        return first.alpha == 1.0;
    }
    return false;
}

- (void)_toggleVisibleViews:(BOOL)hide {
    [[self _viewsToAdjust] enumerateObjectsUsingBlock:^(UIView  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (hide){
            obj.alpha = 0;
        } else {
            obj.alpha = 1;
        }
    }];
}

- (void)fadeOut {
    [UIView animateWithDuration:3.0 animations:^{
        [self _toggleVisibleViews:true];
    }];
}

- (void)fadeIn {
    [UIView animateWithDuration:0.1 animations:^{
        [self _toggleVisibleViews:false];
        [self _startFadeOutTimer];
    }];
}

- (void)_updateFormatters {
    if (self.sliderMode == KBSliderModeDefault) return;
    if (self.currentTime >= 3600){
        [KBSlider elapsedTimeFormatter].allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    } else {
        [KBSlider elapsedTimeFormatter].allowedUnits =  NSCalendarUnitMinute | NSCalendarUnitSecond;
    }
    if (fabs(self.remainingTime) >= 3600){
        [KBSlider sharedTimeFormatter].allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    } else {
        [KBSlider sharedTimeFormatter].allowedUnits =  NSCalendarUnitMinute | NSCalendarUnitSecond;
    }
}

+ (NSDateComponentsFormatter *)elapsedTimeFormatter {
    static dispatch_once_t minOnceToken;
    static NSDateComponentsFormatter *elapsedTimer = nil;
    if(elapsedTimer == nil) {
        dispatch_once(&minOnceToken, ^{
            elapsedTimer = [[NSDateComponentsFormatter alloc] init];
            elapsedTimer.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
            elapsedTimer.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
            elapsedTimer.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        });
    }
    return elapsedTimer;
}

+ (NSDateComponentsFormatter *)sharedTimeFormatter {
    static dispatch_once_t minOnceToken;
    static NSDateComponentsFormatter *sharedTime = nil;
    if(sharedTime == nil) {
        dispatch_once(&minOnceToken, ^{
            sharedTime = [[NSDateComponentsFormatter alloc] init];
            sharedTime.unitsStyle = NSDateComponentsFormatterUnitsStylePositional;
            sharedTime.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorPad;
            sharedTime.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        });
    }
    return sharedTime;
}

- (NSTimeInterval)remainingTime {
    return -(self.totalDuration - self.currentTime);
}

- (NSString *)remainingTimeFormatted {
    return [[KBSlider sharedTimeFormatter] stringFromTimeInterval:self.remainingTime];
}


- (NSString *)elapsedTimeFormatted {
    return [[KBSlider elapsedTimeFormatter] stringFromTimeInterval:self.currentTime];
}

- (NSTimeInterval)totalDuration {
    return _totalDuration;
}

- (void)setTotalDuration:(NSTimeInterval)totalDuration {
    _totalDuration = totalDuration;
    [self setMaximumValue:totalDuration];
    [self _updateFormatters];
    if (durationLabel){
        durationLabel.text = [self remainingTimeFormatted];
    }
}

- (NSTimeInterval)currentTime {
    return _currentTime;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    _currentTime = currentTime;
    [self setValue:currentTime];
    [self _updateFormatters];
    if (currentTimeLabel){
        currentTimeLabel.text = [self elapsedTimeFormatted];
    }
    if (durationLabel){
        durationLabel.text = [self remainingTimeFormatted];
    }
    if (CGRectIntersectsRect(durationLabel.frame, currentTimeLabel.frame)){
        durationLabel.alpha = 0.0;
    } else {
        if ([self _isVisible]){
            durationLabel.alpha = 1.0;
        }
    }
}

#pragma mark End KBSliderModeTransport exclusive

- (KBSliderMode)sliderMode {
    return _sliderMode;
}

- (void)setSliderMode:(KBSliderMode)sliderMode {
    _sliderMode = sliderMode;
    [self setUpThumbView];
    [self setUpThumbViewConstraints];
    [self updateStateDependantViews];
    if (sliderMode == KBSliderModeDefault){
        [self fadeInIfNecessary];
        [self stopFadeOutTimer];
        self.stepValue = _defaultStepValue;
        self.focusScaleFactor = _defaultFocusScaleFactor;
    } else {
        self.focusScaleFactor = 1.0;
        self.stepValue = 10;
    }
}

- (void)setSelected:(BOOL)selected {
    _isSelected = selected;
    [self updateStateDependantViews];
}

- (BOOL)isSelected {
    return _isSelected;
}

- (void)setHighlighted:(BOOL)highlighted {
    _isHighlighted = highlighted;
    [self updateStateDependantViews];
}

- (BOOL)isHighlighted {
    return _isHighlighted;
}

- (void)setEnabled:(BOOL)enabled {
    _isEnabled = enabled;
    _panGestureRecognizer.enabled = enabled;
    [self updateStateDependantViews];
}

- (BOOL)isEnabled {
    return _isEnabled;
}


- (CGFloat)value {
    return _storedValue;
}

- (void)setValue:(CGFloat)newValue {
    _storedValue = MIN(_maximumValue, newValue);
    _storedValue = MAX(_minimumValue, _storedValue);
    CGFloat offset = _trackView.bounds.size.width * (_storedValue - _minimumValue) / (_maximumValue - _minimumValue);
    offset = MIN(_trackView.bounds.size.width, offset);
    if(isnan(offset)){
        return;
    }
    //NSLog(@"[KBSlider] attempting to set offset value: %f", offset);
    _thumbViewCenterXConstraint.constant = offset;
}

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    [super pressesEnded:presses withEvent:event];
    for (UIPress *item in presses) {
        //KBSLog(@"pressedEnded type: %ld", item.type);
        if (item.type == UIPressTypeSelect){
        }
        
    }
}

- (CGFloat)maximumValue {
    return _maximumValue;
}

- (void)setMaximumValue:(CGFloat)maximumValue {
    _maximumValue = maximumValue;
    [self setValue:MIN(self.value, maximumValue)];
}

- (CGFloat)minimumValue {
    return _minimumValue;
}

- (void)setMinimumValue:(CGFloat)minimumValue {
    _minimumValue = minimumValue;
    [self setValue:MAX(self.value, minimumValue)];
}

- (UIColor *)maximumTrackTintColor {
    return _maximumTrackTintColor;
}

- (void)setMaximumTrackTintColor:(UIColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    _maximumTrackView.backgroundColor = maximumTrackTintColor;
}

- (void)setMinimumTrackTintColor:(UIColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    _minimumTrackView.backgroundColor = minimumTrackTintColor;
}

- (UIColor *)thumbTintColor {
    return _thumbTintColor;
}

- (void)setThumbTintColor:(UIColor *)thumbTintColor {
    _thumbTintColor = thumbTintColor;
    _thumbView.backgroundColor = thumbTintColor;
}

- (UIColor *)minimumTrackTintColor {
    return _minimumTrackTintColor;
}

- (CGFloat)focusScaleFactor {
    return _focusScaleFactor;
}

- (void)setFocusScaleFactor:(CGFloat)focusScaleFactor {
    _focusScaleFactor = focusScaleFactor;
    [self updateStateDependantViews];
}

- (void)setupView {
    
    [self initializeDefaults];
    [self setUpTrackView];
    [self setUpMinimumTrackView];
    [self setUpMaximumTrackView];
    [self setUpThumbView];
    
    [self setUpTrackViewConstraints];
    [self setUpMinimumTrackViewConstraints];
    [self setUpMaximumTrackViewConstraints];
    [self setUpThumbViewConstraints];
    
    [self setUpGestures];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerConnected:) name:GCControllerDidConnectNotification object:nil];
    [self updateStateDependantViews];
}

- (void)setValue:(CGFloat)value animated:(BOOL)animated {
    [self setValue:value];
    [self stopDeceleratingTimer];
    if (animated){
        [UIView animateWithDuration:self.animationDuration animations:^{
            [self setNeedsLayout];
            [self layoutIfNeeded];
        }];
    }
}

- (void)setMinimumTrackImage:(UIImage *)image forState:(UIControlState)state {
    _minimumTrackViewImages[[NSNumber numberWithUnsignedInteger:state]] = image;
    [self updateStateDependantViews];
}

- (void)setMaximumTrackImage:(UIImage *)image forState:(UIControlState)state {
    _maximumTrackViewImages[[NSNumber numberWithUnsignedInteger:state]] = image;
    [self updateStateDependantViews];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    _thumbViewImages[[NSNumber numberWithUnsignedInteger:state]] = image;
    [self updateStateDependantViews];
}


- (UIImage *)currentThumbImage {
    return _thumbView.image;
}

- (UIImage *)minimumTrackImageForState:(UIControlState)state {
    NSNumber *key = [NSNumber numberWithUnsignedInteger:state];
    return _minimumTrackViewImages[key];
    
}

- (UIImage *)maximumTrackImageForState:(UIControlState)state {
    NSNumber *key = [NSNumber numberWithUnsignedInteger:state];
    return _maximumTrackViewImages[key];
}

- (UIImage *)thumbImageForState:(UIControlState)state {
    NSNumber *key = [NSNumber numberWithUnsignedInteger:state];
    return _thumbViewImages[key];
}

- (void)setUpThumbView {
    if (_thumbView){
        [_thumbView removeFromSuperview];
        _thumbView = nil;
    }
    _thumbView = [UIImageView new];
    _thumbView.backgroundColor = _thumbTintColor;
    [self addSubview:_thumbView];
    if (self.sliderMode != KBSliderModeTransport){ //don't want to make transport
        _thumbView.layer.cornerRadius = _thumbSize/2;
        [self removeTransportViewsIfNecessary];
    } else {
        [self setUpTransportViews];
    }
}

- (void)removeTransportViewsIfNecessary {
    if (currentTimeLabel){
        [currentTimeLabel removeFromSuperview];
        currentTimeLabel = nil;
    }
    if (durationLabel){
        [durationLabel removeFromSuperview];
        durationLabel = nil;
    }
}

- (void)setUpTransportViews {
    
    [self removeTransportViewsIfNecessary];
    currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:currentTimeLabel];
    durationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    durationLabel.translatesAutoresizingMaskIntoConstraints = false;
    [self addSubview:durationLabel];
    durationLabel.textAlignment = NSTextAlignmentCenter;
    [currentTimeLabel.centerXAnchor constraintEqualToAnchor:self.thumbView.centerXAnchor].active = true;
    [currentTimeLabel.topAnchor constraintEqualToAnchor:self.thumbView.bottomAnchor constant:5].active = true;
    currentTimeLabel.text = [self elapsedTimeFormatted];
    [durationLabel.topAnchor constraintEqualToAnchor:self.thumbView.bottomAnchor constant:5].active = true;
    [durationLabel.trailingAnchor constraintEqualToAnchor:self.trackView.trailingAnchor].active = true;
    durationLabel.text = [NSString stringWithFormat:@"%.0f", _totalDuration];
}

- (void)setUpTrackView {
    _trackView = [UIImageView new];
    _trackView.layer.cornerRadius = _trackViewHeight/2;
    _trackView.backgroundColor = _defaultTrackColor;
    [self addSubview:_trackView];
}

- (void)setUpMinimumTrackView {
    _minimumTrackView = [UIImageView new];
    _minimumTrackView.layer.cornerRadius = _trackViewHeight/2;
    _minimumTrackView.backgroundColor = _minimumTrackTintColor;
    [self addSubview:_minimumTrackView];
}

- (void)setUpMaximumTrackView {
    _maximumTrackView = [UIImageView new];
    _maximumTrackView.layer.cornerRadius = _trackViewHeight/2;
    _maximumTrackView.backgroundColor = _maximumTrackTintColor;
    [self addSubview:_maximumTrackView];
}


- (void)setUpTrackViewConstraints {
    _trackView.translatesAutoresizingMaskIntoConstraints = false;
    [_trackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = true;
    [_trackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = true;
    [_trackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = true;
    [_trackView.heightAnchor constraintEqualToConstant:_trackViewHeight].active = true;
    
}

- (void)setUpMinimumTrackViewConstraints {
    _minimumTrackView.translatesAutoresizingMaskIntoConstraints = false;
    [_minimumTrackView.leadingAnchor constraintEqualToAnchor:_trackView.leadingAnchor].active = true;
    [_minimumTrackView.trailingAnchor constraintEqualToAnchor:_thumbView.centerXAnchor].active = true;
    [_minimumTrackView.centerYAnchor constraintEqualToAnchor:_trackView.centerYAnchor].active = true;
    [_minimumTrackView.heightAnchor constraintEqualToConstant:_trackViewHeight].active = true;
    
}

- (void)setUpMaximumTrackViewConstraints {
    _maximumTrackView.translatesAutoresizingMaskIntoConstraints = false;
    [_maximumTrackView.leadingAnchor constraintEqualToAnchor:_thumbView.centerXAnchor].active = true;
    [_maximumTrackView.trailingAnchor constraintEqualToAnchor:_trackView.trailingAnchor].active = true;
    [_maximumTrackView.centerYAnchor constraintEqualToAnchor:_trackView.centerYAnchor].active = true;
    [_maximumTrackView.heightAnchor constraintEqualToConstant:_trackViewHeight].active = true;
    
}

- (void)setUpThumbViewConstraints {
    _thumbView.translatesAutoresizingMaskIntoConstraints = false;
    [_thumbView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = true;
    if (_sliderMode == KBSliderModeTransport){
        [_thumbView.heightAnchor constraintEqualToConstant:30].active = true;
        [_thumbView.widthAnchor constraintEqualToConstant:1].active = true;
    } else {
        [_thumbView.heightAnchor constraintEqualToConstant:_thumbSize].active = true;
        [_thumbView.widthAnchor constraintEqualToConstant:_thumbSize].active = true;
    }
    _thumbViewCenterXConstraint = [_thumbView.centerXAnchor constraintEqualToAnchor:_trackView.leadingAnchor constant:self.value];
    _thumbViewCenterXConstraint.active = true;
}

- (void)setUpGestures {
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureWasTriggered:)];
    [self addGestureRecognizer:_panGestureRecognizer];
    
    _leftTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTapWasTriggered)];
    _leftTapGestureRecognizer.allowedPressTypes = @[@(UIPressTypeLeftArrow)];
    _leftTapGestureRecognizer.allowedTouchTypes = @[@(UITouchTypeIndirect)];
    [self addGestureRecognizer:_leftTapGestureRecognizer];
    
    _rightTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightTapWasTriggered)];
    _rightTapGestureRecognizer.allowedPressTypes = @[@(UIPressTypeRightArrow)];
    _rightTapGestureRecognizer.allowedTouchTypes = @[@(UITouchTypeIndirect)];
    [self addGestureRecognizer:_rightTapGestureRecognizer];
}

- (void)updateStateDependantViews {
    
    UIImage *currentMinImage = _minimumTrackViewImages[[NSNumber numberWithUnsignedInteger:self.state]];
    _minimumTrackView.image = currentMinImage ? currentMinImage : _minimumTrackViewImages[[NSNumber numberWithUnsignedInteger:UIControlStateNormal]];
    UIImage *currentMaxImage = _maximumTrackViewImages[[NSNumber numberWithUnsignedInteger:self.state]];
    _maximumTrackView.image = currentMaxImage ? currentMaxImage : _maximumTrackViewImages[[NSNumber numberWithUnsignedInteger:UIControlStateNormal]];
    UIImage *currentThumbImage = _thumbViewImages[[NSNumber numberWithUnsignedInteger:self.state]];
    _thumbView.image = currentThumbImage ? currentThumbImage : _thumbViewImages[[NSNumber numberWithUnsignedInteger:UIControlStateNormal]];
    
    if ([self isFocused]){
        self.transform = CGAffineTransformMakeScale(_focusScaleFactor, _focusScaleFactor);
    } else {
        self.transform = CGAffineTransformIdentity;
    }
    if (self.sliderMode == KBSliderModeTransport){
        if ([self _isVisible]){
            [self _startFadeOutTimer];
        }
    }
    
}

- (void)controllerConnected:(NSNotification *)n {
    GCController *controller = [n object];
    GCMicroGamepad *micro = [controller microGamepad];
    if (!micro)return;
    
    CGFloat threshold = 0.7;
    micro.reportsAbsoluteDpadValues = true;
    micro.dpad.valueChangedHandler = ^(GCControllerDirectionPad * _Nonnull dpad, float xValue, float yValue) {
        if (xValue < -threshold){
            self.dPadState = DPadStateLeft;
        } else if (xValue > threshold){
            self.dPadState = DPadStateRight;
        } else {
            self.dPadState = DPadStateSelect;
        }
    };
}

- (void)handleDeceleratingTimer:(NSTimer *)timer {
    
    CGFloat centerX = _thumbViewCenterXConstraintConstant + _deceleratingVelocity * 0.01;
    CGFloat percent = centerX / (_trackView.frame.size.width);
    CGFloat newValue = _minimumValue + ((_maximumValue - _minimumValue) * percent);
    [self setValue:newValue];
    if ([self isContinuous]){
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    _thumbViewCenterXConstraintConstant = _thumbViewCenterXConstraint.constant;
    
    _deceleratingVelocity *= _decelerationRate;
    if (![self isFocused] || fabs(_deceleratingVelocity) < 1){
        [self stopDeceleratingTimer];
    }
}

- (void)stopDeceleratingTimer {
    [_deceleratingTimer invalidate];
    _deceleratingTimer = nil;
    _deceleratingVelocity = 0;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (BOOL)isVerticalGesture:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self];
    if (fabs(translation.y) > fabs(translation.x)) {
        return true;
    }
    return false;
}

#pragma mark - Actions

- (void)panGestureWasTriggered:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    if (self.sliderMode == KBSliderModeTransport){
        if (![self _isVisible]){
            [self fadeIn];
        }
    }
    if ([self isVerticalGesture:panGestureRecognizer]){
        return;
    }
    CGFloat translation = [panGestureRecognizer translationInView:self].x;
    CGFloat velocity = [panGestureRecognizer velocityInView:self].x;
    switch(panGestureRecognizer.state){
        case UIGestureRecognizerStateBegan:
            [self stopDeceleratingTimer];
            _thumbViewCenterXConstraintConstant = _thumbViewCenterXConstraint.constant;
            break;
            
        case UIGestureRecognizerStateChanged:{
            CGFloat centerX = _thumbViewCenterXConstraintConstant + translation / 5;
            CGFloat percent = centerX / _trackView.frame.size.width;
            CGFloat newValue = _minimumValue + ((_maximumValue - _minimumValue) * percent);
            [self setValue:newValue];
            if ([self isContinuous]){
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            _thumbViewCenterXConstraintConstant = _thumbViewCenterXConstraint.constant;
            if (fabs(velocity) > _fineTunningVelocityThreshold){
                CGFloat direction = velocity > 0 ? 1 : -1;
                _deceleratingVelocity = fabs(velocity) > _decelerationMaxVelocity ? _decelerationMaxVelocity * direction : velocity;
                _deceleratingTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(handleDeceleratingTimer:) userInfo:nil repeats:true];
            } else {
                [self stopDeceleratingTimer];
            }
            break;
            
        default:
            break;
            
    }
}

- (void)leftTapWasTriggered {
    
    CGFloat newValue = [self value]-_stepValue;
    [self setCurrentTime:newValue];
    [self setValue:newValue animated:true];
    [self fadeInIfNecessary];
}

- (void)fadeInIfNecessary {
    if (self.sliderMode == KBSliderModeTransport){
        if (![self _isVisible]){
            [self fadeIn];
        }
    } else {
        if (![self _isVisible]){
            [self fadeIn];
        }
    }
}

- (void)rightTapWasTriggered {
    CGFloat newValue = [self value]+_stepValue;
    [self setCurrentTime:newValue];
    [self setValue:newValue animated:true];
    [self fadeInIfNecessary];
}

- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    [self fadeInIfNecessary];
    for (UIPress *press in presses){
        switch (press.type) {
            case UIPressTypeSelect:
                if(_dPadState == DPadStateLeft){
                    _panGestureRecognizer.enabled = false;
                    [self leftTapWasTriggered];
                } else if (_dPadState == DPadStateRight){
                    _panGestureRecognizer.enabled = false;
                    [self rightTapWasTriggered];
                } else {
                    _panGestureRecognizer.enabled = false;
                }
                break;
            default:
                break;
        }
    }
    _panGestureRecognizer.enabled = true;
    [super pressesBegan:presses withEvent:event];
}



- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    [coordinator addCoordinatedAnimations:^{
        [self updateStateDependantViews];
    } completion:nil];
}

#pragma mark - Initializers

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    [self setupView];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setupView];
    return self;
}

- (id)init {
    self = [super init];
    [self setupView];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
