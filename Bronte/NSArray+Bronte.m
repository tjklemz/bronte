//
//  NSArray+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 6/23/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import "NSArray+Bronte.h"
#import "CALayer+Bronte.h"
#import "CATextLayer+Bronte.h"
#import "UIFont+Bronte.h"
#import "UIImage+Bronte.h"

@implementation NSArray (Bronte)

- (BOOL)isDealingWithWords {
    return [self.firstObject isWord];
}

- (BOOL)isParagraph {
    return [self.lastObject isParagraphSeparator];
}

- (CALayer *)firstLineOfSelection {
    return [self isDealingWithWords] ? [self.firstObject superlayer] : self.firstObject;
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

- (NSSet *)linesForSelection {
    NSMutableSet * lines = [NSMutableSet new];
    
    if ([self isDealingWithWords]) {
        for (CATextLayer * word in self) {
            if (word.superlayer) {
                [lines addObject:word.superlayer];
            }
        }
    } else {
        for (CALayer * l in self) {
            [lines addObject:l];
        }
    }
    
    return lines;
}

- (void)configureWithAttributes:(NSDictionary *)attr {
    NSArray * words = [self wordsForSelection];
    for (CATextLayer * w in words) {
        [w configureWithAttributes:attr];
    }
    
    BOOL activateLineIcon = [attr[@"BronteActivateLineIcon"] boolValue];
    BOOL deactivateLineIcon = [attr[@"BronteDeactivateLineIcon"] boolValue];
    
    if (![self isDealingWithWords] && (activateLineIcon || deactivateLineIcon)) {
        UIImage * img = activateLineIcon ? [UIImage lineIconActive] : [UIImage lineIcon];
        NSSet * lines = [self linesForSelection];
        for (CALayer * l in lines) {
            l.contents = (id)img.CGImage;
        }
    }
}

- (void)markSelection {
    NSMutableDictionary * attr = [[UIFont bronteSelectedFontAttributes] mutableCopy];
    attr[@"BronteActivateLineIcon"] = @YES;
    [self configureWithAttributes:attr];
}

- (void)unmarkSelection {
    NSMutableDictionary * attr = [[UIFont bronteDefaultFontAttributes] mutableCopy];
    attr[@"BronteDeactivateLineIcon"] = @YES;
    [self configureWithAttributes:attr];
}

- (void)markSelectionAsDuplicate {
    NSMutableDictionary * attr = [[UIFont bronteDuplicateFontAttributes] mutableCopy];
    attr[@"BronteActivateLineIcon"] = @YES;
    [self configureWithAttributes:attr];
}

@end
