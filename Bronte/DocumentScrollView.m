//
//  DocumentScrollView.m
//  Bronte
//
//  Created by Thomas Klemz on 6/10/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import "DocumentScrollView.h"

@implementation DocumentScrollView

- (void)setContentOffset:(CGPoint)contentOffset {
    self.previousContentOffset = self.contentOffset;
    [super setContentOffset:contentOffset];
}

#pragma mark -

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count == 1) {
        [self.touchDelegate touchesBegan:touches withEvent:event];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count == 1) {
        [self.touchDelegate touchesMoved:touches withEvent:event];
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count == 1) {
        [self.touchDelegate touchesCancelled:touches withEvent:event];
    } else {
        [super touchesCancelled:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count == 1) {
        [self.touchDelegate touchesEnded:touches withEvent:event];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

@end
