//
//  SGPlayerViewController.m
//  Ethereal
//
//  Created by Kevin Bradley on 1/24/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import "SGPlayerViewController.h"
#import <SGPlayer/SGPlayer.h>

@interface SGPlayerViewController ()
@property (nonatomic, strong) SGPlayer *player;
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoChanged:) name:SGPlayerDidChangeInfosNotification object:self.player];
    NSLog(@"[Ethereal] URL: %@", self.mediaURL);
    SGAsset *asset = [[SGURLAsset alloc] initWithURL:_mediaURL];
    NSLog(@"[Ethereal] asset: %@", asset);
    self.player.videoRenderer.view = self.view;
    [self.player replaceWithAsset:asset];
    [self.player play];
  
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
    }
    if (action & SGInfoActionState) {
        NSLog(@"[Ethereal] player: %d, loading: %d, playback: %d, playing: %d, seeking: %d, finished: %d",
              (int)state.player, (int)state.loading, (int)state.playback,
              (int)(state.playback & SGPlaybackStatePlaying),
              (int)(state.playback & SGPlaybackStateSeeking),
              (int)(state.playback & SGPlaybackStateFinished));
    }
}

@end
