//
//     Generated by classdumpios 1.0.1 (64 bit) (iOS port by DreamDevLost)(Debug version compiled Sep 26 2020 13:48:20).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <tvOSAVPlayerTouch/AVMovieFrame.h>

@interface AVVideoFrame : AVMovieFrame
{
    int _format;	// 12 = 0xc
    unsigned long long _width;	// 16 = 0x10
    unsigned long long _height;	// 24 = 0x18
}

+ (id)frameWithAVFrame:(void *)arg1 format:(int)arg2;	// IMP=0x000000000002005c
@property(nonatomic) unsigned long long height; // @synthesize height=_height;
@property(nonatomic) unsigned long long width; // @synthesize width=_width;
@property(nonatomic) int format; // @synthesize format=_format;
- (int)type;	// IMP=0x0000000000020054

@end
