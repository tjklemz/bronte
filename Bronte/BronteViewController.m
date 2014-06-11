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

- (void)configureWord:(CATextLayer *)word withAttributes:(NSDictionary *)attr {
    word.string = [[NSAttributedString alloc] initWithString:((NSAttributedString *)(word.string)).string attributes:attr];
}

- (void)configureMultiWordSelection:(NSDictionary *)selectionInfo withAttributes:(NSDictionary *)attr {
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
                [self configureWord:word withAttributes:attr];
            }
        }
    }
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
            
            int lineNo1 = [hitInfo1[@"lineNo"] intValue];
            int lineNo2 = [hitInfo2[@"lineNo"] intValue];
            
            wordIcon.position = CGPointMake([self lineWidth] + 30, 0.5*(lineNo2 - lineNo1 + 1.0)*[self lineHeight]);
            
            CALayer * line = hitInfo1[@"line"];
            [line addSublayer:wordIcon];
            
            _selectionInfo[@"icon"] = wordIcon;
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
    CALayer * line = hitInfo[@"line"];
    
    if ([line.name isEqualToString:@"P"]) {
        return [self paragraphForLineNumber:[hitInfo[@"lineNo"] intValue]];
    } else if ([line.name isEqualToString:@"L"]) {
        if (hitInfo[@"hitLineHandle"]) {
            return @[line];
        }
        CALayer * word = hitInfo[@"word"];
        if (word) {
            return @[word];
        }
    }
    return @[];
}

- (void)didDropSelection:(NSDictionary *)selectionInfo {
    NSArray * selection = selectionInfo[@"selection"];
    NSDictionary * hitInfo = selectionInfo[@"hitInfo"];
    CGPoint dropPoint = [selectionInfo[@"dropPoint"] CGPointValue];
    
    [self unmarkSelection:selection];
}

#pragma mark - Gestures

- (CGRect)clipboardHandle {
    float p = 0.13;
    float s = p*_scrollView.bounds.size.width;
    return CGRectMake(_scrollView.bounds.size.width - s, 0, s*2, _scrollView.bounds.size.height);
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
        [self unmarkMultiWordSelection];
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

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint p = [gesture locationInView:self.view];
        CGRect clipboardHandle = [self clipboardHandle];
        _isDraggingClipboard = CGRectContainsPoint(clipboardHandle, p);
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        _isDraggingClipboard = NO;
    }
    
    if (_isDraggingClipboard) {
        CGPoint t = [gesture translationInView:self.view];
        CGFloat currentScale = _scrollView.bounds.size.width / [self width];
        CGFloat scale = currentScale + t.x / [self width];
        [self zoomDocument:scale];
        [gesture setTranslation:CGPointZero inView:self.view];
    } else {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            _touchInfo = [NSMutableDictionary new];
            
            CGPoint p = [gesture locationInView:_scrollView];
            NSDictionary * hitInfo = [self hitForPoint:p];
            if (hitInfo) {
                NSArray * selection = [self selectionForHit:hitInfo];
                [self markSelection:selection];
                _touchInfo[@"selection"] = selection;
                _touchInfo[@"hitInfo"] = hitInfo;
            }
        } else {
            NSArray * selection = _touchInfo[@"selection"];
            if (selection) {
                if (gesture.state == UIGestureRecognizerStateEnded) {
                    _touchInfo[@"dropPoint"] = [NSValue valueWithCGPoint:[gesture locationInView:self.view]];
                    [self didDropSelection:_touchInfo];
                    _touchInfo = nil;
                } else {
                    CGPoint t = [gesture translationInView:_scrollView];
                    
                    [CATransaction begin];
                    [CATransaction setAnimationDuration:0];
                    
                    for (CALayer * l in selection) {
                        l.position = CGPointMake(l.position.x + t.x, l.position.y + t.y);
                    }
                    
                    [CATransaction commit];
                    
                    [gesture setTranslation:CGPointZero inView:_scrollView];
                }
            }
        }
    }
}


@end
