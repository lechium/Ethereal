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

@interface SGPlayerViewController () {
    SGPlayer *_player;
}
//@property (nonatomic, strong) SGPlayer *player;
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
    UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
    menuTap.numberOfTapsRequired = 1;
    menuTap.allowedPressTypes = @[@(UIPressTypeMenu)];
    [self.view addGestureRecognizer:menuTap];
    // Do any additional setup after loading the view.
}

- (id <KBVideoPlayerProtocol>)player {
    return _player;
}

- (void)setPlayer:(id<KBVideoPlayerProtocol>)player {
    _player = player;
}

- (void)sliderMoved:(KBSlider *)slider {
    
    SGPlayer *playerCast = (SGPlayer *)self.player;
    
    SGTimeInfo time = playerCast.timeInfo;
    //NSTimeInterval elapsed = CMTimeGetSeconds(time.playback);
    NSTimeInterval duration = CMTimeGetSeconds(time.duration);
    CMTime seekTime = CMTimeMakeWithSeconds(slider.value, time.duration.timescale);
    //CMTime seekTime = CMTimeMake(slider.value, time.duration.timescale);
    //CMTime seekTime = CMTimeMultiplyByFloat64(time.duration, slider.value);
    NSTimeInterval seek = CMTimeGetSeconds(seekTime);
    
    ELog(@"slider value: %.02f seek: %f duration: %f", slider.value, seek, duration);
    if (slider.value < duration) {
        //[_avplayController seekto:slider.value];
        
        if (!CMTIME_IS_NUMERIC(seekTime)) {
            seekTime = kCMTimeZero;
        }
        [playerCast seekToTime:seekTime result:^(CMTime time, NSError *error) {
            //self.seeking = NO;
        }];
    }
}

- (BOOL)avInfoPanelShowing {
    return false;
}

- (void)hideAVInfoView {
    
}

- (void)menuTapped:(UITapGestureRecognizer *)gestRecognizer {
    ELog(@"menu tapped");
    if (gestRecognizer.state == UIGestureRecognizerStateEnded){
        if ([self avInfoPanelShowing]) {
            [self hideAVInfoView];
        } else {
            //[_avplayController pause];
            [self.player pause];
            self.player = nil;
            [self dismissViewControllerAnimated:true completion:nil];
        }
    }
}

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event
{
    
    //ELog(@"pressesEnded: %@", presses);
    SGStateInfo currentState = [(SGPlayer *)[self player] sstateInfo];
    
    for (UIPress *press in presses)
    {
        
        switch (press.type){
                
            case UIPressTypePlayPause:
            case UIPressTypeSelect:
                
                ELog(@"play pause");
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
                
                
                ELog(@"terminate with success!!");
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
    ELog(@"URL: %@", self.mediaURL);
    SGAsset *asset = [[SGURLAsset alloc] initWithURL:_mediaURL];
    ELog(@"asset: %@", asset);
    [[(SGPlayer *)[self player] videoRenderer] setView:self.view];
    //self.player.videoRenderer.view = self.view;
    [(SGPlayer *)[self player] replaceWithAsset:asset];
    //[self.player replaceWithAsset:asset];
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
        ELog(@"playback: %f, duration: %f, cached: %f",
              CMTimeGetSeconds(time.playback),
              CMTimeGetSeconds(time.duration),
              CMTimeGetSeconds(time.cached));
        NSTimeInterval duration = CMTimeGetSeconds(time.duration);
        [_transportSlider setCurrentTime:CMTimeGetSeconds(time.playback)];
        [_transportSlider setTotalDuration:duration];
        
    }
    if (action & SGInfoActionState) {
        ELog(@"player: %d, loading: %d, playback: %d, playing: %d, seeking: %d, finished: %d",
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
