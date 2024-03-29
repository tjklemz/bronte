//
//  UIColor+Bronte.h
//  Bronte
//
//  Created by Thomas Klemz on 4/22/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Bronte)

+ (UIColor *)bronteBackgroundColor;
+ (UIColor *)bronteFontColor;
+ (UIColor *)bronteSelectedFontColor;
+ (UIColor *)bronteClipboardHandleColor;
+ (UIColor *)bronteDuplicateFontColor;
+ (UIColor *)bronteCursorColorWithAlpha:(float)alpha;
+ (UIColor *)bronteSecondaryBackgroundColor;

@end
