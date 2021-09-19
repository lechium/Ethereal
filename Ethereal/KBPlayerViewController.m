//
//  KBPlayerViewController.m
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import "KBPlayerViewController.h"

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
    self.player = [AVQueuePlayer playerWithPlayerItem:singleItem];
    [self.player play];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
