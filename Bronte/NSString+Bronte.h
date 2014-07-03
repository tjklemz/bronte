//
//  NSString+Bronte.h
//  Bronte
//
//  Created by Thomas Klemz on 6/24/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Bronte)

- (BOOL)isCapitalized;
- (BOOL)isUncapped;
- (BOOL)cannotBeCapped;
- (BOOL)canBeCapped;
- (NSString *)cappedString;
- (NSString *)allCappedString;
- (NSString *)uncappedString;
+ (NSString *)leftDoubleQuote;
+ (NSString *)rightDoubleQuote;
+ (NSString *)leftSingleQuote;
+ (NSString *)rightSingleQuote;
- (NSString *)doubleQuotedString;
- (NSString *)singleQuotedString;

@end
