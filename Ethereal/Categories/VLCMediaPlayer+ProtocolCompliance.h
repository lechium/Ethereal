//
//  VLCMediaPlayer+ProtocolCompliance.h
//  Ethereal
//
//  Created by kevinbradley on 2/19/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import <TVVLCKit/TVVLCKit.h>
#import "KBVideoPlaybackProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface VLCMediaPlayer (ProtocolCompliance) <KBVideoPlaybackProtocol>
- (void)observeStatus;
- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter;
@property (nonatomic, copy, nullable) void (^durationAvailable)(VLCTime *duration);
@end

NS_ASSUME_NONNULL_END
