/**
 *  Author:     AdYa
 *  Version:    1.0
 *  iOS:        2.0+
 *  Date:       01/13/2015
 *  Status:     Outdated, Undocumented, Rework Requested
 *
 *  Dependency: None
 *
 *  Description:
 *
 *  Lost of utility methods, should be categorized.
 */

#ifndef UTILS
#define UTILS

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 *  Replaces NSNull object with plain nil value.
 */

#define nonNull(value) [TSUtils nonNull:value]
#define nonNullCls(value, cls) [TSUtils nonNull:value withClass:cls]
#define nonNullClsDef(value, cls, def) [TSUtils nonNull:value withClass:cls default:def]

#define nonEmpty(string) [TSUtils nonEmpty:string]


/*
 *  NSString shortcuts
 */
#define trim(string) [TSUtils trim:string]


#define isValidURL(url) [TSUtils isValidURL:url]


/*
 *  Shortuct to application name
 */
#define APP_NAME [TSUtils appName]


/*
 * Marks method as abstract
 */
#define AbstractMethod() @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];


#endif

@interface TSUtils : NSObject

+(NSString*) trim:(NSString*) target;
+(BOOL) isValidURL:(NSString*) url;
+(BOOL) isValidEmail:(NSString*) email;

/// Returns string with ordinal format.
+(NSString*) ordinalNumber:(NSInteger) number;
+(NSString*) prettyNumber:(NSNumber*) number;


/// Creates an image of the screen
+ (UIImage*) takeScreenshotOnView:(UIView*) view;

/// Shortuct to application name
+(NSString*) appName;

/// Replaces NSNull object with plain nil
+(id) nonNull:(id)target;

/// Do the same as nonNull and also ensures that target is kind of class cls.
+(id) nonNull:(id)target withClass:(Class) cls;

+(id) nonNull:(id)target withClass:(Class)cls default:(id) def;


/// Replaces empty strings with plain nil
+(NSString*) nonEmpty:(NSString*)targetString;
+(BOOL) isEmpty:(NSString*) targetString;


@end
