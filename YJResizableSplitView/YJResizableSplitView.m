//
//  YJResizableSplitView.m
//
//
//  Created by 刘亚军 on 2018/11/21.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import "YJResizableSplitView.h"

#import <Masonry/Masonry.h>

#define YJRS_ColorWithHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define YJRS_ScreenWidth      [UIScreen mainScreen].bounds.size.width
#define YJRS_ScreenHeight     [UIScreen mainScreen].bounds.size.height

@implementation NSBundle (YJRS)
+ (instancetype)yj_rsBundle{
    static NSBundle *dictionaryBundle = nil;
    if (!dictionaryBundle) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        dictionaryBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[YJResizableSplitView class]] pathForResource:@"YJResizableSplitView" ofType:@"bundle"]];
    }
    return dictionaryBundle;
}
+ (NSString *)yj_rsbundlePathWithName:(NSString *)name{
    return [[[NSBundle yj_rsBundle] resourcePath] stringByAppendingPathComponent:name];
}
@end

@implementation UIImage (YJRS)
+ (UIImage *)yj_rsImageNamed:(NSString *)name{
    return [UIImage imageNamed:[NSBundle yj_rsbundlePathWithName:name]];
}
@end

typedef struct YJResizableSplitViewAnchorPoint {
    CGFloat adjustsX;
    CGFloat adjustsY;
    CGFloat adjustsH;
    CGFloat adjustsW;
} YJResizableSplitViewAnchorPoint;

static CGFloat YJDistanceBetweenTwoPoints(CGPoint point1, CGPoint point2) {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy);
};
static YJResizableSplitViewAnchorPoint YJResizableSplitViewNoResizeAnchorPoint = { 0.0, 0.0, 0.0, 0.0 };
static YJResizableSplitViewAnchorPoint YJResizableSplitViewUpperLeftAnchorPoint = { 1.0, 1.0, -1.0, 1.0 };
static YJResizableSplitViewAnchorPoint YJResizableSplitViewUpperMiddleAnchorPoint = { 0.0, 1.0, -1.0, 0.0 };
static YJResizableSplitViewAnchorPoint YJResizableSplitViewUpperRightAnchorPoint = { 0.0, 1.0, -1.0, -1.0 };

typedef struct CGPointYJResizableSplitViewAnchorPointPair {
    CGPoint point;
   YJResizableSplitViewAnchorPoint anchorPoint;
} CGPointYJResizableSplitViewAnchorPointPair;

@interface YJResizableSplitView ()<UIGestureRecognizerDelegate>
{
    CGPoint touchStart;
    // 用于确定哪些位置的点才能触发拖动事件.
    YJResizableSplitViewAnchorPoint anchorPoint;
}
@property (strong, nonatomic) UIImageView *dragImgView;
@property (strong, nonatomic) UIView *dragView;
@end
@implementation YJResizableSplitView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
    }
    return self;
}
- (void)layoutUI{
    [self addSubview:self.dragView];
    [self.dragView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.left.top.equalTo(self);
        make.height.mas_equalTo(20);
    }];
    [self.dragView addSubview:self.dragImgView];
    [self.dragImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.top.equalTo(self.dragView);
        make.width.mas_equalTo(60);
    }];
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.left.bottom.equalTo(self);
        make.top.equalTo(self.dragView.mas_bottom);
    }];
    
    self.dragEnable = YES;
    CALayer *dragLine = [[CALayer alloc] init];
    dragLine.backgroundColor = YJRS_ColorWithHex(0xEBEBEB).CGColor;
    dragLine.frame = CGRectMake(0, 20 - 1, YJRS_ScreenWidth, 1);
    [self.dragView.layer addSublayer:dragLine];
}
- (void)setDragEnable:(BOOL)dragEnable{
    _dragEnable = dragEnable;
    self.dragView.hidden = !dragEnable;
    [self.dragView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(dragEnable ? 20 : 0);
    }];
}
- (YJResizableSplitViewAnchorPoint)anchorPointForTouchLocation:(CGPoint)touchPoint{
    // (1) 计算点击锚点的位置.
    CGPointYJResizableSplitViewAnchorPointPair upperLeft = { CGPointMake(0.0, 0.0), YJResizableSplitViewUpperLeftAnchorPoint };
    CGPointYJResizableSplitViewAnchorPointPair upperMiddle = { CGPointMake(self.bounds.size.width/2, 0.0), YJResizableSplitViewUpperMiddleAnchorPoint };
    CGPointYJResizableSplitViewAnchorPointPair upperRight = { CGPointMake(self.bounds.size.width, 0.0), YJResizableSplitViewUpperRightAnchorPoint };
    CGPointYJResizableSplitViewAnchorPointPair centerPoint = { CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2), YJResizableSplitViewNoResizeAnchorPoint };
    // (2) 遍历每一个锚点,找到一个最靠近的点.
    CGPointYJResizableSplitViewAnchorPointPair allPoints[4] = { upperLeft, upperRight, upperMiddle, centerPoint };
    CGFloat smallestDistance = MAXFLOAT;
    CGPointYJResizableSplitViewAnchorPointPair closestPoint = centerPoint;
    for (NSInteger i = 0; i < 4; i++) {
        CGFloat distance = YJDistanceBetweenTwoPoints(touchPoint, allPoints[i].point);
        if (distance < smallestDistance) {
            closestPoint = allPoints[i];
            smallestDistance = distance;
        }
    }
    return closestPoint.anchorPoint;
}
- (BOOL)isResizing {
    return (anchorPoint.adjustsY);
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragEnable) {
        return;
    }
    UITouch *touch = [touches anyObject];
    anchorPoint = [self anchorPointForTouchLocation:[touch locationInView:self]];
    touchStart = [touch locationInView:self.superview];
    // 响应代理.
    if (self.delegate && [self.delegate respondsToSelector:@selector(YJResizableSplitViewBeginEditing:)]) {
        [self.delegate YJResizableSplitViewBeginEditing:self];
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // 响应代理.
    if (self.delegate && [self.delegate respondsToSelector:@selector(YJResizableSplitViewDidEndEditing:)]) {
        [self.delegate YJResizableSplitViewDidEndEditing:self];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // 响应代理.
    if (self.delegate && [self.delegate respondsToSelector:@selector(YJResizableSplitViewDidEndEditing:)]) {
        [self.delegate YJResizableSplitViewDidEndEditing:self];
    }
}
- (void)resizeUsingTouchLocation:(CGPoint)touchPoint {
    //    CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width;
    //    CGFloat ScreenHeight = [UIScreen mainScreen].bounds.size.height;
    // (1) 更新坐标且判断是否超过规定的最高或最低Y值.
    if (touchPoint.y <= _topDistance) {
        touchPoint.y = _topDistance;
        return;
    }
    if (touchPoint.y >= YJRS_ScreenHeight - _bottomDistance) {
        touchPoint.y = YJRS_ScreenHeight - _bottomDistance;
        return;
    }
    
    // (2) 使用当前的锚点计算增量.
    CGFloat deltaH = anchorPoint.adjustsH * (touchPoint.y - touchStart.y);
    CGFloat deltaY = anchorPoint.adjustsY * (-1.0 * deltaH);
    
    // (3) 计算新的Frame.
    CGFloat newY = self.frame.origin.y + deltaY;
    CGFloat newHeight = self.frame.size.height + deltaH;
    
    self.frame = CGRectMake(0, newY, self.frame.size.width, newHeight);
    
    touchStart = touchPoint;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragEnable) {
        return;
    }
    if ([self isResizing]) {
        [self resizeUsingTouchLocation:[[touches anyObject] locationInView:self.superview]];
        // 响应代理.
        if (self.delegate && [self.delegate respondsToSelector:@selector(YJResizableSplitViewDidBeginEditing:)]) {
            [self.delegate YJResizableSplitViewDidBeginEditing:self];
        }
    }
}
#pragma mark Getter&Setter
- (UIImageView *)dragImgView{
    if (!_dragImgView) {
        _dragImgView = [[ UIImageView alloc] initWithImage:[UIImage yj_rsImageNamed:@"yj_split"]];
    }
    return _dragImgView;
}
- (UIView *)dragView{
    if (!_dragView) {
        _dragView = [UIView new];
    }
    return _dragView;
}
- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [UIView new];
    }
    return _contentView;
}
@end
