//
//  KBContextMenuView.m
//  Ethereal
//
//  Created by kevinbradley on 2/23/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import "KBContextMenuView.h"
#import "UIView+AL.h"
#import "KBContextMenuViewCell.h"

@interface KBContextCollectionHeaderView: UICollectionReusableView
@property (nonatomic, strong) UILabel *label;
@end

@implementation KBContextCollectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[UILabel alloc] initForAutoLayout];
        [self addSubview:_label];
        [_label autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
        _label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        _label.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    }
    return self;
}

@end

@implementation KBContextMenuView {
    UIView *_backgroundView;
}

- (void)killContextView {
    if (self.delegate){
        [self.delegate killContextView];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundView = [[UIView alloc] initForAutoLayout];
        self.backgroundColor = nil;
        [self addSubview:_backgroundView];
        [_backgroundView autoPinEdgesToSuperviewEdges];
        _backgroundView.layer.masksToBounds = true;
        _backgroundView.layer.cornerRadius = 27;
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurView.translatesAutoresizingMaskIntoConstraints = false;
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = false;
        [_backgroundView addSubview:blurView];
        [blurView autoPinEdgesToSuperviewEdges];
        [_backgroundView addSubview:vibrancyEffectView];
        [vibrancyEffectView autoPinEdgesToSuperviewEdges];
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical; //CGRectMake(0, 0, 659, 35)
        layout.itemSize = CGSizeMake(400,70);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.sectionHeadersPinToVisibleBounds = true;
        //layout.minimumLineSpacing = 80;
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = false;
        _collectionView.clipsToBounds = false;
        [self addSubview:_collectionView];
        [self.collectionView registerClass:KBContextMenuViewCell.class forCellWithReuseIdentifier:@"cell"];
        [_collectionView autoPinEdgesToSuperviewEdges];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:KBContextCollectionHeaderView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
        //self.layer.anchorPoint = CGPointMake(0, 0);
    }
    return self;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    KBContextCollectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"Header" forIndexPath:indexPath];
    header.label.text = @"SUBTITLES";
    return header;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGRect frameRect =  [UIScreen mainScreen].bounds;
    CGSize retval;
    retval =  CGSizeMake(frameRect.size.width, 70);
    return retval;
}

- (NSIndexPath *)indexPathForPreferredFocusedViewInCollectionView:(UICollectionView *)collectionView {
    return [NSIndexPath indexPathForItem:0 inSection:0];
}

-  (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    KBContextMenuViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    KBAVInfoPanelMediaOption *opt = [self mediaOptions][indexPath.row];
    cell.label.text = opt.displayName;
    [cell setSelected:opt.selected animated:false];
    //cell.title = opt.displayName;
    //[cell setSelected:opt.selected];
    return cell;
}

-(NSInteger)collectionView:(id)arg1 numberOfItemsInSection:(NSInteger)arg2 {
    return _mediaOptions.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedMediaOptionIndex = indexPath.row;
    KBAVInfoPanelMediaOption *subtitleItem = self.mediaOptions[indexPath.row];
    [subtitleItem setIsSelected:true];
    if (subtitleItem.selectedBlock){
        subtitleItem.selectedBlock(subtitleItem);
    }
    [self.collectionView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showContextView:false fromView:nil completion:^{
            [self killContextView];
        }];
    });
}

- (void)showContextView:(BOOL)show fromView:(UIViewController *_Nullable)viewController completion:(void(^)(void))block {
    if (!show) {
        [UIView animateWithDuration:0.5 animations:^{
            self.transform = CGAffineTransformScale(self.transform, 0.01, 0.01);;
            self.alpha = 0.0;
            self.layer.anchorPoint = CGPointMake(1, 0);
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (block) {
                block();
            }
            //[self_weak_ killContextView];
        }];
    } else {
        //_visibleContextView = [[KBContextMenuView alloc] initForAutoLayout];
        self.alpha = 0;
        self.layer.anchorPoint = CGPointMake(0, 1);
        self.transform = CGAffineTransformScale(self.transform, 0.01, 0.01);
        CGFloat height = 70 + (self.mediaOptions.count * 70);
        [self autoConstrainToSize:CGSizeMake(400, height)];
        //self.mediaOptions = [_avInfoViewController vlcSubtitleData];
        [viewController.view addSubview:self];
        [self.collectionView reloadData];
        [self.trailingAnchor constraintEqualToAnchor:self.sourceView.trailingAnchor constant:0].active = true;
        [self.bottomAnchor constraintEqualToAnchor:self.sourceView.topAnchor constant:-10].active = true;
        [UIView animateWithDuration:0.5 animations:^{
            self.transform = CGAffineTransformIdentity;
            self.alpha = 1.0;
            self.layer.anchorPoint = CGPointMake(0.5, 0.5);
            [self layoutIfNeeded];
            [self setNeedsFocusUpdate];
            [self updateFocusIfNeeded];
        }];
       
    }
}

- (void)showContextView:(BOOL)show fromView:(UIViewController *_Nullable)viewController {
    [self showContextView:show fromView:viewController completion:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
