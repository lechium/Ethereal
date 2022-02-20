//
//  VLCViewController.h
//  Ethereal
//
//  Created by kevinbradley on 2/18/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBVideoPlaybackProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface VLCViewController : UIViewController
@property (nonatomic, weak) id currentAsset;
@property (nonatomic, strong) NSURL *mediaURL;
- (id <KBVideoPlayerProtocol>)player;
@end

NS_ASSUME_NONNULL_END
