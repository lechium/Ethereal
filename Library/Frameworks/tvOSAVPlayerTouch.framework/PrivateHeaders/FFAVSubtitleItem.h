//
//     Generated by classdumpios 1.0.1 (64 bit) (iOS port by DreamDevLost)(Debug version compiled Sep 26 2020 13:48:20).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <objc/NSObject.h>

@class NSString;

@interface FFAVSubtitleItem : NSObject
{
    long long _startTime;	// 8 = 0x8
    long long _duration;	// 16 = 0x10
    NSString *_text;	// 24 = 0x18
}

@property(retain, nonatomic) NSString *text; // @synthesize text=_text;
@property(nonatomic) long long duration; // @synthesize duration=_duration;
@property(nonatomic) long long startTime; // @synthesize startTime=_startTime;
- (void).cxx_destruct;	// IMP=0x000000000003403c
- (id)description;	// IMP=0x0000000000033e78

@end

