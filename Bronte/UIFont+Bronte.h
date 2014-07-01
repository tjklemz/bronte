//
//  UIFont+Bronte.h
//  Bronte
//
//  Created by Thomas Klemz on 4/22/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Bronte)

+ (float)bronteFontSize;
+ (float)bronteLineHeight;
+ (float)bronteWordHeight;
+ (float)bronteWordSpacing;
+ (float)bronteLineWidth;
+ (UIFont *)bronteFontRegular;
+ (NSDictionary *)bronteDefaultFontAttributes;
+ (NSDictionary *)bronteSelectedFontAttributes;
+ (NSDictionary *)bronteInputFontAttributes;
+ (NSDictionary *)bronteDuplicateFontAttributes;

@end
