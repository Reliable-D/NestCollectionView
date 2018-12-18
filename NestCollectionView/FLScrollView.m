//
//  FLScrollView.m
//  NestCollectionView
//
//  Created by 邓乐 on 2018/12/18.
//  Copyright © 2018 fanli. All rights reserved.
//

#import "FLScrollView.h"

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))
#define FLOAT_EQUAL(_f1, _f2) (fabs((_f1) - (_f2)) < 0.000001)

@interface FLScrollView () <UIScrollViewDelegate>

@end

@implementation FLScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        CGFloat maxY = 0;
        UIColor *itemColor = randomColor;
        for (int i = 0; i<20; i++)
        {
            UIView *contentItem = [[UIView alloc] initWithFrame:CGRectMake(0, maxY+10, self.frame.size.width, 100)];
            contentItem.backgroundColor = itemColor;
            [self addSubview:contentItem];
            maxY = CGRectGetMaxY(contentItem.frame);
        }
        
        self.contentSize = CGSizeMake(0, maxY+10);
    }
    return self;
}

#pragma mark- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self headerView])
    {
        UIView *headerView = [self headerView];
        CGFloat offSet = scrollView.contentOffset.y + CGRectGetHeight(headerView.frame);
        if (offSet >= 0)//上滑
        {
            if (offSet <= CGRectGetHeight(headerView.frame))//header当前在展示
            {
                CGRect frame = headerView.frame;
                frame.origin.y = -offSet;
                headerView.frame = frame;
            }
            else//header当前不在展示
            {
                if (!FLOAT_EQUAL(-headerView.frame.origin.y, headerView.frame.size.height))//不一致，再去修改
                {
                    CGRect frame = headerView.frame;
                    frame.origin.y = - frame.size.height;
                    headerView.frame = frame;
                }
            }
        }
        else//下拉
        {
            CGRect frame = headerView.frame;
            frame.origin.y = - offSet;
            headerView.frame = frame;
        }
    }
}

- (UIView *)headerView
{
    if (self.scrollDelegate)
    {
        return [self.scrollDelegate bindHeaderViewToScrollView:self];
    }
    return nil;
}

- (void)syncHeaderOffSet:(CGFloat)offSet
{
    if (offSet < 0)
    {
        [self setContentOffset:CGPointMake(0, offSet)];
    }
    else
    {
        //header已经滑出屏幕,不用再去还原深度
        [self setContentOffset:CGPointZero];
    }
}

@end
