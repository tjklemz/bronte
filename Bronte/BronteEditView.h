//
//  BronteEditView.h
//  Bronte
//
//  Created by Thomas Klemz on 4/23/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BronteEditDelegate <NSObject>

- (void)insertBeforeSelection:(NSArray *)selection;
- (void)insertAfterSelection:(NSArray *)selection;

@end

@interface BronteEditView : UIView {
    CGPoint _selectionPoint;
    float _selectionWidth;
    UIButton * _insertLeftButton;
    UIButton * _insertRightButton;
    NSArray * _selection;
}

@property (readwrite, nonatomic) id<BronteEditDelegate> delegate;

- (id)initWithSelection:(NSArray *)selection;

@end
