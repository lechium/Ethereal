//
//  ViewController.h
//  Ethereal
//
//  Created by Kevin Bradley on 9/8/19.
//  Copyright © 2019 nito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "KBMediaAsset.h"

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (id)defaultCenter;
- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;

@end

@interface UIApplication (private)

- (void)terminateWithSuccess;

@end


@interface ViewController : SettingsViewController

@property (readwrite, assign) BOOL shouldExit;
- (id)initWithDirectory:(NSString *)directory;

@end

