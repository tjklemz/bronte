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
    static UIFont * font = nil;
    if (!font) {
        font = [UIFont fontWithName:@"Lekton-Regular" size:[UIFont bronteFontSize]];
    }
    return font;
}

+ (UIFont *)bronteFontBold {
    static UIFont * font = nil;
    if (!font) {
        font = [UIFont fontWithName:@"Lekton-Bold" size:[UIFont bronteFontSize]];
    }
    return font;
}

+ (UIFont *)bronteInputFont {
    static UIFont * font = nil;
    if (!font) {
        font = [UIFont fontWithName:@"Lekton-Regular" size:24];
    }
    return font;
}

+ (NSDictionary *)bronteDefaultFontAttributes {
    static NSDictionary * attr = nil;
    if (!attr) {
        attr = @{ NSFontAttributeName : [UIFont bronteFontRegular],
                  NSForegroundColorAttributeName: (id)([UIColor bronteFontColor].CGColor) };
    }
    return attr;
}

+ (NSDictionary *)bronteSelectedFontAttributes {
    static NSDictionary * attr = nil;
    if (!attr) {
        attr = @{ NSFontAttributeName : [UIFont bronteFontBold],
                  NSForegroundColorAttributeName: (id)[UIColor bronteSelectedFontColor].CGColor };
    }
    return attr;
}

+ (NSDictionary *)bronteInputFontAttributes {
    static NSDictionary * attr = nil;
    if (!attr) {
        attr = @{ NSFontAttributeName : [UIFont bronteInputFont],
                  NSForegroundColorAttributeName: [UIColor bronteFontColor] };
    }
    return attr;
}

@end
