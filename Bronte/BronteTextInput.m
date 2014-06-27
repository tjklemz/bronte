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
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.spellCheckingType = UITextSpellCheckingTypeNo;
        self.keyboardAppearance = UIKeyboardAppearanceDark;
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        _defaultAttr = [UIFont bronteInputFontAttributes];
        
        self.backgroundColor = [UIColor clearColor];
        
        _lines = [NSMutableArray new];
        [self newLine];
        
        [self beginAnimation];
    }
    return self;
}

- (void)setInsertBefore:(BOOL)insertBefore {
    _insertBefore = insertBefore;
    [self checkIfAdjunctCursorNeedsDisplay];
}

- (void)beginAnimation {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(doAnimation) userInfo:nil repeats:YES];
        _t = 0;
        [self setNeedsDisplayInRect:[self cursorRect]];
    }
}

- (void)doAnimation {
    _t += 0.0009;
    [self setNeedsDisplayInRect:[self cursorRect]];
}

- (void)stopAnimation {
    [_timer invalidate];
    _timer = nil;
}

- (BOOL)adjunctCursorNeedsDisplay {
    if (self.insertBefore) {
        NSString * currentLine = [self currentLine];
        return !currentLine.length || ![[currentLine substringFromIndex:currentLine.length-1] isEqualToString:[self spaceCharacter]];
    }
    return ![self hasText];
}

- (void)checkIfAdjunctCursorNeedsDisplay {
    if ([self adjunctCursorNeedsDisplay]) {
        [self beginAnimation];
    } else {
        [self stopAnimation];
    }
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
    _textNeedsDisplay = YES;
}

- (NSMutableString *)currentLine {
    return [_lines lastObject];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    
    if ([self hasText]) {
        [self.delegate didEnterText:_lines];
    }
    
    return YES;
}

- (BOOL)hasText {
    return [[_lines firstObject] length] > 0 || [_lines count] > 1;
}

- (float)maxTextWidth {
    return [UIFont bronteLineWidth] + 80;
}

- (NSString *)spaceCharacter {
    return @"\u2004";
}

- (void)insertText:(NSString *)theText {
    if ([theText isEqualToString:@"\n"] || [theText isEqualToString:@"\r"]) {
        [self newLine];
    } else {
        if (theText.length > 1) {
            NSString * trimmed = [theText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (trimmed.length == 0) {
                theText = [self spaceCharacter];
            } else {
                NSArray * components = [trimmed componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
                trimmed = [components componentsJoinedByString:[self spaceCharacter]];
                theText = [NSString stringWithFormat:@"%@%@%@", [[theText substringToIndex:1] isEqualToString:@" "] ? [self spaceCharacter] : @"", trimmed, [[theText substringFromIndex:theText.length-1] isEqualToString:@" "] ? [self spaceCharacter] : @""];
            }
        } else if ([theText isEqualToString:@" "] || [theText isEqualToString:@"\t"]) {
            theText = [self spaceCharacter];
        }
        
        float maxW = [self maxTextWidth];
        
        float newWidth = [[self currentLine] sizeWithAttributes:_defaultAttr].width + [theText sizeWithAttributes:_defaultAttr].width;
            
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
    
    [self checkIfAdjunctCursorNeedsDisplay];
    
    _textNeedsDisplay = YES;
    
    [self setNeedsDisplay];
}

- (void)deleteBackward {
    if ([[self currentLine] length]) {
        NSRange theRange = NSMakeRange([self currentLine].length-1, 1);
        [[self currentLine] deleteCharactersInRange:theRange];
    } else if ([_lines count] > 1) {
        [_lines removeLastObject];
    }
    
    [self checkIfAdjunctCursorNeedsDisplay];
    
    _textNeedsDisplay = YES;
    
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (float)startX {
    return (self.bounds.size.width - [self maxTextWidth]) / 2;
}

- (CGRect)cursorRect {
    int i = 0;
    float startX = [self startX];
    
    NSMutableString * line = _lines.lastObject;
    CGSize s = [line sizeWithAttributes:_defaultAttr];
    CGRect rectForLine = CGRectMake(startX, (self.frame.size.height / 2) - s.height - (i+3.5)*[UIFont bronteLineHeight]*0.8, s.width, s.height);
    float x = rectForLine.origin.x + rectForLine.size.width - 1;
    float w = 20;
    return CGRectMake(x, rectForLine.origin.y, w, rectForLine.size.height);
}

- (void)drawRect:(CGRect)rect {
    [[UIColor bronteSecondaryBackgroundColor] set];
    UIRectFill(rect);
    [[UIColor bronteFontColor] set];
    
    UIBezierPath * path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, 0)];
    [path moveToPoint:CGPointMake(0, self.bounds.size.height)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width, self.bounds.size.height)];
    [path stroke];
    
    BOOL drawAjunctCursor = [self adjunctCursorNeedsDisplay];
    
    // draw cursor
    
    CGRect cursorRect = [self cursorRect];
    
    float x = cursorRect.origin.x;
    float maxY = cursorRect.origin.y + cursorRect.size.height;
    float w = 20;
    
    float alpha = drawAjunctCursor ? sinf((_t*180)/M_PI) + 0.5 : 1.0;
    
    [[UIColor colorWithWhite:0.66 alpha:alpha] set];
    [[UIBezierPath bezierPathWithRect:CGRectMake(x, maxY - 4.5, w, 2.5)] fill];
    [[UIColor bronteCursorColorWithAlpha:alpha] set];
    [[UIBezierPath bezierPathWithRect:CGRectMake(x, maxY - 4.5, w, 2)] fill];
    
    // draw "space"
    if (drawAjunctCursor) {
        float midX = x + w / 2.0;
        float topY = cursorRect.origin.y + cursorRect.size.height/2.0 - 10;
        float s = 3;
        float s2 = 3;
        float h = s2*2;
        
        [[UIColor bronteCursorColorWithAlpha:1.0] set];
        UIBezierPath * space = [UIBezierPath bezierPath];
        [space moveToPoint:CGPointMake(midX, topY)];
        [space addLineToPoint:CGPointMake(midX - s, topY + s2)];
        [space addLineToPoint:CGPointMake(midX, topY + h)];
        [space addLineToPoint:CGPointMake(midX + s, topY + s2)];
        [space addLineToPoint:CGPointMake(midX, topY)];
        [space fill];
        
        float topY2 = topY + 8;
        
        UIBezierPath * space2 = [UIBezierPath bezierPath];
        [space2 moveToPoint:CGPointMake(midX, topY2)];
        [space2 addLineToPoint:CGPointMake(midX - s, topY2 + s2)];
        [space2 addLineToPoint:CGPointMake(midX, topY2 + h)];
        [space2 addLineToPoint:CGPointMake(midX + s, topY2 + s2)];
        [space2 addLineToPoint:CGPointMake(midX, topY2)];
        [space2 fill];
    }
    
    if (_textNeedsDisplay) {
        [[UIColor bronteFontColor] set];
        
        float startX = [self startX];
        
        NSEnumerator * enumerator = [_lines reverseObjectEnumerator];
        NSMutableString * line = nil;
        int i = 0;
        
        while ((line = [enumerator nextObject])) {
            CGSize s = [line sizeWithAttributes:_defaultAttr];
            CGRect rectForLine = CGRectMake(startX, (self.frame.size.height / 2) - s.height - (i+3.5)*[UIFont bronteLineHeight]*0.8, s.width, s.height);
            [line drawInRect:rectForLine withAttributes:_defaultAttr];
            ++i;
        }
    }
    
    _textNeedsDisplay = NO;
}

#pragma mark - UITextInput

- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction
{
    return 0;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    return CGRectZero;
}

- (void)unmarkText
{
    
}

- (UITextRange *)characterRangeAtPoint:(CGPoint)point
{
    return nil;
}

- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction
{
    return nil;
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
    return nil;
}

- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range
{
    return nil;
}

- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other
{
    return 0;
}

- (void)dictationRecognitionFailed
{
    
}

- (void)dictationRecordingDidEnd
{
    
}

- (CGRect)firstRectForRange:(UITextRange *)range
{
    return CGRectZero;
}

- (CGRect)frameForDictationResultPlaceholder:(id)placeholder
{
    return CGRectZero;
}

- (void)insertDictationResult:(NSArray *)dictationResult
{
    NSMutableString * string = [NSMutableString new];
    
    for (int i = 0; i < dictationResult.count - 1; ++i) {
        UIDictationPhrase * phrase = dictationResult[i];
        [string appendString:phrase.text];
    }
    
    UIDictationPhrase * lastPhrase = dictationResult[dictationResult.count-1];
    
    if (!self.insertBefore && [lastPhrase.text isEqualToString:@" "] && string.length > 0) {
        // only insert the space if there was a period
        if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:[string characterAtIndex:string.length-1]]) {
            [string appendString:@" "];
        }
    } else {
        [string appendString:lastPhrase.text];
    }
    
    [self insertText:string];
}

- (id)insertDictationResultPlaceholder
{
    return nil;
}

- (NSInteger)offsetFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
    return 0;
}

- (UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
    return nil;
}

- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset
{
    return nil;
}

- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction
{
    return nil;
}

- (void)removeDictationResultPlaceholder:(id)placeholder willInsertResult:(BOOL)willInsertResult
{
    
}

- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
    
}

- (NSArray *)selectionRectsForRange:(UITextRange *)range
{
    return nil;
}

- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range
{
    
}

- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    
}

- (NSString *)textInRange:(UITextRange *)range
{
    return nil;
}

- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
    return nil;
}


@end
