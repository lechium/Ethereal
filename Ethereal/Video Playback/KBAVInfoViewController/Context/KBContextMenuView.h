//
//  KBContextMenuView.h
//  Ethereal
//
//  Created by kevinbradley on 2/23/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KBAVInfoPanelMediaOption.h"
#import "KBAction.h"
#import "KBMenu.h"
NS_ASSUME_NONNULL_BEGIN


@protocol KBContextMenuViewDelegate <NSObject>

- (void)killContextView;

@end

@interface KBContextMenuView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic,strong) UIView *sourceView;
@property (nonatomic,retain) NSArray <KBAVInfoPanelMediaOption *>* mediaOptions;
@property (nonatomic,strong) KBMenu *menu;
@property (assign,nonatomic) long long selectedMediaOptionIndex;
@property (nonatomic, weak) id <KBContextMenuViewDelegate> delegate;
@property (nonatomic, strong) UICollectionView *collectionView;
- (void)showContextView:(BOOL)show fromView:(UIViewController *_Nullable)viewController;
- (void)showContextView:(BOOL)show fromView:(UIViewController *_Nullable)viewController completion:(void(^_Nullable)(void))block;
- (void)showContextView:(BOOL)show completion:(void (^)(void))block;
@end

NS_ASSUME_NONNULL_END
