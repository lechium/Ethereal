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

typedef NS_ENUM(NSInteger, KBSubtitleTagType) {
    KBSubtitleTagTypeOff,
    KBSubtitleTagTypeAuto,
    KBSubtitleTagTypeOn,
};

@protocol KBAVInfoViewControllerDelegate <NSObject>
- (void)willShowAVViewController;
- (void)willHideAVViewController;
@end

@interface KBAVInfoPanelMediaOption: NSObject {
    
    
}
@property (nonatomic,readonly) NSString * displayName;
@property (nonatomic,readonly) NSString * languageCode;
@property (nonatomic,readonly) AVMediaSelectionOption * mediaSelectionOption;
@property (nonatomic,readonly) BOOL selected;
@property (nonatomic, copy, nullable) void (^selectedBlock)(KBAVInfoPanelMediaOption *selected);
@property (readonly) KBSubtitleTagType tag;
-(id)initWithLanguageCode:(NSString * _Nullable)code displayName:(NSString *)name mediaSelectionOption:(AVMediaSelectionOption *_Nullable)option tag:(KBSubtitleTagType)tag;
-(void)setIsSelected:(BOOL)selected;
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

- (NSArray *)subtitleData;
- (void)setSubtitleData:(NSArray *)subtitleData;
+ (NSDateComponentsFormatter *)sharedTimeFormatter;
- (void)showFromViewController:(UIViewController *)pvc;
- (void)closeWithCompletion:(void(^_Nullable)(void))block;
- (void)setMetadata:(KBAVMetaData *)metadata;
+ (BOOL)areSubtitlesAlwaysOn;
- (BOOL)shouldDismissView;
@end

NS_ASSUME_NONNULL_END
