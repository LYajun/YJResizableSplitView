//
//  YJResizableSplitView.h
//
//
//  Created by 刘亚军 on 2018/11/21.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSBundle (YJRS)
+ (instancetype)yj_rsBundle;
+ (NSString *)yj_rsbundlePathWithName:(NSString *)name;
@end

@interface UIImage (YJRS)
+ (UIImage *)yj_rsImageNamed:(NSString *)name;
@end

@class YJResizableSplitView;
@protocol YJResizableSplitViewDelegate <NSObject>
@optional
// 开始拖动的时候响应的代理方法
- (void)YJResizableSplitViewBeginEditing:(YJResizableSplitView *)resizableSplitView;
// 拖动的时候响应的代理方法
- (void)YJResizableSplitViewDidBeginEditing:(YJResizableSplitView *)resizableSplitView;
//结束拖动的时候响应的代理方法
- (void)YJResizableSplitViewDidEndEditing:(YJResizableSplitView *)resizableSplitView;

@end

@interface YJResizableSplitView : UIView
@property (nonatomic,assign) id<YJResizableSplitViewDelegate> delegate;
// 距离顶部的间距
@property (nonatomic, assign) CGFloat topDistance;
// 距离底部的间距
@property (nonatomic, assign) CGFloat bottomDistance;
@property (strong, nonatomic) UIView *contentView;
@property (nonatomic,assign) BOOL dragEnable;
@end
