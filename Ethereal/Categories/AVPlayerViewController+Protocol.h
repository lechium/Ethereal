//
//  AVPlayerViewController+Protocol.h
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "KBVideoPlaybackProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVPlayerViewController (Protocol) <KBVideoPlayerProtocol>
@property (nonatomic, strong) NSURL *mediaURL;
@end

NS_ASSUME_NONNULL_END
