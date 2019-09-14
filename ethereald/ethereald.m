#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "../MediaRemote/MediaRemote.h"
#import "TVSPreferences.h"
/*
@interface TVSPreferences : NSObject
+(id)preferencesWithDomain:(id)arg1;
+(id)addObserverForDomain:(id)arg1 withDistributedSynchronizationHandler:(void (^)(id object))arg1;
 
@end
*/
 @interface NSDistributedNotificationCenter : NSNotificationCenter
+ (id)defaultCenter;
- (void)removeObserver:(id)observer;
- (void)addObserver:(id)arg1 selector:(SEL)arg2 name:(id)arg3 object:(id)arg4;
- (void)postNotificationName:(id)arg1 object:(id)arg2 userInfo:(id)arg3;
@end

typedef enum : NSUInteger {
    SDAirDropDiscoverableModeOff,
    SDAirDropDiscoverableModeContactsOnly,
    SDAirDropDiscoverableModeEveryone,
} SDAirDropDiscoverableMode;

@interface SFAirDropDiscoveryController: UIViewController
- (void)setDiscoverableMode:(NSInteger)mode;
@end;

#define DLog(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__]);
#define APPLICATION_IDENTIFIER "com.nito.Ethereal"

@interface etherealHelper: NSObject

@property (nonatomic, strong) NSDictionary *settings;
@property (nonatomic, strong) SFAirDropDiscoveryController *discoveryController;

+ (id)sharedHelper;
- (void)adr:(NSNotification *)note;
@end

@implementation etherealHelper

- (void)reloadSettings {
    // Reload settings.
    NSLog(@"*** [ethereald] :: Reloading settings");
    CFPreferencesAppSynchronize(CFSTR(APPLICATION_IDENTIFIER));
    
    CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR(APPLICATION_IDENTIFIER), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    if (!keyList) {
        self.settings = [NSMutableDictionary dictionary];
    } else {
        CFDictionaryRef dictionary = CFPreferencesCopyMultiple(keyList, CFSTR(APPLICATION_IDENTIFIER), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        
        self.settings = [(__bridge NSDictionary *)dictionary copy];
        NSLog(@"settings: %@", self.settings);
        CFRelease(dictionary);
        CFRelease(keyList);
    }
}

- (id)getPreferenceKey:(NSString*)key {
    return [self.settings objectForKey:key];
}

- (void)disableAirDrop {
    
    DLog(@"AirDrop Disabled!");
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [self.discoveryController setDiscoverableMode:SDAirDropDiscoverableModeOff];
}

- (void)setupAirDrop {
   
    if ([self.discoveryController discoverableMode] == SDAirDropDiscoverableModeEveryone) return;
    DLog(@"AirDrop Enabled!");
    [[NSDistributedNotificationCenter defaultCenter] addObserver:[etherealHelper sharedHelper] selector:@selector(adr:) name:@"com.nito.AirDropper/airDropFileReceived" object:nil];
    self.discoveryController = [[SFAirDropDiscoveryController alloc] init] ;
    [self.discoveryController setDiscoverableMode:SDAirDropDiscoverableModeEveryone];
    
}

- (void)adr:(NSNotification *)n {
    
    __block BOOL isPassive = FALSE;
    MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef info) {
        if (info != nil){
            isPassive = true;
            DLog(@"passive");
        }
        NSDictionary *userInfo = [n userInfo];
        NSArray <NSString *>*items = userInfo[@"Items"];
        DLog(@"etherealHelper airdropped Items: %@", items);
        if (items.count > 0){
            [self processItemWithDelay:items[0] passive:isPassive];
        }
        
        NSArray <NSString *>*URLS = userInfo[@"URLS"];
        if (URLS.count > 0){
            [self processURLWithDelay:URLS[0] passive:isPassive];
        }
    });
    
}

- (NSArray *)approvedExtensions {
    
    return @[@"mov", @"mp4", @"m4v", @"mkv", @"avi", @"mp3", @"vob", @"mpg", @"mpeg", @"flv", @"wmv", @"swf", @"asf", @"rmvb", @"rm"];
    
}

- (void)processURLWithDelay:(NSString *)path passive:(BOOL)passive {
    
    NSLog(@"path ext: %@",[path pathExtension] );
    if (![[self approvedExtensions] containsObject:[path pathExtension].lowercaseString]){
        //return;
    }
    DLog(@"etherealHelper opening ethereal");
    [self openApp:@"com.nito.Ethereal"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = @{@"URLS": @[path]};
        
        DLog(@"posting notifictation with userinfo: %@", userInfo);
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.nito.Ethereal/airDropFileReceived" object:nil userInfo:userInfo];
        
    });
    
}

- (void)processItemWithDelay:(NSString *)path passive:(BOOL)passive {
    
    if (![[self approvedExtensions] containsObject:[path pathExtension].lowercaseString]){
        return;
    }
    
    //NSFileOwnerAccountName
    //NSFileGroupOwnerAccountName
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *folderAttrs = @{NSFileGroupOwnerAccountName: @"staff",NSFileOwnerAccountName: @"mobile"};
    NSError *error = nil;
    NSString *etherealFolder = @"/var/mobile/Documents/Ethereal";
    if (![man fileExistsAtPath:etherealFolder]){
        [man createDirectoryAtPath:etherealFolder withIntermediateDirectories:YES attributes:folderAttrs error:&error];
        DLog(@"error: %@", error);
    }
    
    NSString *fileName = path.lastPathComponent;
    NSString *attemptCopy = [etherealFolder stringByAppendingPathComponent:fileName];
    DLog(@"attempted path: %@", attemptCopy);
    [man moveItemAtPath:path toPath:attemptCopy error:&error];
    
    if (passive) {
        
        DLog(@"video is playing, passively show an alert");
        NSDictionary *alertDict = @{@"message": [NSString stringWithFormat:@"%@ saved. You can view it in Ethereal when you are ready.",fileName], @"title":@"AirDrop Completed!", @"imageID": @"PBSSystemBulletinImageIDTV", @"delay": @4};
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.nito.bulletinh4x/displayBulletin" object:nil userInfo:alertDict];
        
        return;
        
    }
    
    DLog(@"etherealHelper opening ethereal");
    [self openApp:@"com.nito.Ethereal"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = @{@"Items": @[attemptCopy]};
        
        DLog(@"posting notifictation with userinfo: %@", userInfo);
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.nito.Ethereal/airDropFileReceived" object:nil userInfo:userInfo];
      
    });
}

- (void)preferencesUpdated {
    
    NSString *stateKey = @"airdropServerState";
    TVSPreferences *prefs = [TVSPreferences preferencesWithDomain:@"com.nito.Ethereal"];
    BOOL serverRunning = [prefs boolForKey:stateKey];
    if (serverRunning){
        [self setupAirDrop];
    } else {
        [self disableAirDrop];
    }
}

- (void)setupListener {
    
    [TVSPreferences addObserverForDomain:@"com.nito.Ethereal" withDistributedSynchronizationHandler:^(id object) {
        [self preferencesUpdated];
    }];
    
}

- (void)openApp:(NSString *)bundleID {
    
    id workspace = nil;
    NSString *mcs = @"/System/Library/Frameworks/MobileCoreServices.framework/";
    NSBundle *bundle = [NSBundle bundleWithPath:mcs];
    NSError *theError = nil;
    [bundle loadAndReturnError:&theError];
    DLog(@"the error: %@", theError);
    Class LSApplicationWorkspace_class = objc_getClass("LSApplicationWorkspace");
    if (!LSApplicationWorkspace_class) {
        fprintf(stderr,"Unable to get Workspace class\n");
    }
    workspace = [LSApplicationWorkspace_class performSelector:@selector (defaultWorkspace)];
    if (!workspace) {fprintf(stderr,"Unable to get Workspace\n"); }

    if (workspace){
        [workspace performSelector:@selector(openApplicationWithBundleID:) withObject:(id) bundleID ];
    }
    
}
     

+ (id)sharedHelper
{
    static dispatch_once_t onceToken;
    
    static etherealHelper *shared = nil;
    if(shared == nil)
    {
        dispatch_once(&onceToken, ^{
            shared = [[etherealHelper alloc] init];
            [shared setupListener];
            [shared reloadSettings];
            [shared preferencesUpdated];
        });
    }
    return shared;
}


@end


int main(int argc, char* argv[])
{
    DLog(@"\ethereald: LOADED\n\n");
    
    etherealHelper *helper = [etherealHelper sharedHelper];
  
    //[helper setupAirDrop];
    
    CFRunLoopRun();
    return 0;
}

