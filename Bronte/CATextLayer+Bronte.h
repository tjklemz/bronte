//
//  CATextLayer+Bronte.h
//  Bronte
//
//  Created by Thomas Klemz on 6/24/14.
//  Copyright (c) 2014 Lory & Ludlow. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CATextLayer (Bronte)

+ (float)extraSpacing;
+ (CATextLayer *)makeWord:(NSString *)word;
- (NSString *)word;
- (void)setWord:(NSString *)newWord;

@end
