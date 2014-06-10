//
//  CALayer+Bronte.m
//  Bronte
//
//  Created by Thomas Klemz on 5/3/14.
//  Copyright (c) 2014 Lory and Ludlow. All rights reserved.
//

#import "CALayer+Bronte.h"

@implementation CALayer (Bronte)

- (float)maxX {
    return self.position.x + self.bounds.size.width - self.anchorPoint.x*self.bounds.size.width;
}

- (float)minX {
    return self.position.x - self.anchorPoint.x*self.bounds.size.width;
}

@end
