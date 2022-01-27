//
//  KBAVInfoViewController.h
//  Ethereal
//
//  Created by kevinbradley on 1/9/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import "KBSlider.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KBButtonType) {
    KBButtonTypeText,
    KBButtonTypeImage,
};

@interface KBButton: UIControl

@property (readwrite, assign) KBButtonType buttonType;
@property (nonatomic, strong, nullable) UILabel *titleLabel;
@property (nonatomic, strong, nullable) UIImageView *buttonImageView;
@property (nonatomic, copy, nullable) void (^focusChanged)(BOOL focused, UIFocusHeading direction);
+(instancetype)buttonWithType:(KBButtonType)buttonType;
- (void)setTitle:(nullable NSString *)title forState:(UIControlState)state;
@end

typedef NS_ENUM(NSInteger, KBAVInfoStyle) {
    KBAVInfoStyleLegacy,
    KBAVInfoStyleNew,
};

typedef NS_ENUM(NSInteger, KBSubtitleTagType) {
    KBSubtitleTagTypeOff,
    KBSubtitleTagTypeAuto,
    KBSubtitleTagTypeOn,
};

@protocol KBAVInfoViewControllerDelegate <NSObject>
@optional
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
@property (nonatomic) NSString *genre;
@property (nonatomic) NSString *year;
@property (readwrite, assign) BOOL isHD;
@property (readwrite, assign) BOOL hasCC;
@end

@interface KBAVInfoViewController : UIViewController <UITabBarDelegate>

@property UITabBar *tempTabBar;
@property KBButton *infoButton;
@property (nonatomic, weak) AVPlayerItem *playerItem;
@property (nonatomic, weak) id <KBAVInfoViewControllerDelegate> delegate;
@property (nonatomic, copy, nullable) void (^playbackStatusChanged)(AVPlayerItemStatus status);
@property (nonatomic, copy, nullable) void (^infoFocusChanged)(BOOL focused, UIFocusHeading direction);
@property (readwrite, assign) KBAVInfoStyle infoStyle;

@property (nonatomic, strong, nullable) NSLayoutConstraint *descriptionViewLeadingAnchor;

- (void)attachToView:(KBSlider *)theView inController:(UIViewController *)pvc;
- (void)showWithCompletion:(void(^_Nullable)(void))block;
- (BOOL)isHD;
- (BOOL)hasClosedCaptions;
- (NSArray *)subtitleData;
- (void)setSubtitleData:(NSArray *)subtitleData;
+ (NSDateComponentsFormatter *)sharedTimeFormatter;
- (void)showFromViewController:(UIViewController *)pvc;
- (void)closeWithCompletion:(void(^_Nullable)(void))block;
- (void)setMetadata:(KBAVMetaData *)metadata;
+ (BOOL)areSubtitlesAlwaysOn;
- (BOOL)shouldDismissView;
- (BOOL)subtitlesOn;
- (void)toggleSubtitles:(BOOL)on;
@end

NS_ASSUME_NONNULL_END
