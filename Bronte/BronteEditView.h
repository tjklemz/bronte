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
- (void)linesNeedArranging:(NSSet *)lines;
- (void)deleteSelection:(NSArray *)selection;

@end

@interface BronteEditView : UIView {
    UIButton * _insertLeftButton;
    UIButton * _insertRightButton;
    UIButton * _deleteCharacterButton;
    BOOL _hidePointer;
}

@property (nonatomic) CGPoint selectionPoint;
@property (readwrite, nonatomic, weak) id<BronteEditDelegate> delegate;
@property (readwrite, nonatomic) NSMutableArray * selection;

- (void)hidePointer;
- (void)showPointer;
- (id)initWithSelection:(NSArray *)selection;
- (float)offset;
- (CGPoint)findSelectionPoint;
- (void)adjustPosition;
- (BOOL)isInsertingLeft;

@end
