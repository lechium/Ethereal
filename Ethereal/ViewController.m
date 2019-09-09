//
//  ViewController.m
//  Ethereal
//
//  Created by Kevin Bradley on 9/8/19.
//  Copyright © 2019 nito. All rights reserved.
//

#import "ViewController.h"
#import "PlayerViewController.h"
#import <tvOSAVPlayerTouch/tvOSAVPlayerTouch.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>



@interface ViewController ()

@property (nonatomic, strong) NSString *currentPath;


@end

@implementation ViewController

- (void)enterDirectory {
    
    LOG_SELF;
    NSIndexPath *ip = [self savedIndexPath];
    MetaDataAsset  *mda = self.items[ip.row];
    NSString *fullPath = [[self currentPath] stringByAppendingPathComponent:mda.name];
    ViewController *vc = [[ViewController alloc] initWithDirectory:fullPath];
    [[self navigationController] pushViewController:vc animated:true];
    
}

- (void)playFile {
    
    LOG_SELF;
    
    NSIndexPath *ip = [self savedIndexPath];
    MetaDataAsset  *mda = self.items[ip.row];
    NSString *fullPath = [[self currentPath] stringByAppendingPathComponent:mda.name];
    NSLog(@"fullPath: %@", fullPath);
    [self showPlayerViewWithFile:fullPath];
    
    
    
}

- (NSArray *)approvedExtensions {
    
    return @[@"mov", @"mp4", @"m4v", @"mkv", @"avi", @"mp3", @"vob", @"mpg", @"mpeg", @"flv", @"wmv", @"swf", @"asf", @"rmvb", @"rm"];
    
}


- (NSArray *)currentItems {
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSArray *contents = [man contentsOfDirectoryAtPath:self.currentPath error:nil];
    __block NSMutableArray *itemArray = [NSMutableArray new];
    [contents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *fullPath = [self.currentPath stringByAppendingPathComponent:obj];
        NSDictionary *attrs = [man attributesOfItemAtPath:fullPath error:nil];
        BOOL isDirectory = [attrs[NSFileType] isEqual:NSFileTypeDirectory];
        
        if ([[self approvedExtensions] containsObject:[obj pathExtension].lowercaseString] || isDirectory){
            MetaDataAsset *currentAsset = [MetaDataAsset new];
            currentAsset.name = obj;
            if (isDirectory){
                currentAsset.selectorName = @"enterDirectory";
                currentAsset.imagePath = @"folder";
            } else {
                currentAsset.selectorName = @"playFile";
                currentAsset.imagePath = @"video-icon";
            }
            [itemArray addObject:currentAsset];
        }
        
        
    }];
    
    return itemArray;
    
}

- (id)initWithDirectory:(NSString *)directory {
    
    self = [super init];
    self.currentPath = directory;
    self.title = directory.lastPathComponent;
    return self;
    
}

- (NSArray *)defaultCompatFiles {
    
    return @[@"mp4", @"mpeg4", @"m4v", @"mov"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    LOG_SELF;
    [self refreshList];
    if (self.shouldExit){
     //   [[UIApplication sharedApplication] terminateWithSuccess];
       // [self dismissViewControllerAnimated:true completion:nil];
    }
}

- (void)showPlayerViewWithFile:(NSString *)theFile {
    
    if ([[self defaultCompatFiles] containsObject:theFile.pathExtension.lowercaseString]){
        
        NSLog(@"default compat files contains %@", theFile);
        AVPlayerViewController *playerView = [[AVPlayerViewController alloc] init];
        AVPlayerItem *singleItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:theFile]];
        
        playerView.player = [AVQueuePlayer playerWithPlayerItem:singleItem];
        self.shouldExit = true;
        [self presentViewController:playerView animated:YES completion:nil];
        [playerView.player play];
        
        return;
    }
    
    PlayerViewController *playerController = [PlayerViewController new];
    playerController.mediaURL = [NSURL fileURLWithPath:theFile];
    [self presentViewController:playerController animated:true completion:nil];
    self.shouldExit = true;
}

- (void)refreshList {
 
    self.items = [self currentItems];
    [[self tableView] reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    LOG_SELF;
    self.view.alpha = 1;
 
    if (self.currentPath == nil){
        self.currentPath = @"/var/mobile/Documents";
    }
    self.items = [self currentItems];
    self.title = self.currentPath.lastPathComponent;
    
    // Do any additional setup after loading the view, typically from a nib.
}


@end
