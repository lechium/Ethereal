//
//  PlayerViewController.h
//  AVPlayerDemo
//
//  Created by apple on 15/12/5.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBVideoPlaybackProtocol.h"
@interface PlayerViewController : UIViewController <KBVideoPlaybackProtocol>
// audio or video file path (local or network file path)
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) NSString *avFormatName;
- (id <KBVideoPlayerProtocol>)player;
@end
