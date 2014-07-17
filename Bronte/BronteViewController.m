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
#import "CATextLayer+Bronte.h"
#import "NSMutableArray+Bronte.h"
#import "NSNumber+Bronte.h"

#import <POP.h>

@interface BronteViewController ()

@end

@implementation BronteViewController

- (UIEdgeInsets)scrollViewInsets {
    CGPoint o = [self lineOriginForLineNumber:0];
    float p = o.y + 10;
    return UIEdgeInsetsMake(p, 0, p, [self width] - (o.x + [NSNumber lineWidth] + 60));
}

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _defaultAttr = [UIFont bronteDefaultFontAttributes];
        
        _lines = [NSMutableArray new];
        
        self.view.backgroundColor = [UIColor bronteSecondaryBackgroundColor];
        self.view.layer.zPosition = -11;
        
        DocumentScrollView * scrollView = [[DocumentScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
        scrollView.touchDelegate = self;
        scrollView.backgroundColor = [UIColor bronteBackgroundColor];
        _docLayer = scrollView.layer;
        _docLayer.masksToBounds = NO;
        _docLayer.zPosition = -10;
        
        _docLayer = [CALayer layer];
        _docLayer.frame = scrollView.layer.frame;
        [scrollView.layer addSublayer:_docLayer];
        
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
        panGesture.delegate = self;
        [self.view addGestureRecognizer:panGesture];
        
        UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        longPressGesture.delegate = self;
        longPressGesture.minimumPressDuration = 0.75;
        [self.view addGestureRecognizer:longPressGesture];
        
        _shouldAllowPan = YES;
        
        [self newLine]; //required
        
        //testing only
        [self addText:@"You don't know about me without you have read a book by the name of The Adventures of Tom Sawyer; but that ain't no matter.  That book was made by Mr. Mark Twain, and he told the truth, mainly.  There was things which he stretched, but mainly he told the truth.  That is nothing.  I never seen anybody but lied one time or another, without it was Aunt Polly, or the widow, or maybe Mary.  Aunt Polly — Tom's Aunt Polly, she is — and Mary, and the Widow Douglas is all told about in that book, which is mostly a true book, with some stretchers, as I said before." toLine:_lines.lastObject];
        
        for (int i = 0; i < 1; ++i) {
            [self addText:@"Now the way that the book winds up is this:  Tom and me found the money that the robbers hid in the cave, and it made us rich.  We got six thousand dollars apiece — all gold.  It was an awful sight of money when it was piled up.  Well, Judge Thatcher he took it and put it out at interest, and it fetched us a dollar a day apiece all the year round — more than a body could tell what to do with.  The Widow Douglas she took me for her son, and allowed she would sivilize me; but it was rough living in the house all the time, considering how dismal regular and decent the widow was in all her ways; and so when I couldn't stand it no longer I lit out.  I got into my old rags and my sugar-hogshead again, and was free and satisfied.  But Tom Sawyer he hunted me up and said he was going to start a band of robbers, and I might join if I would go back to the widow and be respectable.  So I went back." toLine:_lines.lastObject];
            
            [self addText:@"The widow she cried over me, and called me a poor lost lamb, and she called me a lot of other names, too, but she never meant no harm by it. She put me in them new clothes again, and I couldn't do nothing but sweat and sweat, and feel all cramped up.  Well, then, the old thing commenced again.  The widow rung a bell for supper, and you had to come to time. When you got to the table you couldn't go right to eating, but you had to wait for the widow to tuck down her head and grumble a little over the victuals, though there warn't really anything the matter with them, — that is, nothing only everything was cooked by itself.  In a barrel of odds and ends it is different; things get mixed up, and the juice kind of swaps around, and the things go better." toLine:_lines.lastObject];
            
            [self addText:@"After supper she got out her book and learned me about Moses and the Bulrushers, and I was in a sweat to find out all about him; but by and by she let it out that Moses had been dead a considerable long time; so then I didn't care no more about him, because I don't take no stock in dead people." toLine:_lines.lastObject];
        }
        
        int numWords = 0;
        
        for (CALayer * line in _lines) {
            numWords += [line wordsForLayer].count;
        }
        
        NSLog(@"numWords: %d", numWords);
        
        // end of testing code
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:UIKeyboardDidHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification object:nil];
        
        _clipboard = [NSMutableDictionary new];
        
        _clipboardLayer = [CALayer layer];
        _clipboardLayer.frame = _docLayer.bounds;
        _clipboardLayer.anchorPoint = CGPointZero;
        _clipboardLayer.position = CGPointMake(_scrollView.bounds.size.width, 0);
        _clipboardLayer.backgroundColor = [UIColor clearColor].CGColor;
        _clipboardLayer.opaque = NO;
        _clipboardLayer.zPosition = _docLayer.zPosition;
        _clipboardLayer.masksToBounds = NO;
        [self.view.layer addSublayer:_clipboardLayer];
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

- (float)maxScrollOffset {
    return fmaxf(0, _scrollView.contentSize.height - _scrollView.bounds.size.height);
}

- (float)minScrollOffset {
    return 0;
}

- (CGPoint)originForFirstWord {
    return CGPointMake([NSNumber lineHandleWidth] + [UIFont bronteWordSpacing], ([UIFont bronteWordHeight]/2.0) - 0.5 - 4);
}

- (CGPoint)lineOriginForLineNumber:(NSUInteger)n {
    float offset = n < _lines.count && [_lines[n] isParagraphSeparator] ? 63 - 0.5*[NSNumber linePadding] : 0;
    return CGPointMake(([self width] - [UIFont bronteLineWidth])/2.0 - [NSNumber lineHandleWidth] + 15 + offset, 50 + n*[NSNumber lineHeight]);
}

- (void)adjustScrollViewContentSize {
    CGPoint offset = _scrollView.contentOffset;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, [self currentScale]*[self lineOriginForLineNumber:_lines.count+2].y);
    [_scrollView setContentOffset:offset animated:NO];
}

- (CALayer *)newLine {
    CALayer * l = [CALayer makeLine];
    l.position = [self lineOriginForLineNumber:_lines.count];
    //l.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    [_docLayer addSublayer:l];
    [_lines addObject:l];
    
    [self adjustScrollViewContentSize];
    
    return l;
}

- (CALayer *)insertNewParagraphSeparatorAfter:(CALayer *)l {
    return [self insertLine:[CALayer makeParagraphSeparator] after:l];
}

- (CALayer *)newParagraphSeparator {
    return [self insertNewParagraphSeparatorAfter:_lines.lastObject];
}

- (CALayer *)insertNewLineAfter:(CALayer *)l {
    return [self insertLine:[CALayer makeLine] after:l];
}

- (CALayer *)insertLine:(CALayer *)newLine after:(CALayer *)l {
    NSUInteger n = [_lines indexOfObject:l];
    [_lines insertObject:newLine atIndex:n+1];
    newLine.position = [self lineOriginForLineNumber:n+1];
    [_docLayer addSublayer:newLine];
    
    float currentScale = [self currentScale];
    
    for (NSUInteger i = n+1; i < _lines.count; ++i) {
        [self arrangeLineNumber:i basedOnScale:currentScale];
    }
    
    [self adjustScrollViewContentSize];
    
    return newLine;
}

- (CALayer *)addWord:(NSString *)word toLine:(CALayer *)line {
    CALayer * w = [CATextLayer makeWord:word];
    w.position = [self originForFirstWord];
    
    CALayer * l = line;
    
    if ([l isParagraphSeparator]) {
        l = [self insertNewLineAfter:l];
        //[self newParagraphSeparator];
    }
    
    CALayer * lastWord = [line wordsForLine].lastObject;
    float newX = lastWord ? [lastWord maxX] : w.position.x;
    
    if (newX + w.bounds.size.width > [NSNumber availableLineWidth]) {
        l = [self insertNewLineAfter:l];
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
    return [self hitForPoint:p restricted:YES];
}

- (NSDictionary *)hitForPoint:(CGPoint)p restricted:(BOOL)restricted {
    float scale = 1.0/[self currentScale];
    
    float w = [self lineOriginForLineNumber:_lines.count].x + [NSNumber lineWidth];
    
    p = CGPointMake(scale*p.x, scale*p.y);
    
    for (int i = 0; i < _lines.count; ++i) {
        CALayer * line = _lines[i];
        CALayer * hit = nil;
        
        CGRect hitZone = CGRectMake(0, line.frame.origin.y, w, line.frame.size.height);
        BOOL allowedHit = !restricted || CGRectContainsPoint(hitZone, p);
        
        if (allowedHit && (hit = [line hitTest:p])) {
            NSMutableDictionary * hitInfo = [NSMutableDictionary new];
            hitInfo[@"line"] = line;
            hitInfo[@"lineNo"] = [NSNumber numberWithInt:i];
            hitInfo[@"origPoint"] = [NSValue valueWithCGPoint:p];
            if ([hit isWord]) {
                hitInfo[@"word"] = hit;
            } else {
                float currentScale = [self currentScale];
                if (p.x < line.position.x + currentScale*[NSNumber lineHandleWidth]) {
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

- (void)configureMultiWordSelection:(NSDictionary *)selectionInfo withAttributes:(NSDictionary *)attr {
    [self forEachWordInMultiSelection:selectionInfo Do:^(CATextLayer *word) {
        [word configureWithAttributes:attr];
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
            wordIcon.contents = (id)[UIImage wordIcon].CGImage;
            wordIcon.name = @"M";
            
            int lineNo1 = [hitInfo1[@"lineNo"] intValue];
            int lineNo2 = [hitInfo2[@"lineNo"] intValue];
            
            wordIcon.position = CGPointMake((w1.superlayer.bounds.size.width - w1.position.x - wordIcon.frame.size.width) + 30, 0.5*(lineNo2 - lineNo1 + 0.675)*[NSNumber lineHeight]);
            [w1 addSublayer:wordIcon];
            _selectionInfo[@"icon"] = wordIcon;
            
            _selectionInfo[@"selection"] = [self wordsForMultiSelection:_selectionInfo];
        }
    }
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
    __block NSSet * affectedLines = [selection linesForSelection];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (selection) [selection unmarkSelection];
        if (_selectionInfo) [self unmarkMultiWordSelection];
        [self linesNeedArranging:affectedLines];
        affectedLines = nil;
    }];
    
    for (CALayer * l in selection) {
        l.hidden = NO;
        l.position = l.originalPosition;
    }
    
    [CATransaction commit];
}

- (void)didDropWords:(NSDictionary *)selectionInfo {
    NSArray * selection = selectionInfo[@"selection"];
    CGPoint dropPoint = [selectionInfo[@"dropPoint"] CGPointValue];
    
    float startX = [self lineOriginForLineNumber:_lines.count].x;
    
    if (dropPoint.x < startX) {
        dropPoint.x = startX + 1;
    }
    
    NSDictionary * dropInfo = [self hitForPoint:dropPoint];
    CALayer * dropLine = dropInfo[@"line"];
    
    if (dropLine && ![dropLine isParagraphSeparator]) {
        float currentScale = [self currentScale];
        float startX = [self lineOriginForLineNumber:_lines.count].x;
        
        NSDictionary * hitInfo = selectionInfo[@"hitInfo"];
        CALayer * origLine = hitInfo[@"line"];
//        CALayer * dropWord = dropInfo[@"word"];
        
//        if (selection.count > 1 && !dropWord) {
//            [self putBackSelection:selection];
//        } else {
            int dropLineNo = [dropInfo[@"lineNo"] intValue];
            CGPoint dropLineOrigin = [self lineOriginForLineNumber:dropLineNo];
            CGPoint origLineOrigin = [self lineOriginForLineNumber:[hitInfo[@"lineNo"] intValue]];
            CGPoint origHitPoint = [hitInfo[@"origPoint"] CGPointValue];
            
            __block NSMutableSet * affectedLines = [NSMutableSet new];
            
            [CATransaction begin];
            [CATransaction setAnimationDuration:0];
            [CATransaction setCompletionBlock:^{
                
            }];
            CGPoint dp = CGPointMake(selection.count > 1 ? [self anchorPointForSelection:selection basedOnDropPoint:CGPointMake((dropPoint.x/currentScale - startX), 0)].x : [[selection firstObject] position].x, 0);
            // needs to be in reverse due to the z ordering. see the method -wordsForLine
            NSEnumerator * reverse = [selection reverseObjectEnumerator];
            CATextLayer * w = nil;
            while ((w = [reverse nextObject])) {
                [affectedLines addObject:w.superlayer];
                [w removeFromSuperlayer];
                dp.y = dropPoint.y/currentScale - dropLineOrigin.y - (origHitPoint.y/currentScale - (w.originalPosition.y + origLineOrigin.y));
                w.position = dp;
                w.hidden = NO;
                [dropLine addSublayer:w];
            }
            [CATransaction commit];
            
            [affectedLines addObject:dropLine];
            
            if (origLine != dropLine || selection.count > 1) {
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
        //}
    } else {
        [self putBackSelection:selection];
    }
}

- (void)didDropLines:(NSDictionary *)selectionInfo {
    NSArray * selection = selectionInfo[@"selection"];
    
    CGPoint dropPoint = [selectionInfo[@"dropPoint"] CGPointValue];
    
    float startX = [self lineOriginForLineNumber:_lines.count].x + [NSNumber lineHandleWidth];
    
    if (dropPoint.x < startX) {
        dropPoint.x = startX + 1;
    }
    
    NSDictionary * dropInfo = [self hitForPoint:dropPoint];
    CALayer * dropLine = dropInfo[@"line"];
    
    float currentScale = [self currentScale];
    
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
    } else if ([selection isParagraph]) {
        int dropLineNo = [dropInfo[@"lineNo"] intValue];
        
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
        before = dropPoint.y < dropLine.position.y + currentScale*[NSNumber lineHeight]*0.5;
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
        [self adjustScrollViewContentSize];
    } else {
        [self putBackSelection:selection];
    }
}

- (void)didDropSelection:(NSDictionary *)selectionInfo {
    NSArray * selection = selectionInfo[@"selection"];
    
    if (selection) [selection unmarkSelection];
    if (_selectionInfo) [self unmarkMultiWordSelection];
    
    CGPoint dropPoint = [selectionInfo[@"dropPoint"] CGPointValue];
    BOOL didDropOnClipboard = [self clipboardDropZoneContainsPoint:dropPoint];
    
    if (!didDropOnClipboard) {
        for (CALayer * l in selection) {
            l.hidden = YES;
        }
        
        if ([selection isDealingWithWords]) {
            [self didDropWords:selectionInfo];
        } else {
            [self didDropLines:selectionInfo];
        }
    } else {
        [self moveSelectionToClipboard:selectionInfo];
    }
}

#pragma mark - Clipboard

- (void)moveSelectionToClipboard:(NSDictionary *)selectionInfo {
    NSArray * selection = selectionInfo[@"selection"];
    
    NSArray * words = [selection wordsForSelection];
    
    if (words.count) {
        NSMutableArray * wordsAsStrings = [NSMutableArray new];
        
        float scale = 0.6;
        CATransform3D transform = CATransform3DMakeScale(scale, scale, 1.0);
        
        for (CATextLayer * w in words) {
            [wordsAsStrings addObject:[w word]];
        }
        
        NSString * text = [wordsAsStrings componentsJoinedByString:@" "];
        CATextLayer * textLayer = [CATextLayer makeWord:text];
        textLayer.wrapped = YES;
        
        CALayer * firstLine = [selection firstLineOfSelection];
        CALayer * lastLine = [selection lastLineOfSelection];
        
        float h = fmaxf(scale*(lastLine.position.y - firstLine.position.y) + 1.5*[UIFont bronteLineHeight], 1.5*[UIFont bronteLineHeight]);
        float w = fmaxf(fminf([UIFont bronteLineWidth], 1.25*[textLayer.string size].width), 140);
        
        textLayer.frame = CGRectMake(0, 0, w, h);
        textLayer.transform = transform;
        
        CGPoint dropPoint = [selectionInfo[@"dropPoint"] CGPointValue];
        dropPoint.y -= _scrollView.contentOffset.y;
        dropPoint.x -= _clipboardLayer.position.x - _scrollView.frame.origin.x;
        
        CGPoint pos = dropPoint;
        pos.x -= scale*w / 2.0;
        pos.y -= scale*h / 2.0;
        pos.x = [NSNumber bound:pos.x low:[self clipboardFrame].size.width high:_clipboardLayer.frame.size.width - 10];
        pos.y = [NSNumber bound:pos.y low:10 high:_clipboardLayer.frame.size.height - textLayer.frame.size.height];
        textLayer.position = pos;
        textLayer.zPosition = 10;
        
        [self deleteSelection:selection];
        
        [_clipboardLayer addSublayer:textLayer];
    }
}

#pragma mark - Editing

- (float)inputOffsetForSelection:(NSArray *)selection {
    CALayer * l = [_editView isInsertingLeft] ? [selection firstLineOfSelection] : [selection lastLineOfSelection];
    return (l.position.y - _scrollView.contentOffset.y) - 0*[NSNumber lineHeight];
}

- (NSUInteger)linesAboveEditMenu {
    return 5;
}

- (float)editMenuOffsetForSelection:(NSArray *)selection {
    CALayer * l = [selection lastLineOfSelection];
    return (l.position.y - _scrollView.contentOffset.y) - [self linesAboveEditMenu]*[NSNumber lineHeight];
}

- (CALayer *)focusLineForSelection:(NSArray *)selection {
    CALayer * l = [selection lastLineOfSelection];
    NSUInteger i = [_lines indexOfObject:l];
    if (i != NSNotFound) {
        long n = i - [self linesAboveEditMenu];
        if (n >= 0) {
            return _lines[i];
        }
    }
    
    return nil;
}

- (void)bringUpEditMenuForSelection:(NSArray *)selection {
    if (_editView && [_editView superview]) {
        return;
    }
    
    [self cancelScrolling];
    [self dismissSelections];
    
    [selection markSelection];
    _touchInfo = [self newTouchSelection:selection];
    
    __weak BronteViewController * me = self;
    
    float deltaZoom = 1.0 - [self currentScale];
    
    [self zoomDocument:1.0 focusLine:[self focusLineForSelection:selection] animationDuration:0 completion:^(BOOL finished) {
        float offset = [me editMenuOffsetForSelection:selection];
        
        _editView = [[BronteEditView alloc] initWithSelection:selection];
        _editView.layer.zPosition = MAXFLOAT;
        _editView.delegate = self;
        _editView.hidden = YES;
        CGRect origFrame = _editView.frame;
        CGRect newFrame = origFrame;
        newFrame.origin.y += newFrame.size.height;
        _editView.frame = newFrame;
        [_scrollView addSubview:_editView];
        
        _scrollView.previousContentOffset = _scrollView.contentOffset;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_scrollView setContentOffset:CGPointMake(0, _scrollView.contentOffset.y + offset)];
        } completion:^(BOOL finished) {
            if (deltaZoom > 0.1) {
                _scrollView.previousContentOffset = _scrollView.contentOffset;
            }
            
            _editView.hidden = NO;
            
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                _editView.frame = origFrame;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
}

- (void)dismissEditMenu {
    [self dismissEditMenuAndForceOffset:NO];
}

- (void)dismissEditMenuAndForceOffset:(BOOL)force {
    if (_editView) {
        [_editView hidePointer];
        
        [self arrangeWordsInLines:[_editView.selection linesForSelection]];
        
        float maxOffset = [self maxScrollOffset];
        float minOffset = [self minScrollOffset];
        
        float prevOffset = [NSNumber bound:_scrollView.previousContentOffset.y low:minOffset high:maxOffset];
        
        float currentOffset = _scrollView.contentOffset.y;
        BOOL outOfBounds = currentOffset < minOffset || currentOffset > maxOffset;
        
        if (force || (fabs(prevOffset - currentOffset) < 0.8*_scrollView.bounds.size.height) || outOfBounds) {
            if (outOfBounds) {
                prevOffset = [NSNumber bound:currentOffset low:minOffset high:maxOffset];
            }
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [_scrollView setContentOffset:CGPointMake(0, prevOffset)];
            } completion:^(BOOL finished) {
                
            }];
        }
        
        CGRect newFrame = _editView.frame;
        newFrame.origin.y += _inputView ? _inputView.frame.size.height + _inputView.frame.origin.y : newFrame.size.height;
        
        [UIView animateWithDuration:(_inputView ? 0.3 : 0.175) delay:0 options:(_inputView ? UIViewAnimationOptionCurveEaseOut :UIViewAnimationOptionCurveLinear) animations:^{
            _editView.frame = newFrame;
        } completion:^(BOOL finished) {
            NSArray * selection = _touchInfo[@"selection"];
            [selection unmarkSelection];
            _touchInfo = nil;
            
            [_editView removeFromSuperview];
            _editView = nil;
            _inputView = nil;
        }];
    }
}

- (void)didDeleteCharacterFromLine:(CALayer *)line {
    NSArray * words = [line wordsForLine];
    
    for (CATextLayer * w in words) {
        if ([[w word] length] == 0) {
            [w removeFromSuperlayer];
            [_editView.selection removeWord:w];
        }
    }
    
    words = [line wordsForLine];
    
    if (words.count == 0) {
        [_editView.selection removeObject:line];
        [self removeBlankLines];
    } else {
        NSSet * lines = [NSSet setWithObject:line];
        [self linesNeedArranging:lines];
    }
    
    if (_editView.selection.count) {
        if (![_editView isInsertingLeft]) {
            [self editMenuNeedsAdjusting];
        } else {
            [self arrangeLinesBasedOnScale:[self currentScale]];
            [_editView adjustPosition];
        }
    } else {
        [_editView setNeedsDisplay];
        
        __weak BronteViewController * me = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [me dismissEditMenu];
            [me arrangeLinesBasedOnScale:[me currentScale]];
        });
    }
}

- (void)deleteSelection:(NSArray *)selection {
    NSSet * lines = [selection linesForSelection];
    NSArray * words = [selection wordsForSelection];
    
    CGPoint prevOffset = _scrollView.previousContentOffset;
    
    CALayer * firstLine = [selection firstLineOfSelection];
    
    if (firstLine.position.y < _scrollView.contentOffset.y) {
        prevOffset.y = firstLine.position.y - ([self linesAboveEditMenu] + 1)*[self currentScale]*[NSNumber lineHeight];
    } else {
        prevOffset = _scrollView.contentOffset;
    }
    
    for (CATextLayer * word in words) {
        [word removeFromSuperlayer];
    }
    
    [self arrangeWordsInLines:lines];
    
    if ([selection isParagraph]) {
        [selection.lastObject removeFromSuperlayer];
        [_lines removeObject:selection.lastObject];
    }
    
    _scrollView.previousContentOffset = prevOffset;
    [self dismissEditMenuAndForceOffset:YES];
    
    __weak BronteViewController * me = self;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSSet * lines = [selection linesForSelection];
        for (CALayer * l in lines) {
            [l removeFromSuperlayer];
        }
        [me removeBlankLines];
        [me arrangeLinesBasedOnScale:[me currentScale]];
        [me adjustScrollViewContentSize];
    });
}

- (void)editMenuNeedsAdjusting {
    CGPoint newPoint = [_editView findSelectionPoint];
    
    float delta = newPoint.y - _editView.selectionPoint.y;
    
    if (fabsf(delta) > 1) {
        [self arrangeLinesBasedOnScale:[self currentScale]];
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_scrollView setContentOffset:CGPointMake(0, _scrollView.contentOffset.y + delta)];
            [_editView adjustPosition];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [_editView adjustPosition];
    }
}

- (void)linesNeedArranging:(NSSet *)lines {
    for (CALayer * line in lines) {
        CALayer * l = line;
        NSArray * words = [l wordsForLine];
        CGPoint o = [self originForFirstWord];
        
        for (CATextLayer * word in words) {
            word.position = o;
            o.x += word.bounds.size.width;
        }
    }
}

#pragma mark - Keyboard

- (void)dismissInputView {
    [_inputView removeFromSuperview];
    _inputView = nil;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    if (!_isRotating) {
        //[self dismissInputView];
        [self dismissEditMenu];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
}

- (void)insertSelectionRequested:(NSArray *)selection before:(BOOL)before {
    float y = [_editView offset];
    float offset = [self inputOffsetForSelection:selection];
    _inputView = [[BronteTextInput alloc] initWithFrame:CGRectMake(0, y, [self width], [self height] - fabsf(_editView.frame.origin.y - (_scrollView.contentOffset.y + offset)) - y)];
    _inputView.insertBefore = before;
    _inputView.delegate = self;
    [_editView addSubview:_inputView];
    [_inputView becomeFirstResponder];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _scrollView.contentOffset = CGPointMake(0, _scrollView.contentOffset.y + offset);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)insertBeforeSelection:(NSArray *)selection {
    [self insertSelectionRequested:selection before:YES];
}

- (void)insertAfterSelection:(NSArray *)selection {
    [self insertSelectionRequested:selection before:NO];
}

- (NSArray *)wordsFromLine:(CALayer *)line afterWord:(CATextLayer *)word {
    NSMutableArray * wordsAfter = [NSMutableArray new];
    NSArray * words = [line wordsForLine];
    
    NSUInteger theWordIndex = [words indexOfObject:word];
    for (NSUInteger i = theWordIndex + 1; i < words.count; ++i) {
        CATextLayer * w = words[i];
        [wordsAfter addObject:w];
    }
    
    return wordsAfter;
}

- (void)removeWordsFromLine:(NSArray *)words {
    for (CATextLayer * w in words) {
        [w removeFromSuperlayer];
    }
}

- (NSString *)wordsAsString:(NSArray *)words {
    NSMutableString * string = [NSMutableString new];
    
    for (CATextLayer * w in words) {
        [string appendFormat:@"%@ ", [w word]];
    }
    
    return string;
}

- (void)didEnterText:(NSArray *)lines beforeWord:(NSString *)theWord onLine:(CALayer *)theLine withExtra:(NSString *)extra {
    CALayer * addedLine = theLine;
    
    long stop = lines.count - 1;
    
    for (long i = 0; i < stop; ++i) {
        NSString * line = lines[i];
        
        if (line.length == 0) {
            addedLine = [self insertNewParagraphSeparatorAfter:addedLine];
        } else {
            addedLine = [self addText:line toLine:addedLine];
        }
    }
    
    NSString * s = [NSString stringWithFormat:@"%@%@", lines.lastObject, theWord];
    addedLine = [self addText:s toLine:addedLine];
    
    addedLine = [self addText:extra toLine:addedLine];
}

- (void)didEnterText:(NSArray *)lines afterWord:(NSString *)theWord onLine:(CALayer *)theLine withExtra:(NSString *)extra {
    long i = 0;

    NSString * s = [NSString stringWithFormat:@"%@%@", theWord, lines.firstObject];
    i += [lines.firstObject length] ? 1 : 0;
    
    CALayer * addedLine = theLine;
    addedLine = [self addText:s toLine:addedLine];
    
    long stop = lines.count - 1;
    
    for (; i < stop; ++i) {
        NSString * line = lines[i];
        
        if (line.length == 0) {
            addedLine = [self insertNewParagraphSeparatorAfter:addedLine];
        } else {
            addedLine = [self addText:line toLine:addedLine];
        }
    }
    
    if (i < lines.count && [lines.lastObject length] > 0) {
        addedLine = [self addText:lines.lastObject toLine:addedLine];
    }
    
    addedLine = [self addText:extra toLine:addedLine];
}

- (void)didEnterText:(NSArray *)lines {
    [_editView hidePointer];
    
    @autoreleasepool {
        BOOL before = _inputView.insertBefore;
        
        NSArray * selection = _editView.selection;
        
        CALayer * theLine = before ? [selection firstLineOfSelection] : [selection lastLineOfSelection];
        CATextLayer * theWord = before ? [selection firstWordOfSelection] : [selection lastWordOfSelection];
        
        NSArray * words = [self wordsFromLine:theLine afterWord:theWord];
        NSString * extra = [self wordsAsString:words];
        [self removeWordsFromLine:words];
        [theWord removeFromSuperlayer];
        
        if (before) {
            [self didEnterText:lines beforeWord:[theWord word] onLine:theLine withExtra:extra];
        } else {
            [self didEnterText:lines afterWord:[theWord word] onLine:theLine withExtra:extra];
        }
    }
    
    [self arrangeLinesBasedOnScale:[self currentScale]];
}

#pragma mark - Gestures

- (CGRect)clipboardFrame {
    float p = 0.09;
    float s = p*_scrollView.frame.size.width;
    return CGRectMake(_scrollView.frame.origin.x + _scrollView.frame.size.width - s, 0, s, _scrollView.frame.size.height);
}

- (CGRect)clipboardHandle {
    CGRect frame = [self clipboardFrame];
    frame.size.width += 80;
    return frame;
}

- (CGRect)clipboardDropZone {
    CGRect dropZone = [self clipboardFrame];
    dropZone.size.width += [self width];
    dropZone.size.height = _scrollView.contentSize.height;
    dropZone.origin.x = ([self lineOriginForLineNumber:_lines.count].x + [NSNumber lineWidth]);
    return dropZone;
}

- (CGRect)infoHandle {
    float p = 0.09;
    float s = p*_scrollView.frame.size.width;
    return CGRectMake(_scrollView.frame.origin.x, 0, s, _scrollView.frame.size.height);
}

- (void)dismissSelections {
    [self dismissEditMenu];
    
    NSArray * currentSelection = _touchInfo[@"selection"];
    
    if (currentSelection) {
        [currentSelection unmarkSelection];
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
            [selection markSelection];
            _touchInfo = [self newTouchSelection:selection withHitInfo:hitInfo];
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
        [selection markSelection];
        _touchInfo = [self newTouchSelection:selection withHitInfo:hitInfo];
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
        NSDictionary * hitInfo = [self hitForPoint:p restricted:NO];
        
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
    
    NSDictionary * hitInfo1 = [self hitForPoint:p1 restricted:NO];
    NSDictionary * hitInfo2 = [self hitForPoint:p2 restricted:NO];
    
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
    return 0.525;
}

- (void)arrangeWordsInLines:(NSSet *)lines {
    for (CALayer * line in lines) {
        CALayer * l = line;
        NSArray * words = [l wordsForLine];
        CGPoint o = [self originForFirstWord];
        
        for (CATextLayer * word in words) {
            
            if (o.x + word.bounds.size.width > [NSNumber availableLineWidth]) {
                o = [self originForFirstWord];
                l = [self insertNewLineAfter:l];
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

- (CATextLayer *)anchorWordForSelection:(NSArray *)selection {
    return [selection firstWordOfSelection];
}

- (float)anchorWordWidth:(CATextLayer *)anchorWord forSelection:(NSArray *)selection {
    return selection.count > 1 ? 100 : anchorWord.bounds.size.width;
}

- (CGPoint)anchorPointForSelection:(NSArray *)selection basedOnDropPoint:(CGPoint)dropPoint {
    CGPoint anchorPoint = dropPoint;
    anchorPoint.x -= 0.5*[self anchorWordWidth:[self anchorWordForSelection:selection] forSelection:selection];
    return anchorPoint;
}

- (void)arrangeWordsInLine:(CALayer *)l basedOnPoint:(CGPoint)point excludingWords:(NSArray *)excluded {
    CATextLayer * anchorWord = [self anchorWordForSelection:excluded];
    
    NSArray * words = [l wordsForLine];
    CGPoint o = [self originForFirstWord];
    
    float anchorWordWidth = [self anchorWordWidth:anchorWord forSelection:excluded];
    CGPoint anchorPoint = [self anchorPointForSelection:excluded basedOnDropPoint:point];
    
    for (CATextLayer * word in words) {
        float width = word.bounds.size.width;
        
        if ([excluded containsObject:word]) {
            continue;
        }
        
        BOOL before = [excluded count] > 1 ? [word shouldComeBeforePoint:anchorPoint] : [word shouldComeBeforeWord:anchorWord];
        word.position = before ? o : CGPointMake(o.x + anchorWordWidth, o.y);
        o.x += width;
    }
}

- (void)arrangeWordsInLine:(CALayer *)l ignoringWords:(NSArray *)excluded {
    NSArray * words = [l wordsForLine];
    CGPoint o = [self originForFirstWord];
    
    for (CATextLayer * word in words) {
        if ([excluded containsObject:word]) {
            continue;
        }
        
        word.position = o;
        o.x += word.bounds.size.width;
    }
}

- (void)removeBlankLines {
    NSMutableArray * itemsToRemove = [NSMutableArray new];
    
    for (CALayer * line in _lines) {
        if ([line isLine] && [line wordsForLayer].count == 0) {
            [itemsToRemove addObject:line];
            [line removeFromSuperlayer];
            line.contents = nil;
        }
    }
    
    [_lines removeObjectsInArray:itemsToRemove];
    [self adjustScrollViewContentSize];
}

- (void)removeLine:(CALayer *)line {
    [line removeFromSuperlayer];
    [_lines removeObject:line];
    [self adjustScrollViewContentSize];
}

- (void)arrangeLineNumber:(NSUInteger)lineNo basedOnScale:(float)scale {
    CALayer * line = _lines[lineNo];
    CGPoint o = [self lineOriginForLineNumber:lineNo];
    //line.transform = CATransform3DMakeScale(scale, scale, 1.0);
    line.position = CGPointMake(o.x, o.y);
}

- (void)arrangeLinesBasedOnScale:(float)scale {
    for (int i = 0; i < _lines.count; ++i) {
        [self arrangeLineNumber:i basedOnScale:scale];
    }
    
    [self addParagraphSeparatorIfNeeded];
}

- (CALayer *)addParagraphSeparatorIfNeeded {
    if (_lines.count > 1 && ![_lines.lastObject isParagraphSeparator]) {
       return [self newParagraphSeparator];
    }
    return nil;
}

- (void)zoomDocument:(float)scale focusLine:(CALayer *)focusLine animationDuration:(float)duration completion:(void (^)(BOOL finished))completion {
    float delta = focusLine ? (_scrollView.contentOffset.y - [self currentScale]*focusLine.frame.origin.y) : 0;
    
    [self cancelScrolling];
    
    [UIView animateWithDuration:duration animations:^{
        float fullW = [self width];
        
        float currentScale = [NSNumber bound:scale low:[self minDocScale] high:[self maxDocScale]];

        CGPoint prevOffset = _scrollView.contentOffset;
        _scrollView.frame = CGRectMake(0, 0, currentScale*fullW, _scrollView.frame.size.height);
        _scrollView.contentOffset = prevOffset;
        
        UIEdgeInsets insets = [self scrollViewInsets];
        _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(currentScale*insets.top, currentScale*insets.left, currentScale*insets.bottom, currentScale*insets.right);
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:duration];
        [CATransaction setCompletionBlock:^{
            
        }];
        //[self arrangeLinesBasedOnScale:currentScale];
        _docLayer.anchorPoint = CGPointZero;
        _docLayer.position = CGPointZero;
        _docLayer.transform = CATransform3DMakeScale(currentScale, currentScale, 1.0);
        _clipboardLayer.position = CGPointMake(_scrollView.frame.origin.x + _scrollView.frame.size.width, 0);
        [CATransaction commit];
        
        if (focusLine) {
            float newOffset = focusLine.frame.origin.y*currentScale + delta;
            //NSLog(@"offset: %f, newOffset: %f, origin: %f", _scrollView.contentOffset.y, newOffset, focusLine.frame.origin.y);
            [_scrollView setContentOffset:CGPointMake(0, newOffset) animated:NO];
        }
        
        [self adjustScrollViewContentSize];
    } completion:completion];
}

- (void)zoomDocument:(float)scale focusLine:(CALayer *)focusLine {
    [self zoomDocument:scale focusLine:focusLine animationDuration:0 completion:nil];
}

- (float)currentScale {
    return _scrollView.bounds.size.width/[self width];
}

- (void)translateSelection:(NSArray *)selection withTranslation:(CGPoint)t {
    float currentScale = [self currentScale];
    
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

static BOOL _isScrollingBasedOnDrag = NO;

- (void)cancelScrollingBasedOnDrag {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _isScrollingBasedOnDrag = NO;
}

- (void)checkIfShouldScrollBasedOnPoint:(CGPoint)p {
    NSTimeInterval holdDelay = 0.2;
    
    if ([self pointIsInLowerScrollArea:p]) {
        if (!_isScrollingBasedOnDrag) {
            [self performSelector:@selector(scrollDownBasedOnDrag:) withObject:nil afterDelay:holdDelay];
            _isScrollingBasedOnDrag = YES;
        }
    } else if ([self pointIsInUpperScrollArea:p]) {
        if (!_isScrollingBasedOnDrag) {
            [self performSelector:@selector(scrollUpBasedOnDrag:) withObject:nil afterDelay:holdDelay];
            _isScrollingBasedOnDrag = YES;
        }
    } else {
        [self cancelScrollingBasedOnDrag];
    }
}

static CAShapeLayer * _clipboardMask = nil;

- (BOOL)clipboardDropZoneContainsPoint:(CGPoint)p {
    float scale = [self currentScale];
    
    CGRect dropZone = [self clipboardDropZone]; // in self.view coordinates
    dropZone.origin.x *= scale;
    
    return CGRectContainsPoint(dropZone, p);
}

- (void)checkIfShouldMarkClipboardAreaBasedOnPoint:(CGPoint)p {
    if ([self clipboardDropZoneContainsPoint:p]) {
        [self markClipboardArea];
    } else {
        [self unmarkClipboardArea];
    }
}

- (void)markClipboardArea {
    if (!_clipboardMask.superlayer) {
        _clipboardMask = [CAShapeLayer layer];
        _clipboardMask.backgroundColor = [UIColor bronteClipboardHandleColor].CGColor;
        _clipboardMask.frame = [self clipboardFrame];
        [self.view.layer addSublayer:_clipboardMask];
        _clipboardMask.zPosition = _docLayer.zPosition + 1;
    }
}

- (void)unmarkClipboardArea {
    [_clipboardMask removeFromSuperlayer];
    _clipboardMask = nil;
}

- (NSMutableDictionary *)newTouchSelection:(NSArray *)selection withHitInfo:(NSDictionary *)hitInfo {
    return [@{@"selection": selection, @"hitInfo": hitInfo} mutableCopy];
}

- (NSMutableDictionary *)newTouchSelection:(NSArray *)selection {
    return [@{@"selection": selection} mutableCopy];
}

- (void)handleSelectionDrag:(UIPanGestureRecognizer *)gesture {
    static CALayer * affectedLine = nil;
    
    CGPoint p = [gesture locationInView:_scrollView];
    
    if (gesture.state == UIGestureRecognizerStateBegan && !_touchInfo[@"alreadyDraggingSelection"]) {
        NSDictionary * hitInfo = [self hitForPoint:p restricted:NO];
        NSArray * selection = [self allowedSelectionForHitInfo:hitInfo];
        
        if (selection) {
            _touchInfo = [self newTouchSelection:selection withHitInfo:hitInfo];
        } else {
            [self dismissSelections];
        }
    } else {
        NSArray * selection = _touchInfo[@"selection"];
        
        if (selection) {
            if (gesture.state == UIGestureRecognizerStateEnded) {
                [self cancelScrollingBasedOnDrag];
                
                [self dropCurrentTouchSelectionAtPoint:p];
                
                [affectedLine deactivateLine];
                affectedLine = nil;
            } else {
                CGPoint t = [gesture translationInView:_scrollView];
                
                [self translateSelection:selection withTranslation:t];
                
                if ([selection isDealingWithWords]) {
                    float startX = [self lineOriginForLineNumber:_lines.count].x;
                    
                    if (p.x < startX) {
                        p.x = startX + 1;
                    }
                    
                    NSArray * excluded = [selection wordsForSelection];
                    CALayer * line = [[self hitForPoint:p] objectForKey:@"line"];
                    
                    if (line) {
                        [line activateLine];
                        [self arrangeWordsInLine:line basedOnPoint:[line convertPoint:p fromLayer:line.superlayer] excludingWords:excluded];
                    }
                    
                    if (affectedLine && affectedLine != line) {
                        [affectedLine deactivateLine];
                        [self arrangeWordsInLine:affectedLine ignoringWords:excluded];
                    }
                    
                    affectedLine = line;
                }
                
                [self checkIfShouldScrollBasedOnPoint:p];
                [self checkIfShouldMarkClipboardAreaBasedOnPoint:p];
                
                [gesture setTranslation:CGPointZero inView:_scrollView];
            }
        }
    }
}

- (void)handleClipboardDrag:(UIPanGestureRecognizer *)gesture {
    static CALayer * hit = nil;
    static CGPoint origPosition = {0, 0};
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        hit = [_clipboardLayer hitTest:[gesture locationInView:self.view]];
        
        if (hit == _clipboardLayer) {
            hit = nil;
        }
        
        if (hit) {
            origPosition = hit.position;
        }
    }
    
    if (hit) {
        CGPoint t = [gesture translationInView:self.view];
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:0];
        hit.position = CGPointMake(origPosition.x + t.x, origPosition.y + t.y);
        [CATransaction commit];
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateFailed || gesture.state == UIGestureRecognizerStateCancelled) {
        hit = nil;
    }
}

- (void)doInertialScroll:(UIPanGestureRecognizer *)gesture {
    float velocity = -[gesture velocityInView:_scrollView].y;
    
    float minOffset = [self minScrollOffset];
    float maxOffset = [self maxScrollOffset];
    
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

- (CALayer *)focusLineForZoom {
    CGPoint focusPoint = CGPointMake(_scrollView.frame.origin.x + _scrollView.frame.size.width / 2.0, 20);
    focusPoint = [self.view convertPoint:focusPoint toView:_scrollView];
    focusPoint.x /= 2*[self currentScale];
    CALayer * line = [[self hitForPoint:focusPoint] objectForKey:@"line"];
    return line;
}

- (NSArray *)allowedSelectionForHitInfo:(NSDictionary *)hitInfo {
    NSArray * selection = [self selectionForHit:hitInfo];
    NSArray * currentSelection = [self currentSelection];
    
    if(selection.count && (!currentSelection.count || [currentSelection isEqualToArray:selection])) {
        return selection;
    }
    
    return nil;
}

- (NSArray *)duplicateSelection:(NSArray *)selection {
    NSMutableArray * dup = [NSMutableArray new];
    
    for (CALayer * l in selection) {
        CALayer * d = [l duplicate];
        [l.superlayer addSublayer:d];
        [dup addObject:d];
    }
    
    return dup;
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    static CALayer * focusLine = nil;
    
    static CGFloat origOffset = 0;
    
    static BOOL isDraggingClipboardArea = NO;
    static BOOL isDraggingInfoArea = NO;
    static BOOL isScrollingOnSides = NO;
    static BOOL stillDeciding = YES;
    static BOOL didHitClipboardArea = NO;
    
    if (!_shouldAllowPan) {
        return;
    }
    
    _didPan = YES;
    
    BOOL canScroll = _scrollView.contentSize.height > _scrollView.bounds.size.height;
    
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
            
            didHitClipboardArea = [_clipboardLayer hitTest:p] != nil;
        }
    }
    
    failed = failed || gesture.state == UIGestureRecognizerStateFailed || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStatePossible;
    
    if (!failed) {
        float maxOffset = [self maxScrollOffset];
        float minOffset = [self minScrollOffset];
        
        if (isDraggingClipboardArea || isDraggingInfoArea) {
            CGPoint t = [gesture translationInView:_scrollView];
            CGPoint v = [gesture velocityInView:_scrollView];
            
            if (stillDeciding) {
                isScrollingOnSides = fabs(t.y) > fabs(t.x) || fabs(v.y) > fabs(v.x);
                
                if (!isScrollingOnSides) {
                    focusLine = [self focusLineForZoom];
                }
                
                stillDeciding = NO;
            }
            
            if (isScrollingOnSides && canScroll) {
                float newOffset = origOffset - t.y;
                
                if (newOffset < minOffset) {
                    newOffset -= (origOffset - t.y - minOffset)*(1-0.33);
                } else if (newOffset > maxOffset) {
                    newOffset -= (origOffset - t.y - maxOffset)*(1-0.33);
                }
                
                [_scrollView setContentOffset:CGPointMake(0, newOffset)];
            } else if (isDraggingClipboardArea) {
                CGFloat scale = [self currentScale] + t.x / [self width];
                
                CGPoint p = [gesture locationInView:self.view];
                
                if (p.x <= [self minDocScale]*[self width] || _scrollView.frame.origin.x < 0) {
                    [CATransaction begin];
                    [CATransaction setAnimationDuration:0];
                    
                    float origin = [NSNumber bound:(_scrollView.frame.origin.x + t.x) low:(-_scrollView.frame.size.width) high:0];
                    
                    CGPoint offset = _scrollView.contentOffset;
                    _scrollView.frame = CGRectMake(origin, _scrollView.frame.origin.y,
                                                   _scrollView.frame.size.width, _scrollView.frame.size.height);
                    _scrollView.contentOffset = offset;
                    _clipboardLayer.position = CGPointMake(_scrollView.frame.origin.x + _scrollView.frame.size.width, 0);
                    
                    [CATransaction commit];
                } else {
                    [self zoomDocument:scale focusLine:focusLine];
                }
                
                [gesture setTranslation:CGPointZero inView:_scrollView];
            }
        } else if (didHitClipboardArea) {
            [self handleClipboardDrag:gesture];
        } else {
            [self handleSelectionDrag:gesture];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded || failed) {
        if (!failed && isScrollingOnSides && canScroll) {
            [self doInertialScroll:gesture];
        }
        
        focusLine = nil;
        isDraggingClipboardArea = NO;
        isDraggingInfoArea = NO;
        isScrollingOnSides = NO;
        stillDeciding = YES;
        didHitClipboardArea = NO;
        _didPan = NO;
    }
}

- (void)dropCurrentTouchSelectionAtPoint:(CGPoint)p {
    _touchInfo[@"dropPoint"] = [NSValue valueWithCGPoint:p];
    [self didDropSelection:_touchInfo];
    _touchInfo = nil;
    
    [self unmarkClipboardArea];
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (_editView.superview) {
        return;
    }
    
    _shouldAllowPan = gesture.state != UIGestureRecognizerStateBegan;
    
    static CGPoint firstPoint = {0, 0};
    
    CGPoint p = [gesture locationInView:_scrollView];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        firstPoint = p;
        
        NSDictionary * hitInfo = [self hitForPoint:p restricted:NO];
        NSArray * selection = [self allowedSelectionForHitInfo:hitInfo];
        
        [self dismissSelections];
        
        if (selection) {
            selection = [self duplicateSelection:selection];
            [selection markSelectionAsDuplicate];
            
            float dY = 0;
            float dX = 0;
            for (CALayer * l in selection) {
                l.position = CGPointMake(l.position.x + dX, l.position.y + dY);
            }
            
            _touchInfo = [self newTouchSelection:selection withHitInfo:hitInfo];
            _touchInfo[@"alreadyDraggingSelection"] = @YES;
        } else {
            gesture.state = UIGestureRecognizerStateFailed;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (!_didPan && _touchInfo[@"selection"]) {
            [self dropCurrentTouchSelectionAtPoint:p];
        }
    }
}

#pragma mark - Gesture delegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !_shouldAllowPan) {
        return NO;
    }
    return YES;
}

@end
