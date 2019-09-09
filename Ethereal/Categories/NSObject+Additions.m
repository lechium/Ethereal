
#import "NSObject+Additions.h"
#import "UIWindow+Additions.h"
#import "SVProgressHUD.h"

@implementation NSURL (QSParameters)
- (NSArray *)parameterArray {
    
    if (![self query]) return nil;
    NSScanner *scanner = [NSScanner scannerWithString:[self query]];
    if (!scanner) return nil;
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *key;
    NSString *val;
    while (![scanner isAtEnd]) {
        if (![scanner scanUpToString:@"=" intoString:&key]) key = nil;
        [scanner scanString:@"=" intoString:nil];
        if (![scanner scanUpToString:@"&" intoString:&val]) val = nil;
        [scanner scanString:@"&" intoString:nil];
        
        key = [key stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        val = [val stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if (key) [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   key, @"key", val, @"value", nil]];
    }
    return array;
}


- (NSDictionary *)parameterDictionary {
    if (![self query]) return nil;
    NSArray *parameterArray = [self parameterArray];
    
    NSArray *keys = [parameterArray valueForKey:@"key"];
    NSArray *values = [parameterArray valueForKey:@"value"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    return dictionary;
}

@end

@implementation NSObject (Additions)

- (void)addCookies:(NSArray *)cookies forRequest:(NSMutableURLRequest *)request
{
    if ([cookies count] > 0)
    {
        NSHTTPCookie *cookie;
        NSString *cookieHeader = nil;
        for (cookie in cookies)
        {
            if (!cookieHeader)
            {
                cookieHeader = [NSString stringWithFormat: @"%@=%@",[cookie name],[cookie value]];
            }
            else
            {
                cookieHeader = [NSString stringWithFormat: @"%@; %@=%@",cookieHeader,[cookie name],[cookie value]];
            }
        }
        if (cookieHeader)
        {
            [request setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
        }
    }
}

- (UIViewController *)topViewController
{
    return [[[UIApplication sharedApplication] keyWindow] visibleViewController];
}
- (NSArray *)properties
{
    u_int count;
    objc_property_t* properties = class_copyPropertyList(self.class, &count);
    NSMutableArray* propArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        NSString *propName = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        [propArray addObject:propName];
    }
    free(properties);
    return propArray;
}

-(NSArray *)ivars
{
    Class clazz = [self class];
    u_int count;
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* ivarName = ivar_getName(ivars[i]);
        [ivarArray addObject:[NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding]];
    }
    free(ivars);
    return ivarArray;
}


- (void)clearAllProperties
{
    u_int count;
    objc_property_t* properties = class_copyPropertyList(self.class, &count);
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        NSString *propName = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        [self setValue:nil forKey:propName];
    }
    free(properties);
}

- (void)showHUD
{
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD show];
}

- (void)classDumpObject:(id)obj
{
    Class clazz = [obj class];
    u_int count;
    Ivar* ivars = class_copyIvarList(clazz, &count);
    NSMutableArray* ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* ivarName = ivar_getName(ivars[i]);
        NSString *ivarPropName = [NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding];
        if ([obj respondsToSelector:NSSelectorFromString(ivarPropName)]){
            id value = [obj valueForKey:ivarPropName];
            if (value){
                NSDictionary *propertyDict = @{ivarPropName: value};
                [ivarArray addObject:propertyDict];
            } else {
                [ivarArray addObject:ivarPropName];
            }
        } else {
            [ivarArray addObject:ivarPropName];
        }
        
        
    }
    free(ivars);
    
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        const char* attributes = property_getAttributes(properties[i]);
        NSString *propertyNameString = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        NSString *attributesString = [NSString  stringWithCString:attributes encoding:NSUTF8StringEncoding];
        NSDictionary *propertyDict = @{propertyNameString: attributesString};
        //NSLog(@"propertyDIct: %@", propertyDict);
        if ([obj respondsToSelector:NSSelectorFromString(propertyNameString)] && [attributesString containsString:@"T@"]){
            id value = [obj valueForKey:propertyNameString];
            if (value){
                NSMutableDictionary *mut = [propertyDict mutableCopy];
                [mut setValue:value forKey:@"value"];
                propertyDict = mut;
            }
        }
       
        [propertyArray addObject:propertyDict];
    }
    free(properties);
    
    Method* methods = class_copyMethodList(clazz, &count);
    NSMutableArray* methodArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        SEL selector = method_getName(methods[i]);
        const char* methodName = sel_getName(selector);
        [methodArray addObject:[NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]];
    }
    free(methods);
    
    NSDictionary* classDump = [NSDictionary dictionaryWithObjectsAndKeys:
                               ivarArray, @"ivars",
                               propertyArray, @"properties",
                               methodArray, @"methods",
                               nil];
    
    NSLog(@"%@", classDump);
}



- (void)associateValue:(id)value withKey:(void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_RETAIN);
}

- (void)weaklyAssociateValue:(id)value withKey:(void *)key
{
    objc_setAssociatedObject(self, key, value, OBJC_ASSOCIATION_ASSIGN);
}

- (id)associatedValueForKey:(void *)key
{
    return objc_getAssociatedObject(self, key);
}

- (NSArray *)allFonts
{
    NSMutableArray *allFontArray = [[NSMutableArray alloc] init];
    NSArray *fontNames = [UIFont familyNames]; //all font family names
    for (NSString *fontFamily in fontNames) //cycle through
    {
        [allFontArray addObjectsFromArray:[UIFont fontNamesForFamilyName:fontFamily]]; //add all font names from the family names to the array
    }
    
    NSArray *sortedArray = [allFontArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]; //sort alphabetically
    
    return sortedArray;
}

- (NSArray *)customFontFamily
{
    return nil;
}


- (NSString *)JSONString {
    NSError* error;
    // Get dictionary into JSON
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    if (error != nil || jsonData == nil)
    {
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

- (NSString *)PrettyJSONString
{
    NSError* error;
    // Get dictionary into JSON
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted // or NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (error != nil || jsonData == nil)
    {
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}


@end
