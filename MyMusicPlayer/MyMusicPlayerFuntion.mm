//
//  MyMusicPlayerFuntion.m
//  MyMusicPlayer
//
//  Created by panyanb on 2017/4/9.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "MyMusicPlayerFuntion.h"

@implementation MyMusicPlayerFuntion

UIImage *getImageWithColor(UIColor *color, CGSize size)
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
UIImage *getRadiusImageWithColor(UIColor *color ,CGSize size)
{
    UIImage *image = getImageWithColor(color, size);
    image  = getRadiusImage(image);
    return image;
}
UIImage *getRadiusImage(UIImage *image)
{
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    // 开启图片上下文
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint center = CGPointMake(rect.size.width * 0.5, rect.size.height * 0.5);
    CGFloat radius = rect.size.width * 0.5;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI* 2 clockwise:YES];
    // 绘制图片路径
    CGContextAddPath(context, path.CGPath);
    // 剪切图片
    CGContextClip(context);
    
    [image drawAtPoint:CGPointZero];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭图形上下文
    UIGraphicsEndImageContext();
    return newImage;
}


BOOL systemVersionUp(CGFloat version)
{
    BOOL isFlag = NO;
    if([UIDevice currentDevice].systemVersion.floatValue >= version)
    {
        isFlag = YES;
    }
    return isFlag;
}
@end
