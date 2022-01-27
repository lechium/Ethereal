//
//  FFAVPlayerController+ProtocolAdherence.m
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import "FFAVPlayerController+ProtocolAdherence.h"
#import <objc/runtime.h>

@implementation FFAVPlayerController (ProtocolAdherence)

@dynamic player;

- (void)play {
    [self resume];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"playerState"];
}


- (void)observeStatus {
    NSLog(@"[Ethereal] observeStatus");
    [self addObserver:self forKeyPath:@"playerState" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"playerState"]) {
        AVPlayerState changed = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        NSLog(@"[Ethereal] playerState changed: %lu", changed);
        switch (changed) {
            case kAVPlayerStatePaused:
            case kAVPlayerStateStoped:
                [self setTimeControlStatus:AVPlayerTimeControlStatusPaused];
                break;
            case kAVPlayerStatePlaying:
                [self setTimeControlStatus: AVPlayerTimeControlStatusPlaying];
                break;
            case kAVPlayerStateUnknown:
            case kAVPlayerStateInitialized:
                [self setTimeControlStatus: AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate];
                break;
            default:
                break;
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setCurrentAsset:(id)currentAsset {
    
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter {
    [self seekto:time.value/time.timescale];
}

- (id)currentAsset {
    return nil;
}

- (id)currentItem {
    return nil;
}
/*
- (AVPlayerTimeControlStatus)timeControlStatus {
    return [objc_getAssociatedObject(self, @selector(timeControlStatus)) integerValue];
}
*/
- (void)setTimeControlStatus:(AVPlayerTimeControlStatus)status {
    objc_setAssociatedObject(self, @selector(timeControlStatus), [NSNumber numberWithInteger:status], OBJC_ASSOCIATION_RETAIN);
}


- (AVPlayerTimeControlStatus) timeControlStatus {
    switch (self.playerState) {
        case kAVPlayerStatePaused: return AVPlayerTimeControlStatusPaused;
        case kAVPlayerStateStoped: return AVPlayerTimeControlStatusPaused;
        case kAVPlayerStatePlaying: return AVPlayerTimeControlStatusPlaying;
        case kAVPlayerStateUnknown: return AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate;
        case kAVPlayerStateInitialized: return AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate;
        default:
            break;
    }
    return AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate;
}

- (NSURL *)mediaURL {
    return nil;
}

- (BOOL)setMediaURL:(nonnull NSURL *)mediaURL {
    return false;
}

@end
