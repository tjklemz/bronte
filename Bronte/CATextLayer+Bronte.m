//
//  CATextLayer+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 6/24/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import "CATextLayer+Bronte.h"
#import "CALayer+Bronte.h"
#import "UIFont+Bronte.h"

@implementation CATextLayer (Bronte)

+ (float)extraSpacing {
    return 2 + [UIFont bronteWordSpacing];
}

+ (CGRect)frameForString:(NSAttributedString *)str {
    return CGRectMake(0, 0, str.size.width + [self extraSpacing], [UIFont bronteLineHeight]);
}

+ (CATextLayer *)makeWord:(NSString *)word {
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:word attributes:[UIFont bronteDefaultFontAttributes]];;
    
    CATextLayer * textLayer = [CATextLayer layer];
    textLayer.contentsScale = [[UIScreen mainScreen] scale];
    textLayer.anchorPoint = CGPointZero;
    textLayer.string = str;
    textLayer.frame = [CATextLayer frameForString:str];
    
    return textLayer;
}

- (NSString *)word {
    return [[self string] string];
}

- (void)setWord:(NSString *)newWord {
    NSMutableAttributedString * attrString = [[self string] mutableCopy];
    [[attrString mutableString] setString:newWord];
    [self setString:attrString];
    CGRect frame = [CATextLayer frameForString:attrString];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, frame.size.width, frame.size.height);
}

- (CATextLayer *)duplicate {
    CATextLayer * d = [CATextLayer makeWord:[self word]];
    d.transform = self.transform;
    d.position = self.position;
    return d;
}

- (void)configureWithAttributes:(NSDictionary *)attr {
    self.string = [[NSAttributedString alloc] initWithString:[self word] attributes:attr];
}

@end
