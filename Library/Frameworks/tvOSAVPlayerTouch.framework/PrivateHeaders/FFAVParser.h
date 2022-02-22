//
//     Generated by classdumpios 1.0.1 (64 bit) (iOS port by DreamDevLost)(Debug version compiled Sep 26 2020 13:48:20).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <objc/NSObject.h>

@class NSURL;

@interface FFAVParser : NSObject
{
    id _avsourceObject;	// 8 = 0x8
    struct DEMUXER_AVSRC_CTX _srcfile_ctx;	// 16 = 0x10
    struct generic_demux *_demuxer;	// 1120 = 0x460
    struct AVCodecContext *_videoCodecCtx;	// 1128 = 0x468
    struct AVPicture _avPicture;	// 1136 = 0x470
    _Bool _isNeedFreeAVPicture;	// 1232 = 0x4d0
    struct SwsContext *_swsContext;	// 1240 = 0x4d8
    NSURL *_url;	// 1248 = 0x4e0
}

+ (id)parseSubtitleFile:(id)arg1 encodingQueryHandler:(CDUnknownBlockType)arg2 frameRate:(double)arg3;	// IMP=0x0000000000032f1c
+ (void)initialize;	// IMP=0x0000000000031e34
+ (id)supportedProtocols;	// IMP=0x0000000000031c60
+ (void)showEncoders;	// IMP=0x0000000000031c38
+ (void)showDecoders;	// IMP=0x0000000000031c10
+ (void)printCodecs:(int)arg1;	// IMP=0x00000000000319a8
+ (void)showFormats;	// IMP=0x00000000000317e8
+ (void)showProtocols;	// IMP=0x0000000000031794
@property(readonly, nonatomic) NSURL *url; // @synthesize url=_url;
- (void).cxx_destruct;	// IMP=0x0000000000033d40
- (id)parseSubtitleStreamAtIndex:(long long)arg1 encodingQueryHandler:(CDUnknownBlockType)arg2;	// IMP=0x0000000000033358
- (id)thumbnailAtTime:(double)arg1;	// IMP=0x0000000000032cfc
- (int)videoStreamIndex;	// IMP=0x0000000000032c74
@property(readonly, nonatomic) unsigned long long numberOfSubtitleStreams;
@property(readonly, nonatomic) unsigned long long frameHeight;
@property(readonly, nonatomic) unsigned long long frameWidth;
@property(readonly, nonatomic) double duration;
- (_Bool)hasSubtitle;	// IMP=0x00000000000329f4
- (_Bool)hasAudio;	// IMP=0x0000000000032978
- (_Bool)hasVideo;	// IMP=0x00000000000328fc
- (_Bool)hasDolby;	// IMP=0x0000000000032880
- (void)closeScaler;	// IMP=0x0000000000032828
- (_Bool)setupScaler;	// IMP=0x0000000000032758
- (id)convertVideoFrame:(struct AVFrame *)arg1;	// IMP=0x00000000000325b8
- (id)decodeFrames:(int)arg1;	// IMP=0x000000000003230c
- (void)close;	// IMP=0x0000000000032210
- (_Bool)openMedia:(id)arg1 withOptions:(id)arg2;	// IMP=0x0000000000031f88
- (void)dealloc;	// IMP=0x0000000000031f04
- (id)init;	// IMP=0x0000000000031e78

@end
