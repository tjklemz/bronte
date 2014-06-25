//
//  NSString+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 6/24/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import "NSString+Bronte.h"

@implementation NSString (Bronte)

- (BOOL)isCapitalized {
    return [[self cappedString] isEqualToString:self];
}

- (BOOL)isUncapped {
    return [[self uncappedString] isEqualToString:self];
}

- (NSString *)cappedString {
    return [self capitalizedStringWithLocale:[NSLocale currentLocale]];
}

- (NSString *)allCappedString {
    return [self uppercaseStringWithLocale:[NSLocale currentLocale]];
}

- (NSString *)uncappedString {
    return [self lowercaseStringWithLocale:[NSLocale currentLocale]];
}

@end
