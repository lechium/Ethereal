
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

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

NS_ASSUME_NONNULL_END
