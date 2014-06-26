//  Created by Thomas Klemz on 4/4/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BronteTextInputDelegate <NSObject>

- (void)didEnterText:(NSArray *)lines;

@end

@interface BronteTextInput : UIView <UIKeyInput> {
    NSDictionary * _defaultAttr;
    NSMutableArray * _lines;
}

@property (readwrite, nonatomic) id delegate;
@property (readwrite, nonatomic) BOOL insertBefore;

@end
