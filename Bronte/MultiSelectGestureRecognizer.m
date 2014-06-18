//
//  MultiSelectGestureRecognizer.m
//  Bronte
//
//  Created by Thomas Klemz on 6/10/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import "MultiSelectGestureRecognizer.h"

@implementation MultiSelectGestureRecognizer

- (void)reset {
    [super reset];
    self.didMove = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if ([touches count] != 1 || [[touches anyObject] tapCount] != 2) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    
    self.didMove = YES;
    
    self.state = UIGestureRecognizerStateChanged;
    
    return;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    self.state = UIGestureRecognizerStateCancelled;
}

@end
