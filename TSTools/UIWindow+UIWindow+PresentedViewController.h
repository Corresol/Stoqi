/**
 *  Author:     AdYa
 *  Version:    1.0
 *  iOS:        2.0+
 *  Date:       11/18/2015
 *  Status:     Completed, Undocumented
 *
 *  Dependency: None
 *
 *  Description:
 *
 *  UIWindow's extension provides method to access currently presented view controller.
 */

#import <UIKit/UIKit.h>

@interface UIWindow (PresentedViewController)
- (UIViewController*) presentedViewController;
@end

@interface UIViewController (PresentedViewController)
+ (UIViewController*) presentedViewController;
@end
