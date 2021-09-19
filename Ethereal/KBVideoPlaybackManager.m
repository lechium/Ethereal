//
//  KBVideoPlaybackManager.m
//  Ethereal
//
//  Created by kevinbradley on 9/17/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import "KBVideoPlaybackManager.h"
#import "PlayerViewController.h"
#import "NSObject+Additions.h"
#include <IOKit/pwr_mgt/IOPMLib.h>
#import <MediaRemote/MediaRemote.h>
#import "NSData+Flip.h"

@interface AVPlayerViewController (hax)
@property (nonatomic, strong) NSURL *mediaURL;
@end

@interface KBVideoPlaybackManager() {
    NSArray *_media;
    NSInteger _playbackIndex;
    UIViewController <KBVideoPlaybackProtocol> *_currentPlayer;
    IOPMAssertionID assertionID;
}

@end
@implementation KBVideoPlaybackManager

- (void)killCurrentPlayer {
    
    //_currentPlayer = nil;
    //[self allowSleepAgain];
}

- (NSDictionary *)currentPlayingDetails {
    NSMutableDictionary *newDict = [NSMutableDictionary new];
    newDict[@"AVMediaRemoteManagerNowPlayingInfoHasDescription"] = @0;
    newDict[@"kMRMediaRemoteNowPlayingInfoClientPropertiesData"] = [NSData dataFromStringHex:@"08912A1211636F6D2E6E69746F2E457468657265616C20F5033A08457468657265616C"];
    newDict[@"kMRMediaRemoteNowPlayingInfoContentItemIdentifier"] = @"com.apple.avkit.5393.d9091c27"; //just hardcoding this for now
    newDict[@"kMRMediaRemoteNowPlayingInfoDuration"] = @100000;
    newDict[@"kMRMediaRemoteNowPlayingInfoElapsedTime"] = @25;
    newDict[@"kMRMediaRemoteNowPlayingInfoIsAlwaysLive"] = [NSNumber numberWithBool:false];
    newDict[@"kMRMediaRemoteNowPlayingInfoMediaType"] = @"kMRMediaRemoteNowPlayingInfoTypeJesus";
    newDict[@"kMRMediaRemoteNowPlayingInfoPlaybackRate"] = @1;
    newDict[@"kMRMediaRemoteNowPlayingInfoTimestamp"] = [NSDate date];
    newDict[@"kMRMediaRemoteNowPlayingInfoTitle"] = @"";
    newDict[@"kMRMediaRemoteNowPlayingInfoUniqueIdentifier"] = @-653714399; //just hardcoding this for now as well
    
    return newDict;
}

- (void)setNowPlayingInfo {
    MRMediaRemoteSetNowPlayingInfo((__bridge CFDictionaryRef)([self currentPlayingDetails]));
}

- (void)getNowPlayingInfo {
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef info) {
        NSLog(@"[Ethereal] We got the information: %@", info);
        NSDictionary *bridged = (__bridge NSDictionary*)info;
        NSString *outputMediaDetails = @"/var/mobile/Documents/media.plist";
        [bridged writeToFile:outputMediaDetails atomically:true];
        //This key may not be available, if its is not, we defer to ignoring the alert.
        NSString *mediaType = [bridged valueForKey:@"kMRMediaRemoteNowPlayingInfoMediaType"];
        
        if (info != nil){
            //im not sure if other constants come back different from the Music one in the official music app, im hoping this catches others as well.
            if ([mediaType containsString:@"Music"]){
            } else {
                //The media type doesnt exist, or doesnt contain the word music, its safe to say we don't want to see it!
                NSLog(@"video playing! fuck yo couch Apple!!");
            }
            
        } else { //info is null, nothing is currently playing, call original implementation.
        }
        
    });
}

- (void)allowSleepAgain {
    NSLog(@"[Ethereal] player done, can sleep again");
    IOPMAssertionRelease(assertionID);
}

- (void)killIdleSleep {
    IOReturn success = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep,
                                        kIOPMAssertionLevelOn, CFSTR("Playing Video"), &assertionID);
    if (success == kIOReturnSuccess) {
        NSLog(@"[Ethereal] sleep killed successfully");
        //Add the work you need to do without
        //  the system sleeping here.
        //NSLog(@"[Ethereal] player done, can sleep again");
        //success = IOPMAssertionRelease(assertionID);
        //The system will be able to sleep again.
    }
}


- (NSArray *)approvedExtensions {
    
    return @[@"mov", @"mp4", @"m4v", @"mkv", @"avi", @"mp3", @"vob", @"mpg", @"mpeg", @"flv", @"wmv", @"swf", @"asf", @"rmvb", @"rm"];
    
}

- (void)createPlayerViewForFile:(NSString *)theFile isLocal:(BOOL)isLocal completion:(void (^)(UIViewController <KBVideoPlaybackProtocol> *controller, BOOL success))block {
    AVPlayerItem *singleItem = nil;
    if (isLocal){
        singleItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:theFile]];
    } else {
        singleItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:theFile]];
    }
    __block AVQueuePlayer *player = [AVQueuePlayer playerWithPlayerItem:singleItem];
    [player play];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (singleItem.error != nil){
            NSLog(@"[Ethereal] %@", [singleItem error]);
            player = nil;
            PlayerViewController *playerController = [PlayerViewController new];
            if (isLocal){
                playerController.mediaURL = [NSURL fileURLWithPath:theFile];
            } else {
                playerController.mediaURL = [NSURL URLWithString:theFile];
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
            [self killIdleSleep];
            if (block){
                block(playerController, true);
            } else {
                NSLog(@"[Ethereal] calling safePresentViewController: %@: line: %d", NSStringFromSelector(_cmd), __LINE__);
                [[self topViewController] safePresentViewController:playerController animated:true completion:nil];
            }
            // [[self topViewController] presentViewController:playerController animated:true completion:nil];
        } else {
            NSLog(@"[Ethereal] no error occured!");
            [player pause];
            dispatch_async(dispatch_get_main_queue(), ^{
                KBPlayerViewController  *playerView = [[KBPlayerViewController alloc] init];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:singleItem];
                //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemReceivedError:) name:AVPlayerItemNewErrorLogEntryNotification object:singleItem];
                playerView.player = player;
                if (block) {
                    block(playerView, true);
                } else {
                    NSLog(@"[Ethereal] calling safePresentViewController: %@: line: %d", NSStringFromSelector(_cmd), __LINE__);
                    [[self topViewController] safePresentViewController:playerView animated:YES completion:nil];
                    [playerView.player play];
                }
                
            });
        }
    });
}

-(UIViewController <KBVideoPlaybackProtocol> *)playerForCurrentIndex {
    
    KBMediaAsset *currentAsset = self.media[_playbackIndex];
    NSString *theFile = currentAsset.filePath;
    if (currentAsset.assetType == KBMediaAssetTypeVideoDefault){
        
        NSLog(@"default compat files contains %@", theFile);
        if (!_currentPlayer) {
            _currentPlayer = [[KBPlayerViewController alloc] init];
        } else {
            if (![_currentPlayer isKindOfClass:KBPlayerViewController.class]) {
                ([[self topViewController] dismissViewControllerAnimated:true completion:nil]);
                    _currentPlayer = nil;
                    _currentPlayer = [[KBPlayerViewController alloc] init];
            }
        }
        [_currentPlayer setMediaURL:[NSURL fileURLWithPath:theFile]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentPlayer.player.currentItem];
        return _currentPlayer;
    } 
    //SGPlayerViewController *playerController = [[SGPlayerViewController alloc] initWithMediaURL:[NSURL fileURLWithPath:theFile]];
    if (!_currentPlayer) {
        _currentPlayer = [PlayerViewController new];
    } else {
        //if (![_currentPlayer isKindOfClass:PlayerViewController.class]) {
            ([[self topViewController] dismissViewControllerAnimated:true completion:nil]);
                _currentPlayer = nil;
                _currentPlayer = [PlayerViewController new];
        //}
    }
    [self killIdleSleep];
    //PlayerViewController *playerController = [PlayerViewController new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    _currentPlayer.mediaURL = [NSURL fileURLWithPath:theFile];
    return _currentPlayer;
    //[self presentViewController:playerController animated:true completion:nil];
}

- (void)itemDidFinishPlaying:(NSNotification *)n {
    
    NSLog(@"[Ethereal] %@ %@", self, NSStringFromSelector(_cmd));
    //[self dismissViewControllerAnimated:true completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:n.object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    NSInteger nextIndex = self.playbackIndex+1;
    NSLog(@"[Ethereal] currentIndex: %lu media count: %lu nextIndex: %lu", self.playbackIndex, self.media.count, nextIndex);
    BOOL hasMore = false;
    if (nextIndex < self.media.count) {
        hasMore = true;
        NSLog(@"[Ethereal] we have more to play!");
        self.playbackIndex = nextIndex;
        AVPlayerViewController *av = _currentPlayer;
        [self playerForCurrentIndex]; //just call it and it updates its local var.
        if (av != _currentPlayer) {
            NSLog(@"[Ethereal] changing up player types?");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (!_currentPlayer){
                    NSLog(@"[Ethereal] ohnoes, this is bad! no current player!, bail to prevent crash for now");
                    [self playerForCurrentIndex];
                }
                if (!_currentPlayer){
                    NSLog(@"[Ethereal] current play is STILL nil??!");
                    return;
                }
                NSLog(@"[Ethereal] calling safePresentViewController: %@: line: %d", NSStringFromSelector(_cmd), __LINE__);;
                [[self topViewController] safePresentViewController:_currentPlayer animated:true completion:nil];
            });
            
        }
    } else {
        [self allowSleepAgain];
    }
    if (self.videoDidFinishPlaying) {
        self.videoDidFinishPlaying(hasMore); //just return falue for now
    } else {
        //just pop the top
        if (!hasMore) {
            
            [[self topViewController] dismissViewControllerAnimated:true completion:nil];
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:n.object];
    
}

- (NSArray *)defaultCompatFiles {
    
    return @[@"mp4", @"mpeg4", @"m4v", @"mov"];
    
}

- (void)setPlaybackIndex:(NSInteger)playbackIndex {
    _playbackIndex = playbackIndex;
}

- (NSInteger)playbackIndex {
    return _playbackIndex;
}

- (void)setMedia:(NSArray<MetaDataAsset *> *)media {
    _media = media;
    NSLog(@"Media: %@", media);
}

- (NSArray <MetaDataAsset *>*)media {
    return _media;
}

+(instancetype)defaultManager {
    static id shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [KBVideoPlaybackManager new];
    });
    return shared;
}
@end
