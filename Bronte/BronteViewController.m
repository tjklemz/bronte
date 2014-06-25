//
//  BronteViewController.m
//  Bronte
//
//  Created by Thomas Klemz on 6/9/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import "BronteViewController.h"
#import "UIFont+Bronte.h"
#import "UIColor+Bronte.h"
#import "CALayer+Bronte.h"
#import "DocumentScrollView.h"
#import "MultiSelectGestureRecognizer.h"
#import "UIImage+Bronte.h"
#import "NSArray+Bronte.h"

#import <POP.h>

@interface BronteViewController ()

@end

@implementation BronteViewController

- (UIEdgeInsets)scrollViewInsets {
    CGPoint o = [self lineOriginForLineNumber:0];
    float p = o.y + 10;
    return UIEdgeInsetsMake(p, 0, p, [self width] - (o.x + [self lineWidth] + 60));
}

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _defaultAttr = [UIFont bronteDefaultFontAttributes];
        
        _lines = [NSMutableArray new];
        
        _wordIcon = [UIImage imageNamed:@"milk.png"];
        _lineIcon = [UIImage imageNamed:@"sugar_gray.png"];
        _lineIcon = [_lineIcon imageByApplyingAlpha:0.5];
        _lineIconActive = [UIImage imageNamed:@"sugar.png"];
        _paraIcon = [UIImage imageNamed:@"mix.png"];
        
        //self.view.backgroundColor = [UIColor bronteBackgroundColor];
        
        DocumentScrollView * scrollView = [[DocumentScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
        scrollView.touchDelegate = self;
        scrollView.backgroundColor = [UIColor bronteBackgroundColor];
        _docLayer = scrollView.layer;
        _docLayer.masksToBounds = NO;
        [scrollView.panGestureRecognizer setMinimumNumberOfTouches:2];
        [scrollView setScrollIndicatorInsets:[self scrollViewInsets]];
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        scrollView.bouncesZoom = NO;
        [scrollView setScrollEnabled:NO];
        
        MultiSelectGestureRecognizer * multiSelectGesture = [[MultiSelectGestureRecognizer alloc] initWithTarget:self action:@selector(multiSelect:)];
        [scrollView addGestureRecognizer:multiSelectGesture];

        [self.view addSubview:scrollView];
        _scrollView = scrollView;
        
        scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, scrollView.bounds.size.height);
        
        UIScreenEdgePanGestureRecognizer * edgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        edgeGesture.edges = UIRectEdgeRight;
        edgeGesture.maximumNumberOfTouches = 1;
        edgeGesture.minimumNumberOfTouches = 1;
        [self.view addGestureRecognizer:edgeGesture];
        
        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        panGesture.maximumNumberOfTouches = 1;
        panGesture.minimumNumberOfTouches = 1;
        [self.view addGestureRecognizer:panGesture];
        
        [self newLine]; //required
        
        //testing only
        [self addText:@"You don't know about me without you have read a book by the name of The Adventures of Tom Sawyer; but that ain't no matter.  That book was made by Mr. Mark Twain, and he told the truth, mainly.  There was things which he stretched, but mainly he told the truth.  That is nothing.  I never seen anybody but lied one time or another, without it was Aunt Polly, or the widow, or maybe Mary.  Aunt Polly — Tom's Aunt Polly, she is — and Mary, and the Widow Douglas is all told about in that book, which is mostly a true book, with some stretchers, as I said before." toLine:_lines.lastObject];
        
        [self addText:@"Now the way that the book winds up is this:  Tom and me found the money that the robbers hid in the cave, and it made us rich.  We got six thousand dollars apiece — all gold.  It was an awful sight of money when it was piled up.  Well, Judge Thatcher he took it and put it out at interest, and it fetched us a dollar a day apiece all the year round — more than a body could tell what to do with.  The Widow Douglas she took me for her son, and allowed she would sivilize me; but it was rough living in the house all the time, considering how dismal regular and decent the widow was in all her ways; and so when I couldn't stand it no longer I lit out.  I got into my old rags and my sugar-hogshead again, and was free and satisfied.  But Tom Sawyer he hunted me up and said he was going to start a band of robbers, and I might join if I would go back to the widow and be respectable.  So I went back." toLine:_lines.lastObject];
        
        [self addText:@"The widow she cried over me, and called me a poor lost lamb, and she called me a lot of other names, too, but she never meant no harm by it. She put me in them new clothes again, and I couldn't do nothing but sweat and sweat, and feel all cramped up.  Well, then, the old thing commenced again.  The widow rung a bell for supper, and you had to come to time. When you got to the table you couldn't go right to eating, but you had to wait for the widow to tuck down her head and grumble a little over the victuals, though there warn't really anything the matter with them, — that is, nothing only everything was cooked by itself.  In a barrel of odds and ends it is different; things get mixed up, and the juice kind of swaps around, and the things go better." toLine:_lines.lastObject];
        
        [self addText:@"After supper she got out her book and learned me about Moses and the Bulrushers, and I was in a sweat to find out all about him; but by and by she let it out that Moses had been dead a considerable long time; so then I didn't care no more about him, because I don't take no stock in dead people." toLine:_lines.lastObject];
        
        // end of testing code
        
        [self adjustScrollViewContentSize];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _isRotating = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    _isRotating = NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logic

- (float)width {
    return fmaxf(self.view.bounds.size.width, self.view.bounds.size.height);
}

- (float)height {
    return fminf(self.view.bounds.size.width, self.view.bounds.size.height);
}

- (float)lineHeight {
    return [UIFont bronteLineHeight];
}

- (float)lineHandleWidth {
    return 80;
}

- (float)lineWidth {
    return [UIFont bronteLineWidth] + [self lineHandleWidth];
}

- (CGPoint)originForFirstWord {
    return CGPointMake([self lineHandleWidth] + [UIFont bronteWordSpacing], ([UIFont bronteWordHeight]/2.0) - 0.5 - 4);
}

- (CGPoint)lineOriginForLineNumber:(NSUInteger)n {
    float offset = n < _lines.count && [_lines[n] isParagraphSeparator] ? 63 : 0;
    return CGPointMake(([self width] - [UIFont bronteLineWidth])/2.0 - [self lineHandleWidth] + 15 + offset, 50 + n*[self lineHeight]);
}

- (void)adjustScrollViewContentSize {
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, [self currentScale]*[self lineOriginForLineNumber:_lines.count+1].y);
}

- (CATextLayer *)makeWord:(NSString *)word {
    NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:word attributes:_defaultAttr];
    
    CGSize s = [str size];
    
    CATextLayer * textLayer = [CATextLayer layer];
    textLayer.contentsScale = [[UIScreen mainScreen] scale];
    textLayer.anchorPoint = CGPointZero;
    textLayer.string = str;
    textLayer.frame = CGRectMake(0, 0, s.width + 2 + [UIFont bronteWordSpacing], [self lineHeight]);
    
    return textLayer;
}

- (CALayer *)makeBlankLine {
    CALayer * l = [CALayer layer];
    l.contentsScale = [[UIScreen mainScreen] scale];
    l.anchorPoint = CGPointZero;
    l.frame = CGRectMake(0, 0, [self lineWidth], [self lineHeight]);
    return l;
}

- (CALayer *)makeLine {
    CALayer * l = [self makeBlankLine];
    
    l.contents = (id)_lineIcon.CGImage;
    l.contentsGravity = kCAGravityLeft;
    l.name = @"L";
    
    return l;
}

- (CALayer *)makeParagraphSeparator {
    CALayer * l = [self makeBlankLine];
    
    l.frame = CGRectMake(0, 0, [self lineWidth] - [self lineHandleWidth], l.bounds.size.height);
    
    l.contents = (id)_paraIcon.CGImage;
    l.contentsGravity = kCAGravityCenter;
    l.name = @"P";
    
    return l;
}

- (CALayer *)newLine {
    CALayer * l = [self makeLine];
    l.position = [self lineOriginForLineNumber:_lines.count];
    //l.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    [_docLayer addSublayer:l];
    [_lines addObject:l];
    return l;
}

- (CALayer *)newParagraphSeparator {
    CALayer * l = [self makeParagraphSeparator];
    [_lines addObject:l];
    l.position = [self lineOriginForLineNumber:_lines.count-1];
    [_docLayer addSublayer:l];
    return l;
}

- (CALayer *)insertLineAfter:(CALayer *)l {
    NSUInteger n = [_lines indexOfObject:l];
    CALayer * newLine = [self makeLine];
    [_docLayer addSublayer:newLine];
    [_lines insertObject:newLine atIndex:n+1];
    
    float currentScale = [self currentScale];
    
    for (NSUInteger i = n+1; i < _lines.count; ++i) {
        [self arrangeLineNumber:i basedOnScale:currentScale];
    }
    
    return newLine;
}

- (CALayer *)addWord:(NSString *)word toLine:(CALayer *)line {
    CALayer * w = [self makeWord:word];
    w.position = [self originForFirstWord];
    
    CALayer * l = line;
    
    if ([l isParagraphSeparator]) {
        l = [self newLine];
        [self newParagraphSeparator];
    }
    
    CALayer * lastWord = [line wordsForLine].lastObject;
    float newX = lastWord ? [lastWord maxX] : w.position.x;
    
    if (newX + w.bounds.size.width > [self lineWidth]) {
        l = [self insertLineAfter:l];
        newX = w.position.x;
    }
    
    w.position = CGPointMake(newX, w.position.y);
    [l addSublayer:w];
    return l;
}

- (NSArray *)textToWords:(NSString *)text {
    return [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (CALayer *)addText:(NSString *)text toLine:(CALayer *)line {
    CALayer * l = line;
    
    NSArray * words = [self textToWords:text];
    
    for (NSString * word in words) {
        if (word.length) {
            l = [self addWord:word toLine:l];
        }
    }
    
    [self addParagraphSeparatorIfNeeded];
    
    return l;
}

#pragma mark - Moving stuff

- (NSDictionary *)hitForPoint:(CGPoint)p {
    for (int i = 0; i < _lines.count; ++i) {
        CALayer * line = _lines[i];
        CALayer * hit = [line hitTest:p];
        
        if (hit) {
            NSMutableDictionary * hitInfo = [NSMutableDictionary new];
            hitInfo[@"line"] = line;
            hitInfo[@"lineNo"] = [NSNumber numberWithInt:i];
            hitInfo[@"origPoint"] = [NSValue valueWithCGPoint:p];
            if ([hit isWord]) {
                hitInfo[@"word"] = hit;
            } else {
                float currentScale = [self currentScale];
                if (p.x < line.position.x + currentScale*[self lineHandleWidth]) {
                    hitInfo[@"hitLineHandle"] = @YES;
                }
            }
            return hitInfo;
        }
    }
    return nil;
}

- (BOOL)didHitParagraphHandle:(NSDictionary *)hitInfo {
    CALayer * line = hitInfo[@"line"];
    return line && [line isParagraphSeparator];
}

- (BOOL)didHitLineHandle:(NSDictionary *)hitInfo {
    CALayer * line = hitInfo[@"line"];
    return line && [line isLine] && hitInfo[@"hitLineHandle"];
}

- (BOOL)didHitMultiSelectHandle:(NSDictionary *)hitInfo {
    if (!_selectionInfo) return NO;
    CALayer * icon = _selectionInfo[@"icon"];
    if (!icon) return NO;
    CGPoint p = [hitInfo[@"origPoint"] CGPointValue];
    CALayer * hit = [icon.superlayer.superlayer hitTest:p];
    return hit && [hit.name isEqualToString:@"M"];
}

- (BOOL)didHitHandle:(NSDictionary *)hitInfo {
    return [self didHitParagraphHandle:hitInfo] || [self didHitLineHandle:hitInfo] || [self didHitMultiSelectHandle:hitInfo];
}

- (NSArray *)paragraphForLineNumber:(int)lineNo {
    NSMutableArray * lines = [NSMutableArray new];
    
    NSUInteger n = lineNo;
    
    while (n < _lines.count && ![_lines[n] isParagraphSeparator]) {
        [lines addObject:_lines[n]];
        ++n;
    }
    
    if (n < _lines.count) {
        [lines addObject:_lines[n]];
    }
    
    for (int i = lineNo-1; i >= 0; --i) {
        CALayer * line = _lines[i];
        if ([line isParagraphSeparator]) {
            break;
        }
        [lines insertObject:line atIndex:0];
    }
    
    return lines;
}

- (void)forEachWordInMultiSelection:(NSDictionary *)selectionInfo Do:(void (^)(CATextLayer * word))block {
    NSDictionary * hitInfo1 = selectionInfo[@"first"];
    NSDictionary * hitInfo2 = selectionInfo[@"last"];
    
    CATextLayer * w1 = hitInfo1[@"word"];
    CATextLayer * w2 = hitInfo2[@"word"];
    
    if (!w1 || !w2) return;
    
    int beginLine = [hitInfo1[@"lineNo"] intValue], endLine = [hitInfo2[@"lineNo"] intValue];
    
    for (int i = beginLine; i <= endLine; ++i) {
        NSArray * words = [_lines[i] wordsForLine];
        if (words.count) {
            NSUInteger beginWord = i == beginLine ? [words indexOfObject:w1] : 0;
            NSUInteger endWord = i == endLine ? [words indexOfObject:w2] : words.count-1;
            
            for (NSUInteger j = beginWord; j <= endWord; ++j) {
                CATextLayer * word = words[j];
                block(word);
            }
        }
    }
}

- (void)configureWord:(CATextLayer *)word withAttributes:(NSDictionary *)attr {
    word.string = [[NSAttributedString alloc] initWithString:((NSAttributedString *)(word.string)).string attributes:attr];
}

- (void)configureMultiWordSelection:(NSDictionary *)selectionInfo withAttributes:(NSDictionary *)attr {
    [self forEachWordInMultiSelection:selectionInfo Do:^(CATextLayer *word) {
        [self configureWord:word withAttributes:attr];
    }];
}

- (NSArray *)wordsForMultiSelection:(NSDictionary *)selectionInfo {
    NSMutableArray * words = [NSMutableArray new];
    
    [self forEachWordInMultiSelection:selectionInfo Do:^(CATextLayer *word) {
        [words addObject:word];
    }];
    
    return words;
}

- (void)unmarkMultiWordSelection {
    if (_selectionInfo) {
        [self configureMultiWordSelection:_selectionInfo withAttributes:[UIFont bronteDefaultFontAttributes]];
        CALayer * icon = _selectionInfo[@"icon"];
        if (icon) {
            [icon removeFromSuperlayer];
        }
        _selectionInfo = nil;
    }
}

- (void)markMultiWordSelection:(NSDictionary *)selectionInfo {
    [self unmarkMultiWordSelection];
    
    NSDictionary * attr = [UIFont bronteSelectedFontAttributes];
    [self configureMultiWordSelection:selectionInfo withAttributes:attr];
    _selectionInfo = [selectionInfo mutableCopy];
}

- (void)commitMarkedMultiWordSelection {
    if (_selectionInfo) {
        NSDictionary * hitInfo1 = _selectionInfo[@"first"];
        NSDictionary * hitInfo2 = _selectionInfo[@"last"];
        
        CALayer * w1 = hitInfo1[@"word"];
        CALayer * w2 = hitInfo2[@"word"];
        
        if (w1 == w2) {
            [self unmarkMultiWordSelection];
        } else {
            CALayer * wordIcon = [CALayer layer];
            wordIcon.frame = CGRectMake(0, 0, 50, 50);
            wordIcon.contents = (id)_wordIcon.CGImage;
            wordIcon.name = @"M";
            
            int lineNo1 = [hitInfo1[@"lineNo"] intValue];
            int lineNo2 = [hitInfo2[@"lineNo"] intValue];
            
            wordIcon.position = CGPointMake((w1.superlayer.bounds.size.width - w1.position.x) + 30, 0.5*(lineNo2 - lineNo1 + 0.675)*[self lineHeight]);
            [w1 addSublayer:wordIcon];
            _selectionInfo[@"icon"] = wordIcon;
            
            _selectionInfo[@"selection"] = [self wordsForMultiSelection:_selectionInfo];
        }
    }
}

- (void)configureSelection:(NSArray *)selection withAttributes:(NSDictionary *)attr {
    BOOL activateLineIcon = [attr[@"BronteActivateLineIcon"] boolValue];
    BOOL deactivateLineIcon = [attr[@"BronteDeactivateLineIcon"] boolValue];
    
    for (CALayer * l in selection) {
        if ([l isLine]) {
            NSArray * words = [l wordsForLine];
            for (CATextLayer * word in words) {
                [self configureWord:word withAttributes:attr];
            }
            
            if (activateLineIcon) {
                l.contents = (id)_lineIconActive.CGImage;
            } else if (deactivateLineIcon) {
                l.contents = (id)_lineIcon.CGImage;
            }
        } else if ([l isWord]) {
            CATextLayer * word = (CATextLayer *)l;
            [self configureWord:word withAttributes:attr];
        }
    }
}

- (void)markSelection:(NSArray *)selection {
    NSMutableDictionary * attr = [[UIFont bronteSelectedFontAttributes] mutableCopy];
    attr[@"BronteActivateLineIcon"] = @YES;
    [self configureSelection:selection withAttributes:attr];
}

- (void)unmarkSelection:(NSArray *)selection {
    NSMutableDictionary * attr = [[UIFont bronteDefaultFontAttributes] mutableCopy];
    attr[@"BronteDeactivateLineIcon"] = @YES;
    [self configureSelection:selection withAttributes:attr];
}

- (NSArray *)currentSelection {
    return _selectionInfo ? _selectionInfo[@"selection"] : (_touchInfo ? _touchInfo[@"selection"] : nil);
}

- (NSArray *)selectionForHit:(NSDictionary *)hitInfo {
    if (!hitInfo) return nil;
    
    NSArray * selection = @[];
    
    CALayer * line = hitInfo[@"line"];
    
    if ([line isParagraphSeparator]) {
        selection = [self paragraphForLineNumber:[hitInfo[@"lineNo"] intValue]];
    } else if ([line isLine]) {
        if (hitInfo[@"hitLineHandle"]) {
            selection = @[line];
        } else {
            CATextLayer * word = hitInfo[@"word"];
            if (word) {
                NSArray * currentSelection = [self currentSelection];
                
                if (currentSelection && [currentSelection selectionContainsWord:word]) {
                    selection = currentSelection;
                } else {
                    selection = @[word];
                }
            } else if ([self didHitMultiSelectHandle:hitInfo]) {
                selection = _selectionInfo[@"selection"];
            }
        }
    }
    
    for (CALayer * l in selection) {
        l.originalPosition = l.position;
    }
    
    return selection;
}

- (void)putBackSelection:(NSArray *)selection {
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (selection) [self unmarkSelection:selection];
        if (_selectionInfo) [self unmarkMultiWordSelection];
    }];
    
    for (CALayer * l in selection) {
        l.hidden = NO;
        l.position = l.originalPosition;
    }
    
    [CATransaction commit];
}

- (void)didDropSelection:(NSDictionary *)selectionInfo {
    NSArray * selection = selectionInfo[@"selection"];
    NSDictionary * hitInfo = selectionInfo[@"hitInfo"];
    CGPoint dropPoint = [selectionInfo[@"dropPoint"] CGPointValue];
    
    for (CALayer * l in selection) {
        l.hidden = YES;
    }
    
    float startX = [self lineOriginForLineNumber:0].x;
    BOOL didDropOnDocument = dropPoint.x >= startX && dropPoint.x <= [self lineWidth] + startX;
    
    if (didDropOnDocument) {
        float currentScale = [self currentScale];
        
        NSDictionary * dropInfo = [self hitForPoint:dropPoint];
        
        if (selection) [self unmarkSelection:selection];
        if (_selectionInfo) [self unmarkMultiWordSelection];
        
        BOOL dealingWithWords = [selection isDealingWithWords];
        
        CALayer * dropLine = dropInfo[@"line"];
        CALayer * origLine = hitInfo[@"line"];
        int dropLineNo = [dropInfo[@"lineNo"] intValue];
        CGPoint dropLineOrigin = [self lineOriginForLineNumber:dropLineNo];
        CGPoint origLineOrigin = [self lineOriginForLineNumber:[hitInfo[@"lineNo"] intValue]];
        
        CGPoint origHitPoint = [hitInfo[@"origPoint"] CGPointValue];
        
        if (dealingWithWords && dropLine && ![dropLine isParagraphSeparator]) {
            CALayer * dropWord = dropInfo[@"word"];
            
            if (selection.count > 1 && !dropWord) {
                [self putBackSelection:selection];
            } else {
                __block NSMutableSet * affectedLines = [NSMutableSet new];
                
                [CATransaction begin];
                [CATransaction setAnimationDuration:0];
                // needs to be in reverse due to the z ordering. see the method -wordsForLine
                NSEnumerator * reverse = [selection reverseObjectEnumerator];
                CATextLayer * w = nil;
                while ((w = [reverse nextObject])) {
                    [affectedLines addObject:w.superlayer];
                    [w removeFromSuperlayer];
                    w.position = CGPointMake(dropPoint.x/currentScale - startX, dropPoint.y/currentScale - dropLineOrigin.y - (origHitPoint.y/currentScale - (w.originalPosition.y + origLineOrigin.y)));
                    w.hidden = NO;
                    [dropLine addSublayer:w];
                }
                [CATransaction commit];
                
                [affectedLines addObject:dropLine];
                
                if (origLine != dropLine) {
                    __weak __block BronteViewController * me = self;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [me arrangeWordsInLines:affectedLines];
                        [me removeBlankLines];
                        [me arrangeLinesBasedOnScale:currentScale];
                        affectedLines = nil;
                    });
                } else {
                    [self arrangeWordsInLines:affectedLines];
                    [self removeBlankLines];
                    [self arrangeLinesBasedOnScale:currentScale];
                }
            }
        } else if (!dealingWithWords) {
            BOOL before = NO;
            BOOL validDrop = NO;
            
            if (!dropLine) {
                CGPoint firstOrigin = [self lineOriginForLineNumber:0];
                CGPoint lastOrigin = [self lineOriginForLineNumber:_lines.count];
                if (dropPoint.y < currentScale*firstOrigin.y) {
                    [_lines removeObjectsInArray:[[selection reverseObjectEnumerator] allObjects]];
                    dropLine = _lines.firstObject;
                    before = YES;
                    validDrop = YES;
                } else if (dropPoint.y > currentScale*lastOrigin.y) {
                    [_lines removeObjectsInArray:[[selection reverseObjectEnumerator] allObjects]];
                    dropLine = _lines.lastObject;
                    before = NO;
                    validDrop = YES;
                }
            } else if ([selection.lastObject isParagraphSeparator]) {
                NSArray * p = [self paragraphForLineNumber:dropLineNo];
                CALayer * halfway = p[p.count/2];
                
                if (dropPoint.y < halfway.position.y) {
                    dropLine = p.firstObject;
                    before = YES;
                } else {
                    dropLine = p.lastObject;
                    before = NO;
                }

                [_lines removeObjectsInArray:[[selection reverseObjectEnumerator] allObjects]];
                validDrop = YES;
            } else {
                validDrop = YES;
                before = dropPoint.y < dropLine.position.y + currentScale*[self lineHeight]*0.5;
                [_lines removeObjectsInArray:[[selection reverseObjectEnumerator] allObjects]];
            }
            
            if (validDrop) {
                NSUInteger n = _lines.count ? ([_lines indexOfObject:dropLine] + (before ? 0 : 1)) : 0;
                
                NSEnumerator * e = [selection reverseObjectEnumerator];
                CALayer * l = nil;
                
                while ((l = [e nextObject])) {
                    l.hidden = NO;
                    [_lines insertObject:l atIndex:n];
                }
                
                [self arrangeLinesBasedOnScale:currentScale];
            } else {
                [self putBackSelection:selection];
            }
        } else {
            [self putBackSelection:selection];
        }
        
    } else {
        
        //TODO: check the clipboard area
        
        [self putBackSelection:selection];
    }
}

#pragma mark - Editing

- (void)bringUpEditMenuForSelection:(NSArray *)selection {
    [self cancelScrolling];
    [self dismissSelections];
    
    [self markSelection:selection];
    _touchInfo = [NSMutableDictionary new];
    _touchInfo[@"selection"] = selection;
    
    [self zoomDocument:1.0 withAnimationDuration:0.2 completion:^(BOOL finished) {
        CALayer * l = [selection lastLineOfSelection];
        
        float offset = (l.position.y - _scrollView.contentOffset.y) - 5*[self lineHeight];
        
        _editView = [[BronteEditView alloc] initWithSelection:selection];
        _editView.delegate = self;
        _editView.hidden = YES;
        CGRect origFrame = _editView.frame;
        CGRect newFrame = origFrame;
        newFrame.origin.y += newFrame.size.height;
        _editView.frame = newFrame;
        [_scrollView addSubview:_editView];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_scrollView setContentOffset:CGPointMake(0, _scrollView.contentOffset.y + offset)];
        } completion:^(BOOL finished) {
            _editView.hidden = NO;
            
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _editView.frame = origFrame;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
}

- (void)dismissEditMenu {
    if (_editView) {
        if (_touchInfo && _touchInfo[@"selection"]) {
            [self unmarkSelection:_touchInfo[@"selection"]];
        }
        
        if (fabs(_scrollView.previousContentOffset.y - _scrollView.contentOffset.y) < [self width]) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [_scrollView setContentOffset:_scrollView.previousContentOffset];
            } completion:^(BOOL finished) {
                
            }];
        }
        
        CGRect newFrame = _editView.frame;
        newFrame.origin.y += newFrame.size.height;
        
        [UIView animateWithDuration:0.175 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _editView.frame = newFrame;
        } completion:^(BOOL finished) {
            [_editView removeFromSuperview];
            _editView = nil;
        }];
    }
}

#pragma mark - Keyboard

- (void)dismissInputView {
    [_inputView removeFromSuperview];
    _inputView = nil;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    if (!_isRotating) {
        [self dismissInputView];
    }
}

- (void)insertBeforeSelection:(NSArray *)selection {
    
}

- (void)insertAfterSelection:(NSArray *)selection {
    _inputView = [[BronteTextInput alloc] initWithFrame:CGRectMake(0, 0, [self width], [self height])];
    CATextLayer * w = [selection lastWordOfSelection];
    
    if (w) {
        _inputView.pre = [[w string] string];
    }
    
    [self.view addSubview:_inputView];
    [_inputView becomeFirstResponder];
}

#pragma mark - Gestures

- (CGRect)clipboardHandle {
    float p = 0.09;
    float s = p*_scrollView.bounds.size.width;
    return CGRectMake(_scrollView.bounds.size.width - s, 0, s*2, _scrollView.bounds.size.height);
}

- (CGRect)infoHandle {
    float p = 0.09;
    float s = p*_scrollView.bounds.size.width;
    return CGRectMake(0, 0, s, _scrollView.bounds.size.height);
}

- (void)dismissSelections {
    [self dismissEditMenu];
    
    NSArray * currentSelection = _touchInfo[@"selection"];
    
    if (currentSelection) {
        [self unmarkSelection:currentSelection];
    }
    if (_selectionInfo) {
        [self unmarkMultiWordSelection];
    }
    _touchInfo = nil;
}

- (void)handleSingleTapOnHandle:(NSDictionary *)hitInfo {
    NSArray * selection = [self selectionForHit:hitInfo];
    NSArray * currentSelection = _touchInfo[@"selection"];
    
    if (!_selectionInfo) {
        
        if (currentSelection) {
            // check if hit should deselect or bring up edit menu
            
            BOOL shouldBringUpEditMenu = NO;
            
            if ([self didHitParagraphHandle:hitInfo]) {
                // see if the current selection is the hit paragraph
                
                if (hitInfo[@"line"] == currentSelection.lastObject) {
                    NSArray * paragraph = [self paragraphForLineNumber:[hitInfo[@"lineNo"] intValue]];
                    if (paragraph.firstObject == currentSelection.firstObject) {
                        shouldBringUpEditMenu = YES;
                    }
                }
                
            } else {
                // has to be a line
                
                if (hitInfo[@"line"] == currentSelection.lastObject) {
                    shouldBringUpEditMenu = YES;
                }
            }
            
            if (shouldBringUpEditMenu) {
                [self bringUpEditMenuForSelection:selection];
            } else {
                [self dismissSelections];
            }
        } else {
            // no multi select, no current selection, so go ahead and mark the new selection
            [self markSelection:selection];
            _touchInfo = [NSMutableDictionary new];
            _touchInfo[@"selection"] = selection;
            _touchInfo[@"hitInfo"] = hitInfo;
        }
    } else {
        // see if the handle hit was on the multi select handle.
        // if so, bring up the edit menu for it, as it is already selected.
        
        if ([self didHitMultiSelectHandle:hitInfo]) {
            // bring up edit menu (there can only be one multi select handle)
            [self bringUpEditMenuForSelection:selection];
        } else {
            // ...else, dismiss everything
            [self dismissSelections];
        }
    }
}

- (void)handleDoubleTapOnHandle:(NSDictionary *)hitInfo {
    NSArray * selection = [self selectionForHit:hitInfo];
    NSArray * currentSelection = _touchInfo[@"selection"];

    // check if anything is selected.
    // if nothing is selected, then select and bring up the edit menu.
    // if something is selected, dismiss everything
    
    if (_selectionInfo || ![currentSelection isEqualToArray:selection]) {
        [self dismissSelections];
    } else {
        [self markSelection:selection];
        _touchInfo = [NSMutableDictionary new];
        _touchInfo[@"selection"] = selection;
        _touchInfo[@"hitInfo"] = hitInfo;
        
        [self bringUpEditMenuForSelection:selection];
    }
}

- (void)editWord:(CATextLayer *)word {
    [self bringUpEditMenuForSelection:@[word]];
//    NSString * s = [[word.string string] copy];
//    UITextChecker * checker = [[UITextChecker alloc] init];
//    NSArray * guesses = [checker guessesForWordRange:NSMakeRange(0, s.length) inString:s language:@"en"];
//    NSLog(@"%@", guesses);
}

- (void)handleDoubleTapOnWord:(CATextLayer *)word {
    if (_selectionInfo || _touchInfo[@"selection"]) {
        [self dismissSelections];
    } else {
        [self editWord:word];
    }
}

- (void)handleSingleTapOnWord:(CATextLayer *)word {
//    NSArray * selection = _touchInfo[@"selection"];
//    
//    if (selection.count == 1 && [selection isDealingWithWords] && selection.firstObject == word) {
//        [self editWord:word];
//    } else if (!_selectionInfo && !selection) {
//        selection = @[word];
//        [self markSelection:selection];
//        _touchInfo = [NSMutableDictionary new];
//        _touchInfo[@"selection"] = selection;
//        _touchInfo[@"hitInfo"] = @{};
//    } else {
//        [self dismissSelections];
//    }
    [self dismissSelections];
}

- (void)handleDoubleTap:(NSDictionary *)hitInfo {
    BOOL didHitHandle = hitInfo && [self didHitHandle:hitInfo];
    
    if (didHitHandle) {
        [self handleDoubleTapOnHandle:hitInfo];
    } else if (hitInfo[@"word"]) {
        [self handleDoubleTapOnWord:hitInfo[@"word"]];
    } else {
        [self dismissSelections];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchDidMove = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchDidMove = YES;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchDidMove = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (!_touchDidMove) {
        // step 1. did it hit an icon?
        
        CGPoint p = [[touches anyObject] locationInView:_scrollView];
        NSDictionary * hitInfo = [self hitForPoint:p];
        
        BOOL didHitHandle = hitInfo && [self didHitHandle:hitInfo];
        
        if (touches.count == 1) {
            NSUInteger tapCount = [[touches anyObject] tapCount];
            
            if (didHitHandle) {
                // N.B. This is the only place where Handle _taps_ are accounted for.
                
                if (tapCount == 1) {
                    [self handleSingleTapOnHandle:hitInfo];
                } else if (tapCount == 2) {
                    [self handleDoubleTapOnHandle:hitInfo];
                } else {
                    [self dismissSelections];
                }
            } else if (hitInfo[@"word"]) {
                if (tapCount == 1) {
                    [self handleSingleTapOnWord:hitInfo[@"word"]];
                } else if (tapCount == 2) {
                    [self handleDoubleTapOnWord:hitInfo[@"word"]];
                }
            } else {
                [self dismissSelections];
            }
        }
    }
    _touchDidMove = NO;
}

- (NSDictionary *)processSelectionInfo:(NSDictionary *)selectionInfo {
    CGPoint p1 = [selectionInfo[@"firstPoint"] CGPointValue];
    CGPoint p2 = [selectionInfo[@"lastPoint"] CGPointValue];
    
    NSDictionary * hitInfo1 = [self hitForPoint:p1];
    NSDictionary * hitInfo2 = [self hitForPoint:p2];
    
    if (!hitInfo1 || !hitInfo2) return nil;
    
    CALayer * w1 = hitInfo1[@"word"];
    CALayer * w2 = hitInfo2[@"word"];
    
    if (!w1 || !w2) return nil;
    
    int lineNo1 = [hitInfo1[@"lineNo"] intValue];
    int lineNo2 = [hitInfo2[@"lineNo"] intValue];
    
    if (lineNo2 < lineNo1 || (w2.position.x < w1.position.x && lineNo2 <= lineNo1)) {
        NSDictionary * t = hitInfo1;
        hitInfo1 = hitInfo2;
        hitInfo2 = t;
        t = nil;
    }
    
    return @{ @"first": hitInfo1, @"last": hitInfo2 };
}

- (void)multiSelect:(MultiSelectGestureRecognizer *)gesture {
    static NSMutableDictionary * selectionInfo = nil;
    
    if (_editView && _editView.superview) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            gesture.state = UIGestureRecognizerStateFailed;
        }
        return;
    }
    
    [self unmarkMultiWordSelection];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        selectionInfo = [NSMutableDictionary new];
        selectionInfo[@"firstPoint"] = [NSValue valueWithCGPoint:[gesture locationInView:_scrollView]];
    } else if (gesture.state == UIGestureRecognizerStateEnded && !gesture.didMove) {
        NSDictionary * hitInfo = [self hitForPoint:[gesture locationInView:_scrollView]];
        [self handleDoubleTap:hitInfo];
    } else {
        selectionInfo[@"lastPoint"] = [NSValue valueWithCGPoint:[gesture locationInView:_scrollView]];
        
        NSDictionary * processedSelectionInfo = [self processSelectionInfo:selectionInfo];
        if (processedSelectionInfo) {
            [self markMultiWordSelection:processedSelectionInfo];
            if (gesture.state == UIGestureRecognizerStateEnded) {
                [self commitMarkedMultiWordSelection];
            }
            processedSelectionInfo = nil;
        }
        
        if (gesture.state == UIGestureRecognizerStateEnded) {
            selectionInfo = nil;
        }
    }
}

#pragma mark - Global Gestures

- (float)maxDocScale {
    return 1;
}

- (float)minDocScale {
    return 0.475;
}

- (void)arrangeWordsInLines:(NSSet *)lines {
    for (CALayer * line in lines) {
        CALayer * l = line;
        NSArray * words = [l wordsForLine];
        CGPoint o = [self originForFirstWord];
        
        for (CATextLayer * word in words) {
            if (o.x + word.bounds.size.width > [self lineWidth]) {
                o = [self originForFirstWord];
                l = [self insertLineAfter:l];
            }
            
            if (word.superlayer != l) {
                [word removeFromSuperlayer];
                word.position = o;
                [l addSublayer:word];
            } else {
                word.position = o;
            }
            
            o.x += word.bounds.size.width;
        }
    }
}

- (void)removeBlankLines {
    NSMutableArray * itemsToRemove = [NSMutableArray new];
    
    for (CALayer * line in _lines) {
        if ([line isLine] && [line wordsForLine].count == 0) {
            [itemsToRemove addObject:line];
            [line removeFromSuperlayer];
        }
    }
    
    [_lines removeObjectsInArray:itemsToRemove];
}

- (void)arrangeLineNumber:(NSUInteger)lineNo basedOnScale:(float)scale {
    CALayer * line = _lines[lineNo];
    line.transform = CATransform3DMakeScale(scale, scale, 1.0);
    CGPoint o = [self lineOriginForLineNumber:lineNo];
    line.position = CGPointMake(o.x*scale, o.y*scale);
}

- (void)arrangeLinesBasedOnScale:(float)scale {
    for (int i = 0; i < _lines.count; ++i) {
        [self arrangeLineNumber:i basedOnScale:scale];
    }
    
    [self addParagraphSeparatorIfNeeded];
}

- (CALayer *)addParagraphSeparatorIfNeeded {
    if (!_lines.lastObject || ![_lines.lastObject isParagraphSeparator]) {
       return [self newParagraphSeparator];
    }
    return nil;
}

- (void)zoomDocument:(float)scale withAnimationDuration:(float)duration completion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:duration animations:^{
        CGFloat minScale = [self minDocScale];
        CGFloat maxScale = [self maxDocScale];
        
        float fullW = fmaxf(self.view.frame.size.width, self.view.frame.size.height);
        
        float currentScale = scale;
        //check max
        currentScale = currentScale > maxScale ? maxScale : currentScale;
        //check min
        currentScale = currentScale < minScale ? minScale : currentScale;
        
        _scrollView.frame = CGRectMake(0, 0, currentScale*fullW, _scrollView.frame.size.height);
        UIEdgeInsets insets = [self scrollViewInsets];
        _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(currentScale*insets.top, currentScale*insets.left, currentScale*insets.bottom, currentScale*insets.right);
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:duration];
        [self arrangeLinesBasedOnScale:currentScale];
        [CATransaction commit];
        
        [self adjustScrollViewContentSize];
    } completion:completion];
}

- (void)zoomDocument:(float)scale {
    [self zoomDocument:scale withAnimationDuration:0 completion:nil];
}

- (float)currentScale {
    return _scrollView.bounds.size.width/[self width];
}

- (void)translateSelection:(NSArray *)selection withTranslation:(CGPoint)t {
    float currentScale = [selection isDealingWithWords] ? [self currentScale] : 1.0f;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    
    for (CALayer * l in selection) {
        l.position = CGPointMake(l.position.x + t.x/currentScale, l.position.y + t.y/currentScale);
    }
    
    [CATransaction commit];
}

- (void)scrollBasedOnDrag:(NSNumber *)offsetNumber {
    NSArray * selection = _touchInfo[@"selection"];
    if (selection) {
        float offset = [offsetNumber floatValue];
        CGPoint offsetPoint = CGPointMake(0, _scrollView.contentOffset.y + offset);
        
        if (offsetPoint.y < _scrollView.contentSize.height - _scrollView.bounds.size.height && offsetPoint.y > 0) {
            [_scrollView setContentOffset:CGPointMake(0, _scrollView.contentOffset.y + offset)];
            
            CGPoint t = CGPointMake(0, offset);
            
            [self translateSelection:selection withTranslation:t];
            
            [self performSelector:@selector(scrollBasedOnDrag:) withObject:offsetNumber afterDelay:0.001];
        }
    }
}

- (void)scrollDownBasedOnDrag:(id)sender {
    [self scrollBasedOnDrag:@1.0];
}

- (void)scrollUpBasedOnDrag:(id)sender {
    [self scrollBasedOnDrag:@(-1.0)];
}

- (BOOL)pointIsInLowerScrollArea:(CGPoint)p {
    return CGRectContainsPoint(CGRectMake(0, 0.95*_scrollView.bounds.size.height + _scrollView.contentOffset.y, _scrollView.bounds.size.width, 0.05*_scrollView.bounds.size.height), p);
}

- (BOOL)pointIsInUpperScrollArea:(CGPoint)p {
    return CGRectContainsPoint(CGRectMake(0, _scrollView.contentOffset.y, _scrollView.bounds.size.width, 0.05*_scrollView.bounds.size.height), p);
}

- (void)cancelScrolling {
    [_scrollView pop_removeAnimationForKey:@"bounce"];
    [_scrollView pop_removeAnimationForKey:@"decelerate"];
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    static CALayer * focusLine = nil;
    static CGFloat delta = 0;
    
    static CGFloat origOffset = 0;
    
    static BOOL isDraggingClipboardArea = NO;
    static BOOL isDraggingInfoArea = NO;
    static BOOL isScrollingOnSides = NO;
    static BOOL stillDeciding = YES;
    
    BOOL failed = NO;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (_editView && [_editView superview]) {
            gesture.state = UIGestureRecognizerStateFailed;
            [gesture reset];
            failed = YES;
        } else {
            CGPoint p = [gesture locationInView:self.view];
            CGRect clipboardHandle = [self clipboardHandle];
            isDraggingClipboardArea = CGRectContainsPoint(clipboardHandle, p);
            CGRect infoHandle = [self infoHandle];
            isDraggingInfoArea = CGRectContainsPoint(infoHandle, p);
            [self cancelScrolling];
            origOffset = _scrollView.contentOffset.y;
        }
    }
    
    if (!failed && gesture.state != UIGestureRecognizerStateFailed && gesture.state != UIGestureRecognizerStateCancelled && gesture.state != UIGestureRecognizerStatePossible) {
        float maxOffset = _scrollView.contentSize.height - _scrollView.bounds.size.height;
        float minOffset = 0;
        
        if (isDraggingClipboardArea || isDraggingInfoArea) {
            CGPoint t = [gesture translationInView:_scrollView];
            CGPoint v = [gesture velocityInView:_scrollView];
            
            if (stillDeciding) {
                isScrollingOnSides = fabs(t.y) > fabs(t.x) || fabs(v.y) > fabs(v.x);
                
                if (!isScrollingOnSides) {
                    CGPoint focusPoint = CGPointMake(_scrollView.bounds.size.width / 2.0, 20);
                    focusPoint = [self.view convertPoint:focusPoint toView:_scrollView];
                    NSDictionary * hitInfo = [self hitForPoint:focusPoint];
                    if (hitInfo) {
                        focusLine = hitInfo[@"line"];
                    }
                    delta = _scrollView.contentOffset.y - focusLine.frame.origin.y;
                }
                
                stillDeciding = NO;
            }
            
            float newOffset = _scrollView.contentOffset.y;
            
            if (isScrollingOnSides) {
                newOffset = origOffset - t.y;
                if (newOffset < minOffset || newOffset > maxOffset) {
                    newOffset = origOffset - t.y*0.33;
                }
            } else if (isDraggingClipboardArea) {
                CGFloat scale = [self currentScale] + t.x / [self width];
                [self zoomDocument:scale];
                newOffset = focusLine.frame.origin.y + delta;
                [gesture setTranslation:CGPointZero inView:_scrollView];
            }
            
            [_scrollView setContentOffset:CGPointMake(0, newOffset)];
        } else {
            CGPoint p = [gesture locationInView:_scrollView];
            
            if (gesture.state == UIGestureRecognizerStateBegan) {
                NSDictionary * hitInfo = [self hitForPoint:p];
                NSArray * selection = [self selectionForHit:hitInfo];
                NSArray * currentSelection = [self currentSelection];
                
                if (selection.count && (!currentSelection.count || [currentSelection isEqualToArray:selection])) {
                    _touchInfo = [NSMutableDictionary new];
                    _touchInfo[@"selection"] = selection;
                    _touchInfo[@"hitInfo"] = hitInfo;
                } else {
                    [self dismissSelections];
                }
            } else {
                NSArray * selection = _touchInfo[@"selection"];
                
                if (selection) {
                    static BOOL isScrolling = NO;
                    
                    if (gesture.state == UIGestureRecognizerStateEnded) {
                        [NSObject cancelPreviousPerformRequestsWithTarget:self];
                        isScrolling = NO;
                        _touchInfo[@"dropPoint"] = [NSValue valueWithCGPoint:[gesture locationInView:_scrollView]];
                        [self didDropSelection:_touchInfo];
                        _touchInfo = nil;
                    } else {
                        CGPoint t = [gesture translationInView:_scrollView];
                        
                        [self translateSelection:selection withTranslation:t];
                        
                        NSTimeInterval holdDelay = 0.2;
                        
                        if ([self pointIsInLowerScrollArea:p]) {
                            if (!isScrolling) {
                                [self performSelector:@selector(scrollDownBasedOnDrag:) withObject:nil afterDelay:holdDelay];
                                isScrolling = YES;
                            }
                        } else if ([self pointIsInUpperScrollArea:p]) {
                            if (!isScrolling) {
                                [self performSelector:@selector(scrollUpBasedOnDrag:) withObject:nil afterDelay:holdDelay];
                                isScrolling = YES;
                            }
                        } else {
                            [NSObject cancelPreviousPerformRequestsWithTarget:self];
                            isScrolling = NO;
                        }
                        
                        [gesture setTranslation:CGPointZero inView:_scrollView];
                    }
                }
            }
        }
        
        if (gesture.state == UIGestureRecognizerStateEnded) {
            if (isScrollingOnSides) {
                float velocity = -[gesture velocityInView:_scrollView].y;
                
                if (_scrollView.contentOffset.y <= minOffset || _scrollView.contentOffset.y >= maxOffset) {
                    velocity = 0;
                }
                
                POPDecayAnimation *decayAnimation = [POPDecayAnimation animation];
                
                POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"com.rounak.bounds.origin" initializer:^(POPMutableAnimatableProperty *prop) {
                    // read value
                    prop.readBlock = ^(id obj, CGFloat values[]) {
                        values[0] = [obj bounds].origin.x;
                        values[1] = [obj bounds].origin.y;
                    };
                    // write value
                    prop.writeBlock = ^(UIScrollView * obj, const CGFloat values[]) {
                        CGRect tempBounds = [obj bounds];
                        tempBounds.origin.x = values[0];
                        tempBounds.origin.y = values[1];
                        [obj setBounds:tempBounds];
                        
                        CGRect bounds = [obj bounds];
                        
                        BOOL outsideBoundsMinimum = obj.contentOffset.y < minOffset;
                        BOOL outsideBoundsMaximum = obj.contentOffset.y > maxOffset;
                        
                        if (outsideBoundsMaximum || outsideBoundsMinimum) {
                            POPDecayAnimation *decayAnimation = [obj pop_animationForKey:@"decelerate"];
                            if (decayAnimation) {
                                CGPoint target = bounds.origin;
                                if (outsideBoundsMinimum) {
                                    target.x = fmax(target.x, 0.0);
                                    target.y = fmax(target.y, 0.0);
                                } else if (outsideBoundsMaximum) {
                                    target.x = fmin(target.x, obj.contentSize.width - bounds.size.width);
                                    target.y = fmin(target.y, obj.contentSize.height - bounds.size.height);
                                }
                                
                                //NSLog(@"bouncing with velocity: %@", decayAnimation.velocity);
                                
                                POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
                                POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"com.rounak.bounds.origin" initializer:^(POPMutableAnimatableProperty *prop) {
                                    // read value
                                    prop.readBlock = ^(id obj, CGFloat values[]) {
                                        values[0] = [obj bounds].origin.x;
                                        values[1] = [obj bounds].origin.y;
                                    };
                                    // write value
                                    prop.writeBlock = ^(id obj, const CGFloat values[]) {
                                        CGRect tempBounds = [obj bounds];
                                        tempBounds.origin.x = values[0];
                                        tempBounds.origin.y = values[1];
                                        [obj setBounds:tempBounds];
                                    };
                                    // dynamics threshold
                                    prop.threshold = 0.01;
                                }];
                                springAnimation.property = prop;
                                springAnimation.velocity = decayAnimation.velocity;
                                springAnimation.toValue = [NSValue valueWithCGPoint:target];
                                springAnimation.springBounciness = 0.0;
                                springAnimation.springSpeed = 5.0;
                                [obj pop_addAnimation:springAnimation forKey:@"bounce"];
                                
                                [obj pop_removeAnimationForKey:@"decelerate"];
                            }
                        }
                    };
                    // dynamics threshold
                    prop.threshold = 0.01;
                }];
                decayAnimation.property = prop;
                decayAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(0, velocity)];
                [_scrollView pop_addAnimation:decayAnimation forKey:@"decelerate"];
            }
            
            focusLine = nil;
            isDraggingClipboardArea = NO;
            isDraggingInfoArea = NO;
            isScrollingOnSides = NO;
            stillDeciding = YES;
        }
    }
}


@end
