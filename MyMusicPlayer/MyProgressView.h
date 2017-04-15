//
//  MyProgressView.h
//  MyMusicPlayer
//
//  Created by panyanb on 2017/3/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyProgressViewDelegate <NSObject>

-(void)beginSliderDragging:(CGFloat)progress;

-(void)sliderValueChange:(CGFloat)progress;

-(void)endSliderDragging:(CGFloat)progress;

@end

@interface MyProgressView : UIView

@property (nonatomic,weak) id<MyProgressViewDelegate> delegate;
/* 
 最小值
 */
@property (nonatomic, assign, readonly) CGFloat minimumValue;

/**
 最大值
 */
@property (nonatomic, assign, readonly) CGFloat maximumValue;

/**
 滑动条值
 */
@property (nonatomic, assign) CGFloat value;

/**
 滑动条进度
 */
@property (nonatomic, assign) CGFloat progress;

/**
 进度条底色
 */
@property (nonatomic, strong) UIColor *sliderBackgroundColor;

/**
 缓冲进度背景色
 */
@property (nonatomic, strong) UIColor *bufferBackgoundColor;

/**
 播放进度背景色
 */
@property (nonatomic, strong) UIColor *progressBackgoundColor;

@end
