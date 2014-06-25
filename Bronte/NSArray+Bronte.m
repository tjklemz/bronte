//
//  NSArray+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 6/23/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import "NSArray+Bronte.h"
#import "CALayer+Bronte.h"

@implementation NSArray (Bronte)

- (BOOL)isDealingWithWords {
    return [self.firstObject isWord];
}

- (BOOL)isParagraph {
    return [self.lastObject isParagraphSeparator];
}

- (CALayer *)lastLineOfSelection {
    return [self isDealingWithWords] ? [self.lastObject superlayer] : self.lastObject;
}

- (CATextLayer *)lastWordOfSelection {
    CATextLayer * lastWord = nil;
    
    if ([self isDealingWithWords]) {
        lastWord = self.lastObject;
    } else if ([self isParagraph]) {
        long n = self.count - 1;
        if (n > 0) {
            lastWord = [self objectAtIndex:n];
        }
    } else if ([self.lastObject isLine]) {
        lastWord = [[self.lastObject wordsForLine] lastObject];
    }
    
    return lastWord;
}

- (BOOL)selectionContainsWord:(CATextLayer *)word {
    BOOL doesContainWord = NO;
    
    if ([self isDealingWithWords] && [self containsObject:word]) {
        doesContainWord = YES;
    } else {
        for (CALayer * s in self) {
            if ([s.sublayers containsObject:word]) {
                doesContainWord = YES;
                break;
            }
        }
    }
    
    return doesContainWord;
}

@end
