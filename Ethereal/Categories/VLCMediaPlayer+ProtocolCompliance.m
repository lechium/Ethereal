//
//  VLCMediaPlayer+ProtocolCompliance.m
//  Ethereal
//
//  Created by kevinbradley on 2/19/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import "VLCMediaPlayer+ProtocolCompliance.h"
#import <objc/runtime.h>

@interface VLCMediaPlayer() {
    //void (^_durationAvailable)(VLCTime *);
}

@end

@implementation VLCMediaPlayer (ProtocolCompliance) 

@dynamic player;

- (void)setStreamsUpdated:(void (^)(void))streamsUpdated {
    objc_setAssociatedObject(self, @selector(streamsUpdated), streamsUpdated, OBJC_ASSOCIATION_RETAIN);
}

-(void (^)(void))streamsUpdated {
    return objc_getAssociatedObject(self, @selector(streamsUpdated));
}

- (void)setDurationAvailable:(void (^)(VLCTime * _Nonnull))durationAvailable {
    objc_setAssociatedObject(self, @selector(durationAvailable), durationAvailable, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)(VLCTime * _Nonnull))durationAvailable {
    return objc_getAssociatedObject(self, @selector(durationAvailable));
}

- (void)seekToTime:(CMTime)time toleranceBefore:(CMTime)toleranceBefore toleranceAfter:(CMTime)toleranceAfter {
    VLCTime *newTime = [VLCTime timeWithInt:(int)(time.value/time.timescale) * 1000];
    [self setTime:newTime];
}

- (void)observeStatus {
    //ELog(@"observeStatus");
    [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    //[self.media addObserver:self forKeyPath:@"length" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}

- (void)setTimeControlStatus:(AVPlayerTimeControlStatus)status {
    objc_setAssociatedObject(self, @selector(timeControlStatus), [NSNumber numberWithInteger:status], OBJC_ASSOCIATION_RETAIN);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        VLCMediaPlayerState changed = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        //ELog(@"playerState changed: %@", VLCMediaPlayerStateToString(changed));
        switch (changed) {
            case VLCMediaPlayerStatePaused:
            case VLCMediaPlayerStateStopped:
                [self setTimeControlStatus:AVPlayerTimeControlStatusPaused];
                break;
            case VLCMediaPlayerStatePlaying:
                [self setTimeControlStatus: AVPlayerTimeControlStatusPlaying];
                //ELog(@"duration now: %@", self.media.length);
                if (self.durationAvailable) {
                    self.durationAvailable(self.media.length);
                }
                break;
            case VLCMediaPlayerStateBuffering:
                [self setTimeControlStatus: AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate];
                //ELog(@"duration now: %@", self.media.length);
                break;
            case VLCMediaPlayerStateESAdded:
                if (self.streamsUpdated) {
                    self.streamsUpdated();
                }
                //ELog(@"duration now: %@", self.media.length);
                break;
            default:
                break;
        }
    } else if ([keyPath isEqualToString:@"length"]){
        id changed = [change objectForKey:NSKeyValueChangeNewKey];
        ELog(@"media length changed: %@", changed);
    } else {
        ELog(@"unhandled key path: %@", keyPath);
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (AVPlayerTimeControlStatus) timeControlStatus {
    if (self.isPlaying) return AVPlayerTimeControlStatusPlaying;
    switch (self.state) {
        case VLCMediaPlayerStatePaused: return AVPlayerTimeControlStatusPaused;
        case VLCMediaPlayerStateStopped: return AVPlayerTimeControlStatusPaused;
        case VLCMediaPlayerStatePlaying: return AVPlayerTimeControlStatusPlaying;
        case VLCMediaPlayerStateBuffering: return AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate;
        case VLCMediaPlayerStateOpening: return AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate;
        default:
            break;
    }
    return AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate;
}

- (void)setCurrentAsset:(id)asset {
    
}

- (id)currentAsset {
    return nil;
}

- (id)currentItem {
    return nil;
}

- (NSURL *)mediaURL {
    return nil;
}

- (BOOL)setMediaURL:(NSURL *)mediaURL {
    return false;
}

@end
