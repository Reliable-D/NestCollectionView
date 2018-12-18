//
//  LinePageCell.h
//  ScrollPageEffect
//
//  Created by biqiang.lai on 22/5/14.
//  Copyright (c) 2014 51fanli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinePageCell : UIView
{
    NSInteger  cellMarkIndex;
    BOOL       isNeedAdaptiveCellFrame;
    NSString *  cellReuseIdentifier;
}
@property(nonatomic,assign)NSInteger cellMarkIndex;
@property(nonatomic,assign) BOOL      isNeedAdaptiveCellFrame;
@property(nonatomic,readonly)NSString *reuseIdentifier;

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

// cell 已经被回收了。
-(void)cellIsRecycled;

- (void)cleanAssociatedObjs;
@end
