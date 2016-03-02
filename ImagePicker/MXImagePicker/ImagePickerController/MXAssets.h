//
//  MXAssets.h
//  MXImagePicker
//
//  Created by MX on 16/2/16.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MXAssets : NSObject<NSCoding>

@property (nonatomic, strong) NSString  *groupPropertyID;  // 查看相册的存储id
@property (nonatomic, strong) NSURL     *groupPropertyURL; // 查看相册存储的位置地址
@property (nonatomic, strong) NSURL     *assetPropertyURL; // 查看相片存储的位置地址

@property (nonatomic, strong) ALAsset *asset;

@end
