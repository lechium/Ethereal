//
//  KBSlider.h
//  KBSlider
//
//  Created by Kevin Bradley on 12/25/20.
//  Copyright © 2020 nito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSThread (additions)
+ (NSArray *)stackFrameTruncatedTo:(NSInteger)offset;
@end

@interface KBGradientView: UIView
@property(nonatomic, readonly, strong) CAGradientLayer *layer;
+(instancetype)standardGradientView;
@end

typedef NS_ENUM(NSInteger, KBScrubMode) {
    KBScrubModeNone,
    KBScrubModeSkippingBackwards,
    KBScrubModeSkippingForwards,
    KBScrubModeJumping, //jumping back and forth at full intervals
    KBScrubModeRewind,
    KBScrubModeFastForward,
};

typedef NS_ENUM(NSInteger, DPadState) {
    DPadStateSelect,
    DPadStateRight,
    DPadStateLeft,
    DPadStateUp,
    DPadStateDown,
};

//KBSlider exclusives!

typedef NS_ENUM(NSInteger, KBSliderMode) {
    KBSliderModeDefault, //normal slider
    KBSliderModeTransport, //tranport mode like for movie playback control
};


@interface KBSlider : UIControl

@property CGFloat value;
@property CGFloat scrubValue;
@property CGFloat minimumValue;
@property CGFloat maximumValue;
@property BOOL isContinuous;
@property UIColor *maximumTrackTintColor;
@property UIColor *minimumTrackTintColor;
@property UIColor *thumbTintColor;
@property CGFloat focusScaleFactor;
@property CGFloat stepValue;

@property UIImage *currentMinimumTrackImage;
@property UIImage *currentMaximumTrackImage;

@property CGFloat storedValue;
@property CGFloat storedScrubberValue; //may not be necessary
@property NSTimeInterval currentTime; //only applicable in the transport mode
@property NSTimeInterval totalDuration; //only applicable in the transport mode
@property BOOL isPlaying; //transport mode only
@property BOOL isScrubbing; //transport mode only
@property (nonatomic, copy, nullable) void (^timeSelectedBlock)(CGFloat currentTime); //transport mode only, is called when a slider value is selected when scrubbing.
@property BOOL fadeOutTransport;
@property KBSliderMode sliderMode;
@property KBScrubMode scrubMode;
@property (nonatomic, weak) AVPlayer *avPlayer; //optional

+ (NSDateComponentsFormatter *)sharedTimeFormatter;
- (NSTimeInterval)remainingTime;
- (NSString *)remainingTimeFormatted;
- (NSString *)elapsedTimeFormatted;
- (UIImage *)currentThumbImage;
- (void)setValue:(CGFloat)value animated:(BOOL)animated;
- (void)setMinimumTrackImage:(UIImage *)minTrackImage forState:(UIControlState)state;
- (void)setMaximumTrackImage:(UIImage *)maxTrackImage forState:(UIControlState)state;
- (void)setThumbImage:(UIImage *)thumbImage forState:(UIControlState)state;
- (UIImage *)minimumTrackImageForState:(UIControlState)state;
- (UIImage *)maximumTrackImageForState:(UIControlState)state;
- (UIImage *)thumbImageForState:(UIControlState)state;
@end

#define DLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#define LOG_SELF        DLog(@"[KBSlider] %@ %@", self, NSStringFromSelector(_cmd))
#define KBSLog(format, ...) DLog(@"[KBSlider] %@",[NSString stringWithFormat:format, ## __VA_ARGS__]);
NS_ASSUME_NONNULL_END
