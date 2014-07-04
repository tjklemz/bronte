//
//  NSNumber+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 7/1/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import "NSNumber+Bronte.h"
#import "UIFont+Bronte.h"

@implementation NSNumber (Bronte)

+ (float)lineHandleWidth {
    return 80;
}

+ (float)linePadding {
    return 80;
}

+ (float)lineWidth {
    return [UIFont bronteLineWidth] + [self lineHandleWidth] + [self linePadding];
}

+ (float)availableLineWidth {
    return [self lineWidth] - [self linePadding];
}

+ (float)lineHeight {
    return [UIFont bronteLineHeight];
}

+ (float)bound:(float)n low:(float)low high:(float)high {
    return fmaxf(low, fminf(high, n));
}

@end
