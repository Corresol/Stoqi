#pragma "Upgrade this to vesrion 2.0"
///TSTOOLS: Split TSUtils into separated categories or classes


#import "TSUtils.h"



#define REGEX_URL_PATTERN @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
#define REGEX_EMAIL_PATTERN @"^([A-Z0-9a-z._%+-]+)@((?:[A-Za-z0-9-]+)\\.)+([A-Za-z]{2,6})$"

@implementation TSUtils




+ (NSString *)trim:(NSString *)target{
    if (![TSUtils nonNull:target]) return nil;
    return [target stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(NSString*) appName{
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString*)kCFBundleNameKey];
}

+(id) nonNull:(id)target{
    return ([[NSNull null] isEqual:target] ? nil : target);
}

+(id) nonNull:(id)target withClass:(Class)cls{
    id nonnullTarget = [self nonNull:target];
    return (nonnullTarget && [nonnullTarget isKindOfClass:cls] ? nonnullTarget : nil);
}

+(id) nonNull:(id)target withClass:(Class)cls default:(id)def{
    id newTarget = [self nonNull:target withClass:cls];
    return (newTarget ? newTarget : def);
}

+(NSString*) nonEmpty:(NSString*)targetString{
    return (targetString ? (targetString.length != 0 ? targetString : nil) : nil);
}

+(BOOL) isEmpty:(NSString *)targetString{
    return (!targetString || targetString.length == 0);
}




+ (BOOL) isValidURL: (NSString *) url {
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_URL_PATTERN];
    return [urlTest evaluateWithObject:url];
}

+ (BOOL) isValidEmail:(NSString*) email{
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_EMAIL_PATTERN];
    return [emailTest evaluateWithObject:email];
}

+ (NSString*) ordinalNumber:(NSInteger) number{
    NSInteger lastDigit = number % 10;
    NSString* suffix = @"";
    NSString* format = @"%d%@";
    switch (lastDigit) {
        case 1: suffix = @"st"; break;
        case 2: suffix = @"nd"; break;
        case 3: suffix = @"rd"; break;
        default: suffix = @"th"; break;
    }
    return [NSString stringWithFormat:format, number, suffix];
}

/// Returns string with number with delimeters
+ (NSString*) prettyNumber:(NSNumber*) number{
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setUsesGroupingSeparator:YES];
    return [formatter stringFromNumber:number];
}


+ (UIImage*) takeScreenshotOnView:(UIView*) view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
