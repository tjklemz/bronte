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

- (NSArray *)wordsForLine {
    if ([self isLine]) {
        NSArray * words = [self.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass:%@", [CATextLayer class]]];
        return [words sortedArrayUsingComparator:^NSComparisonResult(CALayer * obj1, CALayer * obj2) {
            float x1 = [obj1 minX];
            float w1 = obj1.bounds.size.width;
            float x2 = [obj2 minX];
            //float w2 = obj2.bounds.size.width;
            
            // NOTE: Nothing should ever return NSOrderedSame
            return (x1 + 0.5*w1 < x2) ? NSOrderedAscending : NSOrderedDescending;
            
            //return obj1.position.x - obj2.position.x;
        }];
    }
    return nil;
}

@end
