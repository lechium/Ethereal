//
//  KBContextMenuView.h
//  Ethereal
//
//  Created by kevinbradley on 2/23/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBAVInfoPanelMediaOption.h"
NS_ASSUME_NONNULL_BEGIN

@interface KBContextMenuView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic,strong) UIView *sourceView;
@property (nonatomic,retain) NSArray <KBAVInfoPanelMediaOption *>* mediaOptions;
@property (assign,nonatomic) long long selectedMediaOptionIndex;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) UICollectionView *collectionView;
- (void)showContextView:(BOOL)show fromView:(UIViewController *_Nullable)viewController;
- (void)showContextView:(BOOL)show fromView:(UIViewController *_Nullable)viewController completion:(void(^_Nullable)(void))block;
@end

NS_ASSUME_NONNULL_END
