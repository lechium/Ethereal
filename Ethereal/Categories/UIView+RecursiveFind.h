//
//  UIView+UIView_RecursiveFind.h
//  nitoTV4
//
//  Created by Kevin Bradley on 3/12/16.
//  Copyright © 2016 nito. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FM [NSFileManager defaultManager]

@interface NSObject (convenience)

- (NSString *)appSupportFolder;
- (NSString *)downloadFolder;
- (BOOL)darkMode;
@end

@interface UIView (RecursiveFind)

- (BOOL)darkMode;
- (id) clone;
- (UIImage *)snapshotViewWithSize:(CGSize)size;
- (UIImage *) snapshotView;
- (UIView *)findFirstSubviewWithClass:(Class)theClass;
- (void)printRecursiveDescription;
- (void)removeAllSubviews;
- (void)printAutolayoutTrace;
//- (NSString *)recursiveDescription;
- (id)_recursiveAutolayoutTraceAtLevel:(long long)arg1;
@end
