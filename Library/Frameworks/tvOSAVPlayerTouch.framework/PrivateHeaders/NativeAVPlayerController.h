//
//     Generated by classdumpios 1.0.1 (64 bit) (iOS port by DreamDevLost)(Debug version compiled Sep 26 2020 13:48:20).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <objc/NSObject.h>

#import <tvOSAVPlayerTouch/AVAssetResourceLoaderDelegate-Protocol.h>

@class AVAsset, AVPlayer, AVPlayerItem, FFAVSubtitle, NSArray, NSString, NSURL, NativeAVAssetResourceLoaderDelegate, NativeAVPlayerPlaybackView, UIView;
@protocol NativeAVPlayerControllerDelegate;

@interface NativeAVPlayerController : NSObject <AVAssetResourceLoaderDelegate>
{
    NSURL *_url;	// 8 = 0x8
    _Bool _isAppActive;	// 16 = 0x10
    _Bool _isLoadedVideo;	// 17 = 0x11
    _Bool _userPausedPlayback;	// 18 = 0x12
    _Bool _isFinishedPlayback;	// 19 = 0x13
    _Bool _muted;	// 20 = 0x14
    _Bool _isAddedPlayerItemStatusObserver;	// 21 = 0x15
    _Bool _isAddedPlayerItemNetworkLoadingObserver;	// 22 = 0x16
    _Bool _isAddedPlayerObserver;	// 23 = 0x17
    struct {
        long long value;
        int timescale;
        unsigned int flags;
        long long epoch;
    } _duration;	// 24 = 0x18
    id _periodicTimeObserver;	// 48 = 0x30
    _Bool _isPlayingBeforeInterrupted;	// 56 = 0x38
    NativeAVAssetResourceLoaderDelegate *_avrld;	// 64 = 0x40
    long long _currentAudioTrack;	// 72 = 0x48
    NSArray *_audioTracks;	// 80 = 0x50
    NSArray *_avplayitemAudioTracks;	// 88 = 0x58
    FFAVSubtitle *_avSubtitle;	// 96 = 0x60
    double _lastRenderSubtitleStartTime;	// 104 = 0x68
    double _lastRenderSubtitleEndTime;	// 112 = 0x70
    _Bool _shouldAutoPlay;	// 120 = 0x78
    _Bool _allowBackgroundPlayback;	// 121 = 0x79
    _Bool _enableTimeObserver;	// 122 = 0x7a
    _Bool _enableBuiltinSubtitleRender;	// 123 = 0x7b
    id <NativeAVPlayerControllerDelegate> _delegate;	// 128 = 0x80
    NSString *_title;	// 136 = 0x88
    NativeAVPlayerPlaybackView *_playbackView;	// 144 = 0x90
    AVAsset *_asset;	// 152 = 0x98
    AVPlayer *_player;	// 160 = 0xa0
    AVPlayerItem *_playerItem;	// 168 = 0xa8
}

@property(retain, nonatomic) AVPlayerItem *playerItem; // @synthesize playerItem=_playerItem;
@property(retain, nonatomic) AVPlayer *player; // @synthesize player=_player;
@property(retain, nonatomic) AVAsset *asset; // @synthesize asset=_asset;
@property(retain, nonatomic) NativeAVPlayerPlaybackView *playbackView; // @synthesize playbackView=_playbackView;
@property(nonatomic) _Bool enableBuiltinSubtitleRender; // @synthesize enableBuiltinSubtitleRender=_enableBuiltinSubtitleRender;
@property(retain, nonatomic) NSString *title; // @synthesize title=_title;
@property(nonatomic) _Bool enableTimeObserver; // @synthesize enableTimeObserver=_enableTimeObserver;
@property(nonatomic) _Bool allowBackgroundPlayback; // @synthesize allowBackgroundPlayback=_allowBackgroundPlayback;
@property(nonatomic) _Bool shouldAutoPlay; // @synthesize shouldAutoPlay=_shouldAutoPlay;
@property(nonatomic) __weak id <NativeAVPlayerControllerDelegate> delegate; // @synthesize delegate=_delegate;
@property(readonly, nonatomic) long long currentAudioTrack; // @synthesize currentAudioTrack=_currentAudioTrack;
@property(readonly, retain, nonatomic) NSURL *mediaURL; // @synthesize mediaURL=_url;
- (void).cxx_destruct;	// IMP=0x000000000003aeb8
- (void)resourceLoader:(id)arg1 didCancelAuthenticationChallenge:(id)arg2;	// IMP=0x000000000003abe8
- (_Bool)resourceLoader:(id)arg1 shouldWaitForResponseToAuthenticationChallenge:(id)arg2;	// IMP=0x000000000003aae4
- (void)configureAVAssetResourceLoaderDelegate:(id)arg1;	// IMP=0x000000000003a8cc
- (void)handleAudioSessionInterruption:(id)arg1;	// IMP=0x000000000003a73c
- (void)applicationDidBecomeActive:(id)arg1;	// IMP=0x000000000003a650
- (void)applicationDidEnterBackground:(id)arg1;	// IMP=0x000000000003a578
- (void)playerItemDidFailToReachEnd:(id)arg1;	// IMP=0x000000000003a430
- (void)playerItemDidReachEnd:(id)arg1;	// IMP=0x000000000003a384
- (void)enableOrDisableVirtualTrack:(_Bool)arg1;	// IMP=0x000000000003a150
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;	// IMP=0x0000000000039310
- (void)setViewDisplayName;	// IMP=0x0000000000039080
- (void)assetFailedToPrepareForPlayback:(id)arg1;	// IMP=0x0000000000038fe0
- (void)didObserveTimeChange;	// IMP=0x0000000000038bb0
- (void)prepareToPlayAsset:(id)arg1 withKeys:(id)arg2;	// IMP=0x0000000000038684
- (void)removeAVPlayerObservers;	// IMP=0x0000000000038560
- (void)addAVPlayerObservers;	// IMP=0x0000000000038334
- (void)removePlayerItemObservers;	// IMP=0x000000000003807c
- (void)addPlayerItemObservers;	// IMP=0x0000000000037d24
- (void)setSubtitleBackgroundColor:(id)arg1;	// IMP=0x0000000000037c78
- (void)setSubtitleTextColor:(id)arg1;	// IMP=0x0000000000037bcc
- (void)setSubtitleFont:(id)arg1;	// IMP=0x0000000000037b20
- (void)closeSubtitleFile;	// IMP=0x0000000000037ad8
- (_Bool)openSubtitleFile:(id)arg1;	// IMP=0x00000000000378c4
- (void)switchAudioTracker:(int)arg1;	// IMP=0x000000000003780c
- (void)stop;	// IMP=0x00000000000376fc
- (void)pause;	// IMP=0x0000000000037688
- (void)play;	// IMP=0x0000000000037620
@property(readonly, nonatomic) _Bool isPlaying;
@property(readonly, nonatomic) struct CGSize videoFrameSize;
@property(nonatomic) double currentPlaybackTime;
@property(readonly, nonatomic) double duration;
@property(nonatomic, getter=isMuted) _Bool muted;
@property(nonatomic) _Bool fullScreenMode;
@property(readonly, nonatomic) _Bool externalPlaybackActive;
@property(nonatomic) _Bool allowsExternalPlayback;
- (_Bool)openMedia:(id)arg1 options:(id)arg2;	// IMP=0x0000000000036540
@property(readonly, nonatomic) NSArray *audioTracks;
@property(readonly, nonatomic) _Bool hasAudio;
@property(readonly, nonatomic) _Bool hasVideo;
@property(nonatomic) float rateOfPlayback;
@property(readonly, retain, nonatomic) UIView *drawableView;
- (void)dealloc;	// IMP=0x0000000000035d7c
- (id)init;	// IMP=0x0000000000035b0c

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

