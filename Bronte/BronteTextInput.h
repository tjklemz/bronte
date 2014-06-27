//  Created by Thomas Klemz on 4/4/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BronteTextInputDelegate <NSObject>

- (void)didEnterText:(NSArray *)lines;

@end

@interface BronteTextInput : UIView <UITextInput> {
    NSDictionary * _defaultAttr;
    NSMutableArray * _lines;
}

@property (readwrite, nonatomic) id delegate;
@property (readwrite, nonatomic) BOOL insertBefore;

// UITextInput properties

@property(nonatomic, readonly) UITextPosition *beginningOfDocument;
@property(nonatomic, readonly) UITextPosition *endOfDocument;
@property(nonatomic, assign) id<UITextInputDelegate> inputDelegate;
@property(nonatomic, readonly) UITextRange *markedTextRange;
@property(nonatomic, copy) NSDictionary *markedTextStyle;
@property(readwrite, copy) UITextRange *selectedTextRange;
@property(nonatomic, readonly) id<UITextInputTokenizer> tokenizer;

@end
