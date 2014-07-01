//
//  CALayer+Bronte.h
//  Bronte
//
//  Created by Thomas Klemz on 5/3/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (Bronte)

@property (nonatomic) CGPoint originalPosition;
@property (nonatomic) NSValue * dropPoint;

- (float)maxX;
- (float)minX;
- (BOOL)isWord;
- (BOOL)isLine;
- (BOOL)isParagraphSeparator;
- (NSArray *)wordsForLine;
- (BOOL)shouldComeBeforePoint:(CGPoint)p;
- (BOOL)shouldComeAfterPoint:(CGPoint)p;

+ (CALayer *)makeBlankLine;
+ (CALayer *)makeLine;
+ (CALayer *)makeParagraphSeparator;

- (CALayer *)duplicate;
- (void)activateLine;
- (void)deactivateLine;

@end
