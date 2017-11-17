#import "TSUtilsColors.h"
#import <UIKit/UIColor.h>
#import <Foundation/NSString.h>
#import <Foundation/NSScanner.h>

@implementation TSUtilsColors

+(UIColor*) colorWithRed:(int)red green:(int)green blue:(int)blue{
    return [TSUtilsColors colorWithRed:red green:green blue:blue alpha:255];
}

+(UIColor*) colorWithRed:(int)red green:(int)green blue:(int)blue alpha:(int)alpha{
    return [UIColor colorWithRed:((float)red)/255.0f green:((float)green)/255.0f blue:((float)blue)/255.0f alpha:((float)alpha)/255.0f];
}

+(UIColor*) colorWithHexString:(NSString *)hex{
    if (!hex) return [UIColor blackColor];
    if ([hex rangeOfString:@"#"].location == 0) // cut sharp-symbol "#"
        hex = [hex substringFromIndex:1];
    if (hex.length == 6) // append alpha channel
        hex = [NSString stringWithFormat:@"FF%@", [hex uppercaseString]];
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    unsigned int argbValue;
    [scanner scanHexInt:&argbValue];
    return [self colorWithHex:argbValue];
}

+(UIColor*) colorWithHex:(unsigned int) hex{
    return [self colorWithRed:((hex & 0x00FF0000) >> 16)
                        green:((hex & 0x0000FF00) >> 8)
                         blue:((hex & 0x000000FF) >> 0)
                        alpha:((hex & 0xFF000000) >> 24)];
}


@end
