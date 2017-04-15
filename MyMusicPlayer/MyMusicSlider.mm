//
//  MyMusicSlider.m
//  MyMusicPlayer
//
//  Created by panyanb on 2017/4/9.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "MyMusicSlider.h"
#import "MyMusicPlayerProgress.h"


#define sliderSize CGSizeMake(self.frame.size.width, 1.0)

@interface MyMusicSlider()
@property (nonatomic,strong) MyMusicPlayerProgress *progressView;
@end

@implementation MyMusicSlider
{
    BOOL _bshowProgress;
}
-(instancetype)initWithFrame:(CGRect)rect bshowProgress:(BOOL)bshowProgress
{
    self = [super initWithFrame:rect];
    if (self) {
        [self resetUISliderImage];
        _bshowProgress = bshowProgress;
        if (bshowProgress) {
            [self addBufferProgressView];
        }
    }
    return self;
}

-(void)resetUISliderImage
{
    
    UIImage *thumb = getRadiusImageWithColor([UIColor colorWithRed:0x6e/255.0 green:0xaa/255.0 blue:0xfe/255.0 alpha:1.0], CGSizeMake(15, 15));
    UIImage *maxTrack = getImageWithColor([UIColor colorWithRed:0x99/255.0 green:0x9d/255.0 blue:0xa8/255.0 alpha:1.0],sliderSize);
    UIImage *miniTrack = getImageWithColor([UIColor colorWithRed:0x6e/255.0 green:0xaa/255.0 blue:0xfe/255.0 alpha:1.0],sliderSize);
    
    [self setThumbImage:thumb forState:UIControlStateNormal];
    
    [self setMaximumTrackImage:maxTrack forState:UIControlStateNormal];
    
    [self setMinimumTrackImage:miniTrack forState:UIControlStateNormal];
    
    
}
// 缓冲图片
-(void)addBufferProgressView
{
    UIImage *maxImg = [self maximumTrackImageForState:UIControlStateNormal];
    CGRect rect = self.bounds;
    rect.size.height = maxImg.size.height;
    rect.origin.x -= 1;
    rect.origin.y = (self.bounds.size.height - rect.size.height -1.5 ) * 0.5;
    rect.size.width -= 1 * 2;
    UIImage *progressImg = getImageWithColor([UIColor colorWithRed:0xc9/255.0 green:0xdf/255.0 blue:0xfe/255.0 alpha:1.0], maxImg.size);
    UIImage *maxTrackImg = getImageWithColor([UIColor colorWithRed:0x99/255.0 green:0x9d/255.0 blue:0xa8/255.0 alpha:1.0],maxImg.size);
    MyMusicPlayerProgress *progressView = [[MyMusicPlayerProgress alloc] initWithFrame:rect];
    [self addSubview:progressView];
    [self sendSubviewToBack:progressView];
    progressView.progressViewStyle = UIProgressViewStyleDefault;
    [progressView setProgressImage:progressImg];
    [progressView setTrackImage:maxTrackImg];
    progressView.progress = _progress;
    _progressView = progressView;
    // 将原先的slider背景色隐藏起来
    [self setMaximumTrackImage:getImageWithColor([UIColor clearColor],maxImg.size) forState:UIControlStateNormal];
}

-(void)setProgress:(CGFloat)progress
{
    if (_bshowProgress && _progressView) {
        _progressView.progress = progress;
    }
}

@end
