//
//  FFAVPlayerController+ProtocolAdherence.h
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import <tvOSAVPlayerTouch/tvOSAVPlayerTouch.h>
#import "KBVideoPlaybackProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface FFAVPlayerController (ProtocolAdherence) <KBVideoPlaybackProtocol>

- (void)play;
- (id)currentItem;
- (AVPlayerTimeControlStatus) timeControlStatus;
- (id)currentAsset;
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter;
- (void)observeStatus;
@end

NS_ASSUME_NONNULL_END
