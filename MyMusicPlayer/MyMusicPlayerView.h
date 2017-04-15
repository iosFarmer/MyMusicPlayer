//
//  MyMusicPlayerView.h
//  MyMusicPlayer
//
//  Created by panyanb on 2017/4/9.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMusicPlayerView : UIView

-(instancetype)initWithFrame:(CGRect)frame isVideo:(BOOL)isVideo;

@property (nonatomic,strong) UILabel *musicTitle;

-(void)initWithEnginePlayer;


/**
 加载资源

 @param filepath 资源路径
 @param isVideo 是否是视频
 */
-(void)reloadEnginePlayerWithPathFile:(NSString *)filepath isVideo:(BOOL)isVideo;

-(CGFloat)getViewHeight;

-(void)closeEnginePlayer;
@end
