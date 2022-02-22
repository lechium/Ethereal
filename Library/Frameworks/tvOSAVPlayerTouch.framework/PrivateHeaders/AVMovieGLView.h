//
//     Generated by classdumpios 1.0.1 (64 bit) (iOS port by DreamDevLost)(Debug version compiled Sep 26 2020 13:48:20).
//
//  Copyright (C) 1997-2019 Steve Nygard.
//

#import <UIKit/UIView.h>

#import <tvOSAVPlayerTouch/AVSubtitleRenderDelegate-Protocol.h>

@class AVSubtitleRender, GLProgramWrapper, GPUAVImageContrastFilter, GPUAVImageSaturationFilter, UILabel;

@interface AVMovieGLView : UIView <AVSubtitleRenderDelegate>
{
    _Bool _appActive;	// 8 = 0x8
    _Bool _hasInitialized;	// 9 = 0x9
    _Bool _hasRenderedAnyFrame;	// 10 = 0xa
    int _inputRotation;	// 12 = 0xc
    struct CGSize _inputImageSize;	// 16 = 0x10
    float _imageVertices[8];	// 32 = 0x20
    unsigned int _inputTextureForDisplay;	// 64 = 0x40
    unsigned int _displayRenderbuffer;	// 68 = 0x44
    unsigned int _displayFramebuffer;	// 72 = 0x48
    GLProgramWrapper *_displayProgram;	// 80 = 0x50
    int _displayPositionAttribute;	// 88 = 0x58
    int _displayTextureCoordinateAttribute;	// 92 = 0x5c
    int _displayInputTextureUniform;	// 96 = 0x60
    GPUAVImageContrastFilter *_contrastFilter;	// 104 = 0x68
    GPUAVImageSaturationFilter *_saturationFilter;	// 112 = 0x70
    GLProgramWrapper *_yuvConversionProgram;	// 120 = 0x78
    unsigned int _yuvConversionFramebuffer;	// 128 = 0x80
    int _yuvConversionPositionAttribute;	// 132 = 0x84
    int _yuvConversionTextureCoordinateAttribute;	// 136 = 0x88
    int _yuvConversionTextureUniform[3];	// 140 = 0x8c
    unsigned int _yuvTexture[3];	// 152 = 0x98
    unsigned int _convertedRGBTexture;	// 164 = 0xa4
    UILabel *_watermarkLabel;	// 168 = 0xa8
    int _fillMode;	// 176 = 0xb0
    float _aspectRatio;	// 180 = 0xb4
    AVSubtitleRender *_subtitleRender;	// 184 = 0xb8
    struct CGSize _sizeInPixels;	// 192 = 0xc0
}

+ (const float *)textureCoordinatesForRotation:(int)arg1;	// IMP=0x0000000000023af0
+ (Class)layerClass;	// IMP=0x00000000000212d4
@property(readonly, nonatomic) AVSubtitleRender *subtitleRender; // @synthesize subtitleRender=_subtitleRender;
@property(nonatomic) float aspectRatio; // @synthesize aspectRatio=_aspectRatio;
@property(nonatomic) int fillMode; // @synthesize fillMode=_fillMode;
@property(readonly, nonatomic) struct CGSize sizeInPixels; // @synthesize sizeInPixels=_sizeInPixels;
@property(readonly, nonatomic) _Bool isAppActive; // @synthesize isAppActive=_appActive;
- (void).cxx_destruct;	// IMP=0x0000000000023c1c
- (void)subtitleRender:(id)arg1 didBoundChange:(struct CGRect)arg2;	// IMP=0x0000000000023b08
- (void)applicationStateChanged:(id)arg1;	// IMP=0x0000000000023a34
- (void)render:(void *)arg1 pixelformat:(int)arg2;	// IMP=0x00000000000238ec
- (void)setInputSize:(struct CGSize)arg1;	// IMP=0x000000000002377c
- (void)setInputRotation:(int)arg1;	// IMP=0x000000000002376c
@property(nonatomic) float saturation;
@property(nonatomic) float contrast;
@property(nonatomic) float brightness;
- (void)destroyYUVConversionFBO;	// IMP=0x000000000002357c
- (void)createYUVConversionFBO;	// IMP=0x00000000000232d4
- (void)setYUVConversionFBO;	// IMP=0x000000000002326c
- (void)convertYUVToRGBOutput;	// IMP=0x0000000000023128
- (void)render:(id)arg1;	// IMP=0x0000000000022e4c
- (_Bool)prepareYUVTexture:(id)arg1;	// IMP=0x0000000000022abc
- (void)loadYUVConversionProgram;	// IMP=0x0000000000022858
- (void)loadDisplayProgram;	// IMP=0x000000000002254c
- (void)recalculateViewGeometry;	// IMP=0x0000000000022360
- (void)presentFramebuffer;	// IMP=0x00000000000222dc
- (void)setDisplayFramebuffer;	// IMP=0x0000000000022274
- (void)destroyDisplayFramebuffer;	// IMP=0x00000000000221fc
- (void)createDisplayFramebuffer;	// IMP=0x0000000000022070
- (void)dealloc;	// IMP=0x0000000000021f48
- (void)layoutSubviews;	// IMP=0x0000000000021dac
- (void)didMoveToWindow;	// IMP=0x0000000000021c10
- (void)prepareWatermarkLabel;	// IMP=0x0000000000021970
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;	// IMP=0x000000000002182c
- (_Bool)commonInit;	// IMP=0x00000000000213d8
- (id)initWithCoder:(id)arg1;	// IMP=0x0000000000021360
- (id)initWithFrame:(struct CGRect)arg1;	// IMP=0x00000000000212e8

@end

