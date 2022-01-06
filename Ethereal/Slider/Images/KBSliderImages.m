#import "backward.h"
#import "forward.h"
#import "gobackward.h"
#import "goforward.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KBSliderImages.h"


@implementation KBSliderImages

#define SliderImage(base) ([self imageWithBytesNoCopy:(void *)(base) length:sizeof(base) scale:2.0])
#define SliderImageTemplate(base) ([SliderImage(base) imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate])

+ (UIImage *)imageWithBytesNoCopy:(void *)bytes length:(NSUInteger)length scale:(CGFloat)scale {
    NSData *data = [NSData dataWithBytesNoCopy:bytes length:length freeWhenDone:NO];
    return [UIImage imageWithData:data scale:scale];
}

+ (UIImage *)backwardsImage {
    return SliderImageTemplate(backward_fill_png);
}
+ (UIImage *)forwardsImage {
    return SliderImageTemplate(forward_fill_png);
}
+ (UIImage *)skipForwardsImage {
    return SliderImageTemplate(goforward_10_png);
}
+ (UIImage *)skipBackwardsImage {
    return SliderImageTemplate(gobackward_10_png);
}

@end
