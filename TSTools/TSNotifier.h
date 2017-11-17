/**
 *  Author:     AdYa
 *  Version:    2.0
 *  iOS:        6.0+
 *  Date:       03/31/2016
 *  Status:     Outdated, Undocumented
 *
 *  Dependency: @pod MBProgressHUD,
 *              @header TSUtils,
 *              @header TSUtilsColors,
 *              @header UIWindow+PresentedViewController
 *
 *  Description:
 *
 *  TSNotifier provides easy and powerful way to display customizable notifications and progress indicators. It is based on great MBProgressHUD library.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MBProgressHUD;

/** Predefined time values for displaying notifications. */
typedef NS_ENUM(NSInteger, TSNotificationTimeInterval){
    TS_NOTIFICATION_TIME_SWIFT = 1,
    TS_NOTIFICATION_TIME_SHORT = 3,
    TS_NOTIFICATION_TIME_NORMAL = 5,
    TS_NOTIFICATION_TIME_LONG = 8
};

/** Possible positions of notification popup. */
typedef NS_ENUM(NSInteger, TSNotificationPosition) {
    TS_NOTIFICATION_POSITION_TOP_LEFT,
    TS_NOTIFICATION_POSITION_TOP_CENTER,
    TS_NOTIFICATION_POSITION_TOP_RIGHT,
    TS_NOTIFICATION_POSITION_CENTER_LEFT,
    TS_NOTIFICATION_POSITION_CENTER_CENTER,
    TS_NOTIFICATION_POSITION_CENTER_RIGHT,
    TS_NOTIFICATION_POSITION_BOTTOM_LEFT,
    TS_NOTIFICATION_POSITION_BOTTOM_CENTER,
    TS_NOTIFICATION_POSITION_BOTTOM_RIGHT
};
/// UIColor value
extern NSString* const kTSNotificationAppearanceNotificationColor;

/// CGFloat value
extern NSString* const kTSNotificationAppearanceNotificationOpacity;

/// BOOL value
extern NSString* const kTSNotificationAppearanceDimBackground;

/// UIColor value
extern NSString* const kTSNotificationAppearanceTextColor;

/// UIFont value
extern NSString* const kTSNotificationAppearanceTextFont;

/// CGFloat value
extern NSString* const kTSNotificationAppearanceTextSize;

///CGFloat value
extern NSString* const kTSNotificationAppearanceMargin;

/// TSNotificationPosition value
extern NSString* const kTSNotificationAppearancePosition;

/// CGFloat value
extern NSString* const kTSNotificationAppearancePositionXOffset;

/// CGFloat value
extern NSString* const kTSNotificationAppearancePositionYOffset;

@interface TSNotifier : NSObject

+(void) notify:(NSString*) message;

+(void) notify:(NSString*) message
        onView:(UIView*) view;

+(void) notify:(NSString*) message
  timeInterval:(TSNotificationTimeInterval) time;

+(void) notify:(NSString*) message
  timeInterval:(TSNotificationTimeInterval) time
        onView:(UIView*) view;

+(void) notify:(NSString*) message
withAppearance:(NSDictionary*)appearance;

+(void) notify:(NSString*) message
withAppearance:(NSDictionary*)appearance
        onView:(UIView*) view;

+(void) notify:(NSString*) message
withAppearance:(NSDictionary*)appearance
  timeInterval:(TSNotificationTimeInterval) time;

+(void) notify:(NSString*) message
withAppearance:(NSDictionary*)appearance
  timeInterval:(TSNotificationTimeInterval) time
        onView:(UIView*) view;

+(void) hideNotification;

+(void) hideNotificationOnView:(UIView*) view;

+(void) showProgress;
+(void) showProgressWithAppearance:(NSDictionary*) appearance;
+(void) showProgressOnView:(UIView*)view;
+(void) showProgressWithMessage:(NSString*)message;

+(void) showProgressWithMessage:(NSString*)message
                         onView:(UIView*)view;

+(void) showProgressWithMessage:(NSString*)message
                 withAppearance:(NSDictionary*)appearance;

+(void) showProgressWithMessage:(NSString*)message
                 withAppearance:(NSDictionary*)appearance
                         onView:(UIView*)view;

+(void) hideProgress;

+(void) hideProgressOnView:(UIView*)view;
@end
