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

- (void)airDropReceived:(NSNotification *)n {
    
    NSDictionary *userInfo = [n userInfo];
    NSArray <NSString *>*items = userInfo[@"Items"];
    NSLog(@"airdropped Items: %@", items);
    if (items.count > 0){
        [self showPlayerViewWithFile:items[0]];
    }
    /*
     [items enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
     
     //[self processPath:obj];
     [self showPlayerViewWithFile:obj];
     
     }];
     
     */
}

- (NSArray *)defaultCompatFiles {
    
    return @[@"mp4", @"mpeg4", @"m4v", @"mov"];
    
}

- (void)showPlayerViewWithFile:(NSString *)theFile {
    
    if ([[self defaultCompatFiles] containsObject:theFile.pathExtension.lowercaseString]){
        
        NSLog(@"default compat files contains %@", theFile);
        AVPlayerViewController *playerView = [[AVPlayerViewController alloc] init];
        AVPlayerItem *singleItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:theFile]];
        
        playerView.player = [AVQueuePlayer playerWithPlayerItem:singleItem];
        [[self topViewController] presentViewController:playerView animated:YES completion:nil];
        [playerView.player play];
        
        return;
    }
    
    PlayerViewController *playerController = [PlayerViewController new];
    playerController.mediaURL = [NSURL fileURLWithPath:theFile];
    [[self topViewController] presentViewController:playerController animated:true completion:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    InternalLicense *shared = [InternalLicense sharedInstance];
    
    [shared setIsDemoVersion:false];
    [shared setExpiredDate:[NSDate distantFuture]];
    [shared setCustomerName:@"JESUS"];
    [shared setProductName:@"YAZ"];
    NSLog(@"name: %@", shared.customerName);
    NSLog(@"productName: %@", shared.productName);
    NSLog(@"expired date: %@", shared.expiredDate);
    
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
       [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(airDropReceived:) name:@"com.nito.Ethereal/airDropFileReceived" object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
