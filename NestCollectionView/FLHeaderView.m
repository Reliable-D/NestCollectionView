//
//  FLHeaderView.m
//  NestCollectionView
//
//  Created by 邓乐 on 2018/12/18.
//  Copyright © 2018 fanli. All rights reserved.
//

#import "FLHeaderView.h"

@implementation FLHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    
}

- (CGFloat)heightForHeader
{
    return CGRectGetHeight(self.frame);
}

- (CGRect)currentVisibleRect
{
    CGRect result = CGRectZero;
    if (self.superview)
    {
        CGRect rectInWindow = [self.superview convertRect:self.frame toView:nil];
        result = CGRectIntersection([UIScreen mainScreen].bounds, rectInWindow);
    }
    return result;
}

@end
