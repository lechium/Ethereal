//
//  ViewController.m
//  Ethereal
//
//  Created by Kevin Bradley on 9/8/19.
//  Copyright © 2019 nito. All rights reserved.
//

#import "ViewController.h"
//#import "PlayerViewController.h"
//#import <tvOSAVPlayerTouch/tvOSAVPlayerTouch.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "SDWebImageManager.h"
#import "KBVideoPlaybackManager.h"
#import "UIViewController+Presentation.h"
#import "KBAirDropHelper.h"
#import "KBBulletinView.h"


//#import "SGPlayerViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *currentPath;
@end

@implementation ViewController

- (void)mediaThumbnailerDidTimeOut:(VLCMediaThumbnailer *)mediaThumbnailer {
    ELog(@"thumbnailer: %@ timed out!", mediaThumbnailer);
}

- (void)mediaThumbnailer:(VLCMediaThumbnailer *)mediaThumbnailer didFinishThumbnail:(CGImageRef)thumbnail {
    ELog(@"thumbnailer: %@ didFinishThumbnail: %@", mediaThumbnailer, thumbnail);
    VLCMedia *media = [mediaThumbnailer media];
    UIImage *currentImage = [UIImage imageWithCGImage:thumbnail];
    ELog(@"saving thumbnail: %@ for key: %@", currentImage, media.url.path.lastPathComponent);
    [[SDImageCache sharedImageCache] storeImage:currentImage forKey:media.url.path.lastPathComponent];
}

- (void)showSampleBulletin {
    KBBulletinView *bv = [KBBulletinView bulletinWithTitle:@"Test Title" description:@"Test Description" image:[UIImage imageNamed:@"video-icon"]];
    NSString *famName = [[UIFont familyNames] firstObject];
    [bv setTitleFont:[UIFont fontWithName:famName size:29]];
    [bv setDescriptionFont:[UIFont fontWithName:famName size:23]];
    [bv showForTime:5];
}

- (void)enterDirectory {
    NSIndexPath *ip = [self savedIndexPath];
    MetaDataAsset  *mda = self.items[ip.row];
    NSString *fullPath = [[self currentPath] stringByAppendingPathComponent:mda.name];
    ViewController *vc = [[ViewController alloc] initWithDirectory:fullPath];
    [[self navigationController] pushViewController:vc animated:true];
}

- (void)playFile {
    KBVideoPlaybackManager *man = [KBVideoPlaybackManager defaultManager];
    [man setPlaybackIndex:self.savedIndexPath.row];
    UIViewController *playerController = [man playerForCurrentIndex];
    [KBVideoPlaybackManager defaultManager].videoDidFinishPlaying = ^(BOOL moreLeft) {
        NSLog(@"video did finish playing! more left: %d", moreLeft);
        if (!moreLeft) {
            [self dismissViewControllerAnimated:true completion:nil];
        }
    };
    [self safePresentViewController:playerController animated:true completion:nil];
}

- (NSArray *)currentItems {
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSArray *contents = [man contentsOfDirectoryAtPath:self.currentPath error:nil];
    __block NSMutableArray *itemArray = [NSMutableArray new];
    [contents enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *fullPath = [self.currentPath stringByAppendingPathComponent:obj];
        NSDictionary *attrs = [man attributesOfItemAtPath:fullPath error:nil];
        BOOL isDirectory = [attrs[NSFileType] isEqual:NSFileTypeDirectory];
        BOOL isLink = [attrs[NSFileType] isEqual:NSFileTypeSymbolicLink];
        NSError *linkError = nil;
        if (isLink){
            [man contentsOfDirectoryAtPath:fullPath error:&linkError];
            if (linkError){
                NSLog(@"there was a link error: %@", linkError);
            } else {
                isDirectory = true;
            }
        }
        if ([[KBVideoPlaybackManager approvedExtensions] containsObject:[obj pathExtension].lowercaseString] || isDirectory){
            KBMediaAsset *currentAsset = [KBMediaAsset new];
            currentAsset.filePath = fullPath;
            currentAsset.name = obj;
            if (isDirectory){
                currentAsset.selectorName = @"enterDirectory";
                currentAsset.defaultImageName = @"folder";
                currentAsset.assetType = KBMediaAssetTypeDirectory;
                
            } else {
                if ([[KBVideoPlaybackManager defaultCompatFiles] containsObject:[obj pathExtension].lowercaseString]) {
                    currentAsset.assetType = KBMediaAssetTypeVideoDefault;
                } else {
                    currentAsset.assetType = KBMediaAssetTypeVideoCustom;
                }
                unsigned long long fileSize = [attrs[NSFileSize] unsignedLongLongValue];
                NSDate *creationDate = attrs[NSFileCreationDate];
                NSString *fileSizeString = [NSString stringWithFormat:@"%lld MB", fileSize/1024/1024];
                currentAsset.metaDictionary = @{@"File Size": fileSizeString, @"Created": creationDate.description};
                __block UIImage *currentImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:currentAsset.name];
                
                NSLog(@"image from cache: %@", currentImage);
                
                if (!currentImage){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        VLCMedia *media = [VLCMedia mediaWithPath:fullPath];
                        VLCMediaThumbnailer *thumbNailer = [VLCMediaThumbnailer thumbnailerWithMedia:media andDelegate:self];
                        [thumbNailer fetchThumbnail];
                        /*
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
                         */
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

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self refreshList];
}

- (void)refreshList {
    
    self.items = [self currentItems];
    [[KBVideoPlaybackManager defaultManager] setMedia:[self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"assetType != %lu", KBMediaAssetTypeDirectory]]];
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
    [self safePresentViewController:ac animated:TRUE completion:nil];
}

- (void)settingsTest:(id)sender {
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
}
//url = [NSURL URLWithString:app-settings:]
- (NSString *)cachesFolder {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (NSString *)documentsFolder {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}



- (void)airdropFile:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"What file do you want to AirDrop?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    for (KBMediaAsset *item in [[KBVideoPlaybackManager defaultManager] media]) {
        [alertController addAction:[UIAlertAction actionWithTitle:item.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [KBAirDropHelper airdropFile:item.filePath];
        }]];
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self safePresentViewController:alertController animated:true completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.alpha = 1;
    
    if (self.currentPath == nil){
        self.currentPath = @"/var/mobile/Documents";
    }
    self.items = [self currentItems];
    self.title = self.currentPath.lastPathComponent;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editSettings:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(airdropFile:)];
//    UIImage *image = [UIImage imageNamed:@"gear-small"];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(settingsTest:)];
}


@end
