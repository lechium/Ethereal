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

@import tvOSAVPlayerTouch;

@interface PlayerViewController () <FFAVPlayerControllerDelegate>
@property KBSlider *transportSlider;
@property BOOL wasPlaying; //keeps track if we were playing when scrubbing started
@end

@implementation PlayerViewController {
    FFAVPlayerController *_avplayController;
    UIView *_glView;
    NSURL *_mediaURL;
}

- (void)setMediaURL:(NSURL *)mediaURL {
    LOG_SELF;
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

- (id<KBVideoPlayerProtocol>)player {
    return _avplayController;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
   NSLog(@"[Ethereal] gestureRecognizerShouldBegin: %@", gestureRecognizer);
    return true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
   NSLog(@"[Ethereal] shouldRecognizeSimultaneouslyWithGestureRecognizer: %@", gestureRecognizer);
    return TRUE;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
   NSLog(@"[Ethereal] shouldRequireFailureOfGestureRecognizer: %@", gestureRecognizer);
    return FALSE;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer  {
   NSLog(@"[Ethereal] shouldBeRequiredToFailByGestureRecognizer: %@", gestureRecognizer);
    return FALSE;
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
   NSLog(@"[Ethereal] shouldReceiveTouch: %@", gestureRecognizer);
    return TRUE;
}

// called before pressesBegan:withEvent: is called on the gesture recognizer for a new press. return NO to prevent the gesture recognizer from seeing this press
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceivePress:(UIPress *)press {
   NSLog(@"[Ethereal] shouldReceivePress: %@", gestureRecognizer);
    return TRUE;
}

// called once before either -gestureRecognizer:shouldReceiveTouch: or -gestureRecognizer:shouldReceivePress:
// return NO to prevent the gesture recognizer from seeing this event
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveEvent:(UIEvent *)event {
   NSLog(@"[Ethereal] shouldReceiveEvent: %@", gestureRecognizer);
    return TRUE;
}


- (void)menuTapped:(UITapGestureRecognizer *)gestRecognizer {
    NSLog(@"[Ethereal] menu tapped");
    if (gestRecognizer.state == UIGestureRecognizerStateEnded){
    
    }
}


//loading order might be weird based on setting the asset URL and viewDidLoad being triggered, initialize as needed.

- (void)createAVPlayerIfNecessary {
    if (!_avplayController) {
        _avplayController = [[FFAVPlayerController alloc] init];
        _avplayController.delegate = self;
        _avplayController.allowBackgroundPlayback = YES;
        _avplayController.shouldAutoPlay = YES;
        //_avplayController.streamDiscardOption = kAVStreamDiscardOptionSubtitle;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //LOG_SELF;
    // New and initialize FFAVPlayerController instance to prepare for playback
    [self createAVPlayerIfNecessary];
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
}

- (void)createSliderIfNecessary {
    if (!_transportSlider) {
        _transportSlider = [[KBSlider alloc] initWithFrame:CGRectMake(100, 950, 1700, 55)];
       [_transportSlider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)sliderMoved:(KBSlider *)slider {
    BOOL isPlaying = _avplayController.playerState == kAVPlayerStatePlaying;
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

- (void)pressesCancelled:(NSSet<UIPress *> *)presses withEvent:(nullable UIPressesEvent *)event {
    [super pressesCancelled:presses withEvent:event];
}

- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    //NSLog(@"[Ethereal] pressesBegan: %@", presses);
    [super pressesBegan:presses withEvent:event];
}

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
    //NSLog(@"[Ethereal] pressesEnded: %@", presses);
    AVPlayerState currentState = _avplayController.playerState;
    for (UIPress *press in presses) {
        //NSLog(@"[Ethereal] presstype: %lu", press.type);
        switch (press.type){
            case UIPressTypePlayPause:
            case UIPressTypeSelect:
                
                //NSLog(@"[Ethereal] play pause");
                if (currentState == kAVPlayerStatePaused) {
                    [_avplayController resume];
                } else {
                    [_avplayController pause];
                }
                break;
                
            case UIPressTypeUpArrow:
                //NSLog(@"[Ethereal] up");
                //[self upTouch];
                break;
                
            case UIPressTypeDownArrow:
                NSLog(@"[Ethereal] down");
                [self downTouch];
                break;
                
            default:
                NSLog(@"[Ethereal] unhandled type: %lu", press.type);
                break;
                
        }
        
        [super pressesEnded:presses withEvent:event];
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
    _avplayController.streamDiscardOption = kAVStreamDiscardOptionSubtitle;
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
            [_transportSlider setSliderMode:KBSliderModeTransport];
            [_transportSlider setCurrentTime:0];
            [_transportSlider setTotalDuration:_avplayController.duration];
            NSLog(@"setting maximum value to duration: %f",_avplayController.duration);
            
        }
    } else {
        NSLog(@"[Ethereal] Failed to load video!");
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"The video failed to load!" message:[NSString stringWithFormat:@"The video failed to load with error: %@", error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:ac animated:true completion:nil];
    }
}

// AVPlayer state was changed
- (void)FFAVPlayerControllerDidStateChange:(FFAVPlayerController *)controller {
    AVPlayerState state = [controller playerState];
    
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
