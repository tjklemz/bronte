//
//  DocumentScrollView.h
//  Bronte
//
//  Created by Thomas Klemz on 6/10/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentScrollView : UIScrollView

@property (nonatomic, weak) id touchDelegate;
@property (nonatomic) CGPoint previousContentOffset;

@end
