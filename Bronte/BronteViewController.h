//
//  BronteViewController.h
//  Bronte
//
//  Created by Thomas Klemz on 6/9/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BronteEditView.h"
#import "DocumentScrollView.h"
#import "BronteTextInput.h"

@interface BronteViewController : UIViewController <BronteEditDelegate, BronteTextInputDelegate, UIGestureRecognizerDelegate> {
    NSDictionary * _defaultAttr;
    
    NSMutableArray * _lines;
    
    CALayer * _docLayer;
    DocumentScrollView * _scrollView;
    
    BOOL _isDraggingClipboard;
    
    NSMutableDictionary * _selectionInfo;
    
    BOOL _touchDidMove;
    NSMutableDictionary * _touchInfo;
    
    BronteEditView * _editView;
    BronteTextInput * _inputView;
    
    BOOL _isRotating;
    
    BOOL _shouldAllowPan;
}

@end
