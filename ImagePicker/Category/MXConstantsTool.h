//
//  MXConstantsTool.h
//  mexue2
//
//  Created by MX on 15/12/29.
//  Copyright © 2015年 靳海涛. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXConstantsTool : NSObject

CGFloat kWidthScale(); //屏幕宽比例值

/**
 *  UIColor 转 UIImage
 */
+ (UIImage*)createImageWithColor:(UIColor*)color;


/**
 *  判断后台接口返回的数组是否为空
 *
 *  @param object
 *
 *  @return yes & no
 */
+ (BOOL)isEmptyWithData:(NSObject *)object;

// 判断是否是空串
+ (BOOL)isBlankString:(NSString *)string;

@end
