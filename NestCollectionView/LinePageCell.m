//
//  LinePageCell.m
//  ScrollPageEffect
//
//  Created by biqiang.lai on 22/5/14.
//  Copyright (c) 2014 51fanli. All rights reserved.
//

#import "LinePageCell.h"

@implementation LinePageCell
@synthesize cellMarkIndex;
@synthesize isNeedAdaptiveCellFrame;
@synthesize reuseIdentifier = cellReuseIdentifier;

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super init]) {
        cellReuseIdentifier = reuseIdentifier;
        isNeedAdaptiveCellFrame = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        cellReuseIdentifier = nil;
        isNeedAdaptiveCellFrame = NO;
    }
    return self;
}

- (void)dealloc
{
	cellReuseIdentifier = nil;
}

-(void)cellIsRecycled
{

}

- (void)cleanAssociatedObjs
{
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
