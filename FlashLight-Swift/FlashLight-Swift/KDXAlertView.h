//
//  KDXAlertView.h
//  KDXBlockAlert
//
//  Created by Blankwonder on 11/20/12.
//

#import <UIKit/UIKit.h>

#ifndef NS_DESIGNATED_INITIALIZER
#if __has_attribute(objc_designated_initializer)
#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#else
#define NS_DESIGNATED_INITIALIZER
#endif
#endif


@interface KDXAlertView : NSObject

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
                  cancelAction:(void ( ^)(KDXAlertView *alertView))cancelAction NS_DESIGNATED_INITIALIZER;

- (void)addButtonWithTitle:(NSString *)title action:(void ( ^)(KDXAlertView *alertView))action;
- (void)show;

- (UIAlertView *)systemAlertView;

@end
