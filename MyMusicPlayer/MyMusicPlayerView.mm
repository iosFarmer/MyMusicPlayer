//
//  MyMusicPlayerView.m
//  MyMusicPlayer
//
//  Created by panyanb on 2017/4/9.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "MyMusicPlayerView.h"
#import "MyMusicSlider.h"
#import "MyMusicSlider+UITapGesture.h"
#import "MyMusicPlayerEngine.h"
#import <AVFoundation/AVFoundation.h>
#import "AVFoundation/AVAudioPlayer.h"
#import "AVFoundation/AVAudioSession.h"
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSInteger, ControlPanelButtonType){
    ControlPanelButtonPrevious = 100,
    ControlPanelButtonNext,
};
@interface MyMusicPlayerView()<MyMusicPlayerEngineDelegate>
@property (nonatomic,strong) MyMusicSlider *slider;
@property (nonatomic,strong) UILabel *currentTimeLab;
@property (nonatomic,strong) UILabel *totoaTimeLab;
@property (nonatomic,strong) UIButton *playButton;
@property (nonatomic,strong) UIImageView *loadingView;
@property (nonatomic,assign) CGFloat viewHeight;
@property (nonatomic,strong) UIView *playerVideoView;
@property (nonatomic,strong) UIView *controllerView;
@property (nonatomic,strong) UIButton *topBackbtn;
@end

@implementation MyMusicPlayerView
{
    BOOL m_isVideo;
}
-(instancetype)initWithFrame:(CGRect)frame isVideo:(BOOL)isVideo
{
    self = [super initWithFrame:frame];
    if (self) {
        m_isVideo = isVideo;
        if (!isVideo) {
            [self initListenView];
            self.backgroundColor = [UIColor clearColor];
        }
        else{
            
            [self initVideoView];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithUTF8String:APPLICATION_WILL_ENTER_BACKGROUND] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:)
                                                     name:[NSString stringWithUTF8String:APPLICATION_WILL_ENTER_BACKGROUND] object:nil];
    }
    return self;
}

/**
 初始化音乐播放界面
 */
-(void)initListenView
{
    CGFloat originY = 0;
    CGFloat originX = 20;
    UIView *playerView = [[UIView alloc] initWithFrame:CGRectMake(0, originY, self.frame.size.width, self.frame.size.height)];
    playerView.backgroundColor = [UIColor clearColor];
    [self addSubview:playerView];
    
    originY +=10;
    //当前播放标题
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0,originY,self.frame.size.width,20)];
    
    titleLab.textColor = [UIColor colorWithRed:0xc2/255.0 green:0xc2/255.0 blue:0xc2/255.0 alpha:1.0];
    titleLab.font = [UIFont systemFontOfSize:15];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = @"一丝不挂";
    [playerView addSubview:titleLab];
    self.musicTitle = titleLab;
    //播放进度条
    originY += titleLab.frame.size.height + 10;
    
    self.slider = [[MyMusicSlider alloc] initWithFrame:CGRectMake(originX, originY,self.frame.size.width - 2 * originX, 15) bshowProgress:YES];
    
    self.slider.minimumValue = 0.00f;
    self.slider.maximumValue = 1.00f;
    self.slider.value = 0.0;
    [self.slider addTapGestureWithTarget:self action:@selector(tapSliderToSeekTime:)];
    [self.slider addTarget:self action:@selector(playerSliderUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [self.slider addTarget:self action:@selector(playerSliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(playerSliderDown:) forControlEvents:UIControlEventTouchDown];
    
    [playerView addSubview:self.slider];
    
    originY += self.slider.frame.size.height + 10;
    //当前播放时间
    
    UILabel *currentTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, 40 , 20)];
    currentTimeLab.text = @"00:00";
    currentTimeLab.textColor = [UIColor colorWithRed:0xc2/255.0 green:0xc2/255.0 blue:0xc2/255.0 alpha:1.0];
    currentTimeLab.font = [UIFont systemFontOfSize:12];
    currentTimeLab.textAlignment = NSTextAlignmentLeft;
    [playerView addSubview:currentTimeLab];
    self.currentTimeLab = currentTimeLab;
    //音频总时长
    
    UILabel *totalTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - originX - currentTimeLab.frame.size.width,originY,currentTimeLab.frame.size.width, currentTimeLab.frame.size.height)];
    totalTimeLab.text = @"00:00";
    totalTimeLab.textColor = currentTimeLab.textColor;
    totalTimeLab.font = currentTimeLab.font;
    totalTimeLab.textAlignment = NSTextAlignmentRight;
    [playerView addSubview:totalTimeLab];
    self.totoaTimeLab = totalTimeLab;
    
    originY += totalTimeLab.frame.size.height + 10;
    //暂停播放键
    UIImage *buttonImg = [UIImage imageNamed:@"Stop"];
    UIButton *startStopBtn = [[UIButton alloc] initWithFrame:CGRectMake((playerView.frame.size.width - buttonImg.size.width) * 0.5,
                                                                        originY,
                                                                        buttonImg.size.width,
                                                                        buttonImg.size.height)];
    
    [startStopBtn setImage:[UIImage imageNamed:@"Start"] forState:UIControlStateNormal];
    [startStopBtn setImage:[UIImage imageNamed:@"Stop"] forState:UIControlStateSelected];
    startStopBtn.selected = NO;
    [playerView addSubview:startStopBtn];
    [startStopBtn addTarget:self action:@selector(changePlayerState:) forControlEvents:UIControlEventTouchUpInside];
    self.playButton = startStopBtn;
    
    // 缓冲状态
    UIImageView *loadingImgView = [[UIImageView alloc] initWithFrame:startStopBtn.frame];
    loadingImgView.image = [UIImage imageNamed:@""];
    [playerView addSubview:loadingImgView];
    loadingImgView.hidden = YES;
    self.loadingView = loadingImgView;
    
    //上一章
    
    UIImage *perviousImg = [UIImage imageNamed:@"Previous"];
    CGFloat previousEdge = 30;
    CGFloat previousWidth = perviousImg.size.width - 5;
    UIButton *previousBtn = [[UIButton alloc] initWithFrame:CGRectMake(startStopBtn.frame.origin.x - previousEdge - previousWidth, startStopBtn.frame.origin.y + 15, previousWidth, previousWidth)];
    
    [previousBtn setImage:perviousImg forState:UIControlStateNormal];
    [playerView addSubview:previousBtn];
    [previousBtn addTarget:self action:@selector(controlPanelActionTypeWith:) forControlEvents:UIControlEventTouchUpInside];
    previousBtn.tag = ControlPanelButtonPrevious;
    //下一章
    
    UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(startStopBtn.frame) + previousEdge, previousBtn.frame.origin.y, previousWidth, previousWidth)];
    
    [nextBtn setImage:[UIImage imageNamed:@"Next"] forState:UIControlStateNormal];
    [playerView addSubview:nextBtn];
    [nextBtn addTarget:self action:@selector(controlPanelActionTypeWith:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.tag = ControlPanelButtonNext;
    
    originY += self.playButton.frame.size.height + 10;
    self.viewHeight = originY;
}


/**
 初始化视频播放界面
 */
-(void)initVideoView{
    
    _playerVideoView = [[UIView alloc] initWithFrame:self.bounds];
    _playerVideoView.backgroundColor = [UIColor blackColor];
    [self addSubview:_playerVideoView];
    
    _controllerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 42, self.frame.size.width, 42)];
    [self addSubview:_controllerView];
    _controllerView.alpha = 0.8f;
    _controllerView.backgroundColor = [UIColor colorWithRed:0x4c/255.0 green:0x4c/255.0 blue:0x4c/255.0 alpha:1.0];
    
    CGFloat btnWith = 35;
    CGFloat btnHeight = btnWith;
    _playButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 0.5*(_controllerView.frame.size.height - btnHeight), btnWith, btnHeight)];
    [_playButton setImage:[UIImage imageNamed:@"vide_play_back_normal"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"vide_play_back_pause"] forState:UIControlStateSelected];
    [_controllerView addSubview:_playButton];
    [_playButton addTarget:self action:@selector(changePlayerState:)
              forControlEvents:UIControlEventTouchUpInside];
    
    // 播放时长
    _currentTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(_playButton.frame.origin.x + _playButton.frame.size.width + 10, 0.5*(_controllerView.frame.size.height - 14), 60, 14)];
    _currentTimeLab.font = [UIFont systemFontOfSize:13];
    _currentTimeLab.textColor = [UIColor whiteColor];
    _currentTimeLab.text = @"00:00:00";
    [_controllerView addSubview:_currentTimeLab];
    
    CGPoint currentPlayCenter = _currentTimeLab.center;
    currentPlayCenter.y = _playButton.center.y;
    _currentTimeLab.center = currentPlayCenter;
    
    _slider = [[MyMusicSlider alloc] initWithFrame:CGRectMake(_currentTimeLab.frame.origin.x + _currentTimeLab.frame.size.width, 0.5*(_controllerView.frame.size.height - 44), self.frame.size.width - (_currentTimeLab.frame.origin.x + _currentTimeLab.frame.size.width)-70, 42)bshowProgress:YES];
    [_controllerView addSubview:_slider];
    
    self.slider.minimumValue = 0.00f;
    self.slider.maximumValue = 1.00f;
    self.slider.value = 0.0;
    [self.slider addTapGestureWithTarget:self action:@selector(tapSliderToSeekTime:)];
    [self.slider addTarget:self action:@selector(playerSliderUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [self.slider addTarget:self action:@selector(playerSliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(playerSliderDown:) forControlEvents:UIControlEventTouchDown];
    
    // 播放总时长
    _totoaTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(_slider.frame.origin.x + _slider.frame.size.width, 0.5*(_controllerView.frame.size.height - 14), 60, 14)];
    _totoaTimeLab.font = [UIFont systemFontOfSize:13];
    _totoaTimeLab.textColor = [UIColor whiteColor];
    _totoaTimeLab.text = @"00:00:00";
    [_controllerView addSubview:_totoaTimeLab];
    
    CGPoint totalPlayTimeCenter = _totoaTimeLab.center;
    totalPlayTimeCenter.y = _playButton.center.y;
    _totoaTimeLab.center = totalPlayTimeCenter;
    
}

-(void)didEnterBackground:(NSNotification *)notify
{
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    [self setBackGroundInfo];
    
}
- (void)clearBackGroundInfo
{
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}
- (void)setBackGroundInfo
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        
        [dict setObject:[NSNumber numberWithDouble:[[MyMusicPlayerEngine shareInstance] getPlayCurrentTime]] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经播放时间
        [dict setObject:[NSNumber numberWithFloat:[[MyMusicPlayerEngine shareInstance] getPlayRate]] forKey:MPNowPlayingInfoPropertyPlaybackRate];//音乐播放的状态
        [dict setObject:[NSNumber numberWithDouble:[[MyMusicPlayerEngine shareInstance] getPlayDurationTime]] forKey:MPMediaItemPropertyPlaybackDuration];//歌曲总时间设置
        if (systemVersionUp(10.0)) {
            [dict setObject:[NSNumber numberWithFloat:self.slider.value * [[MyMusicPlayerEngine shareInstance] getPlayDurationTime]] forKey:MPNowPlayingInfoPropertyPlaybackProgress];
        }
            
        // 标题
        [dict setObject:self.musicTitle.text forKey:MPMediaItemPropertyTitle];
        // 章节名
        [dict setObject:@"Eason-陈奕迅" forKey:MPMediaItemPropertyAlbumTitle];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        
    }
}

-(CGFloat)getViewHeight
{
    return self.viewHeight;
}


- (void)initPlayBg{
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:nil];//禁止其他应用程序
    
    if(!systemVersionUp(6.0)){
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    else{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionDuckOthers|AVAudioSessionCategoryOptionDefaultToSpeaker|AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    }
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

-(void)initWithEnginePlayer
{
    [self initPlayBg];
    
    [MyMusicPlayerEngine shareInstance].delegate = self;
    
}

-(void)reloadEnginePlayerWithPathFile:(NSString *)filepath isVideo:(BOOL)isVideo
{
    if (!isVideo) {
        
        [[MyMusicPlayerEngine shareInstance] playMusicWithPath:filepath isVideo:isVideo onView:nil];
    }
    else{
        
        [[MyMusicPlayerEngine shareInstance] playMusicWithPath:filepath isVideo:isVideo onView:_playerVideoView];
    }
}
#pragma mark Action Method
- (void)controlPanelActionTypeWith:(UIButton *)button{
    switch (button.tag) {
        case ControlPanelButtonPrevious:
            NSLog(@"上一章");
            
            break;
        case ControlPanelButtonNext:
            NSLog(@"下一章");
            
            break;
        
        default:
            break;
    }
}
- (void)changePlayerState:(UIButton *)btn{
    
    btn.selected = !btn.selected;
    if (btn.selected) {
        NSLog(@"开始播放");
        
        [[MyMusicPlayerEngine shareInstance] resume];
        
    }else{
        NSLog(@"暂停播放");
        [[MyMusicPlayerEngine shareInstance] stop];
    }
}

#pragma mark MyMusicSlider method
-(void)tapSliderToSeekTime:(MyMusicSlider *)slider
{
    CGFloat durationTime = [[MyMusicPlayerEngine shareInstance] getPlayDurationTime];
    CGFloat currentTime = slider.value * durationTime;
    
    [[MyMusicPlayerEngine shareInstance] playAtTime:currentTime];
}


- (void)playerSliderDown:(UISlider*)slider
{
    
    [[MyMusicPlayerEngine shareInstance] pause];
    self.playButton.selected = NO;
    
}

- (void)playerSliderUp:(UISlider*)slider
{
    CGFloat durationTime = [[MyMusicPlayerEngine shareInstance] getPlayDurationTime];
    CGFloat currentTime = slider.value * durationTime;
    self.playButton.selected = YES;
    [[MyMusicPlayerEngine shareInstance] playAtTime:currentTime];
    
}

- (void)playerSliderChange:(UISlider*)slider
{
    CGFloat durationTime = [[MyMusicPlayerEngine shareInstance] getPlayDurationTime];
    CGFloat currentTime = slider.value * durationTime;
    self.currentTimeLab.text = [self formatterTime:currentTime];
}
- (NSString*)formatterTime:(CGFloat)seconds
{
    int s = (int)seconds % 60;
    int m = (int)(seconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", m, s];
}
#pragma mark MyMusicPlayerEngineDelegate method
- (void)engine:(NSObject *)player didChangeEngineStatus:(EnginePlayerStatus)EngineStaus
{
    switch (EngineStaus) {
        case EnginePlayerStatusStopped:
            self.playButton.selected = NO;
            break;
        case EnginePlayerStatusPlaying:
            self.playButton.selected = YES;
            break;
        case EnginePlayerStatusPaused:
            self.playButton.selected = NO;
            break;
        case EnginePlayerStatusEnded:
            self.playButton.selected = NO;
            break;
        case EnginePlayerStatusError:
            self.playButton.selected = NO;
            break;
        case EnginePlayerStatusUnknowns:
            self.playButton.selected = NO;
            break;
        default:
            break;
    }
}

- (void)engine:(NSObject *)player bufferProgress:(CGFloat)progress isCanPlay:(BOOL)isCanPlay
{
    self.slider.progress = progress;
}

- (void)engine:(NSObject *)player playerCurrentTime:(NSTimeInterval)current durationTime:(NSTimeInterval)durationTime
{
    self.currentTimeLab.text = [self formatterTime:current];
    self.totoaTimeLab.text = [self formatterTime:durationTime];
    self.slider.value = current / durationTime;
}

- (void)engine:(NSObject *)player didFinishedSuccessfully:(BOOL)isSuccessfully
{
    NSLog(@"player finished and request next music");
}

- (void)engine:(NSObject *)player didPlayMusicFailed:(NSError *)error
{
    NSLog(@"didPlayMusicFailed %@",error);
}
-(void)closeEnginePlayer
{
    [[MyMusicPlayerEngine shareInstance] closeEnginePlayer];
}
-(void)dealloc
{
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self clearBackGroundInfo];
//    [self closeEnginePlayer];
}
#pragma mark remoteControl
-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        UIEventSubtype subtype = event.subtype;
        switch (subtype) {
            case UIEventSubtypeRemoteControlPlay:
                
                [[MyMusicPlayerEngine shareInstance] resume];
                break;
            case UIEventSubtypeRemoteControlPause:
                
                [[MyMusicPlayerEngine shareInstance] pause];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"下一首");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"上一首");
                break;
            default:
                break;
        }
    }
    
}
@end
