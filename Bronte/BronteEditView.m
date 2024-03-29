//
//  BronteEditView.m
//  Bronte
//
//  Created by Thomas Klemz on 4/23/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import "BronteEditView.h"
#import "UIColor+Bronte.h"
#import "NSArray+Bronte.h"
#import "CATextLayer+Bronte.h"
#import "NSString+Bronte.h"
#import "UIFont+Bronte.h"
#import "CALayer+Bronte.h"

@implementation BronteEditView

- (float)buttonWidth {
    return 50;
}

- (float)buttonPadding {
    return 20;
}

- (float)buttonsPerRow {
    return 3;
}

- (float)startX {
    return self.frame.size.width / 2 - 1.5*[self buttonWidth] - [self buttonPadding];
}

- (float)offset {
    return [UIFont bronteLineHeight];
}

- (float)selectionLineLength {
    return 14;
}

- (float)startY {
    return 30 + [self offset];
}

- (void)hidePointer {
    _hidePointer = YES;
    [self setNeedsDisplay];
}

- (void)showPointer {
    _hidePointer = NO;
    [self setNeedsDisplay];
}

- (CGPoint)findSelectionPoint {
    if ([_selection isParagraph]) {
        return CGPointMake([_selection.lastObject maxX], [_selection.lastObject position].y);
    }
    
    BOOL isInsertingLeft = [self isInsertingLeft];
    
    CALayer * l = isInsertingLeft ? [_selection firstLineOfSelection] : [_selection lastLineOfSelection];
    
    float x = isInsertingLeft ? [_selection firstWordOfSelection].position.x - 4 : ([[_selection lastWordOfSelection] maxX] - [UIFont bronteWordSpacing] - [self selectionLineLength]);
    
    return CGPointMake(l.position.x + x, l.position.y);
}

- (void)adjustPosition {
    _selectionPoint = [self findSelectionPoint];
    self.frame = CGRectMake(0, _selectionPoint.y, self.bounds.size.width, self.bounds.size.height);
    [self setNeedsDisplay];
}

- (id)initWithSelection:(NSArray *)selection
{
    _selection = [selection mutableCopy];
    
    _selectionPoint = [self findSelectionPoint];
    
    float screenWidth = [UIScreen mainScreen].bounds.size.height;
    
    self = [super initWithFrame:CGRectMake(0, _selectionPoint.y, screenWidth, 460 + [self offset])];
    
    if (self) {
        [self setClipsToBounds:NO];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self setBackgroundColor:[UIColor clearColor]];
        
        float w = [self buttonWidth];
        float p = [self buttonPadding];
        
        float startX = [self startX];
        
        float x = startX;
        float y = [self startY];
        
        UIButton * leftInsertButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [leftInsertButton setImage:[UIImage imageNamed:@"edit_icons_insert-left_gray.png"] forState:UIControlStateNormal];
        [leftInsertButton setImage:[UIImage imageNamed:@"edit_icons_insert-left.png"] forState:UIControlStateSelected];
        [leftInsertButton setFrame:CGRectMake(x, y, w, w)];
        [leftInsertButton addTarget:self action:@selector(insertDirectionChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:leftInsertButton];
        _insertLeftButton = leftInsertButton;
        
        x += w + p;
        
        UIButton * insertButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [insertButton setImage:[UIImage imageNamed:@"edit_icons_insert.png"] forState:UIControlStateNormal];
        [insertButton setFrame:CGRectMake(x, y, w, w)];
        [insertButton addTarget:self action:@selector(insert:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:insertButton];
        
        x += w + p;
        
        UIButton * rightInsertButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightInsertButton setImage:[UIImage imageNamed:@"edit_icons_insert-right_gray.png"] forState:UIControlStateNormal];
        [rightInsertButton setImage:[UIImage imageNamed:@"edit_icons_insert-right.png"] forState:UIControlStateSelected];
        [rightInsertButton setFrame:CGRectMake(x, y, w, w)];
        [rightInsertButton setSelected:YES];
        [rightInsertButton addTarget:self action:@selector(insertDirectionChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightInsertButton];
        _insertRightButton = rightInsertButton;
        
        y += w + p*2;
        x = startX;
        
        UIButton * capButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [capButton setImage:[UIImage imageNamed:@"edit_icons_cap.png"] forState:UIControlStateNormal];
        [capButton setFrame:CGRectMake(x, y, w, w)];
        [capButton addTarget:self action:@selector(capitalizeSelection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:capButton];
        
        x += w + p;
        
        UIButton * uncapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [uncapButton setImage:[UIImage imageNamed:@"edit_icons_lc.png"] forState:UIControlStateNormal];
        [uncapButton setFrame:CGRectMake(x, y, w, w)];
        [uncapButton addTarget:self action:@selector(uncapitalizeSelection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:uncapButton];
        
        x += w + p;
        
        UIButton * backspaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backspaceButton setImage:[UIImage imageNamed:@"edit_icons_backspace.png"] forState:UIControlStateNormal];
        [backspaceButton setFrame:CGRectMake(x, y, w, w)];
        [backspaceButton addTarget:self action:@selector(deleteCharacter:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:backspaceButton];
        _deleteCharacterButton = backspaceButton;
        
        y += w + p - 5;
        x = startX;
        
        UIButton * quote2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [quote2 setImage:[UIImage imageNamed:@"edit_icons_quote2.png"] forState:UIControlStateNormal];
        [quote2 setFrame:CGRectMake(x, y, w, w)];
        [quote2 addTarget:self action:@selector(doubleQuoteSelection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:quote2];
        
        x += w + p;
        
        UIButton * quote1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [quote1 setImage:[UIImage imageNamed:@"edit_icons_quote1.png"] forState:UIControlStateNormal];
        [quote1 setFrame:CGRectMake(x, y, w, w)];
        [quote1 addTarget:self action:@selector(singleQuoteSelection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:quote1];
        
        x += w + p;
        
        UIButton * deleteWordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteWordButton setImage:[UIImage imageNamed:@"edit_icons_delete-word.png"] forState:UIControlStateNormal];
        [deleteWordButton setFrame:CGRectMake(x, y + 2, w, w*2 + p)];
        [deleteWordButton addTarget:self action:@selector(deleteSelection:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteWordButton];
        
        y += w + p;
        x = startX;
        
        UIButton * parenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [parenButton setImage:[UIImage imageNamed:@"edit_icons_parentheses.png"] forState:UIControlStateNormal];
        [parenButton setFrame:CGRectMake(x, y, w, w)];
        [parenButton addTarget:self action:@selector(parenSelection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:parenButton];
        
        x += w + p;
        
        UIButton * bracketButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [bracketButton setImage:[UIImage imageNamed:@"edit_icons_brackets.png"] forState:UIControlStateNormal];
        [bracketButton setFrame:CGRectMake(x, y, w, w)];
        [bracketButton addTarget:self action:@selector(bracketSelection:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:bracketButton];
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
    
}

#pragma mark - Actions

- (void)insert:(id)sender {
    if ([self isInsertingLeft]) {
        [self.delegate insertBeforeSelection:_selection];
    } else {
        [self.delegate insertAfterSelection:_selection];
    }
}

- (BOOL)isInsertingLeft {
    return [_insertLeftButton isSelected];
}

- (void)insertDirectionChanged:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
    
    UIButton * other = sender == _insertLeftButton ? _insertRightButton : _insertLeftButton;
    sender.selected = !sender.selected;
    other.selected = !sender.selected;
    
    [_deleteCharacterButton setImage:[UIImage imageNamed:([self isInsertingLeft] ? @"edit_icons_delete.png" : @"edit_icons_backspace.png")] forState:UIControlStateNormal];
    
    [self.delegate editMenuNeedsAdjusting];
    
    [self setNeedsDisplay];
}

- (void)capitalizeSelection:(UIButton *)sender {
    NSArray * words = [_selection wordsForSelection];
    
    if ([[words.firstObject word] canBeCapped] && [[words.firstObject word] isUncapped]) {
        [words.firstObject setWord:[[words.firstObject word] cappedString]];
    } else {
        BOOL allWordsCapped = YES;
        BOOL allWordsUncapped = YES;
        
        for (CATextLayer * w in words) {
            if ([[w word] canBeCapped]) {
                if ([[w word] isUncapped]) {
                    allWordsCapped = NO;
                } else {
                    allWordsUncapped = NO;
                }
            }
        }
        
        for (CATextLayer * w in words) {
            NSString * capped = !allWordsCapped ? [[w word] cappedString] : [[w word] allCappedString];
            [w setWord:capped];
        }
    }
}

- (void)uncapitalizeSelection:(UIButton *)sender {
    NSArray * words = [_selection wordsForSelection];
    
    for (CATextLayer * w in words) {
        NSString * uncapped = [[w word] uncappedString];
        [w setWord:uncapped];
    }
}

- (void)deleteCharacter:(id)sender {
    NSArray * words = [_selection wordsForSelection];
    
    CALayer * line = nil;
    
    if ([self isInsertingLeft]) {
        NSMutableString * s = [[words.firstObject word] mutableCopy];
        if (s.length) {
            [s replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
            [words.firstObject setWord:s];
            line = [words.firstObject superlayer];
        }
    } else {
        NSMutableString * s = [[words.lastObject word] mutableCopy];
        if (s.length) {
            [s replaceCharactersInRange:NSMakeRange(s.length-1, 1) withString:@""];
            [words.lastObject setWord:s];
            line = [words.lastObject superlayer];
        }
    }
    
    if (line) {
        [self.delegate didDeleteCharacterFromLine:line];
    }
}

- (void)deleteSelection:(id)sender {
    [self.delegate deleteSelection:_selection];
}

- (void)wrapSelectionWithLeftString:(NSString *)left rightString:(NSString *)right {
    NSArray * words = [_selection wordsForSelection];
    
    NSString * firstWord = [words.firstObject word];
    NSString * lastWord = [words.lastObject word];
    
    if ([firstWord hasPrefix:left] && firstWord.length >= left.length && ![firstWord isEqualToString:left] &&
        [lastWord hasSuffix:right] && lastWord.length >= right.length && ![lastWord isEqualToString:right]) {
        [words.firstObject setWord:[firstWord stringByReplacingCharactersInRange:NSMakeRange(0, left.length) withString:@""]];
        lastWord = [words.lastObject word];
        // because I'm paranoid
        if ([lastWord hasSuffix:right] && lastWord.length >= right.length && ![lastWord isEqualToString:right]) {
            [words.lastObject setWord:[lastWord stringByReplacingCharactersInRange:NSMakeRange(lastWord.length - right.length, right.length) withString:@""]];
        }
    } else {
        [words.firstObject setWord:[left stringByAppendingString:firstWord]];
        lastWord = [words.lastObject word];
        [words.lastObject setWord:[lastWord stringByAppendingString:right]];
    }
    
    [self.delegate linesNeedArranging:[NSSet setWithObjects:[words.firstObject superlayer], [words.lastObject superlayer], nil]];
    
    [self adjustPosition];
}

- (void)doubleQuoteSelection:(id)sender {
    [self wrapSelectionWithLeftString:[NSString leftDoubleQuote] rightString:[NSString rightDoubleQuote]];
}

- (void)singleQuoteSelection:(id)sender {
    [self wrapSelectionWithLeftString:[NSString leftSingleQuote] rightString:[NSString rightSingleQuote]];
}

- (void)parenSelection:(id)sender {
    [self wrapSelectionWithLeftString:@"(" rightString:@")"];
}

- (void)bracketSelection:(id)sender {
    [self wrapSelectionWithLeftString:@"[" rightString:@"]"];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{    
    float selectionLineLength = [self selectionLineLength];
    
    [[UIColor colorWithRed:166/255.0 green:96/255.0 blue:54/255.0 alpha:1.0] setStroke];
    
    float y = [UIFont bronteLineHeight] - 11;
    
    if (_selection.count && !_hidePointer) {
        UIBezierPath * selectionLine = [UIBezierPath bezierPath];
        [selectionLine moveToPoint:CGPointMake(_selectionPoint.x, y)];
        [selectionLine addLineToPoint:CGPointMake(_selectionPoint.x + selectionLineLength, y)];
        selectionLine.lineWidth = 1;
        [selectionLine stroke];
        
        BOOL isInsertingLeft = [self isInsertingLeft];
        
        UIBezierPath * selectionSide = [UIBezierPath bezierPath];
        float selectionSideX = isInsertingLeft ? _selectionPoint.x : _selectionPoint.x + selectionLineLength + selectionLine.lineWidth;
        [selectionSide moveToPoint:CGPointMake(selectionSideX, y + selectionLine.lineWidth / 2.0)];
        [selectionSide addLineToPoint:CGPointMake(selectionSideX, y - 8)];
        selectionSide.lineWidth = 4;
        [selectionSide stroke];
    }
    
    [[UIColor bronteFontColor] setStroke];
    
    float offset = [self offset];
    
    [[UIColor bronteSecondaryBackgroundColor] setFill];
    UIRectFill(CGRectMake(rect.origin.x, rect.origin.y + offset, rect.size.width + rect.origin.x, rect.size.height - offset));
    
    [[UIColor bronteBackgroundColor] setStroke];
    
    float w = [self buttonWidth];
    float b = [self buttonsPerRow];
    float p = [self buttonPadding];
    
    y = [self startY] + [self buttonWidth] + [self buttonPadding];
    
    UIBezierPath * line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake([self startX], y)];
    [line addLineToPoint:CGPointMake([self startX] + w*b + p*(b-1), y)];
    line.lineWidth = 3.0;
    [line stroke];
}

@end
