//
//  MyMusicPlayerFuntion.h
//  MyMusicPlayer
//
//  Created by panyanb on 2017/4/9.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MyMusicPlayerFuntion : NSObject

/**
 获取图片

 @param color 图片颜色
 @param size 图片大小
 @return 方形图片
 */
UIImage *getImageWithColor(UIColor *color, CGSize size);

/**
 获取图片
 
 @param color 图片颜色
 @param size 图片大小
 @return 圆形图片
 */
UIImage *getRadiusImageWithColor(UIColor *color ,CGSize size);

/**
 是否高于某个版本

 @param version <#version description#>
 @return <#return value description#>
 */
BOOL systemVersionUp(CGFloat version);

@end
