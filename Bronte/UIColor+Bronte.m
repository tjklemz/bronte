//
//  UIColor+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 4/22/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import "UIColor+Bronte.h"

@implementation UIColor (Bronte)

+ (UIColor *)bronteBackgroundColor {
    static UIColor * color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithWhite:0.9375 alpha:1.0];
    });
    return color;
}

+ (UIColor *)bronteFontColor {
    static UIColor * color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithRed:25/255.0 green:28/255.0 blue:32/255.0 alpha:1.0];
    });
    return color;
}

+ (UIColor *)bronteSelectedFontColor {
    static UIColor * color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHue:198/360.0 saturation:0.65 brightness:0.90 alpha:1.0]; //keep, light ocean blue
    });
    return color;
    //return [UIColor colorWithHue:211/360.0 saturation:0.65 brightness:0.95 alpha:1.0]; //keep, light blue 1
    //return [UIColor colorWithHue:215/360.0 saturation:0.67 brightness:0.75 alpha:1.0];
    //return [UIColor colorWithHue:64/360.0 saturation:0.55 brightness:0.53 alpha:1.0];
}

+ (UIColor *)bronteClipboardHandleColor {
    static UIColor * color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //color = [UIColor colorWithHue:211/360.0 saturation:0.65 brightness:0.95 alpha:0.2];
        //color = [UIColor colorWithHue:198/360.0 saturation:0.65 brightness:0.90 alpha:0.08];
        color = [UIColor colorWithWhite:0.8 alpha:0.1];
    });
    return color;
}

+ (UIColor *)bronteDuplicateFontColor {
    static UIColor * color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithHue:22/360.0 saturation:0.67 brightness:0.65 alpha:1.0];
    });
    return color;
}

+ (UIColor *)bronteCursorColorWithAlpha:(float)alpha {
    return [UIColor colorWithHue:64/360.0 saturation:0.55 brightness:0.53+0.22 alpha:alpha];
}

+ (UIColor *)bronteSecondaryBackgroundColor {
    static UIColor * color = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        color = [UIColor colorWithWhite:0.87 alpha:1.0];
    });
    return color;
}

@end
