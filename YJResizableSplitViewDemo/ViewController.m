//
//  ViewController.m
//  YJResizableSplitViewDemo
//
//  Created by 刘亚军 on 2019/1/11.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "ViewController.h"
#import "YJResizableSplitView.h"

#import <Masonry/Masonry.h>

@interface ViewController ()<YJResizableSplitViewDelegate>
@property (nonatomic,strong) YJResizableSplitView *splitView;
@property (nonatomic,strong) UITextView *topTextView;
@property (nonatomic,strong) UITextView *botTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.view addSubview:self.topTextView];
    [self.topTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.left.top.equalTo(self.view);
        make.height.mas_equalTo(200);
    }];
    [self.view addSubview:self.splitView];
    [self.splitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.topTextView.mas_bottom);
    }];
    [self.splitView.contentView addSubview:self.botTextView];
    [self.botTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.splitView.contentView);
    }];
}

#pragma mark YJResizableSplitViewDelegate
- (void)YJResizableSplitViewDidBeginEditing:(YJResizableSplitView *)resizableSplitView{
    CGFloat height = self.view.frame.size.height - CGRectGetHeight(resizableSplitView.frame);
    [self.topTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}
- (UITextView *)topTextView{
    if (!_topTextView) {
        _topTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _topTextView.font = [UIFont systemFontOfSize:17];
        _topTextView.textColor = [UIColor redColor];
        _topTextView.editable = NO;
        _topTextView.selectable = NO;
        _topTextView.text = @"As a student ,i like idioms very much ,and i've learned some of them.What's more ,i think it's very useful to learn some.For example ,\"be in the air\"is one of these idioms ,which means \"something will happen in the future\" .Whatching English movies is a good way to learn idioms.And when you have learned some idioms ,it will help you to understand English better";
    }
    return _topTextView;
}
- (UITextView *)botTextView{
    if (!_botTextView) {
        _botTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _botTextView.font = [UIFont systemFontOfSize:17];
        _botTextView.editable = NO;
        _botTextView.selectable = NO;
        _botTextView.text = @"My new year’s resolutions I have many resolutions in this year.First I am going to study harder in school this year.I want to beat Tom.Next I am going to play sports everyday.Then ,I am going to be writer.Next I am going to communicate better whit my classmates.I am going to eat more vegetable.Finally I am going to learn a new language.English sounds like a lauguage what I conld enjoy";
    }
    return _botTextView;
}
- (YJResizableSplitView *)splitView{
    if (!_splitView) {
        _splitView = [[YJResizableSplitView alloc] initWithFrame:CGRectZero];
        _splitView.delegate = self;
        _splitView.topDistance = 44;
        _splitView.bottomDistance = 88 + 64;
    }
    return _splitView;
}

@end
