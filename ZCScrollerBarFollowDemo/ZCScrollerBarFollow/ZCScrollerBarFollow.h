//
//  ZCScrollerBarFollow.h
//  ZCScrollerBarFollowDemo
//
//  Created by cuibo on 7/8/15.
//  Copyright (c) 2015 cuibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZCScrollerBarFollow;

@protocol ZCScrollerBarFollowDelegate <NSObject>

@required

- (void)scrollerBarFollow:(ZCScrollerBarFollow *)scrollerFollow
                   followView:(UIView *)followView
                  dateForCell:(UITableViewCell *)cell;

@end



@interface ZCScrollerBarFollow : NSObject

@property (nonatomic, weak) id <ZCScrollerBarFollowDelegate> delegate;


@property(assign, nonatomic) BOOL autoHide;                     //自动隐藏（滚动停止时）
@property(assign, nonatomic) BOOL hideScrollBar;                //隐藏默认的滚动条
@property(assign, nonatomic) CGFloat offsetX;                   //跟随视图x偏移
@property(strong, readonly, nonatomic) UIView *followView;      //跟随视图


//初始化，delegate－代理，tableView－作用于表视图，followView－跟随视图
//followView视图不可以设置背景色，如果需要followView具有背景颜色，则必须在followView上添加一个UIView，并改变这个UIView的颜色
- (id)initWithDelegate:(id <ZCScrollerBarFollowDelegate>)delegate
             tableView:(UITableView *)tableView
            followView:(UIView *)followView;


//主动显示滚动标签（需要在table视图可以滚动时执行，既视图控制器viewDidAppear或之后）
//滚动标签默认是不显示的，如果设置了autoHide=NO;则需要在viewDidAppear中调用show，以显示标签
- (void)show;

//滚动相关
- (void)scrollViewDidScroll;
- (void)scrollViewDidEndDragging:(BOOL)decelerate;
- (void)scrollViewDidEndDecelerating;
- (void)scrollViewWillBeginDragging;


@end
