//
//  SGPlayerViewController.h
//  Ethereal
//
//  Created by Kevin Bradley on 1/24/21.
//  Copyright © 2021 nito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBVideoPlaybackProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface SGPlayerViewController : UIViewController <KBVideoPlaybackProtocol>
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) NSString *avFormatName;
@property (nonatomic, weak) id currentAsset;
- (instancetype)initWithMediaURL:(NSURL *)url;
- (id <KBVideoPlayerProtocol>)player;
@end

NS_ASSUME_NONNULL_END
