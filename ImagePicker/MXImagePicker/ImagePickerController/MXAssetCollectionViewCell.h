//
//  MXAssetCollectionViewCell.h
//  MXImagePicker
//
//  Created by MX on 16/2/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXAssetCollectionViewCell;

@protocol MXAssetCollectionViewCellDelegate <NSObject>
@optional
- (void)startPhotoAssetsViewCell:(MXAssetCollectionViewCell *)assetsCell;
- (void)didSelectItemAssetsViewCell:(MXAssetCollectionViewCell *)assetsCell;
- (void)didDeselectItemAssetsViewCell:(MXAssetCollectionViewCell *)assetsCell;

@end

@interface MXAssetCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<MXAssetCollectionViewCellDelegate> delegate;
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, assign) BOOL    isSelected;
@property (nonatomic, assign) BOOL showBadgeIcon; // 是否显示图标
@property (nonatomic, strong) UIImageView *imageView;

@end
