#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@interface NSDistributedNotificationCenter : NSNotificationCenter
+ (id)defaultCenter;
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

@interface etherealHelper: NSObject

@property (nonatomic, strong) SFAirDropDiscoveryController *discoveryController;
+ (id)sharedHelper;
- (void)adr:(NSNotification *)note;
@end

@implementation etherealHelper

- (void)disableAirDrop {
    
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:@"com.nito.AirDropper/airDropFileReceived" object:nil];
    [self.discoveryController setDiscoverableMode:SDAirDropDiscoverableModeOff];
}

- (void)setupAirDrop {
   
    [[NSDistributedNotificationCenter defaultCenter] addObserver:[etherealHelper sharedHelper] selector:@selector(adr:) name:@"com.nito.AirDropper/airDropFileReceived" object:nil];
    self.discoveryController = [[SFAirDropDiscoveryController alloc] init] ;
    [self.discoveryController setDiscoverableMode:SDAirDropDiscoverableModeEveryone];
    
}

- (void)adr:(NSNotification *)n {
    
    NSDictionary *userInfo = [n userInfo];
    NSArray <NSString *>*items = userInfo[@"Items"];
    DLog(@"etherealHelper airdropped Items: %@", items);
    if (items.count > 0){
        [self processItemWithDelay:items[0]];
        //[self showPlayerViewWithFile:items[0]];
    }
    
     NSArray <NSString *>*URLS = userInfo[@"URLS"];
    if (URLS.count > 0){
        [self processURLWithDelay:URLS[0]];
        //[self showPlayerViewWithFile:items[0]];
    }
    
}

- (NSArray *)approvedExtensions {
    
    return @[@"mov", @"mp4", @"m4v", @"mkv", @"avi", @"mp3", @"vob", @"mpg", @"mpeg", @"flv", @"wmv", @"swf", @"asf", @"rmvb", @"rm"];
    
}

- (void)processURLWithDelay:(NSString *)path {
    
    NSLog(@"path ext: %@",[path pathExtension] );
    if (![[self approvedExtensions] containsObject:[path pathExtension].lowercaseString]){
        return;
    }
    DLog(@"etherealHelper opening ethereal");
    [self openApp:@"com.nito.Ethereal"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = @{@"URLS": @[path]};
        
        DLog(@"posting notifictation with userinfo: %@", userInfo);
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.nito.Ethereal/airDropFileReceived" object:nil userInfo:userInfo];
        
    });
    
}

- (void)processItemWithDelay:(NSString *)path {
    
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
    DLog(@"etherealHelper opening ethereal");
    [self openApp:@"com.nito.Ethereal"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        NSDictionary *userInfo = @{@"Items": @[attemptCopy]};
        
        DLog(@"posting notifictation with userinfo: %@", userInfo);
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.nito.Ethereal/airDropFileReceived" object:nil userInfo:userInfo];
      
    });
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
        });
    }
    return shared;
}


@end


int main(int argc, char* argv[])
{
    DLog(@"\ethereald: LOADED\n\n");
    
    etherealHelper *helper = [etherealHelper sharedHelper];
  
    [helper setupAirDrop];
    
    CFRunLoopRun();
    return 0;
}

