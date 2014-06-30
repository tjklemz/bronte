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

- (float)maxX;
- (float)minX;
- (BOOL)isWord;
- (BOOL)isLine;
- (BOOL)isParagraphSeparator;
- (NSArray *)wordsForLine;
- (BOOL)shouldComeBeforePoint:(CGPoint)p;
- (BOOL)shouldComeAfterPoint:(CGPoint)p;

@end
