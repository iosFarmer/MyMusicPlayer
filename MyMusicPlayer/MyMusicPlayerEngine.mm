//
//  MyMusicPlayerEngine.m
//  MyMusicPlayer
//
//  Created by panyanb on 2017/4/8.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "MyMusicPlayerEngine.h"

#define kNCMusicEngineCacheFolderName @"com.nickcheng.NCMusicEngine"
#define kNCMusicEngineCheckMusicInterval 0.1f // Seconds
#define kNCMusicEngineSizeBuffer 100000.0f // Bytes
#define kNCMusicEnginePauseMargin 1.0f  // Seconds
#define kNCMusicEnginePlayMargin 5.0f // Seconds
#define KCurrentTimeRecoder @"CurrentTimeRecoder"
#pragma mark MyMusicPlayerEngine
@interface MyMusicPlayerEngine()<MyMusicPlayerAVPlayerDelegate,MyMusicPlayerAudioSessionDelegate>

@property (nonatomic,strong) MyMusicPlayerAVPlayer *AVPlayer;
@property (nonatomic,strong) MyMusicPlayerAudioSession *SessonPlayer;
@end

@implementation MyMusicPlayerEngine

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc ] init];
    });
    return instance;
}
#pragma mark lazy load method
//-(MyMusicPlayerAudioSession *)SessonPlayer{
//    if (!_SessonPlayer) {
//        _SessonPlayer = [[MyMusicPlayerAudioSession alloc] init];
//    }
//    return _SessonPlayer;
//}
//-(MyMusicPlayerAVPlayer *)AVPlayer{
//    if (!_AVPlayer) {
//        _AVPlayer = [[MyMusicPlayerAVPlayer alloc] init];
//    }
//    return _AVPlayer;
//}

-(void)playMusicWithPath:(NSString *)filepath isVideo:(BOOL)isVideo onView:(UIView *)view
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        if (!isVideo) {// 在线音乐播放
            if (self.SessonPlayer) {
                [self.SessonPlayer stop];
                self.SessonPlayer = nil;
            }
            if (!self.AVPlayer)
            {
                self.AVPlayer = [[MyMusicPlayerAVPlayer alloc] init];
            }
            self.AVPlayer.delegate = self;
            [self.AVPlayer voicePalyerWith:filepath isVideo:isVideo onView:nil];
        }
        else{// 在线视频播放
            if (self.SessonPlayer) {
                [self.SessonPlayer stop];
                self.SessonPlayer = nil;
            }
            if (!self.AVPlayer)
            {
                self.AVPlayer = [[MyMusicPlayerAVPlayer alloc] init];
            }
            self.AVPlayer.delegate = self;
            [self.AVPlayer voicePalyerWith:filepath isVideo:isVideo onView:view];
        }
    }
    else{
        if (!isVideo) {// 本地音乐播放
            if (self.AVPlayer) {
                [self.AVPlayer pause];
                self.AVPlayer = nil;
            }
            if (!self.SessonPlayer) {
                self.SessonPlayer = [[MyMusicPlayerAudioSession alloc] init];
                
            }
            self.SessonPlayer.delegate = self;
            [self.SessonPlayer playWithFilePath:filepath];
        }
        else{// 本地视频
            if (self.SessonPlayer) {
                [self.SessonPlayer stop];
                self.SessonPlayer = nil;
            }
            if (!self.AVPlayer)
            {
                self.AVPlayer = [[MyMusicPlayerAVPlayer alloc] init];
                
            }
            self.AVPlayer.delegate = self;
            [self.AVPlayer voicePalyerWith:filepath isVideo:isVideo onView:view];
        }
    }
    
}


- (void)pause
{
    if (self.AVPlayer) {
        [self.AVPlayer pause];
    }
    if (self.SessonPlayer) {
        [self.SessonPlayer pause];
    }
}

- (void)resume
{
    if (self.AVPlayer) {
        [self.AVPlayer play];
    }
    if (self.SessonPlayer) {
        [self.SessonPlayer resume];
    }
}

- (void)stop
{
    if (self.AVPlayer) {
        [self.AVPlayer pause];
    }
    if (self.SessonPlayer) {
        [self.SessonPlayer stop];
    }
}

- (void)playAtTime:(NSTimeInterval)time
{
    if (self.AVPlayer) {
        [self.AVPlayer seekToTime:time];
    }
    if (self.SessonPlayer) {
        [self.SessonPlayer playAtTime:time];
    }
}

- (NSTimeInterval)getPlayDurationTime
{
    if (self.AVPlayer) {
        return  [self.AVPlayer getAVPlayerDurationTime];
    }
    else{
        return [self.SessonPlayer getPlayDurationTime];
    }
}

- (NSTimeInterval)getPlayCurrentTime
{
    if (self.AVPlayer) {
        return  [self.AVPlayer getAvPlayerCurrentTime];
    }
    else{
        return [self.SessonPlayer getPlayCurrentTime];
    }
}

- (float)getPlayRate
{
    if (self.AVPlayer) {
        return  [self.AVPlayer getAvPlayerRate];
    }
    else{
        return [self.SessonPlayer getPlayRate];
    }
}

- (void)closeEnginePlayer
{
    if (self.AVPlayer) {
        [self.AVPlayer closeAVPlayer];
    }
    else{
        [self.SessonPlayer closeAudioPlayer];
    }
}
#pragma mark MyMusicPlayerAVPlayerDelegate method
- (void)avplayer:(MyMusicPlayerAVPlayer *)avplayer updateBufferProgress:(NSTimeInterval)progress isCanPlay:(BOOL)isCanPlay{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:bufferProgress:isCanPlay:)]) {
        [self.delegate engine:avplayer bufferProgress:progress isCanPlay:isCanPlay];
    }
}

- (void)avplayer:(MyMusicPlayerAVPlayer *)avplayer updatePlayerTime:(NSTimeInterval)time DurationTime:(NSTimeInterval)duration{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:playerCurrentTime:durationTime:)]) {
        [self.delegate engine:avplayer playerCurrentTime:time durationTime:duration];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:time] forKey:KCurrentTimeRecoder];
    }
}

- (void)avplayer:(MyMusicPlayerAVPlayer *)avplayer avPlayerDidFinished:(BOOL)isSuccessfully{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:didFinishedSuccessfully:)]) {
        [self.delegate engine:avplayer didFinishedSuccessfully:isSuccessfully];
    }
}

- (void)avplayer:(MyMusicPlayerAVPlayer *)avplayer avPlayerDidError:(NSError *)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:didPlayMusicFailed:)]) {
        [self.delegate engine:avplayer didPlayMusicFailed:error];
    }
}

- (void)avplayer:(MyMusicPlayerAVPlayer *)avplayer avPlayerStatusChange:(MyAVPlayerStatus)playerStatus{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:didChangeEngineStatus:)]) {
        [self.delegate engine:avplayer didChangeEngineStatus:(EnginePlayerStatus)playerStatus];
    }
}

#pragma mark MyMusicPlayerAudioSessionDelegate method
- (void)engine:(MyMusicPlayerAudioSession *)engine didChangePlayState:(MyAudioSessionState)playState;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:didChangeEngineStatus:)]) {
        [self.delegate engine:engine didChangeEngineStatus:(EnginePlayerStatus)playState];
    }
}
- (void)engine:(MyMusicPlayerAudioSession *)engine downloadProgress:(CGFloat)progress
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:bufferProgress:isCanPlay:)]) {
        [self.delegate engine:engine bufferProgress:progress isCanPlay:YES];
    }
}
- (void)engine:(MyMusicPlayerAudioSession *)engine playCurrentTime:(NSTimeInterval)currentTime playDuration:(NSTimeInterval)duration
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:playerCurrentTime:durationTime:)]) {
        [self.delegate engine:engine playerCurrentTime:currentTime durationTime:duration];
    }
}
- (void)engineDidFinishPlaying:(MyMusicPlayerAudioSession *)engine successfully:(BOOL)flag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:didFinishedSuccessfully:)]) {
        [self.delegate engine:engine didFinishedSuccessfully:flag];
    }
}

- (void)engine:(MyMusicPlayerAudioSession *)engine playFail:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:didPlayMusicFailed:)]) {
        [self.delegate engine:engine didPlayMusicFailed:error];
    }
}
#pragma mark Engine dealloc
-(void)dealloc
{
    NSLog(@"-----%@-----%@",self.SessonPlayer,self.AVPlayer);
}
@end
#pragma mark MyMusicPlayerAudioSession
@interface MyMusicPlayerAudioSession () <AVAudioPlayerDelegate>

@property (nonatomic, assign, readwrite) MyAudioSessionState playState;
@property (nonatomic, strong, readwrite) NSError *error;
@property (nonatomic, strong) AVAudioPlayer *player;

- (void)playLocalFile;
@end

@implementation MyMusicPlayerAudioSession
{
    NSString *_localFilePath;
    NSTimer *_playCheckingTimer;
}
- (id)init {
    return [self initWithSetBackgroundPlaying:YES];
}

- (id)initWithSetBackgroundPlaying:(BOOL)setBGPlay {
    //
    self = [super init];
    if(self){
        
        if (setBGPlay) {
            [[AVAudioSession sharedInstance] setActive: YES error: nil];
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        }
    }
    return self;
}
- (void)playWithFilePath:(NSString *)filePath{
    
    self.playState = AudioSessionStateStopped;
    
    _localFilePath = filePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(engine:downloadProgress:)]) {
            [self.delegate engine:self downloadProgress:1.0];
        }
        
        [self playLocalFile];
    }
}

- (void)playLocalFile
{
    
    if (!self.player) {
        NSURL *musicUrl = [[NSURL alloc] initFileURLWithPath:_localFilePath isDirectory:NO];
        NSError *error = nil;
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:musicUrl error:&error];
        self.player.delegate = self;
        if (error) {
            NSLog(@"[NCMusicEngine] AVAudioPlayer initial error: %@", error);

            self.error = error;
            self.playState = AudioSessionStateError;
        }
    }
    
    if (self.player) {
        if (!self.player.isPlaying) {
            
            if ([self.player prepareToPlay]) NSLog(@"prepareToPlay");
            if ([self.player play]) NSLog(@"play");
            
            self.playState = AudioSessionStatePlaying;
            
            [self startPlayCheckingTimer];
        }
    }
}

- (void)startPlayCheckingTimer {
    //
    if (_playCheckingTimer) {
        [_playCheckingTimer invalidate];
        _playCheckingTimer = nil;
    }
    
    _playCheckingTimer = [NSTimer scheduledTimerWithTimeInterval:kNCMusicEngineCheckMusicInterval
                                                          target:self
                                                        selector:@selector(handlePlayCheckingTimer:)
                                                        userInfo:nil
                                                         repeats:YES];
}
- (void)handlePlayCheckingTimer:(NSTimer *)timer {
    //
    NSTimeInterval playerCurrentTime = self.player.currentTime;
    NSTimeInterval playerDuration = [self getPlayDurationTime];//self.player.duration;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:playCurrentTime:playDuration:)]) {
        if (playerDuration <= 0)
            [self.delegate engine:self playCurrentTime:playerCurrentTime playDuration:playerDuration];
        else
            [self.delegate engine:self playCurrentTime:playerCurrentTime playDuration:playerDuration];
    }

    playerDuration = self.player.duration;
    if (playerDuration - playerCurrentTime < kNCMusicEnginePauseMargin ) {
        [self pause];
        
    }
}
-(void)setPlayState:(MyAudioSessionState)playState
{
    _playState = playState;
    if (self.delegate && [self.delegate respondsToSelector:@selector(engine:didChangePlayState:)]) {
        [self.delegate engine:self didChangePlayState:_playState];
    }
}
- (void)pause {
    if (self.player && self.player.isPlaying) {
        [self.player pause];
        self.playState = AudioSessionStatePaused;
        if (_playCheckingTimer) {
            [_playCheckingTimer invalidate];
            _playCheckingTimer = nil;
        }
    }
}

- (void)resume {
    if (self.player && !self.player.isPlaying) {
        [self.player play];
        self.playState = AudioSessionStatePlaying;
        [self startPlayCheckingTimer];
    }
}

- (void)stop {
    
    if (self.player) {
        [self.player stop];
        self.playState = AudioSessionStateStopped;
        if (_playCheckingTimer) {
            [_playCheckingTimer invalidate];
            _playCheckingTimer = nil;
        }
    }
}

- (void)playAtTime:(NSTimeInterval)time
{
    if (self.player) {
        [self.player prepareToPlay];
        NSTimeInterval playerDuration = self.player.duration;
        if (time < playerDuration) {
            [self.player setCurrentTime:time];
            [self resume];
        }
        
    }
}
- (void)audioPlayerDidFinishPlaying
{
    [self stop];
    self.playState = AudioSessionStateEnded;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(engineDidFinishPlaying:successfully:)]) {
        [self.delegate engineDidFinishPlaying:self successfully:YES];
    }
}
- (NSTimeInterval)getPlayDurationTime
{
    if (self.player) {
        return self.player.duration;
    }
    return 0;
}

- (float)getPlayRate
{
    if (self.player) {
        return self.player.rate;
    }
    return 0;
}
- (NSTimeInterval)getPlayCurrentTime
{
    if (self.player) {
        return self.player.currentTime;
    }
    return 0;
    
}
#pragma mark AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        [self audioPlayerDidFinishPlaying];
    }
}


/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engineBeginInterruptionPlaying:)]) {
        [self.delegate engineBeginInterruptionPlaying:self];
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    [self endInterruption];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
    [self endInterruption];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    [self endInterruption];
}

- (void)endInterruption
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(engineEndInterruptionPlaying:)]) {
        [self.delegate engineEndInterruptionPlaying:self];
    }
    
}
- (void)closeAudioPlayer
{
//    [self pause];
    [[AVAudioSession sharedInstance] setActive: NO error: nil];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    if (self.player) {
        [self.player stop];
        self.player = nil;
    }
}
#pragma mark Audio dealloc
-(void)dealloc
{
    [self closeAudioPlayer];
}
@end

#pragma mark MyMusicPlayerAVPlayer
@interface MyMusicPlayerAVPlayer()
@property (nonatomic, strong)AVPlayer *player;
@property (nonatomic, strong)AVAsset *assetPlayer;
@property (nonatomic, strong)id timeObserver;
@end

@implementation MyMusicPlayerAVPlayer
{
    
    BOOL m_isPlaying;

}
-(AVPlayer *)player
{
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}
- (void)voicePalyerWith:(NSString *)filePath isVideo:(BOOL)isVideo onView:(UIView *)view{
    
    [self currentItemPlayerRemoveObserver];
    
    if (!isVideo) {
        NSURL *soundUrl =[NSURL URLWithString:filePath];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:soundUrl];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        
    }
    else{
        
        NSURL *videoUrl;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {// 本地视频
            videoUrl = [NSURL fileURLWithPath:filePath];
        }
        else{// 网络视频
            videoUrl = [NSURL URLWithString:filePath];
        }
        self.assetPlayer = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
        AVPlayerItem *assetItem = [AVPlayerItem playerItemWithAsset:_assetPlayer];
        [self.player replaceCurrentItemWithPlayerItem:assetItem];
        AVPlayerLayer *playerLayer =[AVPlayerLayer playerLayerWithPlayer:_player];
        [playerLayer setFrame:view.bounds];
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        [view.layer addSublayer:playerLayer];
        
    }
    // 断点续播
    NSNumber *seekToTime = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:KCurrentTimeRecoder];
    NSTimeInterval timeInterval;
    if (seekToTime == nil) {
        timeInterval = 0;
    }
    else{
#pragma mark 这里不处理是因为具体还需要判断，这里只是提供一个断点续播的思路
        timeInterval = 0;
//        timeInterval = seekToTime.floatValue;
    }
    [self.player seekToTime:CMTimeMake(timeInterval, 1)];
    [self currentItemPlayerAddObserver];
    
}

-(void)seekToTime:(NSTimeInterval)sekToTime
{
    if (self.player) {
        [self.player seekToTime:CMTimeMake(sekToTime, 1)];
        [self play];
    }
}

- (void)closeAVPlayer{
    
    [self pause];
    [self currentItemPlayerRemoveObserver];
    
}

- (void)currentItemPlayerRemoveObserver{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.player removeTimeObserver:self.timeObserver];
}

- (void)currentItemPlayerAddObserver{
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew) context:nil];
    //监控缓冲加载情况属性
    [self.player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    //监控播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    //监控时间进度
    __weak typeof(self) wself = self;
    
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        if (wself.delegate && [wself.delegate respondsToSelector:@selector(avplayer:updatePlayerTime:DurationTime:)]) {
            [wself.delegate avplayer:wself updatePlayerTime:time.value / time.timescale  DurationTime:CMTimeGetSeconds(wself.player.currentItem.duration)];
        }
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    AVPlayerItem *playerItem = object;
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = (AVPlayerItemStatus)[change[@"new"] integerValue];
        switch (status) {
            case AVPlayerItemStatusReadyToPlay:
            {
                // 开始播放
                if (![change[@"new"] isEqual:change[@"old"]]) {
                    [self play];
                }
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                if (self.delegate && [self.delegate respondsToSelector:@selector(avplayer:avPlayerDidError:)]) {
                    [self.delegate avplayer:self avPlayerDidError:playerItem.error];
                }
            }
                break;
            case AVPlayerItemStatusUnknown:
            {
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(avplayer:avPlayerStatusChange:)]) {
                    [self.delegate avplayer:self avPlayerStatusChange:AVPlayerStatusUnknowns];
                }
            }
                break;
            default:
                break;
        }
    }
    else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        NSArray *array=playerItem.loadedTimeRanges;
        //本次缓冲时间范围
        CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        //缓冲总长度
        NSTimeInterval totalBuffer = startSeconds + durationSeconds;
        BOOL isCanPlay ;
        if (totalBuffer < [self getAvPlayerCurrentTime] + 10) {
            isCanPlay = NO;
        }
        else {
            isCanPlay = YES;
        }
        
        CMTime duration = playerItem.duration;
        float totalDuration = CMTimeGetSeconds(duration);
        if (self.delegate && [self.delegate respondsToSelector:@selector(avplayer:updateBufferProgress:isCanPlay:)])
        {
            [self.delegate avplayer:self updateBufferProgress:totalBuffer / totalDuration isCanPlay:isCanPlay];
        }
        
    }
    
}


- (void)playbackFinished:(NSNotification *)notify {
    NSLog(@"播放完成");
    if (self.delegate && [self.delegate respondsToSelector:@selector(avplayer:avPlayerDidFinished:)]) {
        [self.delegate avplayer:self avPlayerDidFinished:YES];
    }
}

- (void)play {
    
    if (self.player.status == AVPlayerStatusReadyToPlay && self.player) {
        
        [self.player play];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(avplayer:avPlayerStatusChange:)]) {
            [self.delegate avplayer:self avPlayerStatusChange:AVPlayerStatusPlaying];
        }
        m_isPlaying = YES;
    }
}

- (void)pause {
    
    if (self.player.status == AVPlayerStatusReadyToPlay && self.player) {
        
        [self.player pause];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(avplayer:avPlayerStatusChange:)]) {
            [self.delegate avplayer:self avPlayerStatusChange:AVPlayerStatusPaused];
        }
        m_isPlaying = NO;
    }
}

- (BOOL)isPlayingStatus{
    return m_isPlaying;
}
-(CGFloat)getAvPlayerRate
{
    if (systemVersionUp(10.0)) {
        return (float)self.player.timeControlStatus;
    }
    return self.player.rate;
}
-(NSTimeInterval)getAvPlayerCurrentTime
{
    CMTime cmtime = self.player.currentItem.currentTime;
    if (cmtime.timescale > 0 ) {
        NSNumber *number = [NSNumber numberWithLongLong:cmtime.value / cmtime.timescale];
        return [number longValue];
    }
    return 0;
}
- (NSTimeInterval)getAVPlayerDurationTime{
    return CMTimeGetSeconds(self.player.currentItem.duration);
}
#pragma mark AVPlayer dealloc
-(void)dealloc
{
    [self closeAVPlayer];
}
@end
