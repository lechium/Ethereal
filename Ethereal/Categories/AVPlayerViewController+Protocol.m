//
//  AVPlayer+Protocol.m
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import "AVPlayerViewController+Protocol.h"
#import "NSObject+Additions.h"
@implementation AVPlayerViewController (Protocol)

- (void)setMediaURL:(NSURL *)mediaURL {
    objc_setAssociatedObject(self, @selector(mediaURL), mediaURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    AVPlayerItem *singleItem = [AVPlayerItem playerItemWithURL:mediaURL];
    self.player = [AVQueuePlayer playerWithPlayerItem:singleItem];
    [self.player play];
}

- (NSURL *)mediaURL {
    return objc_getAssociatedObject(self, @selector(mediaURL));
}

@end
