//
//  SGPlayerViewController.m
//  Ethereal
//
//  Created by Kevin Bradley on 1/24/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import "SGPlayerViewController.h"
#import <SGPlayer/SGPlayer.h>
#import "KBSlider.h"

@interface SGPlayerViewController ()
@property (nonatomic, strong) SGPlayer *player;
@property KBSlider *transportSlider;
@end

@implementation SGPlayerViewController

- (instancetype)initWithMediaURL:(NSURL *)url {
    self = [super init];
    if (self){
        _mediaURL = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player = [[SGPlayer alloc] init];
    // Do any additional setup after loading the view.
}

- (void)sliderMoved:(KBSlider *)slider {
    
    SGTimeInfo time = self.player.timeInfo;
    //NSTimeInterval elapsed = CMTimeGetSeconds(time.playback);
    NSTimeInterval duration = CMTimeGetSeconds(time.duration);
    CMTime seekTime = CMTimeMakeWithSeconds(slider.value, time.duration.timescale);
    //CMTime seekTime = CMTimeMake(slider.value, time.duration.timescale);
    //CMTime seekTime = CMTimeMultiplyByFloat64(time.duration, slider.value);
    NSTimeInterval seek = CMTimeGetSeconds(seekTime);
    
    NSLog(@"[Ethereal] slider value: %.02f seek: %f duration: %f", slider.value, seek, duration);
    if (slider.value < duration) {
        //[_avplayController seekto:slider.value];
        
        if (!CMTIME_IS_NUMERIC(seekTime)) {
            seekTime = kCMTimeZero;
        }
        [self.player seekToTime:seekTime result:^(CMTime time, NSError *error) {
            //self.seeking = NO;
        }];
    }
}

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event
{
    
    //NSLog(@"[Ethereal] pressesEnded: %@", presses);
    SGStateInfo currentState = self.player.sstateInfo;
    
    for (UIPress *press in presses)
    {
        
        switch (press.type){
                
            case UIPressTypePlayPause:
            case UIPressTypeSelect:
                
                NSLog(@"[Ethereal] play pause");
                if (currentState.playback & SGPlaybackStatePlaying) {
                    [self.player pause];
                } else {
                    [self.player play];
                }
                break;
                
            case UIPressTypeUpArrow:
                
                //[self upTouch];
                break;
                
            case UIPressTypeDownArrow:
                
                //[self downTouch];
                break;
                
            case UIPressTypeLeftArrow:
                
                break;
                
            case UIPressTypeRightArrow:
                break;
                
            case UIPressTypeMenu:
                
                
                NSLog(@"[Ethereal] terminate with success!!");
                [self dismissViewControllerAnimated:true completion:nil];
                //[[UIApplication sharedApplication] terminateWithSuccess];
                /*
                 [self dismissViewControllerAnimated:true completion:^{
                 [self dismissViewControllerAnimated:true completion:^{
                 //no-op
                 }];
                 }];
                 */
                //[super pressesEnded:presses withEvent:event];
                break;
                
        }
        
        if (press.type == UIPressTypePlayPause)
        {
            
            
            
        } else {
            [super pressesEnded:presses withEvent:event];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    _transportSlider = [[KBSlider alloc] initWithFrame:CGRectMake(100, 950, 1700, 55)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoChanged:) name:SGPlayerDidChangeInfosNotification object:self.player];
    NSLog(@"[Ethereal] URL: %@", self.mediaURL);
    SGAsset *asset = [[SGURLAsset alloc] initWithURL:_mediaURL];
    NSLog(@"[Ethereal] asset: %@", asset);
    self.player.videoRenderer.view = self.view;
    [self.player replaceWithAsset:asset];
    [self.player play];
    [_transportSlider setSliderMode:KBSliderModeTransport];
    [_transportSlider setCurrentTime:0];
    //_transportSlider.isContinuous = false;
    [self.view addSubview:_transportSlider];
    [_transportSlider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];

}

#pragma mark - SGPlayer Notifications

- (void)infoChanged:(NSNotification *)notification
{
    SGTimeInfo time = [SGPlayer timeInfoFromUserInfo:notification.userInfo];
    SGStateInfo state = [SGPlayer stateInfoFromUserInfo:notification.userInfo];
    SGInfoAction action = [SGPlayer infoActionFromUserInfo:notification.userInfo];
    if (action & SGInfoActionTime) {
        NSLog(@"[Ethereal] playback: %f, duration: %f, cached: %f",
              CMTimeGetSeconds(time.playback),
              CMTimeGetSeconds(time.duration),
              CMTimeGetSeconds(time.cached));
        NSTimeInterval duration = CMTimeGetSeconds(time.duration);
        [_transportSlider setCurrentTime:CMTimeGetSeconds(time.playback)];
        [_transportSlider setTotalDuration:duration];
        
    }
    if (action & SGInfoActionState) {
        NSLog(@"[Ethereal] player: %d, loading: %d, playback: %d, playing: %d, seeking: %d, finished: %d",
              (int)state.player, (int)state.loading, (int)state.playback,
              (int)(state.playback & SGPlaybackStatePlaying),
              (int)(state.playback & SGPlaybackStateSeeking),
              (int)(state.playback & SGPlaybackStateFinished));
        if (state.playback & SGPlaybackStateFinished){
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }
}

@end
