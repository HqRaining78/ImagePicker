//
//  MXConstantsTool.m
//  mexue2
//
//  Created by MX on 15/12/29.
//  Copyright © 2015年 靳海涛. All rights reserved.
//

#import "MXConstantsTool.h"

@implementation MXConstantsTool

// 屏幕宽比例值
CGFloat kWidthScale() {
    CGFloat kScreenWidth = [UIScreen mainScreen].bounds.size.width;
    if (kScreenWidth <= 640) {
        return kScreenWidth/320;
    } else if (kScreenWidth <= 750) {
        return kScreenWidth/375;
    } else {
        return kScreenWidth/414;
    }
}

#pragma mark --- UIColor 转 UIImage
+ (UIImage*)createImageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (BOOL)isEmptyWithData:(NSObject *)object{
    if (object == [NSNull null] || object == nil || [@"" isEqualToString:(NSString *)object]) {
        return YES;
    }else{
        return NO;
    }
    return nil;
}

+ (BOOL)isBlankString:(NSString *)string {
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

@end
