//
//  KBAVInfoViewController.h
//  Ethereal
//
//  Created by kevinbradley on 1/9/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
NS_ASSUME_NONNULL_BEGIN

@protocol KBAVInfoViewControllerDelegate <NSObject>
- (void)willShowAVViewController;
- (void)willHideAVViewController;
@end

@interface KBAVMetaData: NSObject
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) NSString *summary;
@property (readwrite, assign) NSInteger duration;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) UIImage *image;
@end

@interface KBAVInfoViewController : UIViewController <UITabBarDelegate>

@property UITabBar *tempTabBar;
@property (nonatomic, weak) AVPlayerItem *playerItem;
@property (nonatomic, weak) id <KBAVInfoViewControllerDelegate> delegate;
+ (NSDateComponentsFormatter *)sharedTimeFormatter;
- (void)showFromViewController:(UIViewController *)pvc;
- (void)closeWithCompletion:(void(^_Nullable)(void))block;
- (void)setMetadata:(KBAVMetaData *)metadata;
+ (BOOL)areSubtitlesAlwaysOn;
@end

NS_ASSUME_NONNULL_END
