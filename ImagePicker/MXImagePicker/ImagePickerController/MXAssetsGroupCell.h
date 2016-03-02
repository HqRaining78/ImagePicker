//
//  MXAssetsGroupCell.h
//  MXImagePicker
//
//  Created by MX on 16/2/16.
//  Copyright © 2016年 MX. All rights reserved.
//
/**
 *  相册列表 （一张照片＋相册名＋相册数量）
 */

#import <UIKit/UIKit.h>

@interface MXAssetsGroupCell : UITableViewCell

@property (nonatomic, strong) ALAssetsGroup *assetsGroup; //映射照片库中的一个相册
@property (nonatomic, assign) BOOL isSelected;

@end
