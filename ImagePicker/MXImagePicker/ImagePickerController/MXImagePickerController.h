//
//  MXImagePickerController.h
//  MXImagePicker
//
//  Created by MX on 16/2/16.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXAssets;

typedef NS_ENUM(NSUInteger, MXImagePickerControllerFilterType) {
    MXImagePickerControllerFilterTypeNone,
    MXImagePickerControllerFilterTypePhotos,
    MXImagePickerControllerFilterTypeVideos
};

UIKIT_EXTERN ALAssetsFilter * ALAssetsFilterFromMXImagePickerControllerFilterType(MXImagePickerControllerFilterType type);

@class MXImagePickerController;

@protocol MXImagePickerControllerDelegate <NSObject>

@optional

// 单选
- (void)imagePickerController:(MXImagePickerController *)imagePicker selectFromCameraWithInfo:(NSDictionary *)info; // 拍照
- (void)imagePickerController:(MXImagePickerController *)imagePicker didSelectAssetWithInfo:(UIImage *)singleImage;

// 多选 (存储的是图片数组的信息)
- (void)imagePickerController:(MXImagePickerController *)imagePicker didSelectAssetsWithInfo:(NSArray *)info;
- (void)imagePickerControllerDidCancel:(MXImagePickerController *)imagePicker;

@end

@interface MXImagePickerController : UIViewController

@property (nonatomic, assign) MXImagePickerControllerFilterType filterType;

@property (nonatomic, weak) id<MXImagePickerControllerDelegate> delegate;

@property (nonatomic, assign) NSUInteger maximumNumberOfSelection;
@property (nonatomic, assign) BOOL allowsMultipleSelection;

@end
