//
//  CALayer+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 5/3/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import "CALayer+Bronte.h"
#import "NSNumber+Bronte.h"
#import "UIImage+Bronte.h"

@implementation CALayer (Bronte)

@dynamic originalPosition;

- (float)maxX {
    return self.position.x + self.bounds.size.width - self.anchorPoint.x*self.bounds.size.width;
}

- (float)minX {
    return self.position.x - self.anchorPoint.x*self.bounds.size.width;
}

- (BOOL)isWord {
    __unsafe_unretained Class cls = [CATextLayer class];
    return [self isKindOfClass:cls];
}

- (BOOL)isLine {
    return [self.name isEqualToString:@"L"];
}

- (BOOL)isParagraphSeparator {
    return [self.name isEqualToString:@"P"];
}

- (BOOL)shouldComeBeforePoint:(CGPoint)p {
    return ([self minX] + 0.55*self.bounds.size.width < p.x);
}

- (BOOL)shouldComeAfterPoint:(CGPoint)p {
    return ![self shouldComeBeforePoint:p];
}

- (NSArray *)wordsForLine {
    if ([self isLine]) {
        NSArray * words = [self.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass:%@", [CATextLayer class]]];
        return [words sortedArrayUsingComparator:^NSComparisonResult(CALayer * obj1, CALayer * obj2) {
            return [obj1 shouldComeBeforePoint:CGPointMake([obj2 minX], 0)] ? NSOrderedAscending : NSOrderedDescending;
        }];
    }
    return nil;
}

+ (CALayer *)makeBlankLine {
    CALayer * l = [CALayer layer];
    l.contentsScale = [[UIScreen mainScreen] scale];
    l.anchorPoint = CGPointZero;
    l.frame = CGRectMake(0, 0, [NSNumber lineWidth], [NSNumber lineHeight]);
    return l;
}

+ (CALayer *)makeLine {
    CALayer * l = [self makeBlankLine];
    
    l.contents = (id)[UIImage lineIcon].CGImage;
    l.contentsGravity = kCAGravityLeft;
    l.name = @"L";
    
    return l;
}

+ (CALayer *)makeParagraphSeparator {
    CALayer * l = [CALayer makeBlankLine];
    
    l.frame = CGRectMake(0, 0, [NSNumber lineWidth] - [NSNumber lineHandleWidth], l.bounds.size.height);
    
    l.contents = (id)[UIImage paragraphIcon].CGImage;
    l.contentsGravity = kCAGravityCenter;
    l.name = @"P";
    
    return l;
}

- (CALayer *)duplicate {
    CALayer * d = [self isParagraphSeparator] ? [CALayer makeParagraphSeparator] : [CALayer makeLine];
    
    NSArray * words = [self wordsForLine];
    
    for (CATextLayer * w in words) {
        CATextLayer * w2 = (CATextLayer *)[w duplicate];
        [d addSublayer:w2];
    }
    
    return d;
}

@end
