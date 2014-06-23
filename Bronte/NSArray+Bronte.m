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

- (CALayer *)lastLineOfSelection {
    return [self isDealingWithWords] ? [self.lastObject superlayer] : self.lastObject;
}

@end
