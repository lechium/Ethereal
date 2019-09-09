//
//  UIView+UIView_RecursiveFind.m
//  nitoTV4
//
//  Created by Kevin Bradley on 3/12/16.
//  Copyright © 2016 nito. All rights reserved.
//

#import "UIView+RecursiveFind.h"
#import "NSObject+Additions.h"
@implementation NSObject (convenience)

- (BOOL)darkMode {
    
    if ([self topViewController].view.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
        return TRUE;
    }
    return FALSE;
}

- (NSString *)appSupportFolder
{
    NSString *outputFolder = @"/var/mobile/Library/nitoTV";
    if (![FM fileExistsAtPath:outputFolder])
    {
        [FM createDirectoryAtPath:outputFolder withIntermediateDirectories:true attributes:nil error:nil];
    }
    return outputFolder;
}

- (NSString *)downloadFolder
{
    NSString *dlF = [[self appSupportFolder] stringByAppendingPathComponent:@"Downloads"];
    if (![FM fileExistsAtPath:dlF])
    {
        [FM createDirectoryAtPath:dlF withIntermediateDirectories:true attributes:nil error:nil];
    }
    return dlF;
}

@end

@implementation UIView (RecursiveFind)

- (BOOL)darkMode {
    
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
        return TRUE;
    }
    return FALSE;
}


- (id) clone {
    NSData *archivedViewData = [NSKeyedArchiver archivedDataWithRootObject: self];
    id clone = [NSKeyedUnarchiver unarchiveObjectWithData:archivedViewData];
    return clone;
}

- (UIImage *)snapshotViewWithSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, self.opaque, 0);
    //DLog(@"size: %@", NSStringFromCGSize(size));
    
    CGRect newBounds = self.bounds;
    newBounds.size.width = size.width;
    newBounds.size.height = size.height;
    newBounds.size = size;
    //DLog(@"newBounds: %@", NSStringFromCGRect(newBounds));
    [self drawViewHierarchyInRect:newBounds afterScreenUpdates:true];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

- (UIImage *) snapshotView
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:true];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}


- (UIView *)findFirstSubviewWithClass:(Class)theClass {
    
    if ([self isKindOfClass:theClass]) {
            return self;
        }
    
    for (UIView *v in self.subviews) {
        UIView *theView = [v findFirstSubviewWithClass:theClass];
        if (theView != nil)
        {
            return theView;
        }
    }
    return nil;
}
- (void)printAutolayoutTrace
{
    // NSString *recursiveDesc = [self performSelector:@selector(recursiveDescription)];
    //NSLog(@"%@", recursiveDesc);
#if DEBUG
    NSString *trace = [self _recursiveAutolayoutTraceAtLevel:0];
    NSLog(@"%@", trace);
#endif
}


- (void)printRecursiveDescription
{
#if DEBUG
    NSString *recursiveDesc = [self performSelector:@selector(recursiveDescription)];
    NSLog(@"%@", recursiveDesc);
#else
    NSLog(@"BUILT FOR RELEASE, NO SOUP FOR YOU");
#endif
}

- (void)removeAllSubviews
{
    for (UIView *view in self.subviews)
    {
        [view removeFromSuperview];
    }
}


@end
