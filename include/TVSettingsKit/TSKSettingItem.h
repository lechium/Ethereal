/*
* This header is generated by classdump-dyld 1.0
* on Sunday, July 22, 2018 at 11:13:54 PM Mountain Standard Time
* Operating System: Version 11.3 (Build 15L211)
* Image Source: /System/Library/PrivateFrameworks/TVSettingKit.framework/TVSettingKit
* classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
*/


@class NSMutableArray, NSString, NSArray, NSFormatter, TSKBundleLoader, NSAttributedString;

@interface TSKSettingItem : NSObject {

	NSMutableArray* _konamiCodes;
	BOOL _shouldPresentChildController;
	BOOL _canFocus;
	BOOL _enabled;
	BOOL _editable;
	BOOL _hidden;
	BOOL _sortsByTitle;
	BOOL _readOnly;
	BOOL _deepLinkableWhenHidden;
	BOOL _enabledInStoreDemoMode;
	BOOL _removeAfterDeletion;
	BOOL _dirty;
	id _representedObject;
	NSString* _keyPath;
	id _defaultValue;
	NSString* _localizedTitle;
	NSString* _localizedValue;
	NSArray* _availableValues;
	NSFormatter* _localizedValueFormatter;
	NSString* _localizedDescription;
	/*^block*/id _updateBlock;
	SEL _action;
	SEL _playButtonAction;
	id _target;
	Class _childControllerClass;
	/*^block*/id _childControllerBlock;
	unsigned long long _accessoryTypes;
	TSKBundleLoader* _bundleLoader;
	NSString* _deepLinkKey;
	NSFormatter* _detailedLocalizedValueFormatter;
	NSString* _detailedLocalizedTitle;
	NSAttributedString* _attributedLocalizedDescription;
	NSString* _identifier;
	SEL _longPressAction;
	SEL _rightButtonAction;

}

@property (nonatomic,retain) TSKBundleLoader * bundleLoader;                                           //@synthesize bundleLoader=_bundleLoader - In the implementation block
@property (getter=isReadOnly,nonatomic,readonly) BOOL readOnly;                                        //@synthesize readOnly=_readOnly - In the implementation block
@property (nonatomic,copy) NSString * deepLinkKey;                                                     //@synthesize deepLinkKey=_deepLinkKey - In the implementation block
@property (assign,nonatomic) BOOL deepLinkableWhenHidden;                                              //@synthesize deepLinkableWhenHidden=_deepLinkableWhenHidden - In the implementation block
@property (nonatomic,retain) NSFormatter * detailedLocalizedValueFormatter;                            //@synthesize detailedLocalizedValueFormatter=_detailedLocalizedValueFormatter - In the implementation block
@property (nonatomic,copy) NSString * detailedLocalizedTitle;                                          //@synthesize detailedLocalizedTitle=_detailedLocalizedTitle - In the implementation block
@property (nonatomic,copy) NSAttributedString * attributedLocalizedDescription;                        //@synthesize attributedLocalizedDescription=_attributedLocalizedDescription - In the implementation block
@property (assign,getter=isEnabledInStoreDemoMode,nonatomic) BOOL enabledInStoreDemoMode;              //@synthesize enabledInStoreDemoMode=_enabledInStoreDemoMode - In the implementation block
@property (assign,nonatomic) BOOL removeAfterDeletion;                                                 //@synthesize removeAfterDeletion=_removeAfterDeletion - In the implementation block
@property (nonatomic,copy) NSString * identifier;                                                      //@synthesize identifier=_identifier - In the implementation block
@property (assign,getter=isDirty,nonatomic) BOOL dirty;                                                //@synthesize dirty=_dirty - In the implementation block
@property (assign,nonatomic) SEL longPressAction;                                                      //@synthesize longPressAction=_longPressAction - In the implementation block
@property (assign,nonatomic) SEL rightButtonAction;                                                    //@synthesize rightButtonAction=_rightButtonAction - In the implementation block
@property (nonatomic,readonly) NSArray * konamiCodes; 
@property (nonatomic,readonly) id representedObject;                                                   //@synthesize representedObject=_representedObject - In the implementation block
@property (nonatomic,copy,readonly) NSString * keyPath;                                                //@synthesize keyPath=_keyPath - In the implementation block
@property (nonatomic,retain) id defaultValue;                                                          //@synthesize defaultValue=_defaultValue - In the implementation block
@property (nonatomic,copy) NSString * localizedTitle;                                                  //@synthesize localizedTitle=_localizedTitle - In the implementation block
@property (nonatomic,copy) NSString * localizedValue;                                                  //@synthesize localizedValue=_localizedValue - In the implementation block
@property (nonatomic,copy) NSArray * availableValues;                                                  //@synthesize availableValues=_availableValues - In the implementation block
@property (nonatomic,retain) NSFormatter * localizedValueFormatter;                                    //@synthesize localizedValueFormatter=_localizedValueFormatter - In the implementation block
@property (nonatomic,copy) NSString * localizedDescription;                                            //@synthesize localizedDescription=_localizedDescription - In the implementation block
@property (nonatomic,copy) id updateBlock;                                                             //@synthesize updateBlock=_updateBlock - In the implementation block
@property (assign,nonatomic) SEL action;                                                               //@synthesize action=_action - In the implementation block
@property (assign,nonatomic) SEL playButtonAction;                                                     //@synthesize playButtonAction=_playButtonAction - In the implementation block
@property (assign,nonatomic,weak) id target;                                                         //@synthesize target=_target - In the implementation block
@property (nonatomic,retain) Class childControllerClass;                                               //@synthesize childControllerClass=_childControllerClass - In the implementation block
//@property (nonatomic,copy) id childControllerBlock;                                                    //@synthesize childControllerBlock=_childControllerBlock - In the implementation block
@property (copy, nonatomic) id (^childControllerBlock)(id theObject);
@property (assign,nonatomic) BOOL shouldPresentChildController;                                        //@synthesize shouldPresentChildController=_shouldPresentChildController - In the implementation block
@property (assign,nonatomic) BOOL canFocus;                                                            //@synthesize canFocus=_canFocus - In the implementation block
@property (assign,getter=isEnabled,nonatomic) BOOL enabled;                                            //@synthesize enabled=_enabled - In the implementation block
@property (assign,getter=isEditable,nonatomic) BOOL editable;                                          //@synthesize editable=_editable - In the implementation block
@property (assign,getter=isHidden,nonatomic) BOOL hidden;                                              //@synthesize hidden=_hidden - In the implementation block
@property (assign,nonatomic) unsigned long long accessoryTypes;                                        //@synthesize accessoryTypes=_accessoryTypes - In the implementation block
@property (assign,nonatomic) BOOL sortsByTitle;                                                        //@synthesize sortsByTitle=_sortsByTitle - In the implementation block
+(id)childPaneItemWithBundle:(id)arg1 representedObject:(id)arg2 ;
+(id)valueForSettingItem:(id)arg1 ;
+(void)setValue:(id)arg1 forSettingItem:(id)arg2 ;
+(id)actionItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 target:(id)arg5 action:(SEL)arg6 ;
+(id)childPaneItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 childControllerClass:(Class)arg5 ;
+(id)childPaneItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 childControllerBlock:(id (^)(id object))completionBlock ;
+(id)childPaneItemWithBundle:(id)arg1 ;
+(id)titleItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 ;
+(id)textInputItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 ;
+(id)toggleItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 onTitle:(id)arg5 offTitle:(id)arg6 ;
+(id)multiValueItemWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 availableValues:(id)arg5 ;
-(void)setLocalizedDescription:(NSString *)arg1 ;
-(id)init;
-(void)setHidden:(BOOL)arg1 ;
-(BOOL)isHidden;
-(id)description;
-(NSString *)identifier;
-(NSString *)localizedDescription;
-(SEL)action;
-(BOOL)isEditable;
-(BOOL)isEnabled;
-(void)setEnabled:(BOOL)arg1 ;
-(void)setIdentifier:(NSString *)arg1 ;
-(void)setTarget:(id)arg1 ;
-(id)target;
-(NSString *)keyPath;
-(void)setAction:(SEL)arg1 ;
-(void)setEditable:(BOOL)arg1 ;
-(SEL)longPressAction;
-(id)defaultValue;
-(NSString *)localizedTitle;
-(void)setLocalizedTitle:(NSString *)arg1 ;
-(void)setDirty:(BOOL)arg1 ;
-(id)representedObject;
-(void)setLocalizedValue:(NSString *)arg1 ;
-(NSString *)localizedValue;
-(BOOL)isDirty;
-(void)setLongPressAction:(SEL)arg1 ;
-(void)setDefaultValue:(id)arg1 ;
-(id)_metadata;
-(id)updateBlock;
-(void)setUpdateBlock:(id)arg1 ;
-(BOOL)isReadOnly;
-(BOOL)canFocus;
-(void)setCanFocus:(BOOL)arg1 ;
-(id)initWithTitle:(id)arg1 description:(id)arg2 representedObject:(id)arg3 keyPath:(id)arg4 readOnly:(BOOL)arg5 accessoryTypes:(unsigned long long)arg6 childControllerClass:(Class)arg7 ;
-(void)setAttributedLocalizedDescription:(NSAttributedString *)arg1 ;
-(void)setAvailableValues:(NSArray *)arg1 ;
-(void)setLocalizedValueFormatter:(NSFormatter *)arg1 ;
-(void)setDetailedLocalizedValueFormatter:(NSFormatter *)arg1 ;
-(void)setAccessoryTypes:(unsigned long long)arg1 ;
-(void)setSortsByTitle:(BOOL)arg1 ;
-(void)setDeepLinkableWhenHidden:(BOOL)arg1 ;
//-(id)childControllerBlock;

-(Class)childControllerClass;
//-(void)setChildControllerBlock:(id)arg1 ;
-(void)setEnabledInStoreDemoMode:(BOOL)arg1 ;
-(void)setBundleLoader:(TSKBundleLoader *)arg1 ;
-(TSKBundleLoader *)bundleLoader;
-(void)setShouldPresentChildController:(BOOL)arg1 ;
-(NSArray *)konamiCodes;
-(void)addKonamiCode:(id)arg1 ;
-(void)_performUpdateTransactionWithBlock:(/*^block*/id)arg1 ;
-(void)_cloneStateToItem:(id)arg1 ;
-(void)_preloadViewController;
-(NSArray *)availableValues;
-(NSFormatter *)localizedValueFormatter;
-(SEL)playButtonAction;
-(void)setPlayButtonAction:(SEL)arg1 ;
-(void)setChildControllerClass:(Class)arg1 ;
-(BOOL)shouldPresentChildController;
-(unsigned long long)accessoryTypes;
-(BOOL)sortsByTitle;
-(NSString *)deepLinkKey;
-(void)setDeepLinkKey:(NSString *)arg1 ;
-(BOOL)deepLinkableWhenHidden;
-(NSFormatter *)detailedLocalizedValueFormatter;
-(NSString *)detailedLocalizedTitle;
-(void)setDetailedLocalizedTitle:(NSString *)arg1 ;
-(NSAttributedString *)attributedLocalizedDescription;
-(BOOL)isEnabledInStoreDemoMode;
-(BOOL)removeAfterDeletion;
-(void)setRemoveAfterDeletion:(BOOL)arg1 ;
-(SEL)rightButtonAction;
-(void)setRightButtonAction:(SEL)arg1 ;
@end
