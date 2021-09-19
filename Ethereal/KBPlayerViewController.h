//
//  KBPlayerViewController.h
//  Ethereal
//
//  Created by kevinbradley on 9/18/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import <AVKit/AVKit.h>
#import "KBVideoPlaybackProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface KBPlayerViewController : AVPlayerViewController <KBVideoPlaybackProtocol>
@property (nonatomic, strong) NSURL *mediaURL;
@end

NS_ASSUME_NONNULL_END