//
//  BronteEditView.h
//  Bronte
//
//  Created by Thomas Klemz on 4/23/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BronteEditDelegate <NSObject>

- (void)insertBefore;
- (void)insertAfter;

@end

@interface BronteEditView : UIView {
    CGPoint _selectionPoint;
    float _selectionWidth;
    UIButton * _insertLeftButton;
    UIButton * _insertRightButton;
}

@property (readwrite, nonatomic) id<BronteEditDelegate> delegate;

- (id)initWithSelectionAt:(CGPoint)p width:(float)w;

@end
