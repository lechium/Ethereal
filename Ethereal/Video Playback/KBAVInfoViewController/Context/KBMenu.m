//
//  KBMenu.m
//  Ethereal
//
//  Created by Kevin Bradley on 2/24/22.
//  Copyright © 2022 nito. All rights reserved.
//

#import "KBMenu.h"

@interface KBMenuElement (private)
- (void)_setTitle:(NSString *)title;
- (void)_setImage:(UIImage *)image;
@end

@interface KBMenu() {
    NSArray *_children;
    KBMenuOptions _options;
}
@end

@implementation KBMenu

- (void)_setOptions:(KBMenuOptions)opt {
    _options = opt;
}

- (KBMenuOptions)options {
    return _options;
}

- (void)_setChildren:(NSArray<KBMenuElement *> * _Nonnull)children {
    _children = children; //create elements
}

- (NSArray *)children {
    return _children;
}

+ (KBMenu *)menuWithTitle:(NSString *)title image:(UIImage *)image identifier:(NSString *)identifier options:(KBMenuOptions)options children:(NSArray<KBMenuElement *> *)children {
    KBMenu *menu = [[KBMenu alloc] init];
    [menu _setTitle:title];
    [menu _setImage:image];
    [menu _setChildren:children];
    [menu _setOptions:options];
    
    return menu;
}

+ (KBMenu *)menuWithTitle:(NSString *)title children:(NSArray<KBMenuElement *> *)children {
    return [KBMenu menuWithTitle:title image:nil identifier:nil options:KBMenuOptionsDisplayInline children:children];
}

+ (KBMenu *)menuWithChildren:(NSArray<KBMenuElement *> *)children {
    KBMenu *menu = [[KBMenu alloc] init];
    [menu _setChildren:children];
    return menu;
}

- (NSString *)description {
    NSString *sup = [super description];
    return [NSString stringWithFormat:@"%@ title: %@ children: %@", sup, self.title, _children];
}

@end
