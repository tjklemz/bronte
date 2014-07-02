//
//  CALayer+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 5/3/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import <objc/runtime.h>

#import "CALayer+Bronte.h"
#import "NSNumber+Bronte.h"
#import "UIImage+Bronte.h"

@implementation CALayer (Bronte)

@dynamic activated, originalPosition;

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

- (BOOL)shouldComeBeforeWord:(CALayer *)w {
    if (self.presentationLayer && w.presentationLayer) {
        return ([self.presentationLayer minX] < [w.presentationLayer minX]);
    }
    return [self minX] < [w minX];
}

- (BOOL)shouldComeAfterWord:(CALayer *)w {
    return ![self shouldComeBeforeWord:w];
}

- (NSArray *)wordsForLineUnsorted {
    return [self.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass:%@", [CATextLayer class]]];
}

- (NSArray *)wordsForLine {
    if ([self isLine]) {
        NSArray * words = [self wordsForLineUnsorted];
        return [words sortedArrayUsingComparator:^NSComparisonResult(CALayer * w1, CALayer * w2) {
            return [w1 shouldComeBeforeWord:w2] ? NSOrderedAscending : NSOrderedDescending;
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
    d.transform = self.transform;
    d.position = self.position;
    
    NSArray * words = [self wordsForLine];
    
    for (CATextLayer * w in words) {
        CATextLayer * w2 = (CATextLayer *)[w duplicate];
        [d addSublayer:w2];
    }
    
    return d;
}

- (void)activateLine {
    if (!self.activated && [self isLine]) {
        self.contents = (id)[UIImage lineIconActive].CGImage;
        self.activated = YES;
    }
}

- (void)deactivateLine {
    if (self.activated && [self isLine]) {
        self.contents = (id)[UIImage lineIcon].CGImage;
        self.activated = NO;
    }
}

@end
