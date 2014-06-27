//  Created by Thomas Klemz on 4/4/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import "BronteTextInput.h"
#import "UIFont+Bronte.h"
#import "UIColor+Bronte.h"

@implementation BronteTextInput

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        _defaultAttr = [UIFont bronteInputFontAttributes];
        
        self.backgroundColor = [UIColor clearColor];
        
        _lines = [NSMutableArray new];
        [self newLine];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self resignFirstResponder];
}

- (void)newLine {
    [_lines addObject:[NSMutableString new]];
}

- (NSMutableString *)currentLine {
    return [_lines lastObject];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

//- (BOOL)resignFirstResponder {
//    [super resignFirstResponder];
//    
//    NSArray * lines = [_lines copy];
//    if (self.pre) {
//        if (self.insertBefore) {
//            [[lines lastObject] addObject:self.pre];
//        } else {
//            [[lines firstObject] insertObject:self.pre atIndex:0];
//        }
//    }
//    
//    [self.delegate didEnterText:lines];
//    
//    return YES;
//}

- (BOOL)hasText {
    return [[_lines firstObject] length] > 0;
}

- (float)maxTextWidth {
    return [UIFont bronteLineWidth] + 80;
}

- (void)insertText:(NSString *)theText {
    if ([theText isEqualToString:@"\n"] || [theText isEqualToString:@"\r"]) {
        [self newLine];
    } else {
        if ([theText isEqualToString:@" "] || [theText isEqualToString:@"\t"]) {
            theText = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"\u2005" : @"\u2004";
        }
        
        float maxW = [self maxTextWidth];
        
        float extra = 0;
        
        float newWidth = extra + [[self currentLine] sizeWithAttributes:_defaultAttr].width + [theText sizeWithAttributes:_defaultAttr].width;
            
        if (newWidth > maxW) {
            // get the last word
            NSString * fullLine = [[self currentLine] stringByAppendingString:theText];
            NSString * lastWord = [[fullLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lastObject];
            
            [[self currentLine] setString:[fullLine stringByReplacingCharactersInRange:NSMakeRange([fullLine length] - [lastWord length], [lastWord length]) withString:@""]];
            [self newLine];
            [[self currentLine] appendString:lastWord];
        } else {
            [[self currentLine] appendString:theText];
        }
    }
    [self setNeedsDisplay];
}

- (void)deleteBackward {
    if ([[self currentLine] length]) {
        NSRange theRange = NSMakeRange([self currentLine].length-1, 1);
        [[self currentLine] deleteCharactersInRange:theRange];
    } else if ([_lines count] > 1) {
        [_lines removeLastObject];
    }
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [[UIColor bronteSecondaryBackgroundColor] set];
    UIRectFill(rect);
    [[UIColor bronteFontColor] set];
    
    UIBezierPath * path = [[UIBezierPath alloc] init];
    [path moveToPoint:rect.origin];
    [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    [path moveToPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)];
    [path addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)];
    [path stroke];
    
    NSEnumerator * enumerator = [_lines reverseObjectEnumerator];
    NSMutableString * line = nil;
    int i = 0;
    
    float startX = (self.bounds.size.width - [self maxTextWidth]) / 2;
    float x = startX;
    
    while ((line = [enumerator nextObject])) {
        BOOL renderPreBefore = !self.insertBefore && i == [_lines count] - 1;
        
        x = renderPreBefore ? x : startX;
        
        CGSize s = [line sizeWithAttributes:_defaultAttr];
        CGRect rectForLine = CGRectMake(x, (self.frame.size.height / 2) - s.height - (i+3.5)*[UIFont bronteLineHeight]*0.8, s.width, s.height);
        [line drawInRect:rectForLine withAttributes:_defaultAttr];
        
        if (i == 0) {
            // draw cursor
            [[UIColor colorWithWhite:0.66 alpha:1.0] set];
            [[UIBezierPath bezierPathWithRect:CGRectMake(rectForLine.origin.x + rectForLine.size.width - 1, rectForLine.origin.y + rectForLine.size.height - 4.5, 20, 2.5)] fill];
            [[UIColor bronteCursorColor] set];
            [[UIBezierPath bezierPathWithRect:CGRectMake(rectForLine.origin.x + rectForLine.size.width - 1, rectForLine.origin.y + rectForLine.size.height - 4.5, 20, 2)] fill];
            [[UIColor bronteFontColor] set];
        } else if (renderPreBefore) {
            
        }
        
        ++i;
    }
}



@end
