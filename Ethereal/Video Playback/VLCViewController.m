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
#import "KBAction.h"
#import "KBMenu.h"

@interface VLCViewController () {
    NSURL *_mediaURL;
    BOOL _ffActive;
    BOOL _rwActive;
    NSTimer *_rightHoldTimer;
    NSTimer *_leftHoldTimer;
    NSTimer *_rewindTimer;
    NSTimer *_ffTimer;
    BOOL _setMeta;
    NSInteger _selectedMediaOptionIndex;
    KBContextMenuView *_visibleContextView;
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
        dispatch_async(dispatch_get_main_queue(), ^{
            _mediaPlayer.drawable = _videoView;
            [_mediaPlayer play];
        });

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
    NSLog(@"[Ethereal] playerState changed: %@", VLCMediaPlayerStateToString(state));
    if (state == VLCMediaPlayerStateEnded) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AVPlayerItemDidPlayToEndTimeNotification object:self];
        _setMeta = false;
    } else if (state == VLCMediaPlayerStateESAdded) {
        NSArray *subNames = [_mediaPlayer videoSubTitlesNames];
        NSArray *subIndices = [_mediaPlayer videoSubTitlesIndexes];
        if (subNames.count > 0) {
            NSLog(@"[Ethereal] subNames: %@ indices: %@", subNames, subIndices);
            [self refreshSubtitleDetails];
        }
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
        } else if ([self contextViewVisible]) {
            [_visibleContextView showContextView:false completion:^{
                [self killContextView];
            }];
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
    //_mediaPlayer.drawable = _videoView;
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
    [_subtitleButton addTarget:self action:@selector(subtitleButtonClicked:) forControlEvents:UIControlEventPrimaryActionTriggered];
    
    @weakify(self);
    _transportSlider.sliderFading = ^(CGFloat direction, BOOL animated) {
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                self_weak_.subtitleButton.alpha = direction;
                if ([self_weak_ contextViewVisible] && direction == 0){
                    //[self_weak_ testShowContextView];
                }
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
        if (duration.intValue == 0) return;
        NSLog(@"[Ethereal] duration available: %@", duration);
        [self_weak_.transportSlider setTotalDuration:duration.intValue/1000];
        [self_weak_ createAndSetMeta];
    };
    
    _mediaPlayer.streamsUpdated = ^{
        if (self_weak_.avInfoViewController.vlcSubtitleData.count != self_weak_.mediaPlayer.numberOfSubtitlesTracks){
            NSLog(@"[Ethereal] streams updated");
            
            if (self_weak_.transportSlider.totalDuration == 0) {
                int duration = self_weak_.mediaPlayer.media.length.intValue;
                if (duration > 0) {
                    NSLog(@"[Ethereal] duration available: %i", duration);
                    [self_weak_.transportSlider setTotalDuration:duration/1000];
                }
            }
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

- (BOOL)contextViewVisible {
    return (_visibleContextView);
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    [super didUpdateFocusInContext:context withAnimationCoordinator:coordinator];
    if ([self.subtitleButton isFocused]){
        self.transportSlider.fadeOutTransport = false;
    } else if ([self.transportSlider isFocused]) {
        self.transportSlider.fadeOutTransport = true;
    }
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

- (void)refreshSubtitleDetails {
    NSArray *subNames = [_mediaPlayer videoSubTitlesNames];
    NSArray *subIndices = [_mediaPlayer videoSubTitlesIndexes];
    NSLog(@"[Ethereal] subNames: %@ indices: %@", subNames, subIndices);
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
}

- (KBMenu *)createSubtitleMenu {
    NSArray<KBAVInfoPanelMediaOption *> *vlcSubtitleData = [_avInfoViewController vlcSubtitleData];
    __block NSMutableArray *menuArray = [NSMutableArray new];
    [vlcSubtitleData enumerateObjectsUsingBlock:^(KBAVInfoPanelMediaOption * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KBAction *action = [KBAction actionWithTitle:obj.displayName image:nil identifier:nil handler:^(__kindof KBAction * _Nonnull action) {
            action.state = KBMenuElementStateOn;
            if (obj.selectedBlock){
                obj.selectedBlock(obj);
            }
        }];
        action.state = KBMenuElementStateOff;
        if (obj.selected){
            action.state = KBMenuElementStateOn;
        }
        [menuArray addObject:action];
    }];
    KBMenu *menu = [KBMenu menuWithTitle:@"Subtitles" children:menuArray];
    NSLog(@"[Ethereal] menu: %@", menu);
    return menu;
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
        NSDictionary *metaDict = [_mediaPlayer.media metaDictionary];
        NSLog(@"[Ethereal] meta dictionary: %@", metaDict);
        if (asset.name == nil){
            asset.name = metaDict[@"title"];
        }
        meta.title = asset.name;
        meta.duration = _mediaPlayer.media.length.intValue/1000;
        meta.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:asset.name];
        [_avInfoViewController setMetadata:meta];
        _transportSlider.title = asset.name;
        _setMeta = true;
        
    } else {
        NSDictionary *metaDict = [_mediaPlayer.media metaDictionary];
        NSLog(@"[Ethereal] meta dictionary: %@", metaDict);
        _transportSlider.title = metaDict[@"title"];
    }
    [self refreshSubtitleDetails];
    //[_avInfoViewController setSubtitleData:_avplayController.subtitleTracks];
}

- (KBAVInfoPanelMediaOption *)selectedSubtitleStream {
    NSInteger stream = [_mediaPlayer currentVideoSubTitleIndex];
    if (stream != -1) {
        NSArray *streams = [_avInfoViewController vlcSubtitleData];
        KBAVInfoPanelMediaOption *selected = [[streams filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"mediaIndex == %lu", stream]] firstObject];
        return selected;
    }
    return nil;
}

- (KBAVInfoPanelMediaOption *)nextSubtitleStream {
    NSInteger stream = [_mediaPlayer currentVideoSubTitleIndex];
    NSArray *subData = [_avInfoViewController vlcSubtitleData];
    if (stream == -1) {
        return [subData firstObject];
    }
    KBAVInfoPanelMediaOption *selected = [self selectedSubtitleStream];
    NSInteger index = [subData indexOfObject:selected];
    NSInteger nextIndex = index+1;
    NSLog(@"[Ethereal] current index: %lu nextIndex: %lu count: %lu", index, nextIndex, subData.count);
    if (nextIndex < subData.count) {
        return subData[nextIndex];
    }
    return nil;
}

- (NSArray *) preferredFocusEnvironments {
    if ([self contextViewVisible]){
        return @[_visibleContextView, self.transportSlider];
    }
    if ([self avInfoPanelShowing]) {
        return @[_avInfoViewController.tempTabBar, self.transportSlider];
    }
    return @[self.transportSlider];
}

- (KBContextMenuView *)visibleContextView {
    return _visibleContextView;
}
- (void)killContextView {
    _visibleContextView = nil;
    self.subtitleButton.opened = false;
}
- (void)testShowContextView {
    @weakify(self);
    if (_visibleContextView) {
        [UIView animateWithDuration:0.5 animations:^{
            self_weak_.visibleContextView.transform = CGAffineTransformScale(self_weak_.visibleContextView.transform, 0.01, 0.01);;
            self_weak_.visibleContextView.alpha = 0.0;
            self_weak_.visibleContextView.layer.anchorPoint = CGPointMake(1, 0);
            [self_weak_.visibleContextView layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self_weak_.visibleContextView removeFromSuperview];
            [self_weak_ killContextView];
        }];
    } else {
        _visibleContextView = [[KBContextMenuView alloc] initForAutoLayout];
        _visibleContextView.alpha = 0;
        _visibleContextView.layer.anchorPoint = CGPointMake(0, 1);
        _visibleContextView.transform = CGAffineTransformScale(_visibleContextView.transform, 0.01, 0.01);
        [_visibleContextView autoConstrainToSize:CGSizeMake(400, 269)];
        _visibleContextView.mediaOptions = [_avInfoViewController vlcSubtitleData];
        [self.view addSubview:_visibleContextView];
        [_visibleContextView.collectionView reloadData];
        [_visibleContextView.trailingAnchor constraintEqualToAnchor:self.subtitleButton.trailingAnchor constant:0].active = true;
        [_visibleContextView.bottomAnchor constraintEqualToAnchor:self.subtitleButton.topAnchor constant:-10].active = true;
        [UIView animateWithDuration:0.5 animations:^{
            self_weak_.visibleContextView.transform = CGAffineTransformIdentity;
            self_weak_.visibleContextView.alpha = 1.0;
            self_weak_.visibleContextView.layer.anchorPoint = CGPointMake(0.5, 0.5);
            [self_weak_.visibleContextView layoutIfNeeded];
            [self_weak_ setNeedsFocusUpdate];
            [self_weak_ updateFocusIfNeeded];
        }];
       
    }
}

- (void)subtitleButtonClicked:(KBButton *)button {
    if (![self subtitlesAvailable]) {
        self.subtitleButton.alpha = 0;
        return;
    }
    if ([self contextViewVisible]){
        [_visibleContextView showContextView:false fromView:nil completion:^{
            button.opened = false;
            [self killContextView];
        }];
    } else {
        _visibleContextView = [[KBContextMenuView alloc] initForAutoLayout];
        _visibleContextView.delegate = self;
        _visibleContextView.sourceView = self.subtitleButton;
        _visibleContextView.menu = [self createSubtitleMenu];
        //_visibleContextView.mediaOptions = [_avInfoViewController vlcSubtitleData];
        [_visibleContextView showContextView:true fromView:self completion:^{
            button.opened = true;
            [self setNeedsFocusUpdate];
            [self updateFocusIfNeeded];
        }];
    }
 /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[self updateSubtitleButtonState];
        [self showSubtitleBulletin];
    });
*/
}

- (void)showSubtitleBulletin {
    BOOL subtitlesOn = [self subtitlesOn];
    NSString *title = @"Subtitles On";
    NSString *desc = [[self selectedSubtitleStream] displayName];
    if (!subtitlesOn) title =  @"Subtitles Off";
    KBBulletinView *bv = [KBBulletinView bulletinWithTitle:title description:desc image:[UIImage imageNamed:@"App Icon"]];
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
    self.subtitleButton.buttonImageView.alpha = 1.0;
    self.subtitleButton.userInteractionEnabled = true;
    /*
    if ([self subtitlesOn]) {
        self.subtitleButton.buttonImageView.alpha = 1.0;
    } else {
        self.subtitleButton.buttonImageView.alpha = 0.5;
    }*/
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
    if (_transportSlider.currentSeekSpeed != KBSeekSpeedNone) {
        [_ffTimer invalidate];
        [_rewindTimer invalidate];
        [_transportSlider seekResume];
        return;
    }
    [_transportSlider setScrubMode:KBScrubModeNone];
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

- (void)setSelectedMediaOptionIndex:(long long)selectedMediaOptionIndex {
    _selectedMediaOptionIndex = selectedMediaOptionIndex;
    [self.avInfoViewController.vlcSubtitleData enumerateObjectsUsingBlock:^(KBAVInfoPanelMediaOption * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == selectedMediaOptionIndex) {
            [obj setIsSelected:true];
        } else {
            [obj setIsSelected:false];
        }
    }];
}

- (void)createSliderIfNecessary {
    if (!_transportSlider) {
        _transportSlider = [[KBSlider alloc] initWithFrame:CGRectMake(100, 850, 1700, 105)];
        [_transportSlider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)stepVideoBackwards {
    if (_mediaPlayer.state == VLCMediaPlayerStateBuffering){
        NSLog(@"[Ethereal] buffering, bail!");
        return;
    }
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
    if (_mediaPlayer.state == VLCMediaPlayerStateBuffering){
        NSLog(@"[Ethereal] buffering, bail!");
        return;
    }
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
