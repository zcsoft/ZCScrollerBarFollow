//
//  ZCScrollerBarFollow.m
//  ZCScrollerBarFollowDemo
//
//  Created by cuibo on 7/8/15.
//  Copyright (c) 2015 cuibo. All rights reserved.
//

#import "ZCScrollerBarFollow.h"

@interface ZCScrollerBarFollow()
{
    __weak UITableView *_tableView;                             //表
    __weak UIImageView *_scrollBar;                             //滚动条
    CGSize _savedTableViewSize;                                 //table视图大小
}

@property (nonatomic, assign) BOOL didEnd;                      //是否已经调用过滚动结束
@property (nonatomic, strong) UIView *followView;               //跟随视图
@property (nonatomic, assign) CGFloat followViewWidth;          //跟随视图的默认宽度

@end


@implementation ZCScrollerBarFollow

//初始化，delegate－代理，tableView－作用于表视图，followView－跟随视图
- (id)initWithDelegate:(id <ZCScrollerBarFollowDelegate>)delegate
             tableView:(UITableView *)tableView
            followView:(UIView *)followView
{
    self = [super init];
    if (self)
    {
        //防止滚动结束后重复调用
        self.didEnd = NO;
        
        //默认参数
        self.autoHide = YES;
        self.hideScrollBar = NO;
        
        //作用视图
        _tableView = tableView;
        //保存追随视图
        self.followView = followView;
        self.followViewWidth = self.followView.frame.size.width;
        //保存代理
        self.delegate = delegate;
        //偏移
        self.offsetX = 0;
    }
    return self;
}

//主动显示滚动标签（需要在table视图可以滚动时执行，既视图控制器viewDidAppear或之后）
- (void)show
{
    //闪现、移动，结束
    [_tableView flashScrollIndicators];
    [_tableView setContentOffset:CGPointMake(0, _tableView.contentOffset.y+1) animated:NO];
    [_tableView setContentOffset:CGPointMake(0, _tableView.contentOffset.y-1) animated:NO];
    [self scrollViewDidEndDecelerating];
}

//计算followView的x坐标，需要考虑偏移和滚动条宽度
- (CGFloat)followViewX
{
    CGFloat x = 0;
    
    //导航条隐藏，则偏移导航宽度（右对其）
    if(self.hideScrollBar)
    {
        x = -self.followViewWidth + _scrollBar.frame.size.width + self.offsetX;
    }
    else
    {
        x = -self.followViewWidth + self.offsetX;;
    }
    
    return x;
}

//获得tableview和滚动条
- (void)captureTableViewAndScrollBar
{
    for (id subview in [_tableView subviews])
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            UIImageView *imageView = (UIImageView *)subview;
            
            //垂直滚动条
            if (imageView.frame.size.width < 10 && imageView.frame.size.height > imageView.frame.size.width)
            {
                UIScrollView *sc = (UIScrollView*)imageView.superview;
                if (sc.frame.size.height < sc.contentSize.height)
                {
                    //隐藏滚动条
                    if(self.hideScrollBar)
                        [imageView setImage:nil];
                    //自动隐藏
                    if(self.autoHide)
                        self.followView.alpha = 0.0;
                    //找到滚动条，设置不裁切，并将标签添加到滚动条上
                    imageView.clipsToBounds = NO;
                    [imageView addSubview:self.followView];
                    _scrollBar = imageView;
                    
                    //此时保存tableview大小
                    _savedTableViewSize = _tableView.frame.size;
                }
            }
        }
    }
}

//更新标签显示（标签移动到不同的cell上了），cell－当前标签所在cell
- (void)updateDisplayWithCell:(UITableViewCell *)cell
{
    [self.delegate scrollerBarFollow:self followView:self.followView dateForCell:cell];
}

//开始滚动（滚动变化）
- (void)scrollViewDidScroll
{
    //设置结束可调用
    self.didEnd = NO;
    
    //滚动条不存在，则获取
    if (!_scrollBar)
    {
        [self captureTableViewAndScrollBar];
    }
    
    //检查变更（如变更，则scrollbar会被失效）
    [self checkChanges];
    
    //如果滚动条不存在，则返回
    if (!_scrollBar)
    {
        return;
    }
    
    CGRect selfFrame = self.followView.frame;
    CGRect scrollBarFrame = _scrollBar.frame;
    
    //设置居中滚动条显示
    self.followView.frame = CGRectMake([self followViewX],  //-宽度，全部显示在屏幕内
                                       (CGRectGetHeight(scrollBarFrame) / 2.0f) - (CGRectGetHeight(selfFrame) / 2.0f),//剧中到滚动条
                                       CGRectGetWidth(selfFrame),
                                       CGRectGetHeight(selfFrame));
    
    //把自己在滚动条上的位置映射到table上
    CGPoint point = CGPointMake(CGRectGetMidX(self.followView.frame), CGRectGetMidY(self.followView.frame));
    point = [_scrollBar convertPoint:point toView:_tableView];
    //获得当前标签位置所在cell
    UITableViewCell* cell=[_tableView cellForRowAtIndexPath:[_tableView indexPathForRowAtPoint:point]];
    //在cell上
    if (cell) {
        [self updateDisplayWithCell:cell];
        if (self.autoHide && ![self.followView alpha])
        {
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.followView setAlpha:1.0f];
            } completion:nil];
        }
    }
    else
    {
        if (self.autoHide && [self.followView alpha])
        {
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.followView setAlpha:0.0f];
            } completion:nil];
        }
    }
}

//停止拖拽，decelerate－是否还有缓冲
- (void)scrollViewDidEndDragging:(BOOL)decelerate
{
    //如果不需要缓冲定制
    if(!decelerate)
    {
        //当前没停止
        if(!self.didEnd)
        {
            self.didEnd = YES;
            [self scrollViewDidEndDecelerating];
        }
    }
}

//减速停止
- (void)scrollViewDidEndDecelerating
{
    //当前没停止
    if(!self.didEnd)
        self.didEnd = YES;
    else
        return;
    
    if (!_scrollBar)
    {
        return;
    }
    
    //修正x，和滚动条右侧对其
    self.followView.frame = (CGRect){[self followViewX], self.followView.frame.origin.y, self.followView.frame.size.width, self.followView.frame.size.height};
    //计算自己在_tableView.superview上的位置，并添加到_tableView.superview上
    //必须添加到_tableView.superview上，因为滚动条会自动隐藏
    CGRect newFrame = [_scrollBar convertRect:self.followView.frame toView:_tableView.superview];
    self.followView.frame = newFrame;
    [_tableView.superview addSubview:self.followView];
    
    if(self.autoHide)
    {
        [UIView animateWithDuration:0.3f delay:1.0f options:UIViewAnimationOptionBeginFromCurrentState  animations:^{
            self.followView.alpha = 0.0f;
        } completion:nil];
    }
}

//将要开始滚动（功能类似scrollViewDidScroll）
- (void)scrollViewWillBeginDragging
{
    self.didEnd = NO;
    
    if (!_scrollBar)
    {
        [self captureTableViewAndScrollBar];
    }
    
    if (!_scrollBar)
    {
        return;
    }
    
    CGRect selfFrame = self.followView.frame;
    CGRect scrollBarFrame = _scrollBar.frame;
    
    self.followView.frame = CGRectIntegral(CGRectMake([self followViewX],
                                                      (CGRectGetHeight(scrollBarFrame) / 2.0f) - (CGRectGetHeight(selfFrame) / 2.0f),
                                                      CGRectGetWidth(selfFrame),
                                                      CGRectGetHeight(selfFrame)));
    
    [_scrollBar addSubview:self.followView];
    
    if(self.autoHide)
    {
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState  animations:^{
            self.followView.alpha = 1.0f;
        } completion:nil];
    }
    
}

//让标签失效
- (void)invalidate
{
    _scrollBar = nil;
    [self.followView removeFromSuperview];
}

//检查table变化
- (void)checkChanges
{
    //table不存在，或者tableView宽高变化
    if (_savedTableViewSize.height != _tableView.frame.size.height ||
        _savedTableViewSize.width != _tableView.frame.size.width)
    {
        [self invalidate];
    }
}

@end
