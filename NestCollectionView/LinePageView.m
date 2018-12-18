//
//  LinePageView.m
//  Fanli
//
//  Created by fanli on 5/21/14.
//  Copyright (c) 2014 www.fanli.com. All rights reserved.
//

#import "LinePageView.h"
#import "LinePageCell.h"
#define ScreenSize [UIScreen mainScreen].bounds.size
#define ScreenWidth ScreenSize.width
#define ScreenHeight ScreenSize.height

@interface ReuseLPCellPools : NSObject
{
    NSMutableDictionary * identifierPoolPairs;
}
@end

@implementation ReuseLPCellPools
- (id)init
{
    if (self = [super init]) {
        identifierPoolPairs = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    if (identifierPoolPairs)
    {
        identifierPoolPairs = nil;
    }
}


- (void)queueACellToCellPools:(LinePageCell *)cell
{
    if (nil == cell.reuseIdentifier) {
        // no identifier ,cann't reuse.
        return;
    }
    
    // get the cell pool which it's key is equal cell.reuseIdentifier.
    NSMutableArray * aCellPool = [identifierPoolPairs objectForKey:cell.reuseIdentifier];
    if ( nil == aCellPool) {
        // this cell.reuseIdentifier 's pool had not been created.
        aCellPool = [NSMutableArray arrayWithObject:cell];
        [identifierPoolPairs setObject:aCellPool forKey:cell.reuseIdentifier];
    }else{
        // find the cell pool,check this cell whether in pool.
        if (NO == [aCellPool containsObject:cell]) {
            [aCellPool addObject:cell];
//            [aCellPool safeAddObject:cell];
        }
        
    }
    
    [cell cellIsRecycled];
    
}

- (LinePageCell *)dequeueACellWithReuseIdentifier:(NSString *)theReuseIdentifier
{
    NSMutableArray * aCellPool = [identifierPoolPairs objectForKey:theReuseIdentifier];
    if ( nil == aCellPool || [aCellPool count] == 0) {
        return nil;
    }else{
        LinePageCell * aReuseCell = nil;
        if ([aCellPool count] > 0) {
            // if cell remove from pool, it's retaincount will dec 1,maybe it will be 0, than the cell
            // will dealloc.  the return value is a wild pointer.
            // retain the cell first and return a autorelease objc.
            aReuseCell = [aCellPool lastObject];
            [aCellPool removeObject:aReuseCell];
        }
        return aReuseCell;
    }
}

- (void)cleanCellAssoiatedObjsInPools
{
	for (NSArray * aPool in [identifierPoolPairs allValues])
	{
		for (LinePageCell * aCellInPool in aPool)
		{
			[aCellInPool cleanAssociatedObjs];
		}
	}
}

@end

@interface LinePageView () <UIScrollViewDelegate>
{
    
}
@property(nonatomic,strong)ReuseLPCellPools    * cellPools;
@property(nonatomic,strong)NSMutableArray       * currentVaildPageCells;
@end

@implementation LinePageView
@synthesize lpDataSource = m_dataSource;
@synthesize lpDelegate = m_delegate;
@synthesize cellPools;
@synthesize currentVaildPageCells;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // 配置scroll view的参数，达到我们line page的效果。
        self.pagingEnabled = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.scrollEnabled = YES;
        self.alwaysBounceHorizontal = YES;
        self.clipsToBounds = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
		self.scrollsToTop = NO;
        self.delegate = self;
        pageCount = 0;
        currentPageIndex = kInvalidPageIndex;
        self.currentVaildPageCells = [NSMutableArray array];
        self.cellPools = [[ReuseLPCellPools alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.currentVaildPageCells = nil;
    self.cellPools = nil;
}

#pragma mark -
#pragma mark interface

- (LinePageCell *)dequeueReusablePageCellWithIdentifier:(NSString *)identifier
{
    return  [self.cellPools dequeueACellWithReuseIdentifier:identifier];
}


- (NSInteger)getMidIndexThisTime
{
    if (self.contentSize.width == 0) {
        return kInvalidPageIndex;
    }
    
    CGPoint offset = self.contentOffset;
    CGFloat quotient = offset.x / self.bounds.size.width;
    NSInteger baseIndex = (NSInteger)quotient;
    
    // need fix the index, if baseIndex cell had move more than a half.
    if(quotient - baseIndex > 0.5)
    {
        baseIndex ++;
    }
    
    return baseIndex;
}

- (NSInteger)getCurrentIndex
{
    return currentPageIndex;
}

- (void)setLpDataSource:(id<LinePageViewDataSource>)aNewlpDataSource
{
    m_dataSource = aNewlpDataSource;
    [self reloadData]; // dataSource had been changed ,reload data.
}

- (void)pageSwitchTo:(NSInteger)index
{
    if (index < 0 || index >= pageCount) {
        // invalid position
        return;
    }
	
	BOOL needAnimated = NO;
    CGRect newDisplayRect = CGRectMake(index * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
    [self scrollRectToVisible:newDisplayRect animated:needAnimated];
	
	if (NO == needAnimated)
	{
		// 由于不做动画的切换，不会触发scrollViewDidEndScrollingAnimation 的调用，
		// 因此直接这里触发mid item change 处理。
		[self performSelector:@selector(checkMidItemIsChanged:) withObject:self afterDelay:0.0];
	}
}

- (void)reloadData
{
    // request the base info from data source
    [self requestBaseInfoFromDataSource];
    
    // redraw line page
     [self reloadLinerPage];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)queryMidItemChanged
{
    if (self.contentOffset.x == 0 && pageCount <= 0) {
        currentPageIndex = kInvalidPageIndex;
        return;
    }
    
    if (fabs(currentPageIndex  - self.contentOffset.x / self.bounds.size.width) > 0.5) {
        currentPageIndex = [self getMidIndexThisTime];
        if (self.lpDelegate) {
            [self.lpDelegate linePageView:self midChangedToIndex:currentPageIndex];
        }
    }

}

- (CGFloat)singleCellWidth
{
	return self.bounds.size.width;
}

- (void)clearCellsAssociatedObjs
{
	for (id aViewObj in self.subviews)
	{
		if ([aViewObj isKindOfClass:[LinePageCell class]])
		{
			[(LinePageCell *)aViewObj cleanAssociatedObjs];
		}
	}
	
	[self.cellPools cleanCellAssoiatedObjsInPools];
}
#pragma mark -
#pragma mark pravite func

- (void)requestBaseInfoFromDataSource
{
    if (self.lpDataSource) {
        pageCount = [self.lpDataSource pageNumberInlinePageView:self];
        if (pageCount > 0) {
            // set the scroll view info
            self.contentSize = CGSizeMake(ScreenWidth * pageCount, self.bounds.size.height);
			currentPageIndex = [self getMidIndexThisTime];
        }else{
			self.contentSize = CGSizeMake(0, 0);
			currentPageIndex = kInvalidPageIndex;
		}
    }
}


- (LinePageCell *)requestPageCellForIndex:(NSInteger)index
{
    if (nil == self.lpDataSource) {
        NSLog(@"Cann't find data source ,nobody will provider a page cell");
        return nil;
    }
    // request get a new page cell for current index
    LinePageCell * reqCell =   [self.lpDataSource linePageView:self cellForIndex:index];
    if (reqCell.isNeedAdaptiveCellFrame) {
        reqCell.frame = self.bounds;
    }
    
    return reqCell;
}

- (void)reloadLinerPage
{
    if (pageCount <= 0) {
        NSLog(@"Invalid page count,cann't reload");
        return;
    }
    
    NSInteger theCurPageIndex = [self getMidIndexThisTime];
    if (theCurPageIndex == kInvalidPageIndex) {
        return;
    }
    // 如果当前没有Cell显示，触发layout,从而请求当前cell.
    if ([self.currentVaildPageCells count] == 0)
    {
        [[self layer] setNeedsLayout];
    }else{
        // 刷新当前已经显示的cell.
        NSArray * inDisplayCells = [self getInDisplayCells];
        
        for (LinePageCell * aNeedRefreshCell in inDisplayCells)
		{
			[self removeCell:aNeedRefreshCell];
            // request get a new page cell for current index
            LinePageCell * newDisplayeCell = [self requestPageCellForIndex:aNeedRefreshCell.cellMarkIndex];
            [self addCell:newDisplayeCell toIndex:theCurPageIndex];
        }
    }
}


- (LinePageCell *)getCellForIndex:(NSInteger)index
{
    if (index < 0 || index >= pageCount)
    {
        // 小于最小的，或者大于最大的
        return nil;
    }
	
	if (pageCount < 0) {
		// 无效配置
		return nil;
	}
    
    for (LinePageCell * aPageCell in self.currentVaildPageCells) {
        if (aPageCell.cellMarkIndex == index) {
            return aPageCell;
        }
    }
    
    return nil;
}

- (NSInteger)getIndexFromCell:(LinePageCell *)cell
{
    if (![self.currentVaildPageCells containsObject:cell])
    {
        return NSNotFound;
    }
    
    return [self.currentVaildPageCells indexOfObject:cell];
}

- (void)addCell:(LinePageCell *)thePageCell toIndex:(NSInteger)index
{
    if (thePageCell)
	{
        thePageCell.cellMarkIndex = index;
	
		if ([self.lpDelegate respondsToSelector:@selector(linePageView:willShowCell:)])
		{
			[self.lpDelegate linePageView:self willShowCell:thePageCell];
		}
		
        thePageCell.center = CGPointMake(self.bounds.size.width / 2 + index * self.bounds.size.width, self.bounds.size.height / 2);
        [self.currentVaildPageCells addObject:thePageCell];
		[self addSubview:thePageCell];
		
		if ([self.lpDelegate respondsToSelector:@selector(linePageView:didShowCell:)])
		{
			[self.lpDelegate linePageView:self didShowCell:thePageCell];
		}
		
		// 由于不做动画，会再结尾处少了一次 scrollViewDidScroll 调用，以致外部不会对
		// cell 变更做出响应，因此添加一次 scrollViewDidScroll 通知
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self scrollViewDidScroll:self];
		});
		
    }
}


- (void)removeCell:(LinePageCell *)thePageCell
{
	if ([self.lpDelegate respondsToSelector:@selector(linePageView:willRemoveCell:)])
	{
		[self.lpDelegate linePageView:self willRemoveCell:thePageCell];
	}

	[thePageCell removeFromSuperview];

	if ([self.lpDelegate respondsToSelector:@selector(linePageView:didRemoveCell:)])
	{
		[self.lpDelegate linePageView:self didRemoveCell:thePageCell];
	}

    if ([self.currentVaildPageCells containsObject:thePageCell]) {
        [self.currentVaildPageCells removeObject:thePageCell];
    }
	
    // if need reuse,put the cell to cells pool.
    [self.cellPools queueACellToCellPools:thePageCell];
}

- (NSArray *)getInDisplayCells
{
    // find the cells which was displayed in window at this time
    NSMutableArray * inDisplayedCells = [NSMutableArray array];
    for (LinePageCell * aPageCell in self.currentVaildPageCells) {
        CGRect pageFrame = aPageCell.frame;
        if (YES == CGRectIntersectsRect(self.bounds, pageFrame)) {
            [inDisplayedCells addObject:aPageCell];
        }
    }
    return inDisplayedCells;
    
}

- (NSArray *)getCenterThreeMusketeers
{
    // 找到居中的三位
    NSMutableArray * threeMusketeers = [NSMutableArray array];
    NSInteger  curIndex = [self getMidIndexThisTime];
    for (LinePageCell * aPageCell in self.currentVaildPageCells) {
        if (aPageCell.cellMarkIndex >= (curIndex - 1) && aPageCell.cellMarkIndex <= (curIndex + 1)) {
            [threeMusketeers addObject:aPageCell];
        }
    }
    
    return threeMusketeers;
}

// 移除已经超出用户感知区域的cells
- (void)removeCellsOutUserSensation
{
    NSMutableArray * invalidCells = [NSMutableArray array];
    
    NSArray * validCells = [self getInDisplayCells];
    for (LinePageCell * aPageCell in self.currentVaildPageCells ) {
        if (NO == [validCells containsObject:aPageCell]) {
            [invalidCells addObject:aPageCell];
        }
    }
    
    // 移走已经无效的cell
    for (LinePageCell * aInvalidCell in invalidCells) {
        [self removeCell:aInvalidCell];
    }

}


// 计算需要显示或者预加载的cell index.
- (void)calcNeededCellIndex:(NSInteger *)bIndexPtr to:(NSInteger *)eIndexPtr
{
    CGPoint fixOffset = self.contentOffset;
 
	CGFloat headTempIndex = fixOffset.x/ self.bounds.size.width;
    NSInteger headIndex = headTempIndex;
	NSInteger endIndex = 0;
    
    if (headIndex < 0) {
        headIndex = 0;
    }
    endIndex = (fixOffset.x - headIndex * self.bounds.size.width) > 0 ? headIndex + 1 : headIndex;
    
    // set return value
    *bIndexPtr = headIndex;
    *eIndexPtr = endIndex;
    
}

 // 加载需要的cell.
- (void)loadNeededCellFrom:(NSInteger)beginCellIndex to:(NSInteger)endCellIndex
{
	for (NSInteger rfIndex = beginCellIndex ; rfIndex <= endCellIndex  && rfIndex < pageCount; rfIndex++)
	{
		BOOL findInSuper = NO;
		
		for (LinePageCell * aPageCell in self.currentVaildPageCells) {
			if (aPageCell.cellMarkIndex == rfIndex) {
				findInSuper = YES;
				break;
			}
		}
		
		if (NO == findInSuper && (rfIndex >= 0 && rfIndex < pageCount)) {
            LinePageCell * aNewPageCell = [self requestPageCellForIndex:rfIndex];
            [self addCell:aNewPageCell toIndex:rfIndex];
		}
	}

}

- (void)cotentLoadView:(UIScrollView *)scrollView
{
    
    NSInteger headIndex = 0;
	NSInteger endIndex = 0;
	
	
	[self calcNeededCellIndex:&headIndex to:&endIndex];
    [self loadNeededCellFrom:headIndex to:endIndex];
	[self removeCellsOutUserSensation];

}

- (void)checkMidItemIsChanged:(UIScrollView *)scrollView
{
	[self queryMidItemChanged];
	[self notifyScrollOffsetChanged:scrollView.contentOffset];
}

#pragma mark -
#pragma mark CALayer delegate methods

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	@autoreleasepool{
		 [self cotentLoadView:self];
	}
}

#pragma mark -
#pragma mark scroll view scroll
- (void)notifyScrollOffsetChanged:(CGPoint)offset
{
	if (self.lpDelegate && [self.lpDelegate respondsToSelector:@selector(linePageView:offsetChanged:)])
	{
		[self.lpDelegate linePageView:self offsetChanged:offset];
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self notifyScrollOffsetChanged:scrollView.contentOffset];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	[self checkMidItemIsChanged:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self checkMidItemIsChanged:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	[self checkMidItemIsChanged:scrollView];
}
@end
