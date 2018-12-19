//
//  FLHeaderView.h
//  NestCollectionView
//
//  Created by 邓乐 on 2018/12/18.
//  Copyright © 2018 fanli. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FLHeaderViewDelegate <NSObject>

- (void)headerViewDidScroll:(CGFloat)offSet;

@end

@interface FLHeaderView : UIView

@property (nonatomic, weak) id<FLHeaderViewDelegate> scrollDelegate;

@property (nonatomic, weak) UIView *relateBottomView;

@end

NS_ASSUME_NONNULL_END
