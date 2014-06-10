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

@interface BronteViewController ()

@end

@implementation BronteViewController

- (UIEdgeInsets)scrollViewInsets {
    CGPoint o = [self lineOriginForLineNumber:0];
    float p = o.y + 10;
    return UIEdgeInsetsMake(p, 0, p, [self width] - (o.x + [self lineWidth] + 50));
}

- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _defaultAttr = [UIFont bronteDefaultFontAttributes];
        
        _lines = [NSMutableArray new];
        
        _wordIcon = [UIImage imageNamed:@"milk_gray.png"];
        _lineIcon = [UIImage imageNamed:@"sugar_gray.png"];
        _paraIcon = [UIImage imageNamed:@"mix_gray.png"];
        
        //self.view.backgroundColor = [UIColor bronteBackgroundColor];
        
        DocumentScrollView * scrollView = [[DocumentScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, self.view.bounds.size.width)];
        scrollView.touchDelegate = self;
        scrollView.backgroundColor = [UIColor bronteBackgroundColor];
        _docLayer = scrollView.layer;
        [scrollView.panGestureRecognizer setMinimumNumberOfTouches:2];
        [scrollView.panGestureRecognizer setMaximumNumberOfTouches:2];
        [scrollView setScrollIndicatorInsets:[self scrollViewInsets]];
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        scrollView.bouncesZoom = NO;

        [self.view addSubview:scrollView];
        _scrollView = scrollView;
        
        scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, scrollView.bounds.size.height);
        [self adjustScrollViewContentSize];
        
        UIScreenEdgePanGestureRecognizer * edgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        edgeGesture.edges = UIRectEdgeRight;
        edgeGesture.maximumNumberOfTouches = 1;
        edgeGesture.minimumNumberOfTouches = 1;
        [self.view addGestureRecognizer:edgeGesture];
        
        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        panGesture.maximumNumberOfTouches = 1;
        panGesture.minimumNumberOfTouches = 1;
        [self.view addGestureRecognizer:panGesture];
        
        [self newLine];
        
        //testing only
        [self addText:@"Mary had a little lamb, its fleece was white as snow; and everywhere that Mary went, the lamb was sure to go. It followed her to school one day, which was against the rule. It made the children laugh and play, to see a lamb at school. And so the teacher turned it out, but still it lingered near and waited patiently about till Mary did appear. \"Why does the lamb love Mary so?\" the eager children cry; \"Why, Mary loves the lamb, you know\" the teacher did reply." toLine:_lines.firstObject];
        
        [self newLine];
        [self newLine];
        
        [self addText:@"Mary had a little lamb, its fleece was white as snow; and everywhere that Mary went, the lamb was sure to go. It followed her to school one day, which was against the rule. It made the children laugh and play, to see a lamb at school. And so the teacher turned it out, but still it lingered near and waited patiently about till Mary did appear. \"Why does the lamb love Mary so?\" the eager children cry; \"Why, Mary loves the lamb, you know\" the teacher did reply." toLine:_lines.lastObject];
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
    textLayer.frame = CGRectMake(0, 0, s.width + 2, [self lineHeight]);
    
    return textLayer;
}

- (CALayer *)makeLine {
    CALayer * l = [CALayer layer];
    l.contentsScale = [[UIScreen mainScreen] scale];
    l.anchorPoint = CGPointZero;
    l.frame = CGRectMake(0, 0, [self lineWidth], [self lineHeight]);
    
    l.contents = (id)_lineIcon.CGImage;
    l.contentsGravity = kCAGravityLeft;
    
    return l;
}

- (void)newLine {
    CALayer * l = [self makeLine];
    l.position = [self lineOriginForLineNumber:_lines.count];
    //l.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    [_docLayer addSublayer:l];
    [_lines addObject:l];
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
    return [line.sublayers sortedArrayUsingComparator:^NSComparisonResult(CALayer * obj1, CALayer * obj2) {
        return obj1.position.x - obj2.position.x;
    }];
}

- (CALayer *)addWord:(NSString *)word toLine:(CALayer *)line {
    CALayer * w = [self makeWord:word];
    w.position = [self originForFirstWord];
    
    CALayer * l = line;
    
    float spacing = [UIFont bronteWordSpacing];
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

#pragma mark - Gestures

- (CGRect)clipboardHandle {
    float p = 0.13;
    float s = p*_scrollView.bounds.size.width;
    return CGRectMake(_scrollView.bounds.size.width - s, 0, s*2, _scrollView.bounds.size.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

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
    }
}


@end
