//
//  MyMusicViewController.m
//  MyMusicPlayer
//
//  Created by Reader on 2017/4/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "MyMusicViewController.h"
#import "MyMusicPlayerView.h"
#import "AppDelegate.h"
@interface MyMusicViewController ()

@property (nonatomic, strong) MyMusicPlayerView *musicPlayerView;
@property (nonatomic, strong) UIImageView *playerImageView;
@end

@implementation MyMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0x55/255.0 green:0x49/255.0 blue:0x43/255.0 alpha:1.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(goBack:)];
}
-(void)goBack:(UIBarButtonItem *)barButtonItem
{
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    appDelegate.allowRotation = NO;//关闭横屏仅允许竖屏
    
    [self setNewOrientation:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}
-(void)addMusicPlayerViewWithVideo:(BOOL)isVideo
{
    if (self.musicPlayerView) {
        [self.musicPlayerView removeFromSuperview];
        self.musicPlayerView = nil;
    }
    if (self.playerImageView) {
        [self.playerImageView removeFromSuperview];
        self.playerImageView = nil;
    }
    if (!isVideo) {
    self.musicPlayerView = [[MyMusicPlayerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 200,
                                                                                        self.view.frame.size.width,
                                                                                        200) isVideo:isVideo];
    
        [self.musicPlayerView initWithEnginePlayer];
        self.musicPlayerView.musicTitle.text = _musicTitle;
        [self addImageView];
    }
    else{
        CGRect bounds = [UIScreen mainScreen].bounds;
        CGFloat width = bounds.size.width < bounds.size.height ? bounds.size.height : bounds.size.width;
        CGFloat height = bounds.size.width < bounds.size.height ? bounds.size.width : bounds.size.height;
        CGRect tempFrame = self.view.frame;
        tempFrame.size.width = width;
        tempFrame.size.height = height;
        self.view.frame = tempFrame;
        self.musicPlayerView =[[MyMusicPlayerView alloc] initWithFrame:self.view.bounds isVideo:isVideo];
        [self.musicPlayerView initWithEnginePlayer];
        [self interfaceOrientations];
        
    }
    [self.view addSubview:self.musicPlayerView];
}
-(void)addImageView
{
    if (!self.playerImageView) {
        self.playerImageView = [[UIImageView alloc] init];
        [self.view addSubview:self.playerImageView];
    }
    self.playerImageView.image = [UIImage imageNamed:@"fucking"];
    CGRect rect = self.musicPlayerView.frame;
    self.playerImageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - rect.size.height);
}
-(void)musicFilepath:(NSString *)filepath isVideo:(BOOL)isVideo
{
    if (self.musicPlayerView) {
        [self.musicPlayerView reloadEnginePlayerWithPathFile:filepath isVideo:isVideo];
    }
}
-(void)interfaceOrientations
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = YES;
    [self setNewOrientation:YES];
}

- (void)setNewOrientation:(BOOL)fullscreen
{
    if (fullscreen) {
        
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
  
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
    }
    else{
        
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];

        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
    }
    
}


@end
