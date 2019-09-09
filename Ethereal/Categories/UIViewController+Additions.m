//
//  UIViewController+Additions.m
//  nitoTV4
//
//  Created by Kevin Bradley on 7/17/18.
//  Copyright © 2018 nito. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)

- (BOOL)darkMode {
    
    if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
        return TRUE;
    }
    return FALSE;
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [ac addAction:okAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:ac animated:true completion:nil];
    });
    
}

@end
