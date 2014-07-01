//
//  UIImage+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 6/16/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import "UIImage+Bronte.h"

@implementation UIImage (Bronte)

- (UIImage *)imageByApplyingAlpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 1.0f);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextSetAlpha(ctx, alpha);
    
    CGContextDrawImage(ctx, area, self.CGImage);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)lineIcon {
    static UIImage * icon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        icon = [[UIImage imageNamed:@"sugar_gray.png"] imageByApplyingAlpha:0.5];
    });
    return icon;
}

+ (UIImage *)lineIconActive {
    static UIImage * icon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        icon = [UIImage imageNamed:@"sugar.png"];
    });
    return icon;
}

+ (UIImage *)wordIcon {
    static UIImage * icon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        icon = [UIImage imageNamed:@"milk.png"];
    });
    return icon;
}

+ (UIImage *)paragraphIcon {
    static UIImage * icon = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        icon = [UIImage imageNamed:@"mix.png"];
    });
    return icon;
}

@end
