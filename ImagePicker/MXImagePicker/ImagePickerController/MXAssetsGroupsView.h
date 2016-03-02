//
//  MXAssetsGroupsView.h
//  MXImagePicker
//
//  Created by MX on 16/2/16.
//  Copyright © 2016年 MX. All rights reserved.
//
/**
 *  导航栏 弹出相册列表
 */
#import <UIKit/UIKit.h>

@class MXAssets;
@class MXAssetsGroupsView;

@protocol MXAssetsGroupsViewDelegate <NSObject>
@optional
- (void)assetsGroupsViewDidCancel:(MXAssetsGroupsView *)groupsView;
- (void)assetsGroupsView:(MXAssetsGroupsView *)groupsView didSelectAssetsGroup:(ALAssetsGroup *)assetsGroup;

@end

@interface MXAssetsGroupsView : UIView

@property (nonatomic, weak) id<MXAssetsGroupsViewDelegate>  delegate;
@property (nonatomic, assign) NSInteger indexAssetsGroup;
@property (nonatomic, strong) NSArray   *assetsGroups;

@property (nonatomic, strong) NSMutableDictionary   *selectedAssetsCount;

- (void)removeAssetSelected:(MXAssets *)assets;
- (void)addAssetSelected:(MXAssets *)assets;

@end
