//
//  MyMusicViewController.h
//  MyMusicPlayer
//
//  Created by Reader on 2017/4/12.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyMusicViewController : UIViewController
@property (nonatomic, strong) NSString *musicTitle;
-(void)addMusicPlayerViewWithVideo:(BOOL)isVideo;
-(void)musicFilepath:(NSString *)filepath isVideo:(BOOL)isVideo;

@end
