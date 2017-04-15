//
//  MyMusicPlayerProgress.m
//  MyMusicPlayer
//
//  Created by panyanb on 2017/4/9.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "MyMusicPlayerProgress.h"

@interface MyMusicPlayerProgress()

@property (nonatomic,strong) UIImageView *trackImageView;
@property (nonatomic,strong) UIImageView *progressImageView;

@end

@implementation MyMusicPlayerProgress

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self resetProgressView];
    }
    return self;
}
-(void)setProgress:(float)progress
{
    [super setProgress:progress];
    [self setNeedsDisplay];
}

-(void)setTrackImage:(UIImage *)trackImage
{
    [super setTrackImage:trackImage];
    self.trackImageView.image = trackImage;
}

-(void)setProgressImage:(UIImage *)progressImage
{
    [super setProgressImage:progressImage];
    self.progressImageView.image = progressImage;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.trackImageView || !self.progressImageView) {
        return;
    }
    UIImage *trackImage = self.trackImage;
    if (self.trackImageView.image) {
        CGRect trackFrame = self.trackImageView.frame;
        CGFloat trackHeight = CGRectGetHeight(self.bounds) > trackImage.size.height ? trackImage.size.height : CGRectGetHeight(self.bounds);
        
        self.trackImageView.frame = CGRectMake(CGRectGetMinX(trackFrame),
                                               CGRectGetMidY(self.bounds) + (CGRectGetHeight(self.bounds) - trackHeight)* 0.5,
                                               CGRectGetWidth(self.bounds),
                                               trackHeight);
    }
    UIImage *progressImage = self.progressImage;
    if (self.progressImageView.image) {
        CGRect progressFrame = self.progressImageView.frame;
        CGFloat progressHeight = CGRectGetHeight(self.bounds) > progressImage.size.height ? progressImage.size.height : CGRectGetHeight(self.bounds);
        self.progressImageView.frame = CGRectMake(CGRectGetMinX(progressFrame),
                                                  CGRectGetMidY(self.bounds) + (CGRectGetHeight(self.bounds) - progressHeight)* 0.5,
                                                  CGRectGetWidth(self.bounds)* self.progress,
                                                  progressHeight);
    }
}

-(void)resetProgressView
{
    NSArray *subviews = self.subviews;
    if (subviews.count != 2) return;
    for (UIView *view in subviews) {
        if (![view isKindOfClass:[UIImageView class]]) {
            return;
        }
    }
    self.trackImageView = subviews[0];
    self.progressImageView = subviews[1];
    
    self.trackImageView.image = self.trackImage;
    self.progressImageView.image = self.progressImage;
}





@end
