//
//  CALayer+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 5/3/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import "CALayer+Bronte.h"

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
    return ([self minX] + 0.5*self.bounds.size.width < p.x);
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

@end
