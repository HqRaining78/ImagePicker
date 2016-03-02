//
//  MXUtils.h
//  MXImagePicker
//
//  Created by MX on 16/2/16.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXUtils : NSObject

+ (UIImage*)loadImageFromBundle:(NSString*)relativePath;
+ (UIImage *)stretchImage:(UIImage *)image
                capInsets:(UIEdgeInsets)capInsets
             resizingMode:(UIImageResizingMode)resizingMode;

+ (UIColor *)getColor:(NSString *)hexColor;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
