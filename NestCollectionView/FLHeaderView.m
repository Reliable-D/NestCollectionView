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
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGesture];
        
//        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
//        swipeGesture.direction = UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown;
//        [self addGestureRecognizer:swipeGesture];
        
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

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    CGPoint transP = [panGesture translationInView:self];
    
    if (self.scrollDelegate)
    {
        [self.scrollDelegate headerViewDidScroll:transP.y];
    }
    
    [panGesture setTranslation:CGPointZero inView:self];
}

//- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)swipeGesture
//{
//}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (CGRectGetMinY(self.frame) < 0)//header上滑
    {
        if (CGRectGetMaxY(self.frame) - CGRectGetHeight(self.relateBottomView.frame) <= 0)//header将要滑出屏幕,bottom悬浮
        {
            CGRect bottomFrame = self.relateBottomView.frame;
            bottomFrame.origin.y = 0;
            self.relateBottomView.frame = bottomFrame;
        }
        else
        {
            CGFloat bottomY = CGRectGetMaxY(self.frame)-CGRectGetHeight(self.relateBottomView.frame);
            
            CGRect bottomFrame = self.relateBottomView.frame;
            bottomFrame.origin.y = bottomY;
            self.relateBottomView.frame = bottomFrame;
        }
        
    }
    else//header下滑
    {
        CGFloat bottomY = CGRectGetMaxY(self.frame)-CGRectGetHeight(self.relateBottomView.frame);
        
        CGRect bottomFrame = self.relateBottomView.frame;
        bottomFrame.origin.y = bottomY;
        self.relateBottomView.frame = bottomFrame;
    }
}

@end
