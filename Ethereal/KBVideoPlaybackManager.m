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
@interface AVPlayerViewController (hax)
@property (nonatomic, strong) NSURL *mediaURL;
@end

@interface KBVideoPlaybackManager() {
    NSArray *_media;
    NSInteger _playbackIndex;
    AVPlayerViewController *_currentPlayer;
}

@end
@implementation KBVideoPlaybackManager

- (NSArray *)approvedExtensions {
    
    return @[@"mov", @"mp4", @"m4v", @"mkv", @"avi", @"mp3", @"vob", @"mpg", @"mpeg", @"flv", @"wmv", @"swf", @"asf", @"rmvb", @"rm"];
    
}

-(UIViewController *)playerForCurrentIndex {
    
    KBMediaAsset *currentAsset = self.media[_playbackIndex];
    NSString *theFile = currentAsset.filePath;
    if (currentAsset.assetType == KBMediaAssetTypeVideoDefault){
        
        NSLog(@"default compat files contains %@", theFile);
        if (!_currentPlayer) {
            _currentPlayer = [[AVPlayerViewController alloc] init];
        } else {
            if (![_currentPlayer isKindOfClass:AVPlayerViewController.class]) {
                ([[self topViewController] dismissViewControllerAnimated:true completion:nil]);
                    _currentPlayer = nil;
                    _currentPlayer = [[AVPlayerViewController alloc] init];
            }
        }
        [_currentPlayer setMediaURL:[NSURL fileURLWithPath:theFile]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentPlayer.player.currentItem];
        return _currentPlayer;
    } 
    //SGPlayerViewController *playerController = [[SGPlayerViewController alloc] initWithMediaURL:[NSURL fileURLWithPath:theFile]];
    if (!_currentPlayer) {
        _currentPlayer = (AVPlayerViewController*)[PlayerViewController new];
    } else {
        if (![_currentPlayer isKindOfClass:PlayerViewController.class]) {
            ([[self topViewController] dismissViewControllerAnimated:true completion:nil]);
                _currentPlayer = nil;
                _currentPlayer = (AVPlayerViewController*)[PlayerViewController new];
        }
    }
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
                [[self topViewController] presentViewController:_currentPlayer animated:true completion:nil];
            });
            
        }
        
    }
    if (self.videoDidFinishPlaying) {
        self.videoDidFinishPlaying(hasMore); //just return falue for now
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
