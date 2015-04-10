//
//  KDXAlertView.h
//  KDXBlockAlert
//
//  Created by Blankwonder on 11/20/12.
//

#import <UIKit/UIKit.h>

@interface KDXAlertView : NSObject

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
                  cancelAction:(void ( ^)(KDXAlertView *alertView))cancelAction;

- (void)addButtonWithTitle:(NSString *)title action:(void ( ^)(KDXAlertView *alertView))action;
- (void)show;

- (UIAlertView *)systemAlertView;

@end
