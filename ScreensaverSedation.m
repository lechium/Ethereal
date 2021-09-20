//this doesn't really exist in nsobject this was just to get it compiling, keeping around for posterity.

@interface NSObject (h4x)
-(id)initWithDomain:(NSString *)domain notifyChanges:(BOOL)notify;
-(NSInteger)activationDelay;
-(void)setActivationDelay:(NSInteger)activationDelay;
@end

- (NSString *)tvsPath {
    return @"/System/Library/PrivateFrameworks/TVSettingKit.framework";
}

- (void)loadTVSettings {
    NSBundle *b = [NSBundle bundleWithPath: [self tvsPath]];
    [b load];
    id tempFacade = [[NSClassFromString(@"TSKPreferencesFacade") alloc] initWithDomain: @"com.apple.TVScreenSaver" notifyChanges: true];
    screenSaverFacade = [tempFacade valueForKey:@"_prefs"];
}

- (void)_syncSSPrefs {
    [self loadTVSettings];
    screenSaverTimeout = [screenSaverFacade activationDelay];
    
}

- (void)toggleScreenSaver:(BOOL)isOn {
    if (isOn) {
        [screenSaverFacade setActivationDelay:screenSaverTimeout];
    } else {
        [screenSaverFacade setActivationDelay:0];
    }
}

- (void)killCFPrefsd {
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall" arguments:@[@"-9", @"cfprefsd"]];
}
