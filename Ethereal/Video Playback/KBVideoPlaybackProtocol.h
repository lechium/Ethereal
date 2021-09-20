//
//  KBVideoPlaybackProtocol.h
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import <Foundation/Foundation.h>

@import tvOSAVPlayerTouch;

NS_ASSUME_NONNULL_BEGIN

@protocol KBVideoPlayerProtocol <FFAVPlayerControllerDelegate>

- (void)play;
- (void)pause;
- (id)currentItem;

@end

@protocol KBVideoPlaybackProtocol <NSObject>
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) id <KBVideoPlayerProtocol> player;
@end

NS_ASSUME_NONNULL_END
