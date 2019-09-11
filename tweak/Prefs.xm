@interface _TVSettingsOpenURLConfig : NSObject

+ (id)_keyValueDictionaryForURL:(id)arg1;	// IMP=0x00000001000d1b2c
+ (id)configWithPrefsURL:(id)arg1;	// IMP=0x00000001000d12b8
+ (id)configWithAppSettingsURL:(id)arg1;	// IMP=0x00000001000d117c
+ (id)configWithSettingsURL:(id)arg1;	// IMP=0x00000001000d10cc
@property(nonatomic) _Bool shouldActivateLastComponent; // @synthesize shouldActivateLastComponent=_shouldActivateLastComponent;
@property(copy, nonatomic) NSArray *parsedPathComponents; // @synthesize parsedPathComponents=_parsedPathComponents;
@property(copy, nonatomic) NSDictionary *parameters; // @synthesize parameters=_parameters;
@property(copy, nonatomic) NSURL *originalURL; // @synthesize originalURL=_originalURL;
@end

%hook TVSettingsAppDelegate

- (_Bool)_openURLConfiguration:(id)arg1 {
	
	%log;
	BOOL orig = %orig;
	NSArray *parsedPathComponents = [arg1 parsedPathComponents];
	NSURL *origUrl = [arg1 originalURL];
	HBLogDebug(@"parsedPathComponents: %@", parsedPathComponents);
	HBLogDebug(@"origUrl: %@", origUrl);
	if (parsedPathComponents.count > 0){
		NSString *identifier = parsedPathComponents.lastObject;
		HBLogDebug(@"identifier: %@", identifier);
		if ([identifier isEqualToString:@"com.nito.Ethereal"]){
			id controller = [NSClassFromString(@"TVSettingsTweakViewController") new];
			[[[[self window] rootViewController] navigationController] pushViewController:controller animated:FALSE];
			return YES;
		}
	}
	//- (id)_findFirstViewOfClass:(Class)arg1 inViewHierarchy:(id)arg2 depth:(int)arg3
	return orig;
}

- (_Bool)application:(id)arg1 openURL:(id)arg2 options:(id)arg3 {

	%log;
	return %orig;
}

%end

