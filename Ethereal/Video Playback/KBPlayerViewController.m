//
//  KBPlayerViewController.m
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import "KBPlayerViewController.h"
#import "KBVideoPlaybackManager.h"

@interface AVPlayerViewController (private)
-(void)_handleMenuTapGestureDismissal:(id)arg1;
@end

@implementation KBQueuePlayer
@end

@interface KBPlayerViewController () {
    NSURL *_mediaURL;
}

@end

@implementation KBPlayerViewController

- (NSURL *)mediaURL {
    return _mediaURL;
}

- (BOOL)setMediaURL:(NSURL *)mediaURL {
    _mediaURL = mediaURL;
    AVPlayerItem *singleItem = [AVPlayerItem playerItemWithURL:mediaURL];
    if (![[singleItem asset] isPlayable]){
        ELog(@"this is not playable!!");
        singleItem = nil;
        return false;
    }
    self.player = [KBQueuePlayer playerWithPlayerItem:singleItem];
    [self.player play];
    return true;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)_handleMenuTapGestureDismissal:(id)arg1 {
    LOG_FUNCTION;
    [super _handleMenuTapGestureDismissal:arg1];
    [KBVideoPlaybackManager defaultManager].loopVideo = false;
}

@end
