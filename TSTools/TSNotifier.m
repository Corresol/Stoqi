#import "TSNotifier.h"
#import "MBProgressHUD.h"
#import "TSUtils.h"
#import "TSUtilsColors.h"

#import "UIWindow+UIWindow+PresentedViewController.h"

#define PRESENTED_VIEW [UIViewController presentedViewController].view

#define DEFAULT_MESSAGE nil
#define DEFAULT_VIEW PRESENTED_VIEW
#define DEFAULT_APPEARANCE nil
#define DEFAULT_TIME_INTERVAL TS_NOTIFICATION_TIME_NORMAL


NSString* const kTSNotificationAppearanceNotificationColor = @"TSNotAppBGColor";
NSString* const kTSNotificationAppearanceNotificationOpacity = @"TSNotAppBGOpacity";
NSString* const kTSNotificationAppearanceDimBackground = @"TSNotAppDimBG";
NSString* const kTSNotificationAppearanceTextColor = @"TSNotAppTextColor";
NSString* const kTSNotificationAppearanceTextFont = @"TSNotAppTextFont";
NSString* const kTSNotificationAppearanceTextSize = @"TSNotAppTextSize";
NSString* const kTSNotificationAppearanceMargin = @"TSNotAppMargin";
NSString* const kTSNotificationAppearancePosition = @"TSNotAppPosition";
NSString* const kTSNotificationAppearancePositionXOffset = @"TSNotAppPosXOffset";
NSString* const kTSNotificationAppearancePositionYOffset = @"TSNotAppPosYOffset";

@implementation TSNotifier

/// Determines where to put text in main label or details label
+(void) setText:(NSString*) text withAppearance:(NSDictionary*)appearance forHUD:(MBProgressHUD*)hud onView:(UIView*) view{
    UIFont* font = [appearance objectForKey:kTSNotificationAppearanceTextFont];
    UIColor* color = [appearance objectForKey:kTSNotificationAppearanceTextColor];
    float offsetX = [[appearance objectForKey:kTSNotificationAppearancePositionXOffset] floatValue];
    float margin = [[appearance objectForKey:kTSNotificationAppearanceMargin] floatValue];
    float fontSize = [nonNull([appearance objectForKey:kTSNotificationAppearanceTextSize]) floatValue];
    font = (fontSize == 0 ? font : [font fontWithSize:fontSize]);
    if ([text sizeWithAttributes:@{NSFontAttributeName : font}].width < (view.frame.size.width - offsetX - 4 * margin)){
        hud.labelText = text;
        hud.labelFont = font;
        hud.labelColor = color;
        hud.detailsLabelText = nil;
    }
    else{
        hud.detailsLabelText = text;
        hud.detailsLabelFont = font;
        hud.detailsLabelColor = color;
        hud.labelText = nil;
    }
}

/// Default appearance dictionary.
+(NSDictionary*) notificationAppearanceWithCustomValues:(NSDictionary*) custom{
    NSMutableDictionary* appearance = [NSMutableDictionary dictionaryWithDictionary:
                                       @{kTSNotificationAppearanceNotificationColor : colorARGB(220, 16, 16, 16),
                                         kTSNotificationAppearanceNotificationOpacity : @(0.8f),
                                         kTSNotificationAppearanceDimBackground : @(NO),
                                         kTSNotificationAppearanceTextColor : [UIColor whiteColor],
                                         kTSNotificationAppearanceTextSize : @(0),
                                         kTSNotificationAppearanceTextFont : [UIFont systemFontOfSize:16.0f],
                                         kTSNotificationAppearanceMargin : @(10.0f),
                                         kTSNotificationAppearancePosition : @(TS_NOTIFICATION_POSITION_BOTTOM_CENTER),
                                         kTSNotificationAppearancePositionXOffset : @(0),
                                         kTSNotificationAppearancePositionYOffset : @(30.0f)
                                         }];
    if (custom) [appearance setValuesForKeysWithDictionary:custom];
    return appearance;
}

/// Default error appearance dictionary.
+(NSDictionary*) notificationErrorAppearanceWithCustomValues:(NSDictionary*) custom{
    NSMutableDictionary* appearance = [NSMutableDictionary dictionaryWithDictionary:[self notificationAppearanceWithCustomValues:nil]];
    [appearance setValuesForKeysWithDictionary:@{kTSNotificationAppearanceTextColor : colorRGB(180, 24, 24)}];
    if (custom) [appearance setValuesForKeysWithDictionary:custom];
    return appearance;
}

/// Applies appearance to the hud.
+(void) setAppearance:(NSDictionary*) appearance forHUD:(MBProgressHUD*)hud onView:(UIView*) view{
    hud.dimBackground = [[appearance objectForKey:kTSNotificationAppearanceDimBackground] boolValue];
    hud.color = [appearance objectForKey:kTSNotificationAppearanceNotificationColor];
    hud.opacity = [[appearance objectForKey:kTSNotificationAppearanceNotificationOpacity] floatValue];
    hud.margin = [[appearance objectForKey:kTSNotificationAppearanceMargin] floatValue];
    float x = [[appearance objectForKey:kTSNotificationAppearancePositionXOffset] floatValue];
    float y = [[appearance objectForKey:kTSNotificationAppearancePositionYOffset] floatValue];
    [self setPostition:[[appearance objectForKey:kTSNotificationAppearancePosition] integerValue]
      withCustomOffset:CGPointMake(x, y)
                forHUD:hud
                onView:view];
}

/// Positions the hud.
+(void) setPostition:(TSNotificationPosition)position withCustomOffset:(CGPoint) offset forHUD:(MBProgressHUD*)hud onView:(UIView*) view{
    [hud layoutIfNeeded]; // layout to calculate hud size
    [hud setNeedsLayout];
    switch (position) {
        case TS_NOTIFICATION_POSITION_TOP_LEFT:
        case TS_NOTIFICATION_POSITION_TOP_CENTER:
        case TS_NOTIFICATION_POSITION_TOP_RIGHT:{
            hud.yOffset = -(view.frame.size.height - hud.size.height - offset.y) / 2;
            break;
        }
        default:
        case TS_NOTIFICATION_POSITION_CENTER_LEFT:
        case TS_NOTIFICATION_POSITION_CENTER_CENTER:
        case TS_NOTIFICATION_POSITION_CENTER_RIGHT: {
            hud.yOffset = offset.y;
            break;
        }
        case TS_NOTIFICATION_POSITION_BOTTOM_LEFT:
        case TS_NOTIFICATION_POSITION_BOTTOM_CENTER:
        case TS_NOTIFICATION_POSITION_BOTTOM_RIGHT: {
            hud.yOffset = (view.frame.size.height - hud.size.height - offset.y) / 2;
            break;
        }
    }
    switch (position) {
        case TS_NOTIFICATION_POSITION_TOP_LEFT:
        case TS_NOTIFICATION_POSITION_CENTER_LEFT:
        case TS_NOTIFICATION_POSITION_BOTTOM_LEFT:{
            hud.xOffset = -(view.frame.size.width - hud.size.width  - offset.x) / 2;
            break;
        }
        default:
        case TS_NOTIFICATION_POSITION_TOP_CENTER:
        case TS_NOTIFICATION_POSITION_CENTER_CENTER:
        case TS_NOTIFICATION_POSITION_BOTTOM_CENTER:
        {
            hud.xOffset = offset.x;
            break;
        }
        case TS_NOTIFICATION_POSITION_TOP_RIGHT:
        case TS_NOTIFICATION_POSITION_CENTER_RIGHT:
        case TS_NOTIFICATION_POSITION_BOTTOM_RIGHT: {
            hud.xOffset = (view.frame.size.width - hud.size.width  - offset.x) / 2;
            break;
        }
    }
}

#pragma mark - Notifications

+(void) notify:(NSString*) message{
    [self notify:message withAppearance:DEFAULT_APPEARANCE];
}
+(void) notify:(NSString*) message onView:(UIView*) view{
    [self notify:message withAppearance:DEFAULT_APPEARANCE onView:view];
}
+(void) notify:(NSString*) message timeInterval:(TSNotificationTimeInterval) time{
    [self notify:message withAppearance:DEFAULT_APPEARANCE timeInterval:time];
}
+(void) notify:(NSString*) message timeInterval:(TSNotificationTimeInterval) time onView:(UIView*) view{
    [self notify:message withAppearance:DEFAULT_APPEARANCE timeInterval:time onView:view];
}

+(void) notify:(NSString*) message withAppearance:(NSDictionary*)appearance{
    [self notify:message withAppearance:appearance onView:DEFAULT_VIEW];
}
+(void) notify:(NSString*) message withAppearance:(NSDictionary*)appearance onView:(UIView*) view{
    [self notify:message withAppearance:appearance timeInterval:DEFAULT_TIME_INTERVAL onView:view];
}
+(void) notify:(NSString*) message withAppearance:(NSDictionary*)appearance timeInterval:(TSNotificationTimeInterval) time{
    [self notify:message withAppearance:appearance timeInterval:time onView:DEFAULT_VIEW];
}
+(void) notify:(NSString*) message withAppearance:(NSDictionary*)appearance timeInterval:(TSNotificationTimeInterval) time onView:(UIView*) view{
    if (!view || !nonEmpty(message) || time <= 0) return;
    [self hideNotificationOnView:view];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.userInteractionEnabled = NO;
    hud.removeFromSuperViewOnHide = YES;
    appearance = [self notificationAppearanceWithCustomValues:appearance];
    [self setText:message withAppearance:appearance forHUD:hud onView:view];
    [self setAppearance:appearance forHUD:hud onView:view];
    [hud hide:YES afterDelay:time];
}

+(void) hideNotification{
    [MBProgressHUD hideHUDForView:PRESENTED_VIEW animated:YES];
}
+(void) hideNotificationOnView:(UIView*) view{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

#pragma mark - Progress indicator

+(void) showProgress{
    [self showProgressOnView:DEFAULT_VIEW];
}

+(void) showProgressWithAppearance:(NSDictionary *)appearance{
    [self showProgressWithMessage:DEFAULT_MESSAGE withAppearance:appearance];
}
+(void) showProgressOnView:(UIView*)view{
    [self showProgressWithMessage:DEFAULT_MESSAGE onView:view];
}
+(void) showProgressWithMessage:(NSString*)message{
    [self showProgressWithMessage:message withAppearance:DEFAULT_APPEARANCE];
}

+(void) showProgressWithMessage:(NSString*)message onView:(UIView*)view{
    [self showProgressWithMessage:message withAppearance:DEFAULT_APPEARANCE onView:view];
}
+(void) showProgressWithMessage:(NSString*)message withAppearance:(NSDictionary*)appearance{
    [self showProgressWithMessage:message withAppearance:appearance onView:DEFAULT_VIEW];
}
+(void) showProgressWithMessage:(NSString*)message withAppearance:(NSDictionary*)appearance onView:(UIView*)view{
    if (!view) return;
    [self hideProgressOnView:view];
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
}

+(void) hideProgress{
    [self hideProgressOnView:PRESENTED_VIEW];
}
+(void) hideProgressOnView:(UIView*)view{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end
