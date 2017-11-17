#ifndef TSUtilsColors_h
#define TSUtilsColors_h

/*
 * UIColor shortcuts with int values (255-base)
 */
#define colorARGB(a,r,g,b) [TSUtilsColors colorWithRed:r green:g blue:b alpha:a]
#define colorRGB(r,g,b) [TSUtilsColors colorWithRed:r green:g blue:b]
#define colorHexString(string) [TSUtilsColors colorWithHexString:string]
#define colorHex(hex) [TSUtilsColors colorWithHex:hex]


#endif

#import <Foundation/NSObject.h>

@class NSString;
@class UIColor;

@interface TSUtilsColors : NSObject

+(UIColor*) colorWithRed:(int) red green:(int) green blue:(int)blue;
+(UIColor*) colorWithRed:(int) red green:(int) green blue:(int)blue alpha:(int)alpha;
+(UIColor*) colorWithHexString:(NSString*) hexString;
+(UIColor*) colorWithHex:(unsigned int) hex;

@end
