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
    return [UIColor colorWithWhite:0.9375 alpha:1.0];
}

+ (UIColor *)bronteFontColor {
    return [UIColor colorWithRed:25/255.0 green:28/255.0 blue:32/255.0 alpha:1.0];
}

+ (UIColor *)bronteSelectedFontColor {
    return [UIColor colorWithHue:198/360.0 saturation:0.65 brightness:0.90 alpha:1.0]; //keep, light ocean blue
    //return [UIColor colorWithHue:211/360.0 saturation:0.65 brightness:0.95 alpha:1.0]; //keep, light blue 1
    //return [UIColor colorWithHue:215/360.0 saturation:0.67 brightness:0.75 alpha:1.0];
    //return [UIColor colorWithHue:64/360.0 saturation:0.55 brightness:0.53 alpha:1.0];
}

+ (UIColor *)brontePreFontColor {
    return [UIColor colorWithRed:25/255.0 green:28/255.0 blue:32/255.0 alpha:0.5];
}

+ (UIColor *)bronteSecondaryBackgroundColor {
    return [UIColor colorWithWhite:0.87 alpha:1.0];
}

@end
