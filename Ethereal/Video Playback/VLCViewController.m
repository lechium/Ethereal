//
//  VLCViewController.m
//  Ethereal
//
//  Created by kevinbradley on 2/18/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import "VLCViewController.h"
#import "KBSlider.h"
#import "KBButton.h"
#import "KBAVInfoViewController.h"
#import "VLCMediaPlayer+ProtocolCompliance.h"
#import <TVVLCKit/TVVLCKit.h>
#import "KBMediaAsset.h"
#import "SDWebImageManager.h"
#import "KBSliderImages.h"
#import "UIView+AL.h"
#import "KBBulletinView.h"

@interface VLCViewController () {
    NSURL *_mediaURL;
    BOOL _ffActive;
    BOOL _rwActive;
    NSTimer *_rightHoldTimer;
    NSTimer *_leftHoldTimer;
    NSTimer *_rewindTimer;
    NSTimer *_ffTimer;
    BOOL _setMeta;
}
@property UIView *videoView;
@property VLCMediaPlayer *mediaPlayer;

@property KBSlider *transportSlider;
@property KBButton *subtitleButton;
@property BOOL wasPlaying; //keeps track if we were playing when scrubbing started
@property KBAVInfoViewController *avInfoViewController;
@property UITapGestureRecognizer *leftTap;
@property UITapGestureRecognizer *rightTap;
@end

@implementation VLCViewController

- (id)player {
    return _mediaPlayer;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_mediaURL) {
        [_mediaPlayer play];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeChanged:) name:VLCMediaPlayerTimeChanged object:nil];
    [self handleSubtitleOptions];
    [self updateSubtitleButtonState];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChanged:) name:VLCMediaPlayerStateChanged object:nil];
    //[_mediaPlayer play];
}

- (void)stateChanged:(NSNotification *)n {
    //NSLog(@"[Ethereal] state changed: %@", n);
    VLCMediaPlayerState state = [(VLCMediaPlayer *)[n object] state];
    if (state == VLCMediaPlayerStateEnded) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AVPlayerItemDidPlayToEndTimeNotification object:self];
        _setMeta = false;
    }
}

- (void)handleSubtitleOptions {
    //_avplayController.enableBuiltinSubtitleRender = [KBAVInfoViewController areSubtitlesAlwaysOn];
    
}

- (BOOL)avInfoPanelShowing {
    if (self.avInfoViewController.infoStyle == KBAVInfoStyleNew) {
        return self.transportSlider.frame.origin.y == 550;
    }
    return self.avInfoViewController.view.alpha;
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
        //[self createAndSetMeta];
    }
    if (_avInfoViewController.infoStyle == KBAVInfoStyleNew) {
        [self slideUpInfo];
        return;
    }
    self.transportSlider.userInteractionEnabled = false;
    [self.transportSlider hideSliderAnimated:true];
    [_avInfoViewController showFromViewController:self];
}

- (void)menuTapped:(UITapGestureRecognizer *)gestRecognizer {
    NSLog(@"[Ethereal] menu tapped");
    if (gestRecognizer.state == UIGestureRecognizerStateEnded){
        if ([self avInfoPanelShowing]) {
            [self hideAVInfoView];
        } else {
            [_mediaPlayer stop];
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }
}

- (void)resetSetMeta {
    _setMeta = false;
}

- (void)viewDidLoad {
    LOG_SELF;
    [super viewDidLoad];
    _setMeta = false;
    _videoView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_videoView];
    _mediaPlayer = [VLCMediaPlayer new];
    _mediaPlayer.drawable = _videoView;
    if (_mediaURL) {
        _mediaPlayer.media = [VLCMedia mediaWithURL:_mediaURL];
    }
    [self createSliderIfNecessary];
    [self.view addSubview:_transportSlider];
    _avInfoViewController = [KBAVInfoViewController new];
    //[self createAndSetMeta];
    _avInfoViewController.infoStyle = KBAVInfoStyleNew;
    [_avInfoViewController attachToView:_transportSlider inController:self];
    [_transportSlider setSliderMode:KBSliderModeTransport];
    [_transportSlider setCurrentTime:0];
    _transportSlider.fadeOutTransport = true;
    [_transportSlider setIsContinuous:false];
    [_transportSlider setAvPlayer:self.player];
    
    _subtitleButton = [KBButton buttonWithType:KBButtonTypeImage];
    _subtitleButton.buttonImageView.image = [KBSliderImages captionsImage];
    _subtitleButton.alpha = 0;
    [_subtitleButton autoConstrainToSize:CGSizeMake(68, 68)];
    [self.view addSubview:_subtitleButton];
    if ([self subtitlesAvailable]) {
        NSLog(@"[Ethereal] subtitles available!");
    } else {
        NSLog(@"[Ethereal] subtitles not available!");
    }
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
    
    
    [self.player observeStatus];
    _mediaPlayer.durationAvailable = ^(VLCTime * _Nonnull duration) {
        NSLog(@"[Ethereal] duration available: %@", duration);
        [self_weak_.transportSlider setTotalDuration:duration.intValue/1000];
        [self_weak_ createAndSetMeta];
    };
    
    _mediaPlayer.streamsUpdated = ^{
        if (self_weak_.avInfoViewController.vlcSubtitleData.count != self_weak_.mediaPlayer.numberOfSubtitlesTracks){
            NSLog(@"[Ethereal] streams updated");
            [self_weak_ resetSetMeta];
            [self_weak_ createAndSetMeta];
        }
    };
    
    _transportSlider.timeSelectedBlock = ^(CGFloat currentTime) {
        if (currentTime < self_weak_.mediaPlayer.media.length.intValue/1000) {
            VLCTime *time = [VLCTime timeWithInt:currentTime*1000];
            [self_weak_.mediaPlayer setTime:time];
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
    
    UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
    menuTap.numberOfTapsRequired = 1;
    menuTap.allowedPressTypes = @[@(UIPressTypeMenu)];
    [self.view addGestureRecognizer:menuTap];
    
    
    _leftTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftTapHandler:)];
    _leftTap.allowedPressTypes = @[@(UIPressTypeLeftArrow)];
    _leftTap.delegate = self;
    [self.view addGestureRecognizer:_leftTap];
    
    _rightTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightTapHandler:)];
    _rightTap.allowedPressTypes = @[@(UIPressTypeRightArrow)];
    _rightTap.delegate = self;
    [self.view addGestureRecognizer:_rightTap];
    
    UILongPressGestureRecognizer *longRightPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightLongPress:)];
    longRightPress.allowedPressTypes = @[@(UIPressTypeRightArrow)];
    [longRightPress requireGestureRecognizerToFail:_rightTap];
    [self.view addGestureRecognizer:longRightPress];
    
    UILongPressGestureRecognizer *longLeftPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftLongPress:)];
    longLeftPress.allowedPressTypes = @[@(UIPressTypeLeftArrow)];
    [longLeftPress requireGestureRecognizerToFail:_leftTap];
    [self.view addGestureRecognizer:longLeftPress];
    
    

}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    [super didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
    if ([self avInfoPanelShowing]) {
        if ([self.transportSlider isFocused]) {
            [self hideAVInfoView];
        }
    }
}

- (void)timeChanged:(NSNotification *)n {
    //NSLog(@"[Ethereal] time changed: %@", n);
    self.transportSlider.currentTime = self.mediaPlayer.time.intValue / 1000;
}

- (void)setMediaURL:(NSURL *)mediaURL {
    _mediaURL = mediaURL;
    if (!_mediaPlayer) {
        _mediaPlayer = [VLCMediaPlayer new];
        _mediaPlayer.drawable = _videoView;
    }
    _mediaPlayer.media = [VLCMedia mediaWithURL:mediaURL];
}

- (void)createAndSetMeta {
    if (_setMeta) return;
    CGSize frameSize = [_mediaPlayer videoSize];
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
        meta.duration = _mediaPlayer.media.length.intValue/1000;
        meta.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:asset.name];
        [_avInfoViewController setMetadata:meta];
        _transportSlider.title = asset.name;
        _setMeta = true;
        NSDictionary *metaDict = [_mediaPlayer.media metaDictionary];
        NSLog(@"[Ethereal] meta dictionary: %@", metaDict);
    }
    NSArray *subNames = [_mediaPlayer videoSubTitlesNames];
    NSArray *subIndices = [_mediaPlayer videoSubTitlesIndexes];
    __block NSMutableArray *dicts = [NSMutableArray new];
    [subNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dict = @{@"language": obj, @"index": subIndices[idx]};
        [dicts addObject:dict];
    }];
    if(dicts.count > 0){
        NSLog(@"[Ethereal] setting subtitle data: %@", dicts);
        [_avInfoViewController setVlcSubtitleData:dicts];
        [self updateSubtitleButtonState];
    }
    //[_avInfoViewController setSubtitleData:_avplayController.subtitleTracks];
}

- (void)subtitleButtonClicked {
    if (![self subtitlesAvailable]) {
        self.subtitleButton.alpha = 0;
        return;
    }
    NSArray <KBAVInfoPanelMediaOption *>*subtitleData = [_avInfoViewController vlcSubtitleData];
    if ([self subtitlesOn]){
        [_mediaPlayer setCurrentVideoSubTitleIndex:-1];
    } else {
        KBAVInfoPanelMediaOption *first = [subtitleData firstObject];
        first.selectedBlock(first);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateSubtitleButtonState];
        [self showSubtitleBulletin];
    });

}

- (void)showSubtitleBulletin {
    BOOL subtitlesOn = [self subtitlesOn];
    NSString *title = @"Subtitles On";
    if (!subtitlesOn) title =  @"Subtitles Off";
    KBBulletinView *bv = [KBBulletinView bulletinWithTitle:title description:nil image:[UIImage imageNamed:@"App Icon"]];
    [bv showForTime:5];
}

- (BOOL)subtitlesAvailable {
    return ([_mediaPlayer numberOfSubtitlesTracks] > 0);
}

- (BOOL)subtitlesOn {
    return [_mediaPlayer currentVideoSubTitleIndex] != -1;
}

- (void)updateSubtitleButtonState {
    if (![self subtitlesAvailable]){
        self.subtitleButton.buttonImageView.alpha = 0.0;
        self.subtitleButton.userInteractionEnabled = false;
        return;
    }
    self.subtitleButton.userInteractionEnabled = true;
    if ([self subtitlesOn]) {
        self.subtitleButton.buttonImageView.alpha = 1.0;
    } else {
        self.subtitleButton.buttonImageView.alpha = 0.5;
    }
}

- (NSURL *)mediaURL {
    return _mediaURL;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([_mediaPlayer isPlaying]){
        [_mediaPlayer stop];
    }
    _setMeta = false;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //[_mediaPlayer stop];
    //_mediaPlayer = nil;
}

- (void)togglePlayPause {
    if ([_mediaPlayer isPlaying]) {
        [_mediaPlayer pause];
    } else {
        [_mediaPlayer play];
    }
}

- (void)sliderMoved:(KBSlider *)slider {
    BOOL isPlaying = _mediaPlayer.isPlaying;
    slider.isPlaying = isPlaying;
    if (!_wasPlaying) {
        _wasPlaying = isPlaying;
    }
    if (isPlaying) {
        [_mediaPlayer pause];
    }
    //NSLog(@"[Ethereal] slider value: %.02f duration: %f", slider.value, _avplayController.duration);
    if (slider.value < _mediaPlayer.media.length.value.floatValue) {
        //[_avplayController seekto:slider.value];
    }
    if (_wasPlaying) {
        [_mediaPlayer play];
        _wasPlaying = false;
    }
}

- (void)createSliderIfNecessary {
    if (!_transportSlider) {
        _transportSlider = [[KBSlider alloc] initWithFrame:CGRectMake(100, 850, 1700, 105)];
        [_transportSlider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)stepVideoBackwards {
    self.transportSlider.scrubMode = KBScrubModeSkippingBackwards;
    [self.transportSlider fadeInIfNecessary];
    NSTimeInterval newValue = self.transportSlider.value - 10;
    VLCTime *time = [VLCTime timeWithInt:newValue*1000];
    [_mediaPlayer setTime:time];
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
    VLCTime *time = [VLCTime timeWithInt:newValue*1000];
    [_mediaPlayer setTime:time];
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
    [_mediaPlayer pause];
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
    VLCTime *time = [VLCTime timeWithInt:self.transportSlider.value*1000];
    [_mediaPlayer setTime:time];
    [_mediaPlayer play];
}

- (void)startRewinding {
    _rwActive = true;
    self.transportSlider.scrubMode = KBScrubModeRewind;
    self.transportSlider.currentSeekSpeed = KBSeekSpeed1x;
    [self.transportSlider fadeInIfNecessary];
    [_mediaPlayer pause];
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
    VLCTime *time = [VLCTime timeWithInt:self.transportSlider.value*1000];
    [_mediaPlayer setTime:time];
    [_mediaPlayer play];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press {
    //NSLog(@"[Ethereal] shouldReceivePress: %@", gestureRecognizer);
    if (gestureRecognizer == _leftTap || gestureRecognizer == _rightTap){
        if ([press kb_isSynthetic]){
            NSLog(@"[Ethereal] no synth for you!");
            return FALSE;
        }
    }
    return TRUE;
}


- (void)leftTapHandler:(UITapGestureRecognizer *)gestureRecognizer {
    LOG_SELF;
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
    LOG_SELF;
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

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    //NSLog(@"[Ethereal] pressesEnded: %@", presses);
    //AVPlayerState currentState = _avplayController.playerState;
    for (UIPress *press in presses) {
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
            
            default:
                NSLog(@"[Ethereal] unhandled type: %lu", press.type);
                [super pressesEnded:presses withEvent:event];
                break;
                
        }
        
    }
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
