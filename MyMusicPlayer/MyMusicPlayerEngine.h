//
//  MyMusicPlayerEngine.h
//  MyMusicPlayer
//
//  Created by panyanb on 2017/4/8.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@class MyMusicPlayerAudioSession;
@class MyMusicPlayerAVPlayer;

typedef NS_ENUM(NSInteger,EnginePlayerStatus)  {
    EnginePlayerStatusStopped,
    EnginePlayerStatusPlaying,
    EnginePlayerStatusPaused,
    EnginePlayerStatusEnded,
    EnginePlayerStatusError,
    EnginePlayerStatusUnknowns,
};

@protocol MyMusicPlayerEngineDelegate <NSObject>

@optional
- (void)engine:(NSObject *)player didChangeEngineStatus:(EnginePlayerStatus)EngineStaus;

- (void)engine:(NSObject *)player bufferProgress:(CGFloat)progress isCanPlay:(BOOL)isCanPlay;

- (void)engine:(NSObject *)player playerCurrentTime:(NSTimeInterval)current durationTime:(NSTimeInterval)durationTime;

- (void)engine:(NSObject *)player didFinishedSuccessfully:(BOOL)isSuccessfully;

- (void)engine:(NSObject *)player didPlayMusicFailed:(NSError *)error;


@end

@interface MyMusicPlayerEngine : NSObject

+(instancetype)shareInstance;

-(void)playMusicWithPath:(NSString *)filepath isVideo:(BOOL)isVideo onView:(UIView *)view;

@property (nonatomic,weak) id<MyMusicPlayerEngineDelegate> delegate;

- (void)pause;

- (void)resume;

- (void)stop;

- (void)playAtTime:(NSTimeInterval)time;

- (NSTimeInterval)getPlayDurationTime;

- (NSTimeInterval)getPlayCurrentTime;

- (float)getPlayRate;

- (void)closeEnginePlayer;
@end


typedef NS_ENUM(NSInteger,  MyAudioSessionState)
{
    AudioSessionStateStopped,
    AudioSessionStatePlaying,
    AudioSessionStatePaused,
    AudioSessionStateEnded,
    AudioSessionStateError,
    AudioSessionStateUnknowns,
};



@protocol MyMusicPlayerAudioSessionDelegate <NSObject>

@optional
- (void)engine:(MyMusicPlayerAudioSession *)engine didChangePlayState:(MyAudioSessionState)playState;
- (void)engine:(MyMusicPlayerAudioSession *)engine downloadProgress:(CGFloat)progress;
- (void)engine:(MyMusicPlayerAudioSession *)engine playCurrentTime:(NSTimeInterval)currentTime playDuration:(NSTimeInterval)duration;
- (void)engineDidFinishPlaying:(MyMusicPlayerAudioSession *)engine successfully:(BOOL)flag;
- (void)engineBeginInterruptionPlaying:(MyMusicPlayerAudioSession *)engine;
- (void)engineEndInterruptionPlaying:(MyMusicPlayerAudioSession *)engine;
- (void)engine:(MyMusicPlayerAudioSession *)engine playFail:(NSError *)error;
@end

@interface MyMusicPlayerAudioSession : NSObject
@property (nonatomic, assign, readonly) MyAudioSessionState playState;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, assign) id<MyMusicPlayerAudioSessionDelegate> delegate;
@property (nonatomic, assign) CGFloat voiceFileLength;


- (id)initWithSetBackgroundPlaying:(BOOL)setBGPlay;

- (void)playWithFilePath:(NSString *)filePath;

- (void)pause;

- (void)resume;

- (void)stop;

- (void)playAtTime:(NSTimeInterval)time;

- (NSTimeInterval)getPlayDurationTime;

- (NSTimeInterval)getPlayCurrentTime;

- (float)getPlayRate;

- (void)closeAudioPlayer;
@end


typedef NS_ENUM(NSInteger, MyAVPlayerStatus) {
    AVPlayerStatusStopped,
    AVPlayerStatusPlaying,
    AVPlayerStatusPaused,
    AVPlayerStatusEnded,
    AVPlayerStatusError,
    AVPlayerStatusUnknowns,
};

@protocol MyMusicPlayerAVPlayerDelegate <NSObject>

@optional

- (void)avplayer:(MyMusicPlayerAVPlayer *)avplayer updateBufferProgress:(NSTimeInterval)progress isCanPlay:(BOOL)isCanPlay;

- (void)avplayer:(MyMusicPlayerAVPlayer *)avplayer updatePlayerTime:(NSTimeInterval)time DurationTime:(NSTimeInterval)duration;

- (void)avplayer:(MyMusicPlayerAVPlayer *)avplayer avPlayerDidFinished:(BOOL)isSuccessfully;

- (void)avplayer:(MyMusicPlayerAVPlayer *)avplayer avPlayerDidError:(NSError *)error;

- (void)avplayer:(MyMusicPlayerAVPlayer *)avplayer avPlayerStatusChange:(MyAVPlayerStatus)playerStatus;

@end

@interface MyMusicPlayerAVPlayer : NSObject

@property (nonatomic, assign) id<MyMusicPlayerAVPlayerDelegate> delegate;

- (void)voicePalyerWith:(NSString *)filePath isVideo:(BOOL)isVideo onView:(UIView *)view;

- (void)play;

- (void)pause;

-(void)seekToTime:(NSTimeInterval)sekToTime;

-(NSTimeInterval)getAvPlayerCurrentTime;

-(CGFloat)getAvPlayerRate;

- (BOOL)isPlayingStatus;

- (NSTimeInterval)getAVPlayerDurationTime;

- (void)closeAVPlayer;

@end

