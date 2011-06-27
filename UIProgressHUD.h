//
//  UIProgressHUD.h
//  HUD
//
//  Created by stallman on 10/04/20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIProgressHUD : UIView
- (void)show: (BOOL)yesOrNo;
- (void)setText: (NSString *)text;
- (void)showInView:(id)view;
- (void)hide;
- (void)done;
- (UIProgressHUD *)initWithWindow: (UIView *)window;
@end
