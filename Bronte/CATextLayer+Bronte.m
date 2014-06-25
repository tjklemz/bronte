//
//  CATextLayer+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 6/24/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import "CATextLayer+Bronte.h"

@implementation CATextLayer (Bronte)

- (NSString *)word {
    return [[self string] string];
}

- (void)setWord:(NSString *)newWord {
    NSMutableAttributedString * attrString = [[self string] mutableCopy];
    [[attrString mutableString] setString:newWord];
    [self setString:attrString];
}

@end
