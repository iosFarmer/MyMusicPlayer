//
//  MyMusicSlider+UITapGesture.m
//  MyMusicPlayer
//
//  Created by panyanb on 2017/4/9.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "MyMusicSlider+UITapGesture.h"

#import <objc/runtime.h>


static char *gestureKey;
static char *targetKey;
static char *actionStringKey;
@implementation MyMusicSlider (UITapGesture)
-(void)addTapGestureWithTarget:(id)target action:(SEL)action
{
    id gesture = objc_getAssociatedObject(self, &gestureKey);
    if (!gesture) {
        objc_setAssociatedObject(self, &targetKey, target, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(self, &actionStringKey, NSStringFromSelector(action), OBJC_ASSOCIATION_RETAIN);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
        
        objc_setAssociatedObject(self, &gestureKey, tapGesture, OBJC_ASSOCIATION_RETAIN);
    }
}

-(void)tapGesture:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [tapGesture locationInView:self];
        float value = (self.maximumValue - self.minimumValue) * location.x / self.frame.size.width;
        [self setValue:value animated:YES];
        id target = objc_getAssociatedObject(self, &targetKey);
        if (target) {
            NSString *actionStr = objc_getAssociatedObject(self, &actionStringKey);
//            SEL action = NSSelectorFromString(actionStr);
//            [target performSelector:action withObject:self];
            
//            SEL selector = NSSelectorFromString(actionStr);
//            IMP imp = [target methodForSelector:selector];
//            void (*func)(id, SEL) = (void *)imp;
//            func(target, selector);
            
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector: NSSelectorFromString(actionStr) withObject:self];
#pragma clang diagnostic pop
        }
        
    }
}

-(void)dealloc
{
    UITapGestureRecognizer *tapGesture;
    id gesture = objc_getAssociatedObject(self, &gestureKey);
    if (gesture) {
        tapGesture = (UITapGestureRecognizer *)gesture;
        [self removeGestureRecognizer:tapGesture];
    }
}
@end
