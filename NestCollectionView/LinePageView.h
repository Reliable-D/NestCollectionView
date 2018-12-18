//
//  LinePageView.h
//  Fanli
//
//  Created by fanli on 5/21/14.
//  Copyright (c) 2014 www.fanli.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LinePageCell.h"
#import "PopGestureScrollView.h"

#define  kInvalidPageIndex  -1

@class LinePageView;
@protocol LinePageViewDataSource <NSObject>
@required
// 请求page页面的个数。
- (NSInteger)pageNumberInlinePageView:(LinePageView *)linePage;
// 请求指定index的 page cell.
- (LinePageCell *)linePageView:(LinePageView *)linePage cellForIndex:(NSInteger)pageIndex;
@end


@protocol LinePageViewDelegate <NSObject>

/**
 通知调用方页面已切换到指定的index

 @param linePage 当前的LinePageView
 @param newPageIndex 切换新的页面的index
 */
- (void)linePageView:(LinePageView *)linePage midChangedToIndex:(NSInteger)newPageIndex;
@optional

/**
 指定页面将被移出主视图

 @param linePage 当前的LinePageView
 @param cell 即将被移除出主视图的cell
 */
- (void)linePageView:(LinePageView *)linePage willRemoveCell:(LinePageCell *)cell;

/**
 指定页面即将被添加到主视图

 @param linePage 当前的LinePageView
 @param cell 即将被添加到主视图的cell
 */
- (void)linePageView:(LinePageView *)linePage willShowCell:(LinePageCell *)cell;

/**
 指定页面已经被添加到主视图

 @param linePage 当前的LinePageView
 @param cell 已经添加到主视图的cell
 */
- (void)linePageView:(LinePageView *)linePage didShowCell:(LinePageCell *)cell;

/**
 主scrollView滚动的offset回传

 @param linePage 当前的LinePageView
 @param offset 当前linePageView滚动的offset值
 */
- (void)linePageView:(LinePageView *)linePage offsetChanged:(CGPoint)offset;

/**
 指定页面已被移除主视图（暂时提供给SFTdNewsContentViewController使用）

 @param linePage 当前的LinePageView
 @param cell 被移出主视图的cell
 */
- (void)linePageView:(LinePageView *)linePage didRemoveCell:(LinePageCell *)cell;
@end

@interface LinePageView : PopGestureScrollView
{
	__weak id<LinePageViewDataSource>		m_dataSource;
    __weak id<LinePageViewDelegate>        m_delegate;
    
    NSInteger                       pageCount;
    NSInteger                       currentPageIndex;
}
@property (nonatomic,weak) id<LinePageViewDataSource> lpDataSource;
@property (nonatomic,weak) id<LinePageViewDelegate> lpDelegate;
@property (nonatomic,readonly) CGFloat  singleCellWidth;

- (NSInteger)getCurrentIndex;
- (LinePageCell *)getCellForIndex:(NSInteger)index; // returns nil if cell is not visible or index  is out of range
- (LinePageCell *)dequeueReusablePageCellWithIdentifier:(NSString *)identifier;
- (void)pageSwitchTo:(NSInteger)index;
- (void)reloadData;
- (NSInteger)getIndexFromCell:(LinePageCell *)cell;
- (void)clearCellsAssociatedObjs;
@end
