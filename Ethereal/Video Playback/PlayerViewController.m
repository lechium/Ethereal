//
//  PlayerViewController.m
//  AVPlayerDemo
//
//  Created by apple on 15/12/5.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "PlayerViewController.h"
#import "ViewController.h"
#import "KBSlider.h"
#import "KBVideoPlaybackManager.h"
#import "KBAVInfoViewController.h"
#import "SDWebImageManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "KBSliderImages.h"
#import "UIView+AL.h"
#import "KBBulletinView.h"

@import tvOSAVPlayerTouch;

@interface PlayerViewController () <FFAVPlayerControllerDelegate> {
    BOOL _ffActive;
    BOOL _rwActive;
    NSTimer *_rightHoldTimer;
    NSTimer *_leftHoldTimer;
    NSTimer *_rewindTimer;
    NSTimer *_ffTimer;
    //UIPress *_ignorePress;
}

@property UIPress *ignorePress;
@property KBSlider *transportSlider;
@property KBButton *subtitleButton;
@property BOOL wasPlaying; //keeps track if we were playing when scrubbing started
@property KBAVInfoViewController *avInfoViewController;

@end

@implementation PlayerViewController {
    FFAVPlayerController <KBVideoPlayerProtocol> *_avplayController;
    UIView *_glView;
    NSURL *_mediaURL;
}


- (BOOL)avInfoPanelShowing {
    if (self.avInfoViewController.infoStyle == KBAVInfoStyleNew) {
        return self.transportSlider.frame.origin.y == 550;
    }
    return self.avInfoViewController.view.alpha;
}

- (FFAVPlayerController *)avPlayController {
    return _avplayController;
}

- (void)hideAVInfoView {
    if (!self.avInfoPanelShowing) return;
    if (_avInfoViewController.infoStyle == KBAVInfoStyleNew) {
        [self slideDownInfo];
        return;
    }
    [_avInfoViewController closeWithCompletion:^{
        self.transportSlider.userInteractionEnabled = true;
        self.transportSlider.hidden = false; //likely frivolous
    }];
}

- (void)slideDownInfo {
    [_transportSlider fadeIn];
    _transportSlider.fadeOutTransport = true;
    [self.view layoutIfNeeded];
    @weakify(self);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self_weak_.transportSlider.frame = CGRectMake(100, 850, 1700, 105);
        [self_weak_.view layoutIfNeeded];
    } completion:nil];
}


- (void)slideUpInfo {
    _transportSlider.fadeOutTransport = false;
    [_transportSlider hideSliderOnly];
    [self.view layoutIfNeeded];
    @weakify(self);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self_weak_.transportSlider.frame = CGRectMake(100, 550, 1700, 105);
        [self_weak_.view layoutIfNeeded];
    } completion:nil];
}

- (void)showAVInfoView {
    if (self.avInfoPanelShowing) return;
    if (!_avInfoViewController){
        _avInfoViewController = [KBAVInfoViewController new];
        [self createAndSetMeta];
    }
    if (_avInfoViewController.infoStyle == KBAVInfoStyleNew) {
        [self slideUpInfo];
        return;
    }
    self.transportSlider.userInteractionEnabled = false;
    [self.transportSlider hideSliderAnimated:true];
    [_avInfoViewController showFromViewController:self];
}
- (void)setMediaURL:(NSURL *)mediaURL {
    _mediaURL = mediaURL;
    NSMutableDictionary *options = [NSMutableDictionary new];
    
    if (!self.mediaURL.isFileURL) {
        options[AVOptionNameAVProbeSize] = @(256*1024); // 256kb, default is 5Mb
        options[AVOptionNameAVAnalyzeduration] = @(1);  // default is 5 seconds
        options[AVOptionNameHttpUserAgent] = @"Mozilla/5.0";
    }
    
    if (self.avFormatName) {
        options[AVOptionNameAVFormatName] = self.avFormatName;
    }
    
    [self createAVPlayerIfNecessary];
    //  _avplayController.enableBuiltinSubtitleRender = NO;
    BOOL open = [_avplayController openMedia:self.mediaURL withOptions:options];
    if (open) {
        NSLog(@"[Ethereal] opened successfully");
    } else {
        NSLog(@"[Ethereal] failed to load file");
    }
}


- (NSURL *)mediaURL {
    return _mediaURL;
}

- (void)setPlayer:(id<KBVideoPlayerProtocol>)player {
    //no-op for right now, just trying to quiet down warnings.
}

- (id<KBVideoPlayerProtocol>)player {
    return _avplayController;
}
/*
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //NSLog(@"[Ethereal] gestureRecognizerShouldBegin: %@", gestureRecognizer);
    return true;
}
*/
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //NSLog(@"[Ethereal] %@ shouldRecognizeSimultaneouslyWithGestureRecognizer: %@", gestureRecognizer, otherGestureRecognizer);
    if ([gestureRecognizer isKindOfClass:UISwipeGestureRecognizer.class] && [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        //return FALSE;
    }
    return TRUE;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    //NSLog(@"[Ethereal] shouldRequireFailureOfGestureRecognizer: %@", gestureRecognizer);
    if ([gestureRecognizer isKindOfClass:UISwipeGestureRecognizer.class] && [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        //NSLog(@"[Ethereal], fail");
        //return TRUE;
    }
    return FALSE;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer  {
    //NSLog(@"[Ethereal] %@ shouldBeRequiredToFailByGestureRecognizer: %@", gestureRecognizer, otherGestureRecognizer);
    return FALSE;
}
/*
// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //NSLog(@"[Ethereal] shouldReceiveTouch: %@", gestureRecognizer);
    return TRUE;
}
*/
// called before pressesBegan:withEvent: is called on the gesture recognizer for a new press. return NO to prevent the gesture recognizer from seeing this press
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press {
    //NSLog(@"[Ethereal] shouldReceivePress: %@", gestureRecognizer);
    return TRUE;
}
/*
// called once before either -gestureRecognizer:shouldReceiveTouch: or -gestureRecognizer:shouldReceivePress:
// return NO to prevent the gesture recognizer from seeing this event
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveEvent:(UIEvent *)event {
    //NSLog(@"[Ethereal] shouldReceiveEvent: %@", gestureRecognizer);
    return TRUE;
}
*/

- (void)menuTapped:(UITapGestureRecognizer *)gestRecognizer {
    NSLog(@"[Ethereal] menu tapped");
    if (gestRecognizer.state == UIGestureRecognizerStateEnded){
        if ([self avInfoPanelShowing]) {
            [self hideAVInfoView];
        } else {
            [_avplayController pause];
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }
}


//loading order might be weird based on setting the asset URL and viewDidLoad being triggered, initialize as needed.

- (void)createAVPlayerIfNecessary {
    if (!_avplayController) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
        _avplayController = [[FFAVPlayerController alloc] init];
#pragma clang diagnostic pop
        _avplayController.delegate = self;
        _avplayController.allowBackgroundPlayback = YES;
        _avplayController.shouldAutoPlay = YES;
        [_avplayController observeStatus];
        //_avplayController.streamDiscardOption = kAVStreamDiscardOptionSubtitle;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // New and initialize FFAVPlayerController instance to prepare for playback
    [self createAVPlayerIfNecessary];
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    swipeDown.delegate = self;
    [self.view addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    swipeUp.delegate = self;
    [self.view addGestureRecognizer:swipeUp];
    
    UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
    menuTap.numberOfTapsRequired = 1;
    menuTap.allowedPressTypes = @[@(UIPressTypeMenu)];
    [self.view addGestureRecognizer:menuTap];
    
    /*
    UITapGestureRecognizer *leftTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTapHandler:)];
    leftTap.allowedPressTypes = @[@(UIPressTypeLeftArrow)];
    [self.view addGestureRecognizer:leftTap];
    
    UITapGestureRecognizer *rightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightTapHandler:)];
    rightTap.allowedPressTypes = @[@(UIPressTypeRightArrow)];
    [self.view addGestureRecognizer:rightTap];
    
    UILongPressGestureRecognizer *longRightPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightLongPress:)];
    longRightPress.allowedPressTypes = @[@(UIPressTypeRightArrow)];
    [longRightPress requireGestureRecognizerToFail:rightTap];
    [self.view addGestureRecognizer:longRightPress];
    
    UILongPressGestureRecognizer *longLeftPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftLongPress:)];
    longLeftPress.allowedPressTypes = @[@(UIPressTypeLeftArrow)];
    [longLeftPress requireGestureRecognizerToFail:leftTap];
    [self.view addGestureRecognizer:longLeftPress];
    */
    /*
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.allowedPressTypes = @[@(UIPressTypePlayPause)];
    [self.view addGestureRecognizer:doubleTap];
    */
    //[self testRemoteCommandCenterStuff];
}

- (void)doubleTap:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"[Ethereal] double tap");
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        AVRoutePickerView *routerPickerView = [[AVRoutePickerView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        routerPickerView.activeTintColor = [UIColor clearColor];
        routerPickerView.delegate = self;
        [self.view addSubview:routerPickerView];
    }
}


- (void)routePickerViewWillBeginPresentingRoutes:(AVRoutePickerView *)routePickerView {
    NSLog(@"[Ethereal] routePickerViewWillBeginPresentingRoutes");
}
//AirPlay界面结束时回调
- (void)routePickerViewDidEndPresentingRoutes:(AVRoutePickerView *)routePickerView {
    NSLog(@"[Ethereal] routePickerViewDidEndPresentingRoutes");
}

/*
 let remoteCommandCenter = MPRemoteCommandCenter.shared()
 remoteCommandCenter.skipForwardCommand.addTarget(self, action: #selector(skipForwardHandler))
 remoteCommandCenter.skipBackwardCommand.addTarget(self, action: #selector(skipBackwardHandler))
 */

- (MPRemoteCommandHandlerStatus)testSkipForward {
    NSLog(@"[Ethereal] testSkipForward");
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)testSkipBackwards {
    NSLog(@"[Ethereal] testSkipBackwards");
    return MPRemoteCommandHandlerStatusSuccess;
}

- (void)seekForwardTest {
    NSLog(@"[Ethereal] seekForwardTest");
}

- (void)seekBackwardsTest {
    NSLog(@"[Ethereal] seekBackwardsTest");
}



- (void)testRemoteCommandCenterStuff {
    MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];
    [center.skipForwardCommand addTarget:self action:@selector(testSkipForward)];
    [center.skipBackwardCommand addTarget:self action:@selector(testSkipBackwards)];
    [center.seekForwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"[Ethereal] seekForwardTest");
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [center.seekBackwardCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        NSLog(@"[Ethereal] seekBackwardCommand");
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    //[center.seekForwardCommand addTarget:self action:@selector(seekForwardTest)];
    //[center.seekBackwardCommand addTarget:self action:@selector(seekBackwardsTest)];
}

- (void)leftTapHandler:(UITapGestureRecognizer *)gestureRecognizer {
    if (!_transportSlider.isFocused) {
        return;
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (_transportSlider.currentSeekSpeed != KBSeekSpeedNone) {
            KBSeekSpeed speed = [_transportSlider handleSeekingPressType:UIPressTypeLeftArrow];
            if (speed == KBSeekSpeedNone) {
                [_rewindTimer invalidate];
                [_ffTimer invalidate];
            }
        } else {
            [self stepVideoBackwards];
        }
    }
}

- (void)rightTapHandler:(UITapGestureRecognizer *)gestureRecognizer {
    if (!_transportSlider.isFocused) {
        return;
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (_transportSlider.currentSeekSpeed != KBSeekSpeedNone) {
            KBSeekSpeed speed = [_transportSlider handleSeekingPressType:UIPressTypeRightArrow];
            if (speed == KBSeekSpeedNone) {
                [_rewindTimer invalidate];
                [_ffTimer invalidate];
            }
        } else {
            [self stepVideoForwards];
        }
    }
}

- (void)handleRightLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [_ffTimer invalidate];
        [_rewindTimer invalidate];
        [self startFastForwarding];
    }
}

- (void)handleLeftLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [_ffTimer invalidate];
        [_rewindTimer invalidate];
        [self startRewinding];
    }
}


- (void)swipeUp:(UIGestureRecognizer *)gestureRecognizer {
    if (![self.avInfoViewController shouldDismissView]){
        return;
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self hideAVInfoView];
        self.transportSlider.hidden = false;
        self.transportSlider.userInteractionEnabled = true;
    }
}

- (void)swipeDown:(UISwipeGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self showAVInfoView];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[KBVideoPlaybackManager defaultManager] killCurrentPlayer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _wasPlaying = false;
    [self createSliderIfNecessary];
    [self handleSubtitleOptions];
    
}
//- (CGSize)videoFrameSize
- (void)createAndSetMeta {
    CGSize frameSize = [_avplayController videoFrameSize];
    KBMediaAsset *asset = [self currentAsset];
    if (!_avInfoViewController) if (!_avInfoViewController){
        _avInfoViewController = [KBAVInfoViewController new];
    }
    if (asset) {
        KBAVMetaData *meta = [KBAVMetaData new];
        if (frameSize.width >= 1280){
            meta.isHD = true;
        }
        meta.title = asset.name;
        meta.duration = _avplayController.duration;
        meta.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:asset.name];
        [_avInfoViewController setMetadata:meta];
        _transportSlider.title = asset.name;
    }
    [_avInfoViewController setSubtitleData:_avplayController.subtitleTracks];
}

- (void)handleSubtitleOptions {
    _avplayController.enableBuiltinSubtitleRender = [KBAVInfoViewController areSubtitlesAlwaysOn];
}

- (void)createSliderIfNecessary {
    if (!_transportSlider) {
        _transportSlider = [[KBSlider alloc] initWithFrame:CGRectMake(100, 850, 1700, 105)];
        [_transportSlider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)sliderMoved:(KBSlider *)slider {
    BOOL isPlaying = _avplayController.playerState == kAVPlayerStatePlaying;
    slider.isPlaying = isPlaying;
    if (!_wasPlaying) {
        _wasPlaying = isPlaying;
    }
    if (isPlaying) {
        [_avplayController pause];
    }
    //NSLog(@"[Ethereal] slider value: %.02f duration: %f", slider.value, _avplayController.duration);
    if (slider.value < _avplayController.duration) {
        [_avplayController seekto:slider.value];
    }
    if (_wasPlaying) {
        [_avplayController resume];
        _wasPlaying = false;
    }
}

- (void)pressesChanged:(NSSet<UIPress *> *)presses withEvent:(nullable UIPressesEvent *)event {
    [super pressesChanged:presses withEvent:event];
}

- (void)pressesCancelled:(NSSet<UIPress *> *)presses withEvent:(nullable UIPressesEvent *)event {
    for (UIPress *press in presses) {
        switch (press.type){
            case UIPressTypeMenu:
                break;
            default:
                [super pressesCancelled:presses withEvent:event];
        }
    }
}

- (void)stepVideoBackwards {
    self.transportSlider.scrubMode = KBScrubModeSkippingBackwards;
    [self.transportSlider fadeInIfNecessary];
    NSTimeInterval newValue = self.transportSlider.value - 10;
    [_avplayController seekto:newValue];
    @weakify(self);
    [self.transportSlider setValue:newValue animated:false completion:^{
        self_weak_.transportSlider.currentTime = newValue;
        [self_weak_.transportSlider delayedResetScrubMode];
    }];
    
}

- (void)stepVideoForwards {
    self.transportSlider.scrubMode = KBScrubModeSkippingForwards;
    [self.transportSlider fadeInIfNecessary];
    NSTimeInterval newValue = self.transportSlider.value + 10;
    [_avplayController seekto:newValue];
    @weakify(self);
    [self.transportSlider setValue:newValue animated:false completion:^{
        self_weak_.transportSlider.currentTime = newValue;
        [self_weak_.transportSlider delayedResetScrubMode];
    }];
    
}

- (void)startFastForwarding {
    _ffActive = true;
    self.transportSlider.scrubMode = KBScrubModeFastForward;
    self.transportSlider.currentSeekSpeed = KBSeekSpeed1x;
    [self.transportSlider fadeInIfNecessary];
    [_avplayController pause];
    @weakify(self);
    _ffTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:true block:^(NSTimer * _Nonnull timer) {
        NSTimeInterval newValue = self_weak_.transportSlider.value + self_weak_.transportSlider.stepValue;
        self_weak_.transportSlider.value = newValue;
        self_weak_.transportSlider.currentTime = newValue;
    }];
}

- (void)stopFastForwarding {
    _ffActive = false;
    [_ffTimer invalidate];
    [_avplayController seekto:self.transportSlider.value];
    [_avplayController setPlaybackSpeed:1.0];
    [_avplayController resume];
}

- (void)startRewinding {
    _rwActive = true;
    self.transportSlider.scrubMode = KBScrubModeRewind;
    self.transportSlider.currentSeekSpeed = KBSeekSpeed1x;
    [self.transportSlider fadeInIfNecessary];
    [_avplayController pause];
    @weakify(self);
    _rewindTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:true block:^(NSTimer * _Nonnull timer) {
        NSTimeInterval newValue = self.transportSlider.value - self.transportSlider.stepValue;
        self_weak_.transportSlider.value = newValue;
        self_weak_.transportSlider.currentTime = newValue;
    }];
}

- (void)stopRewinding {
    _rwActive = false;
    [_rewindTimer invalidate];
    [_avplayController seekto:self.transportSlider.value];
    [_avplayController setPlaybackSpeed:1.0];
    [_avplayController resume];
}

- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    @weakify(self);
    //NSLog(@"[Ethereal] type: %lu subtype: %lu press count:%lu", event.type, event.subtype, presses.count);
    for (UIPress *press in presses) {
        //NSInteger source = [[press valueForKey:@"source"] integerValue];
        //NSInteger gameControllerComp = [[press valueForKey:@"gameControllerComponent"] integerValue];
        //NSLog(@"[Ethereal] press source: %lu gcc: %lu", source, gameControllerComp);
        switch (press.type){
            case UIPressTypeMenu:
                //[_avplayController pause]; //safer than disposing of it, its a stop gap for now. but its still an improvement.
                break;
                
            case UIPressTypeRightArrow: {
                if (_transportSlider.isFocused) {
                    _rightHoldTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:false block:^(NSTimer * _Nonnull timer) {
                        self_weak_.ignorePress = press;
                        [self_weak_ startFastForwarding];
                    }];
                }
            }
                break;
                
            case UIPressTypeLeftArrow: {
                if (_transportSlider.isFocused) {
                    _leftHoldTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:false block:^(NSTimer * _Nonnull timer) {
                        self_weak_.ignorePress = press;
                        [self_weak_ startRewinding];
                    }];
                }
            }
                 
                
            default:
                [super pressesBegan:presses withEvent:event];
                break;
        }
    }
    
}

- (void)togglePlayPause {
    if (_transportSlider.currentSeekSpeed != KBSeekSpeedNone) {
        [_ffTimer invalidate];
        [_rewindTimer invalidate];
        [_transportSlider seekResume];
        return;
    }
    [_transportSlider setScrubMode:KBScrubModeNone];
    AVPlayerState currentState = _avplayController.playerState;
    if (currentState == kAVPlayerStatePaused) {
        [_avplayController resume];
    } else {
        [_avplayController pause];
    }
}

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    //NSLog(@"[Ethereal] pressesEnded: %@", presses);
    //AVPlayerState currentState = _avplayController.playerState;
    for (UIPress *press in presses) {
        if (press == _ignorePress){
            //NSLog(@"[Ethereal] IGNORE ME!");
            _ignorePress = nil;
            return;
        }
        //NSLog(@"[Ethereal] presstype: %lu", press.type);
        switch (press.type){
                
            case UIPressTypeMenu:
                break;
           
            case UIPressTypeSelect:
                if ([_transportSlider isFocused]){
                    NSLog(@"[Ethereal] togglePlayPause");
                    [self togglePlayPause];
                }
                break;
                
            case UIPressTypePlayPause:
           
                
                //NSLog(@"[Ethereal] play pause");
                [self togglePlayPause];
                break;
            case UIPressTypeUpArrow:
                if ([self.avInfoViewController shouldDismissView]){
                    [self hideAVInfoView]; //need to make this one smarter
                }
                
                break;
                
                
            case UIPressTypeLeftArrow:
                
                if (_transportSlider.isFocused) {
                    NSLog(@"[Ethereal] slider is focused");
                    [_leftHoldTimer invalidate];
                    if (_transportSlider.currentSeekSpeed != KBSeekSpeedNone) {
                        KBSeekSpeed speed = [_transportSlider handleSeekingPressType:UIPressTypeLeftArrow];
                        if (speed == KBSeekSpeedNone) {
                            [_rewindTimer invalidate];
                            [_ffTimer invalidate];
                        }
                    } else {
                        
                        if ([press kb_isSynthetic]){
                            return;
                        }
                        
                        [self stepVideoBackwards];
                    }
                
                }
                break;
                
            case UIPressTypeRightArrow:
                if (_transportSlider.isFocused) {
                    NSLog(@"[Ethereal] slider is focused");
                    [_rightHoldTimer invalidate];
                    if (_transportSlider.currentSeekSpeed != KBSeekSpeedNone) {
                        KBSeekSpeed speed = [_transportSlider handleSeekingPressType:UIPressTypeRightArrow];
                        if (speed == KBSeekSpeedNone) {
                            [_rewindTimer invalidate];
                            [_ffTimer invalidate];
                        }
                    } else {
                        if ([press kb_isSynthetic]){
                            return;
                        }
                        [self stepVideoForwards];
                    }
                }
                break;
                
                
            default:
                NSLog(@"[Ethereal] unhandled type: %lu", press.type);
                [super pressesEnded:presses withEvent:event];
                break;
                
        }
        
    }
}

- (void)upTouch {
    if (_avplayController.playbackSpeed < 2.0) {
        [_avplayController setPlaybackSpeed:_avplayController.playbackSpeed+0.25];
    }
}

- (void)downTouch {
    /*
     if (_avplayController.playbackSpeed > 0.5) {
     [_avplayController setPlaybackSpeed:_avplayController.playbackSpeed-0.25];
     }*/
    //NSLog(@"[Ethereal] go to end");
    [_avplayController seekto:_avplayController.duration];
    //_avplayController.streamDiscardOption = kAVStreamDiscardOptionSubtitle;
}

- (void)forwardDidTouch:(id)sender {
    NSLog(@"[Ethereal] forwardDidTouch");
    if (_avplayController.currentPlaybackTime+10 < _avplayController.duration) {
        [_avplayController seekto:_avplayController.currentPlaybackTime+10];
    }
}

- (void)rewindDidTouch:(id)sender {
    NSLog(@"[Ethereal] rewindDidTouch");
    if (_avplayController.currentPlaybackTime-10 >= 0) {
        [_avplayController seekto:_avplayController.currentPlaybackTime-10];
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    AVPlayerState currentState = _avplayController.playerState;
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                if (currentState == kAVPlayerStatePaused) {
                    [_avplayController resume];
                }
                break;
            case UIEventSubtypeRemoteControlPause:
                if (currentState == kAVPlayerStatePlaying) {
                    [_avplayController pause];
                }
                break;
            case UIEventSubtypeRemoteControlStop:
                _avplayController = nil;
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (currentState == kAVPlayerStatePlaying) {
                    [_avplayController pause];
                } else {
                    [_avplayController resume];
                }
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                // play previous track...
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                // play next track...
                break;
            default:
                break;
        }
    }
}

#pragma mark - FFAVPlayerControllerDelegate

- (void)FFAVPlayerControllerWillLoad:(FFAVPlayerController *)controller {
    NSLog(@"[Ethereal] Loading av resource...");
}

- (void)FFAVPlayerControllerDidLoad:(FFAVPlayerController *)controller error:(NSError *)error {
    if (error) {
        NSLog(@"[Ethereal] Unable to load av resource!");
    } else {
        NSLog(@"[Ethereal] Loaded av resource!");
    }
    
    if (!error) {
        if ([_avplayController hasVideo]) {
            _glView = [_avplayController drawableView];
            _glView.frame = self.view.bounds;
            _glView.autoresizingMask =
            UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view insertSubview:_glView atIndex:0];
            [self createSliderIfNecessary];
            [_glView addSubview:_transportSlider];
            _avInfoViewController = [KBAVInfoViewController new];
            [self createAndSetMeta];
            _avInfoViewController.infoStyle = KBAVInfoStyleNew;
            [_avInfoViewController attachToView:_transportSlider inController:self];
            [_transportSlider setSliderMode:KBSliderModeTransport];
            [_transportSlider setCurrentTime:0];
            _transportSlider.fadeOutTransport = true;
            [_transportSlider setIsContinuous:false];
            NSLog(@"[Ethereal] total duration: %f", _avplayController.duration);
            [_transportSlider setTotalDuration:_avplayController.duration];
            [_transportSlider setAvPlayer:self.player];
            
            _subtitleButton = [KBButton buttonWithType:KBButtonTypeImage];
            _subtitleButton.buttonImageView.image = [KBSliderImages captionsImage];
            _subtitleButton.alpha = 0;
            [_subtitleButton autoConstrainToSize:CGSizeMake(68, 68)];
            [_glView addSubview:_subtitleButton];
            [self updateSubtitleButtonState];
            [_subtitleButton.bottomAnchor constraintEqualToAnchor:_transportSlider.topAnchor constant:60].active = true;
            [_subtitleButton.trailingAnchor constraintEqualToAnchor:_transportSlider.trailingAnchor].active = true;
            _subtitleButton.layer.masksToBounds = true;
            _subtitleButton.layer.cornerRadius = 68/2;
            [_subtitleButton addTarget:self action:@selector(subtitleButtonClicked) forControlEvents:UIControlEventPrimaryActionTriggered];
            
            @weakify(self);
            
            _transportSlider.sliderFading = ^(CGFloat direction, BOOL animated) {
                if (animated) {
                    [UIView animateWithDuration:0.3 animations:^{
                        self_weak_.subtitleButton.alpha = direction;
                    } completion:^(BOOL finished) {
                        if (direction == 0) {
                            if ([self_weak_.subtitleButton isFocused]){
                                [self_weak_ setNeedsFocusUpdate];
                            }
                        }
                    }];
                } else {
                    self_weak_.subtitleButton.alpha = direction;
                }
            };
            
            _transportSlider.timeSelectedBlock = ^(CGFloat currentTime) {
                if (currentTime < self_weak_.avPlayController.duration) {
                    [self_weak_.avPlayController seekto:currentTime];
                }
            };
            _transportSlider.scanStartedBlock = ^(CGFloat currentTime, KBSeekDirection direction) {
                if (direction == KBSeekDirectionRewind){
                    [self_weak_ startRewinding];
                } else if (direction == KBSeekDirectionFastForward) {
                    [self_weak_ startFastForwarding];
                }
            };
            
            _transportSlider.scanEndedBlock = ^(KBSeekDirection direction) {
                if (direction == KBSeekDirectionRewind){
                    [self_weak_ stopRewinding];
                } else if (direction == KBSeekDirectionFastForward) {
                    [self_weak_ stopFastForwarding];
                }
            };
            NSLog(@"setting maximum value to duration: %f",_avplayController.duration);
            
            _transportSlider.stepVideoBlock = ^(KBStepDirection direction) {
                if (direction == KBStepDirectionForwards){
                    [self_weak_ stepVideoForwards];
                } else if (direction == KBStepDirectionBackwards){
                    [self_weak_ stepVideoBackwards];
                }
            };
            

            _avInfoViewController.infoFocusChanged = ^(BOOL focused, UIFocusHeading direction) {
                if (focused) {
                    BOOL contains = (direction & UIFocusHeadingDown) != 0;
                    if (contains) {
                        if (![self_weak_ avInfoPanelShowing]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self_weak_ showAVInfoView];
                            });
                        }
                    } else {
                        [self_weak_ setNeedsFocusUpdate];
                    }
                }
            };
            
            
        }
    } else {
        NSLog(@"[Ethereal] Failed to load video!");
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"The video failed to load!" message:[NSString stringWithFormat:@"The video failed to load with error: %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:ac animated:true completion:nil];
    }
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    [super didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
    if ([self avInfoPanelShowing]) {
        if ([self.transportSlider isFocused]) {
            [self hideAVInfoView];
        }
    }
}

- (void)showSubtitleBulletin {
    BOOL subtitlesOn = [self subtitlesOn];
    NSString *title = @"Subtitles On";
    if (!subtitlesOn) title =  @"Subtitles Off";
    KBBulletinView *bv = [KBBulletinView bulletinWithTitle:title description:nil image:[UIImage imageNamed:@"App Icon"]];
    [bv showForTime:5];
}

- (void)subtitleButtonClicked {
    FFAVPlayerController *player = (FFAVPlayerController*)[self player];
    if ([player respondsToSelector:@selector(switchSubtitleStream:)]){
        if ([player enableBuiltinSubtitleRender]) {
            [player setEnableBuiltinSubtitleRender:false];
        } else {
            [player setEnableBuiltinSubtitleRender:true];
            [player switchSubtitleStream:0];
        }
    }
    [self updateSubtitleButtonState];
    [self showSubtitleBulletin];
}

- (BOOL)subtitlesOn {
    FFAVPlayerController *player = (FFAVPlayerController*)[self player];
    return [player enableBuiltinSubtitleRender];
}

- (void)updateSubtitleButtonState {
    if ([self subtitlesOn]) {
        self.subtitleButton.buttonImageView.alpha = 1.0;
    } else {
        self.subtitleButton.buttonImageView.alpha = 0.5;
    }
}

- (NSArray *) preferredFocusEnvironments {
    if ([self avInfoPanelShowing]) {
        return @[_avInfoViewController.tempTabBar, self.transportSlider];
    }
    return @[self.transportSlider];
}

// AVPlayer state was changed
- (void)FFAVPlayerControllerDidStateChange:(FFAVPlayerController *)controller {
    AVPlayerState state = [controller playerState];
    if (state == kAVPlayerStatePlaying){
        self.transportSlider.isPlaying = true;
    } else {
        self.transportSlider.isPlaying = false;
    }
    if (state == kAVPlayerStateFinishedPlayback) {
        
        // For local media file source
        // If playback reached to end, we return to begin of the media file,
        // and pause the player to prepare for next playback.
        
        if ([self.mediaURL isFileURL]) {
            //[controller seekto:0];
            //[controller pause];
            //[self dismissViewControllerAnimated:true completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:AVPlayerItemDidPlayToEndTimeNotification object:self];
        }
    }
}

// AVPlayer current play time was changed
- (void)FFAVPlayerControllerDidCurTimeChange:(FFAVPlayerController *)controller
                                    position:(NSTimeInterval)position {
    self.transportSlider.currentTime = position;
}

// AVPlayer current subtitle item was changed
- (void)FFAVPlayerControllerDidSubtitleChange:(FFAVPlayerController *)controller
                                 subtitleItem:(FFAVSubtitleItem *)subtitleItem {
    NSLog(@"[Ethereal] %@", subtitleItem);
}

// Enter or exit full screen mode
- (void)FFAVPlayerControllerDidEnterFullscreenMode:
(FFAVPlayerController *)controller {
    // Update full screen bar button
}

- (void)FFAVPlayerControllerDidExitFullscreenMode:
(FFAVPlayerController *)controller {
    // Update full screen bar button
}

- (void)FFAVPlayerControllerDidBufferingProgressChange:(FFAVPlayerController *)controller progress:(double)progress {
    // Log the buffering progress info
    //NSLog(@"[Ethereal] >>> BUFFERING : %.3f%%", progress);
}

- (void)FFAVPlayerControllerDidBitrateChange:(FFAVPlayerController *)controller bitrate:(NSInteger)bitrate {
    // Log the bitrate info
    //NSLog(@"[Ethereal] bitrate : %ld Kbits/s", bitrate);
}

@end
