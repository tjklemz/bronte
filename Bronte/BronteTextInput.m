//  Created by Thomas Klemz on 4/4/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import "BronteTextInput.h"
#import "UIFont+Bronte.h"
#import "UIColor+Bronte.h"

@implementation BronteTextInput

- (void)createAttributes {
    _defaultAttr = @{ NSFontAttributeName : [UIFont bronteFontRegular],
                      NSForegroundColorAttributeName: [UIColor bronteFontColor] };
    
    _preAttr = @{ NSFontAttributeName : [UIFont bronteFontRegular],
                  NSForegroundColorAttributeName : [UIColor brontePreFontColor] };
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        [self createAttributes];
        
        self.backgroundColor = [UIColor clearColor];
        
        _lines = [NSMutableArray new];
        [self newLine];
    }
    return self;
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

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    
    NSArray * lines = [_lines copy];
    if (self.pre) {
        if (self.insertBefore) {
            [[lines lastObject] addObject:self.pre];
        } else {
            [[lines firstObject] insertObject:self.pre atIndex:0];
        }
    }
    
    [self.delegate didEnterText:lines];
    
    return YES;
}

- (BOOL)hasText {
    return [[_lines firstObject] length] > 0;
}

- (float)maxTextWidth {
    float a = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 0.99 : 0.96;
    return a*[UIFont bronteLineWidth];
}

- (void)insertText:(NSString *)theText {
    if ([theText isEqualToString:@"\n"] || [theText isEqualToString:@"\r"]) {
        [self newLine];
    } else {
        if ([theText isEqualToString:@" "] || [theText isEqualToString:@"\t"]) {
            theText = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"\u2005" : @"\u2004";
        }
        
        float maxW = [self maxTextWidth];
        
        float extra = [self hasText] ? [_pre sizeWithAttributes:_preAttr].width : 0;
        
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

- (void)orientationChanged {
    [self createAttributes];
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
    
    CGSize preSize = self.pre ? [self.pre sizeWithAttributes:_preAttr] : CGSizeZero;
    
    while ((line = [enumerator nextObject])) {
        BOOL renderPreBefore = self.pre && !self.insertBefore && i == [_lines count] - 1;
        
        x = renderPreBefore ? x + preSize.width : startX;
        
        CGSize s = [line sizeWithAttributes:_defaultAttr];
        CGRect rectForLine = CGRectMake(x, (self.frame.size.height / 2) - (0.4*s.height) - i*[UIFont bronteLineHeight], s.width, s.height);
        [line drawInRect:rectForLine withAttributes:_defaultAttr];
        
        // draw cursor
        if (i == 0) {
            [[UIBezierPath bezierPathWithRect:CGRectMake(rectForLine.origin.x + rectForLine.size.width, rectForLine.origin.y + rectForLine.size.height - 5, 15, 1)] fill];
        } else if (renderPreBefore) {
            [self.pre drawInRect:CGRectMake(startX, rectForLine.origin.y, preSize.width, preSize.height) withAttributes:_preAttr];
        }
        
        ++i;
    }
}



@end
