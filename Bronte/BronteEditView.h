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
- (void)didDeleteCharacterFromLine:(CALayer *)line;
- (void)editMenuNeedsAdjusting;

@end

@interface BronteEditView : UIView {
    UIButton * _insertLeftButton;
    UIButton * _insertRightButton;
    UIButton * _deleteCharacterButton;
}

@property (nonatomic) CGPoint selectionPoint;
@property (readwrite, nonatomic, weak) id<BronteEditDelegate> delegate;
@property (readwrite, nonatomic) NSMutableArray * selection;

- (id)initWithSelection:(NSArray *)selection;
- (CGPoint)findSelectionPoint;
- (void)adjustPosition;
- (BOOL)isInsertingLeft;

@end
