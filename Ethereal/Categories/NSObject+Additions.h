
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
@interface NSURL (QSParameters)

- (NSArray *)parameterArray;
- (NSDictionary *)parameterDictionary;

@end

@interface NSObject (Additions)

- (void)addCookies:(NSArray *)cookies forRequest:(NSMutableURLRequest *)request;
- (void)clearAllProperties;
- (void)associateValue:(id)value withKey:(void *)key; // Strong reference
- (void)weaklyAssociateValue:(id)value withKey:(void *)key;
- (id)associatedValueForKey:(void *)key;
- (NSArray *)allFonts;
- (void)classDumpObject:(id)object;
- (NSString *)JSONString;
- (NSString *)PrettyJSONString;
- (void)showHUD;
- (UIViewController *)topViewController;
-(NSArray *)ivars;
- (NSArray *)properties;
@end
