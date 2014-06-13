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
        _lineIconActive = [UIImage imageNamed:@"sugar.png"];
        _paraIcon = [UIImage imageNamed:@"mix.png"];
        
        //self.view.backgroundColor = [UIColor bronteBackgroundColor];
        
        DocumentScrollView * scrollView = [[DocumentScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
        scrollView.touchDelegate = self;
        scrollView.backgroundColor = [UIColor bronteBackgroundColor];
        _docLayer = scrollView.layer;
        _docLayer.masksToBounds = NO;
        [scrollView.panGestureRecognizer setMinimumNumberOfTouches:2];
        [scrollView.panGestureRecognizer setMaximumNumberOfTouches:2];
        [scrollView setScrollIndicatorInsets:[self scrollViewInsets]];
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        scrollView.bouncesZoom = NO;
        
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
        [self addText:@"Mary had a little lamb, its fleece was white as snow; and everywhere that Mary went, the lamb was sure to go. It followed her to school one day, which was against the rule. It made the children laugh and play, to see a lamb at school. And so the teacher turned it out, but still it lingered near and waited patiently about till Mary did appear. \"Why does the lamb love Mary so?\" the eager children cry; \"Why, Mary loves the lamb, you know\" the teacher did reply." toLine:_lines.firstObject];
        
        [self newParagraphSeparator];
        
        for (int i = 0; i < 3; ++i) {
            [self addText:@"Mary had a little lamb, its fleece was white as snow; and everywhere that Mary went, the lamb was sure to go. It followed her to school one day, which was against the rule. It made the children laugh and play, to see a lamb at school. And so the teacher turned it out, but still it lingered near and waited patiently about till Mary did appear. \"Why does the lamb love Mary so?\" the eager children cry; \"Why, Mary loves the lamb, you know\" the teacher did reply." toLine:_lines.lastObject];
        }
        
        // end of testing code
        
        [self adjustScrollViewContentSize];
    }
    return self;
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
    return CGPointMake(([self width] - [UIFont bronteLineWidth])/2.0 - [self lineHandleWidth] + 15, 50 + n*[self lineHeight]);
}

- (void)adjustScrollViewContentSize {
    float currentScale = _scrollView.bounds.size.width/[self width];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, currentScale*[self lineOriginForLineNumber:_lines.count+3].y);
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
    l.position = [self lineOriginForLineNumber:_lines.count];
    [_docLayer addSublayer:l];
    [_lines addObject:l];
    return l;
}

- (CALayer *)insertLineAfter:(CALayer *)l {
    NSUInteger n = [_lines indexOfObject:l];
    CALayer * newLine = [self makeLine];
    [_docLayer addSublayer:newLine];
    [_lines insertObject:newLine atIndex:n+1];
    
    for (NSUInteger i = n+1; i < _lines.count; ++i) {
        CALayer * line = _lines[i];
        line.position = [self lineOriginForLineNumber:i];
    }
    
    return newLine;
}

- (NSArray *)wordsForLine:(CALayer *)line {
    NSArray * words = [line.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass:%@", [CATextLayer class]]];
    return [words sortedArrayUsingComparator:^NSComparisonResult(CALayer * obj1, CALayer * obj2) {
        return obj1.position.x - obj2.position.x;
    }];
}

- (CALayer *)addWord:(NSString *)word toLine:(CALayer *)line {
    CALayer * w = [self makeWord:word];
    w.position = [self originForFirstWord];
    
    CALayer * l = line;
    
    if ([l.name isEqualToString:@"P"]) {
        l = [self newLine];
        [self newParagraphSeparator];
    }
    
    float spacing = 0;//[UIFont bronteWordSpacing];
    CALayer * lastWord = [self wordsForLine:line].lastObject;
    
    float newX = lastWord ? [lastWord maxX] + spacing : w.position.x;
    
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
        l = [self addWord:word toLine:l];
    }
    return l;
}

#pragma mark - Moving stuff

- (NSDictionary *)hitForPoint:(CGPoint)p {
    __unsafe_unretained Class cls = [CATextLayer class];
    
    for (int i = 0; i < _lines.count; ++i) {
        CALayer * line = _lines[i];
        CALayer * hit = [line hitTest:p];
        
        if (hit) {
            NSMutableDictionary * hitInfo = [NSMutableDictionary new];
            hitInfo[@"line"] = line;
            hitInfo[@"lineNo"] = [NSNumber numberWithInt:i];
            hitInfo[@"origPoint"] = [NSValue valueWithCGPoint:p];
            if ([hit isKindOfClass:cls]) {
                hitInfo[@"word"] = hit;
            } else {
                CGFloat currentScale = _scrollView.bounds.size.width / [self width];
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
    return line && [line.name isEqualToString:@"P"];
}

- (BOOL)didHitLineHandle:(NSDictionary *)hitInfo {
    CALayer * line = hitInfo[@"line"];
    return line && [line.name isEqualToString:@"L"] && hitInfo[@"hitLineHandle"];
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
    [lines addObject:_lines[lineNo]];
    
    for (int i = lineNo-1; i >= 0; --i) {
        CALayer * line = _lines[i];
        if ([line.name isEqualToString:@"P"]) {
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
        NSArray * words = [self wordsForLine:_lines[i]];
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
    __unsafe_unretained Class cls = [CATextLayer class];
    
    BOOL activateLineIcon = attr[@"BronteActivateLineIcon"];
    BOOL deactivateLineIcon = attr[@"BronteDeactivateLineIcon"];
    
    for (CALayer * l in selection) {
        if ([l.name isEqualToString:@"L"]) {
            NSArray * words = [self wordsForLine:l];
            for (CATextLayer * word in words) {
                [self configureWord:word withAttributes:attr];
            }
            
            if (activateLineIcon) {
                l.contents = (id)_lineIconActive.CGImage;
            } else if (deactivateLineIcon) {
                l.contents = (id)_lineIcon.CGImage;
            }
        } else if ([l isKindOfClass:cls]) {
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

- (NSArray *)selectionForHit:(NSDictionary *)hitInfo {
    if (!hitInfo) return nil;
    
    NSArray * selection = @[];
    
    CALayer * line = hitInfo[@"line"];
    
    if ([line.name isEqualToString:@"P"]) {
        selection = [self paragraphForLineNumber:[hitInfo[@"lineNo"] intValue]];
    } else if ([line.name isEqualToString:@"L"]) {
        if (hitInfo[@"hitLineHandle"]) {
            selection = @[line];
        } else {
            CALayer * word = hitInfo[@"word"];
            if (word) {
                if (_selectionInfo) {
                    // see if just grabbed the multi selection
                    NSArray * multiSelection = _selectionInfo[@"selection"];
                    if ([multiSelection containsObject:word]) {
                        selection = multiSelection;
                    }
                } else if (_touchInfo && _touchInfo[@"selection"]) {
                    // see if just grabbed the current selection
                    NSArray * currentSelection = _touchInfo[@"selection"];
                    for (CALayer * s in currentSelection) {
                        if ([s.sublayers containsObject:word]) {
                            selection = currentSelection;
                            break;
                        }
                    }
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

- (void)didDropSelection:(NSDictionary *)selectionInfo {
    NSArray * selection = selectionInfo[@"selection"];
    NSDictionary * hitInfo = selectionInfo[@"hitInfo"];
    CGPoint dropPoint = [selectionInfo[@"dropPoint"] CGPointValue];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        if (selection) {
            [self unmarkSelection:selection];
        }
        
        if (_selectionInfo) {
            [self unmarkMultiWordSelection];
        }
    }];
    
    for (CALayer * l in selection) {
        l.position = l.originalPosition;
    }
    
    [CATransaction commit];
}

#pragma mark - Gestures

- (CGRect)clipboardHandle {
    float p = 0.08;
    float s = p*_scrollView.bounds.size.width;
    return CGRectMake(_scrollView.bounds.size.width - s, 0, s*2, _scrollView.bounds.size.height);
}

- (void)dismissSelections {
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
                // bring up edit menu
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
            // bring up edit menu (there can only be one multi select handle
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
    
    if (_selectionInfo || currentSelection) {
        [self dismissSelections];
    } else {
        [self markSelection:selection];
        _touchInfo = [NSMutableDictionary new];
        _touchInfo[@"selection"] = selection;
        _touchInfo[@"hitInfo"] = hitInfo;
        
        //TODO: bring up edit menu
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
                } else {
                    [self handleDoubleTapOnHandle:hitInfo];
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
    
    [self unmarkMultiWordSelection];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        selectionInfo = [NSMutableDictionary new];
        selectionInfo[@"firstPoint"] = [NSValue valueWithCGPoint:[gesture locationInView:_scrollView]];
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

- (void)zoomDocument:(float)currentScale {
    static const CGFloat minScale = 0.475;
    static const CGFloat maxScale = 1.0f;
    
    float fullW = fmaxf(self.view.frame.size.width, self.view.frame.size.height);
    
    //check max
    currentScale = currentScale > maxScale ? maxScale : currentScale;
    //check min
    currentScale = currentScale < minScale ? minScale : currentScale;
    
    _scrollView.frame = CGRectMake(0, 0, currentScale*fullW, _scrollView.frame.size.height);
    UIEdgeInsets insets = [self scrollViewInsets];
    _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(currentScale*insets.top, currentScale*insets.left, currentScale*insets.bottom, currentScale*insets.right);
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    for (int i = 0; i < _lines.count; ++i) {
        CALayer * line = _lines[i];
        line.transform = CATransform3DMakeScale(currentScale, currentScale, 1.0);
        CGPoint o = [self lineOriginForLineNumber:i];
        line.position = CGPointMake(o.x*currentScale, o.y*currentScale);
    }
    [CATransaction commit];
    
    [self adjustScrollViewContentSize];
}

- (void)translateSelection:(NSArray *)selection withTranslation:(CGPoint)t {
    __unsafe_unretained Class cls = [CATextLayer class];
    
    float currentScale = [selection.firstObject isKindOfClass:cls] ? _scrollView.bounds.size.width/[self width] : 1.0f;
    
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

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gesture locationInView:self.view];
        CGRect clipboardHandle = [self clipboardHandle];
        _isDraggingClipboard = CGRectContainsPoint(clipboardHandle, p);
    }
    
    if (_isDraggingClipboard) {
        CGPoint t = [gesture translationInView:self.view];
        CGFloat currentScale = _scrollView.bounds.size.width / [self width];
        CGFloat scale = currentScale + t.x / [self width];
        [self zoomDocument:scale];
        [gesture setTranslation:CGPointZero inView:self.view];
    } else {
        CGPoint p = [gesture locationInView:_scrollView];
        
        if (gesture.state == UIGestureRecognizerStateBegan) {
            NSDictionary * hitInfo = [self hitForPoint:p];
            NSArray * selection = [self selectionForHit:hitInfo];
            
            if (![selection count]) {
                [self dismissSelections];
            } else {
                NSArray * currentSelection = _selectionInfo ? _selectionInfo[@"selection"] : (_touchInfo ? _touchInfo[@"selection"] : nil);
                if (![currentSelection count]) {
                    [self markSelection:selection];
                    _touchInfo = [NSMutableDictionary new];
                    _touchInfo[@"selection"] = selection;
                    _touchInfo[@"hitInfo"] = hitInfo;
                } else {
                    if ([currentSelection isEqualToArray:selection]) {
                        _touchInfo = [NSMutableDictionary new];
                        _touchInfo[@"selection"] = selection;
                        _touchInfo[@"hitInfo"] = hitInfo;
                    } else {
                        [self dismissSelections];
                    }
                }
            }
        } else {
            NSArray * selection = _touchInfo[@"selection"];
            
            static BOOL isScrolling = NO;
            
            if (selection) {
                if (gesture.state == UIGestureRecognizerStateEnded) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self];
                    isScrolling = NO;
                    _touchInfo[@"dropPoint"] = [NSValue valueWithCGPoint:[gesture locationInView:self.view]];
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
        _isDraggingClipboard = NO;
    }
}


@end
