//
//  UIFont+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 4/22/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import "UIFont+Bronte.h"
#import "UIColor+Bronte.h"

@implementation UIFont (Bronte)

+ (float)bronteFontSize {
    return 26;
}

+ (float)bronteLineHeight {
    NSAttributedString * em = [[NSAttributedString alloc] initWithString:@"M" attributes:[self bronteDefaultFontAttributes]];
    return em.size.height*2;
}

+ (float)bronteWordHeight {
    NSAttributedString * em = [[NSAttributedString alloc] initWithString:@"M" attributes:[self bronteDefaultFontAttributes]];
    return em.size.height;
}

+ (float)bronteWordSpacing {
    NSAttributedString * space = [[NSAttributedString alloc] initWithString:@"\u2004" attributes:[self bronteDefaultFontAttributes]];
    return space.size.width;
}

+ (float)bronteLineWidth {
    return 690;
}

+ (UIFont *)bronteFontRegular {
    return [UIFont fontWithName:@"Lekton-Regular" size:[UIFont bronteFontSize]];
}

+ (UIFont *)bronteFontBold {
    return [UIFont fontWithName:@"Lekton-Bold" size:[UIFont bronteFontSize]];
}

+ (NSDictionary *)bronteDefaultFontAttributes {
    return @{ NSFontAttributeName : [UIFont bronteFontRegular],
              NSForegroundColorAttributeName: (id)([UIColor bronteFontColor].CGColor) };
}

+ (NSDictionary *)bronteSelectedFontAttributes {
    return @{ NSFontAttributeName : [UIFont bronteFontBold],
              NSForegroundColorAttributeName: (id)[UIColor bronteSelectedFontColor].CGColor };
}

@end
