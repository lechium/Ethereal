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
#import "SDWebImageManager.h"


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

- (void)itemDidFinishPlaying:(NSNotification *)n
{
    
    [self dismissViewControllerAnimated:true completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:n.object];
    
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
                currentAsset.defaultImageName = @"folder";
                
            } else {
                
                __block UIImage *currentImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:currentAsset.name];
                
                NSLog(@"image from cache: %@", currentImage);
                
                if (!currentImage){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                       
                        FFAVParser *mp = [[FFAVParser alloc] init];
                        if ([mp openMedia:[NSURL fileURLWithPath:fullPath] withOptions:nil]) {
                            currentImage = [mp thumbnailAtTime:fminf(20, mp.duration/2.0)];
                            if (currentImage){
                                NSLog(@"thumbnails: %@", currentImage);
                                mp = nil;
                            }
                            
                            
                        }
                        // currentImage = [UIImage imageWithContentsOfFile:currentAsset.imagePath];
                        [[SDImageCache sharedImageCache] storeImage:currentImage forKey:currentAsset.name];
                    });
                }
                
                currentAsset.selectorName = @"playFile";
                currentAsset.defaultImageName = @"video-icon";
                currentAsset.accessory = false;
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:singleItem];
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

- (void)editSettings:(id)sender {
    
    [self.tableView setEditing:!self.tableView.editing animated:true];
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self.tableView isEditing]){
        return UITableViewCellEditingStyleNone;
    }
    NSFileManager *man = [NSFileManager defaultManager];
    MetaDataAsset  *mda = self.items[indexPath.row];
    NSString *fullPath = [[self currentPath] stringByAppendingPathComponent:mda.name];
    NSDictionary *attrs = [man attributesOfItemAtPath:fullPath error:nil];
    BOOL isDirectory = [attrs[NSFileType] isEqual:NSFileTypeDirectory];
    if (!isDirectory){
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    LOG_SELF;
    NSLog(@"editingStyle : %li, indexPath: %@", (long)editingStyle, indexPath);
    NSFileManager *man = [NSFileManager defaultManager];
    MetaDataAsset  *mda = self.items[indexPath.row];
    NSString *fullPath = [[self currentPath] stringByAppendingPathComponent:mda.name];
    NSString *messageString = [NSString stringWithFormat:@"Are you sure you want to delete '%@'? This is permanent and cannot be undone.", mda.name];
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Delete Item?" message:messageString preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [man removeItemAtPath:fullPath error:nil];
        [self refreshList];
        //DLog(@"do it");
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    
    [ac addAction: cancel];
    [ac addAction:action];
    [self presentViewController:ac animated:TRUE completion:nil];
}

- (void)settingsTest:(id)sender {
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:url];
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editSettings:)];
    
    UIImage *image = [UIImage imageNamed:@"gear-small"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(settingsTest:)];
}


@end
