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

@end
