//
//  UIImage+Bronte.h
//  Bronte
//
//  Created by Thomas Klemz on 6/16/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Bronte)

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha;
+ (UIImage *)lineIcon;
+ (UIImage *)lineIconActive;
+ (UIImage *)wordIcon;
+ (UIImage *)paragraphIcon;

@end
