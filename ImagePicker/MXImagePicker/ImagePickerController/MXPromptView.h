//
//  MXPromptView.h
//  MXImagePicker
//
//  Created by MX on 16/2/17.
//  Copyright © 2016年 MX. All rights reserved.
//
/**
 *  弹出的警告视图
 */
#import <UIKit/UIKit.h>

@interface MXPromptView : UIWindow

+ (void)showWithImageName:(NSString*)imageName message:(NSString *)string;

@end
