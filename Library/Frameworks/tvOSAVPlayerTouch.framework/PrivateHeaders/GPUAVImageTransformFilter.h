//
//     Generated by classdumpios 1.0.1 (64 bit) (iOS port by DreamDevLost)(Debug version compiled Sep 26 2020 13:48:20).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <tvOSAVPlayerTouch/GPUAVImageFilter.h>

@interface GPUAVImageTransformFilter : GPUAVImageFilter
{
    int transformMatrixUniform;	// 192 = 0xc0
    int orthographicMatrixUniform;	// 196 = 0xc4
    struct GPUMathMatrix4x4 orthographicMatrix;	// 200 = 0xc8
    _Bool _ignoreAspectRatio;	// 264 = 0x108
    _Bool _anchorTopLeft;	// 265 = 0x109
    struct CGAffineTransform affineTransform;	// 272 = 0x110
    struct CATransform3D _transform3D;	// 320 = 0x140
}

@property(nonatomic) _Bool anchorTopLeft; // @synthesize anchorTopLeft=_anchorTopLeft;
@property(nonatomic) _Bool ignoreAspectRatio; // @synthesize ignoreAspectRatio=_ignoreAspectRatio;
@property(nonatomic) struct CATransform3D transform3D; // @synthesize transform3D=_transform3D;
@property(nonatomic) struct CGAffineTransform affineTransform; // @synthesize affineTransform;
- (void)setupFilterForSize:(struct CGSize)arg1;	// IMP=0x0000000000010274
- (void)newFrameReady;	// IMP=0x0000000000010134
- (void)convert3DTransform:(struct CATransform3D *)arg1 toMatrix:(struct GPUMathMatrix4x4 *)arg2;	// IMP=0x0000000000010070
- (void)loadOrthoMatrix:(float *)arg1 left:(float)arg2 right:(float)arg3 bottom:(float)arg4 top:(float)arg5 near:(float)arg6 far:(float)arg7;	// IMP=0x000000000000ffcc
- (id)init;	// IMP=0x000000000000fed0

@end

