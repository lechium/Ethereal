//
//  KBPlayerViewController.m
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import "KBPlayerViewController.h"

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

- (void)setMediaURL:(NSURL *)mediaURL {
    _mediaURL = mediaURL;
    AVPlayerItem *singleItem = [AVPlayerItem playerItemWithURL:mediaURL];
    self.player = [KBQueuePlayer playerWithPlayerItem:singleItem];
    [self.player play];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


@end
