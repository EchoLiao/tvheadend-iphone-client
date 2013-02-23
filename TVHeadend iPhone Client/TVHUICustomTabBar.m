//
//  TVHUICustomTabBar.m
//  TVHeadend iPhone Client
//
//  Created by zipleen on 2/23/13.
//  Copyright (c) 2013 zipleen. All rights reserved.
//

#import "TVHUICustomTabBar.h"

@implementation TVHUICustomTabBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self customize];
    }
    return self;
}

- (void)customize {
    UIImage *tabbarBg = [UIImage imageNamed:@"tabbar.png"];
    UIImage *tabBarSelected = [UIImage imageNamed:@"tabbar_selected.png"];
    [self setBackgroundImage:tabbarBg ]; 
    [self setSelectionIndicatorImage:tabBarSelected];
}

@end
