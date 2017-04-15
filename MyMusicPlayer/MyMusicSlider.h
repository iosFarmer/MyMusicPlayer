//
//  MyMusicSlider.h
//  MyMusicPlayer
//
//  Created by panyanb on 2017/4/9.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMusicSlider : UISlider

-(instancetype)initWithFrame:(CGRect)rect bshowProgress:(BOOL)bshowProgress;

@property (nonatomic,assign) CGFloat progress;

@end
