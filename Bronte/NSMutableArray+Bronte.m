//
//  NSMutableArray+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 6/25/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import "NSMutableArray+Bronte.h"
#import "NSArray+Bronte.h"

@implementation NSMutableArray (Bronte)

- (void)removeWord:(CATextLayer *)word {
    if ([self isDealingWithWords]) {
        [self removeObject:word];
    }
}

@end
