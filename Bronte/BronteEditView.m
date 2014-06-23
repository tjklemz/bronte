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

- (float)startY {
    return 30;
}

- (id)initWithSelection:(NSArray *)selection
{
    CALayer * l = [selection lastLineOfSelection];
    
    _selectionPoint = l.position;
    _selectionPoint.y += l.bounds.size.height;
    
    float screenWidth = [UIScreen mainScreen].bounds.size.height;
    
    self = [super initWithFrame:CGRectMake(0, _selectionPoint.y, screenWidth, 460)];
    
    if (self) {
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self setBackgroundColor:[UIColor bronteSecondaryBackgroundColor]];
        
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
        [self addSubview:capButton];
        
        x += w + p;
        
        UIButton * uncapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [uncapButton setImage:[UIImage imageNamed:@"edit_icons_lc.png"] forState:UIControlStateNormal];
        [uncapButton setFrame:CGRectMake(x, y, w, w)];
        [self addSubview:uncapButton];
        
        x += w + p;
        
        UIButton * backspaceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backspaceButton setImage:[UIImage imageNamed:@"edit_icons_backspace_l.png"] forState:UIControlStateNormal];
        [backspaceButton setFrame:CGRectMake(x, y, w, w)];
        [self addSubview:backspaceButton];
        
        y += w + p - 5;
        x = startX;
        
        UIButton * quote2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [quote2 setImage:[UIImage imageNamed:@"edit_icons_quote2.png"] forState:UIControlStateNormal];
        [quote2 setFrame:CGRectMake(x, y, w, w)];
        [self addSubview:quote2];
        
        x += w + p;
        
        UIButton * quote1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [quote1 setImage:[UIImage imageNamed:@"edit_icons_quote1.png"] forState:UIControlStateNormal];
        [quote1 setFrame:CGRectMake(x, y, w, w)];
        [self addSubview:quote1];
        
        x += w + p;
        
        UIButton * deleteWordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteWordButton setImage:[UIImage imageNamed:@"edit_icons_delete.png"] forState:UIControlStateNormal];
        [deleteWordButton setFrame:CGRectMake(x, y + 2, w, w*2 + p)];
        [self addSubview:deleteWordButton];
        
        y += w + p;
        x = startX;
        
        UIButton * parenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [parenButton setImage:[UIImage imageNamed:@"edit_icons_parentheses.png"] forState:UIControlStateNormal];
        [parenButton setFrame:CGRectMake(x, y, w, w)];
        [self addSubview:parenButton];
        
        x += w + p;
        
        UIButton * bracketButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [bracketButton setImage:[UIImage imageNamed:@"edit_icons_brackets.png"] forState:UIControlStateNormal];
        [bracketButton setFrame:CGRectMake(x, y, w, w)];
        [self addSubview:bracketButton];
    }
    return self;
}

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
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    float offset = 8;
    
    [[UIColor colorWithRed:166/255.0 green:96/255.0 blue:54/255.0 alpha:1.0] setStroke];
    
    UIBezierPath * selectionLine = [UIBezierPath bezierPath];
    [selectionLine moveToPoint:_selectionPoint];
    [selectionLine addLineToPoint:CGPointMake(_selectionPoint.x + _selectionWidth, _selectionPoint.y)];
    selectionLine.lineWidth = 1.5;
    [selectionLine stroke];
    
//    BOOL isInsertingLeft = [self isInsertingLeft];
    
//    UIBezierPath * selectionSide = [UIBezierPath bezierPath];
//    float selectionSideX = isInsertingLeft ? _selectionPoint.x : _selectionPoint.x + _selectionWidth + selectionLine.lineWidth;
//    [selectionSide moveToPoint:CGPointMake(selectionSideX, _selectionPoint.y + selectionLine.lineWidth / 2.0)];
//    [selectionSide addLineToPoint:CGPointMake(selectionSideX, 0)];
//    selectionSide.lineWidth = 4.5;
//    [selectionSide stroke];
    
    [[UIColor bronteFontColor] setStroke];
    
    offset += _selectionPoint.y - 1.0;
    
    [[UIColor bronteSecondaryBackgroundColor] setFill];
    UIRectFill(CGRectMake(rect.origin.x, rect.origin.y + offset, rect.size.width + rect.origin.x, rect.size.height + rect.origin.y));
    
    [[UIColor bronteBackgroundColor] setStroke];
    
    float w = [self buttonWidth];
    float b = [self buttonsPerRow];
    float p = [self buttonPadding];
    
    float y = [self startY] + [self buttonWidth] + [self buttonPadding];
    
    UIBezierPath * line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake([self startX], y)];
    [line addLineToPoint:CGPointMake([self startX] + w*b + p*(b-1), y)];
    line.lineWidth = 3.0;
    [line stroke];
}

@end
