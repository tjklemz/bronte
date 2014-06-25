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

- (CATextLayer *)firstWordOfSelection {
    return [self wordsForSelection].firstObject;
}

- (CATextLayer *)lastWordOfSelection {
    return [self wordsForSelection].lastObject;
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

- (NSArray *)wordsForSelection {
    NSMutableArray * words = [NSMutableArray new];
    
    if ([self isDealingWithWords]) {
        for (CATextLayer * word in self) {
            [words addObject:word];
        }
    } else {
        for (CALayer * l in self) {
            [words addObjectsFromArray:[l wordsForLine]];
        }
    }
    
    return words;
}

@end
