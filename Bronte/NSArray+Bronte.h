//
//  NSArray+Bronte.h
//  Bronte
//
//  Created by Thomas Klemz on 6/23/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Bronte)

- (BOOL)isDealingWithWords;
- (CALayer *)firstLineOfSelection;
- (CALayer *)lastLineOfSelection;
- (CATextLayer *)firstWordOfSelection;
- (CATextLayer *)lastWordOfSelection;
- (BOOL)selectionContainsWord:(CATextLayer *)word;
- (NSArray *)wordsForSelection;
- (NSSet *)linesForSelection;

@end
