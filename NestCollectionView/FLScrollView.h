//
//  FLScrollView.h
//  NestCollectionView
//
//  Created by 邓乐 on 2018/12/18.
//  Copyright © 2018 fanli. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "FLScrollViewInterface.h"

NS_ASSUME_NONNULL_BEGIN
@class FLScrollView;
@protocol FLScrollViewDelegate <NSObject>

- (UIView *)bindHeaderViewToScrollView:(FLScrollView *)scrollView;

@end

@interface FLScrollView : UIScrollView

@property (nonatomic, weak) id<FLScrollViewDelegate> scrollDelegate;

- (void)syncHeaderOffSet:(CGFloat)offSet;

@end

NS_ASSUME_NONNULL_END
