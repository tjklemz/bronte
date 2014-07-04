//
//  NSNumber+Bronte.h
//  Bronte
//
//  Created by Thomas Klemz on 7/1/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Bronte)

+ (float)lineHandleWidth;
+ (float)linePadding;
+ (float)lineWidth;
+ (float)availableLineWidth;
+ (float)lineHeight;
+ (float)bound:(float)n low:(float)low high:(float)high;

@end
