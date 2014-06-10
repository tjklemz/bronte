//
//  BronteViewController.h
//  Bronte
//
//  Created by Thomas Klemz on 6/9/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BronteViewController : UIViewController {
    NSDictionary * _defaultAttr;
    
    NSMutableArray * _lines;
    
    UIImage * _wordIcon;
    UIImage * _lineIcon;
    UIImage * _paraIcon;
    
    CALayer * _docLayer;
    UIScrollView * _scrollView;
}

@end
