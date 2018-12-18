//
//  ViewController.m
//  NestCollectionView
//
//  Created by 邓乐 on 2018/12/18.
//  Copyright © 2018 fanli. All rights reserved.
//

#import "ViewController.h"
#import "FLScrollView.h"
#import "FLHeaderView.h"
#import "LinePageView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController () <LinePageViewDelegate,LinePageViewDataSource,UIScrollViewDelegate,FLScrollViewDelegate>

@property (nonatomic, strong) FLHeaderView *headerView;

@property (nonatomic, strong) LinePageView *linePageView;

@property (nonatomic, strong) UIScrollView *catBar;

@property (nonatomic, strong) NSMutableArray *scrollArray;

#define  kViewCellID    @"viewcell"

@property (nonatomic, weak) FLScrollView *currentScrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.scrollArray = [NSMutableArray array];
    
    self.headerView = [[FLHeaderView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 844)];
    self.headerView.backgroundColor = [UIColor orangeColor];
    
    CGFloat headerItemY = 10;
    CGFloat headerItemMargin = 10;
    CGFloat headerItemHeight = ((800 - 5*headerItemMargin)/4);
    for (int i = 0; i < 4; i ++) {
        UIView *headerItem = [[UIView alloc] initWithFrame:CGRectMake(headerItemMargin, headerItemY, ScreenWidth-headerItemMargin*2, headerItemHeight)];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake((CGRectGetWidth(headerItem.frame)-50)*0.5f, (headerItemHeight-50)*0.5f, 50, 50);
        [btn setTitle:[NSString stringWithFormat:@"btn-%d",i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [headerItem addSubview:btn];
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        headerItem.backgroundColor = [UIColor whiteColor];
        headerItemY = CGRectGetMaxY(headerItem.frame)+headerItemMargin;
        [self.headerView addSubview:headerItem];
    }
    
    [self.view addSubview:self.headerView];
    
//    self.catBar = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerView.frame)-44, ScreenWidth, 44)];
//    self.catBar.backgroundColor = [UIColor lightGrayColor];
//    CGFloat catBarStartX = 10;
//    for (int i = 0; i < 10; i++) {
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(catBarStartX, 0, 60, 44)];
//        titleLabel.textColor = [UIColor blueColor];
//        titleLabel.text = [NSString stringWithFormat:@"分类-%d",i+1];
//        catBarStartX = CGRectGetMaxX(titleLabel.frame)+10;
//        [self.catBar addSubview:titleLabel];
//    }
//    self.catBar.contentSize = CGSizeMake(catBarStartX, 0);
    
    self.linePageView = [[LinePageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.view addSubview:self.linePageView];
    self.linePageView.lpDelegate = self;
    self.linePageView.lpDataSource = self;
    [self.view addSubview:self.linePageView];
    self.linePageView.pagingEnabled = YES;
    CGFloat startX = ScreenWidth;
    for (int i = 0; i < 5; i++)
    {
        FLScrollView *scroll = [[FLScrollView alloc] initWithFrame:CGRectMake(startX*i, 0, ScreenWidth, ScreenHeight)];
        [self.scrollArray addObject:scroll];\
        scroll.scrollDelegate = self;
        scroll.contentInset = UIEdgeInsetsMake(CGRectGetHeight(self.headerView.frame), 0, 0, 0);
    }
    self.currentScrollView = self.scrollArray.firstObject;
    
    //[self.view bringSubviewToFront:self.headerView];
}

#pragma mark- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma mark -LinePageViewDelegate
- (void)linePageView:(LinePageView *)linePage midChangedToIndex:(NSInteger)newPageIndex
{
    self.currentScrollView = [self.scrollArray objectAtIndex:newPageIndex];
}

- (void)linePageView:(LinePageView *)linePage willRemoveCell:(LinePageCell *)cell
{
    
}

- (void)linePageView:(LinePageView *)linePage willShowCell:(LinePageCell *)cell
{
    FLScrollView *targetScroll = [cell viewWithTag:10001];
    
    CGFloat offSet = fabs(CGRectGetMinY(self.headerView.frame))-CGRectGetHeight(self.headerView.frame);
    
    [targetScroll syncHeaderOffSet:offSet];
}

- (void)linePageView:(LinePageView *)linePage didShowCell:(LinePageCell *)cell
{
    
}

#pragma mark -LinePageViewDataSource
// 请求page页面的个数。
- (NSInteger)pageNumberInlinePageView:(LinePageView *)linePage
{
    return 3;
}
// 请求指定index的 page cell.
- (LinePageCell *)linePageView:(LinePageView *)linePage cellForIndex:(NSInteger)pageIndex
{
    LinePageCell * cell = [linePage dequeueReusablePageCellWithIdentifier:kViewCellID];
    if (nil == cell)
    {
        cell = [[LinePageCell alloc] initWithReuseIdentifier:kViewCellID];
        cell.frame = linePage.frame;
        cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    UIView * detailView = [cell viewWithTag:10001];
    if (detailView)
    {
        [detailView removeFromSuperview];
    }
    
    FLScrollView* scrollView = [self.scrollArray objectAtIndex:pageIndex];
    if (scrollView)
    {
        scrollView.frame = cell.bounds;
        scrollView.tag = 10001;
        [cell addSubview:scrollView];
    }
    
    return cell;
}

- (void)clickBtn:(UIButton *)sender
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Btn Clicked" message:[NSString stringWithFormat:@"%@ was clicked!",sender.titleLabel.text] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        return ;
    }];
    [alertC addAction:okAction];
    [self presentViewController:alertC animated:YES completion:nil];
}

#pragma mark- FLScrollViewDelegate
- (UIView *)bindHeaderViewToScrollView:(FLScrollView *)scrollView
{
    if (scrollView == self.currentScrollView)
    {
        return self.headerView;
    }
    return nil;
}


@end
