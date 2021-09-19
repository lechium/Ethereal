//
//  KBVideoPlaybackManager.h
//  Ethereal
//
//  Created by kevinbradley on 9/17/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "KBMediaAsset.h"
#import "KBVideoPlaybackProtocol.h"
#import "KBPlayerViewController.h"
#import "UIViewController+Presentation.h"

NS_ASSUME_NONNULL_BEGIN

@interface KBVideoPlaybackManager : NSObject
+ (instancetype)defaultManager;
@property NSArray <KBMediaAsset *> *media;
@property NSInteger playbackIndex;
- (void)killCurrentPlayer;
- (NSArray *)approvedExtensions;
- (NSArray *)defaultCompatFiles;
- (UIViewController <KBVideoPlaybackProtocol> *)playerForCurrentIndex;
- (void)createPlayerViewForFile:(NSString *)theFile isLocal:(BOOL)isLocal completion:(void (^)(UIViewController <KBVideoPlaybackProtocol> *controller, BOOL success))block;
- (void)killIdleSleep;
- (void)allowSleepAgain;
@property (nonatomic, copy) void (^videoDidFinishPlaying)(BOOL moreLeft);
@end

NS_ASSUME_NONNULL_END
