//
//  AppDelegate.m
//  Ethereal
//
//  Created by Kevin Bradley on 9/8/19.
//  Copyright © 2019 nito. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayerViewController.h"
#import "ViewController.h"
#import <tvOSAVPlayerTouch/tvOSAVPlayerTouch.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "NSObject+Additions.h"
#import "SDWebImageManager.h"


@interface InternalLicense: NSObject

- (BOOL)isExpired;
- (void)setCustomerName:(id)name;
- (void)setProductName:(id)name;
- (void)setIsDemoVersion:(BOOL)isDemo;
- (void)setExpiredDate:(id)date;
- (BOOL)isDemoVersion;
- (BOOL)hasHWDecoderSupport;
- (NSString *)version;
- (NSString *)productName;
- (NSString *)customerName;
- (NSString *)licenseString;
- (id)expiredDate;
+ (id)sharedInstance;
@end
@interface AppDelegate ()
@end
@implementation AppDelegate

- (void)itemDidFinishPlaying:(NSNotification *)n {
    [[self topViewController] dismissViewControllerAnimated:true completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:n.object];
}

//never fires.. how the hell do u check for errors or file compat?? yeesh.
- (void)itemReceivedError:(NSNotification *)n {
  NSLog(@"[Ethereal] itemReceivedError: %@", [n userInfo]);
}

//test video
//https://api.air.tv/v1/portal/hls/EYBAG1FeSbeVhmVEomo6kA

- (void)checkPlabackStatus:(AVPlayerItem *)singleItem withFile:(NSString *)theFile isLocal:(BOOL)isLocal {
    
    if (singleItem.error != nil){
        NSLog(@"[Ethereal] %@", [singleItem error]);
        [[self topViewController] dismissViewControllerAnimated:true completion:^{
            PlayerViewController *playerController = [PlayerViewController new];
            if (isLocal){
                playerController.mediaURL = [NSURL fileURLWithPath:theFile];
            } else {
                playerController.mediaURL = [NSURL URLWithString:theFile];
            }
             [[self topViewController] presentViewController:playerController animated:true completion:nil];
        }];
    }
}

- (void)showPlayerViewWithFile:(NSString *)theFile isLocal:(BOOL)isLocal {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AVPlayerItem *singleItem = nil;
        if (isLocal){
            singleItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:theFile]];
        } else {
            singleItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:theFile]];
        }
        AVPlayerViewController *playerView = [[AVPlayerViewController alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:singleItem];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemReceivedError:) name:AVPlayerItemNewErrorLogEntryNotification object:singleItem];
        playerView.player = [AVQueuePlayer playerWithPlayerItem:singleItem];
        [[self topViewController] presentViewController:playerView animated:YES completion:nil];
        [playerView.player play];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self checkPlabackStatus:singleItem withFile:theFile isLocal:isLocal];
        });
    });
    
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    NSLog(@"[Ethereal] URL: %@", url);
    if ([url isFileURL]){
        NSFileManager *man = [NSFileManager defaultManager];
        NSString *newPath = [NSString stringWithFormat:@"/var/mobile/Documents/Ethereal/%@", url.path.lastPathComponent];
        NSString *originalPath = url.path;
        NSError *error = nil;
        [man moveItemAtPath:originalPath toPath:newPath error:&error];
        NSLog(@"[Ethereal] error: %@", error);
        [self showPlayerViewWithFile:newPath isLocal:TRUE];
    } else {
        [self showPlayerViewWithFile:url.absoluteString isLocal:false];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    InternalLicense *shared = [InternalLicense sharedInstance];
    [shared setIsDemoVersion:false];
    [shared setExpiredDate:[NSDate distantFuture]];
    [shared expiredDate];
    /*
    [[SDImageCache sharedImageCache] cleanDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    */

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
 
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
