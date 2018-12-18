//
//  PopGestureScrollView.m
//  Fanli
//
//  Created by Shaoqing.fan on 16/5/30.
//  Copyright © 2016年 www.fanli.com. All rights reserved.
//

#import "PopGestureScrollView.h"

static CGFloat const FLPopGestureMinLocation = 50.0f;

@implementation PopGestureScrollView

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	BOOL result = [super gestureRecognizerShouldBegin:gestureRecognizer];
	
	if (YES == result)
	{
		if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
		{
			CGPoint pt = [gestureRecognizer locationInView:self];
			if (pt.x <= FLPopGestureMinLocation)
			{
				return NO;
			}
		}
	}
	
	return result;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
		[otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]&&
		(self.contentOffset.x <= 0))
	{
		return YES;
	}
	
	return NO;
}

@end
