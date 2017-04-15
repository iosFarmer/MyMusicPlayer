//
//  MyProgressView.m
//  MyMusicPlayer
//
//  Created by panyanb on 2017/3/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "MyProgressView.h"


#define kPlayProgressBarHeight 1

@interface MyProgressView()

@property (nonatomic,strong) UIView *sldierView;

@property (nonatomic,strong) UIView *bufferView;

@property (nonatomic,strong) UIView *progressView;

@property (nonatomic,strong) UIButton *progressButton;

@property (nonatomic,assign) CGPoint lastPoint;

@end


@implementation MyProgressView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _maximumValue = 1.0;
        _minimumValue = 0.0;
        
        
        CGFloat progressY = ( self.frame.size.height - kPlayProgressBarHeight ) * 0.5;
        // 滑动条背景
        _sldierView = [[UIView alloc] initWithFrame:CGRectMake(0, progressY, self.frame.size.width, kPlayProgressBarHeight)];
        _sldierView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_sldierView];
        // 缓冲进度条
        _bufferView = [[UIView alloc] initWithFrame:CGRectMake(0, progressY, 0, kPlayProgressBarHeight)];
        _bufferView.backgroundColor = [UIColor redColor];
        [self addSubview:_bufferView];
        // 进度条
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, progressY, 0, kPlayProgressBarHeight)];
        _progressView.backgroundColor = [UIColor orangeColor];
        [self addSubview:_progressView];
        // 滑动按钮
        _progressButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _progressButton.backgroundColor = [UIColor blueColor];
        [self addSubview:_progressButton];
        _progressButton.frame = CGRectMake(0, progressY, 15, 15);
        _progressButton.layer.cornerRadius = _progressButton.frame.size.height * 0.5;
        _progressButton.layer.masksToBounds = YES;
        
        CGPoint center = _progressButton.center;
        center.y = _progressView.frame.origin.y;
        _progressButton.center = center;
        _lastPoint = _progressButton.center;
        [_progressButton addTarget:self action:@selector(beiginSliderDragging:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_progressButton addTarget:self action:@selector(endSliderDragging:withEvent:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_progressButton addTarget:self action:@selector(sliderDragging:withEvent:) forControlEvents:UIControlEventTouchDragInside];
        
    }
    return self;
}

#pragma mark UIButton action method

-(void)beiginSliderDragging:(UIButton *)button withEvent:(UIEvent *)event
{
    CGPoint location = [[[event allTouches] anyObject] locationInView:self];
    CGFloat x = (_maximumValue - _minimumValue) * (location.x / _sldierView.frame.size.width);
//    [self setValue:x];
    if (self.delegate && [self.delegate respondsToSelector:@selector(beginSliderDragging:)]) {
        [self.delegate beginSliderDragging:x];
    }
    
}

-(void)endSliderDragging:(UIButton *)button withEvent:(UIEvent *)event
{
    CGPoint location = [[[event allTouches] anyObject] locationInView:self];
    CGFloat x = (_maximumValue - _minimumValue) * (location.x / _sldierView.frame.size.width);
//    [self setValue:x];
    if (self.delegate && [self.delegate respondsToSelector:@selector(endSliderDragging:)]) {
        [self.delegate endSliderDragging:x];
    }
}

-(void)sliderDragging:(UIButton *)button withEvent:(UIEvent *)event
{
    CGPoint location = [[[event allTouches] anyObject] locationInView:self];
    CGFloat offsetX = location.x - _lastPoint.x;
    CGPoint tempPoint = CGPointMake(button.center.x + offsetX, button.center.y);
    
    CGFloat x = (_maximumValue - _minimumValue) * ((tempPoint.x -  _sldierView.frame.origin.x) / _sldierView.frame.size.width);
    [self setValue:x];
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderValueChange:)]) {
        [self.delegate sliderValueChange:x];
    }
    
}


/**
 当前进度

 @param value 进度值
 */
-(void)setValue:(CGFloat)value
{
    CGFloat processValue = _sldierView.frame.size.width * value;
    CGPoint point = _progressButton.center;
    point.x = _sldierView.frame.origin.x + processValue;
    
    if (point.x > _sldierView.frame.origin.x && point.x < self.frame.size.width) {
        _progressButton.center = point;
        _lastPoint = point;
        
        CGRect tempRect = _progressView.frame;
        tempRect.size.width = point.x;
        _progressView.frame = tempRect;
        
    }
    
}

/**
 缓冲进度

 @param progress 缓冲值
 */
-(void)setProgress:(CGFloat)progress
{
    
    CGFloat bufferValue = _sldierView.frame.size.width * progress;
    CGRect tempRect = _bufferView.frame;
    tempRect.size.width = bufferValue;
    _bufferView.frame = tempRect;
    
}
#pragma mark setter method

-(void)setMaximumValue:(CGFloat)maximumValue
{
    _maximumValue = maximumValue;
}

-(void)setMinimumValue:(CGFloat)minimumValue
{
    _minimumValue = minimumValue;
}

-(void)setBufferBackgoundColor:(UIColor *)bufferBackgoundColor
{
    if (_bufferBackgoundColor  != bufferBackgoundColor) {
        _bufferView.backgroundColor = bufferBackgoundColor;
    }
}

-(void)setSliderBackgroundColor:(UIColor *)sliderBackgroundColor
{
    if (_sliderBackgroundColor != sliderBackgroundColor) {
        _sldierView.backgroundColor = sliderBackgroundColor;
    }
}

-(void)setProgressBackgoundColor:(UIColor *)progressBackgoundColor
{
    if (_progressBackgoundColor != progressBackgoundColor) {
        _progressView.backgroundColor = progressBackgoundColor;
    }
}



@end
