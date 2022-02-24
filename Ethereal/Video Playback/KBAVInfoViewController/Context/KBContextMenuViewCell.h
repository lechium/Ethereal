//
//  KBContextMenuViewCell.h
//  Ethereal
//
//  Created by kevinbradley on 2/23/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KBContextMenuViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *label;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
