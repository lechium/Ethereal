

#import "EtherealSettings.h"
#import <TVSettingsKit/TSKTextInputSettingItem.h>
#import <MobileCoreServices/LSApplicationWorkspace.h>
#import <MobileCoreServices/LSApplicationProxy.h>

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <spawn.h>
#include <sys/wait.h>

#include <string.h>
#include <math.h>
#include <sys/stat.h>
#include <sys/param.h>


@interface LSApplicationProxy (More)
+(id)applicationProxyForIdentifier:(id)arg1;
-(BOOL)isContainerized;
-(NSURL *)dataContainerURL;
@end

@interface LSApplicationWorkspace (More)

-(id)allInstalledApplications;
-(BOOL)openApplicationWithBundleID:(id)arg1;

@end


@interface EtherealSettings() {
    
}
@property (nonatomic, strong) NSString *importsPath;
@property (nonatomic, strong) NSString *defaultBundleID;
@end

@implementation EtherealSettings



- (void)sendBulletinWithMessage:(NSString *)message title:(NSString *)title {
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[@"message"] = message;
    dict[@"title"] = title;
    dict[@"timeout"] = @2;
    
    NSString *imagePath = [[NSBundle bundleForClass:self.class] pathForResource:@"icon" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    if (imageData){
        dict[@"imageData"] = imageData;
    }
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.nito.bulletinh4x/displayBulletin" object:nil userInfo:dict];
    
}


- (void)openEthereal {
    
    LSApplicationWorkspace *ws = [LSApplicationWorkspace defaultWorkspace];
    [ws openApplicationWithBundleID:@"com.nito.Ethereal"];
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    NSLog(@"EtherealSettings viewWillAppear");
    
}

- (id)loadSettingGroups {


    id facade = [[NSClassFromString(@"TVSettingsPreferenceFacade") alloc] initWithDomain:@"com.nito.Ethereal" notifyChanges:TRUE];
    NSMutableArray *_backingArray = [NSMutableArray new];
    TSKSettingItem *settingsItem = [TSKSettingItem toggleItemWithTitle:@"Toggle AirDrop Server" description:@"Turn on AirDrop to receive multimedia files and URLs for importing and playback in Ethereal" representedObject:facade keyPath:@"airdropServerState" onTitle:nil offTitle:nil];
    //NSLog(@"created settings item: %@", settingsItem);
    
    TSKSettingItem *openItem = [TSKSettingItem actionItemWithTitle:@"Open Ethereal" description:@"A Shortcut to open Ethereal" representedObject:facade keyPath:@"" target:self action:@selector(openEthereal)];
    TSKSettingGroup *group = [TSKSettingGroup groupWithTitle:nil settingItems:@[settingsItem, openItem]];
    [_backingArray addObject:group];
    [self setValue:_backingArray forKey:@"_settingGroups"];
    
    return _backingArray;
    
}

-(id)previewForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    TSKPreviewViewController *item = [super previewForItemAtIndexPath:indexPath];
    TSKSettingGroup *currentGroup = self.settingGroups[indexPath.section];
    TSKSettingItem *currentItem = currentGroup.settingItems[indexPath.row];
    NSString *imagePath = [[NSBundle bundleForClass:self.class] pathForResource:@"icon" ofType:@"jpg"];
    UIImage *icon = [UIImage imageWithContentsOfFile:imagePath];
    if (icon != nil) {
        TSKVibrantImageView *imageView = [[TSKVibrantImageView alloc] initWithImage:icon];
        [item setContentView:imageView];
    }
    
    return item;
    
}


@end
