//
//  MXAssetCollectionViewCell.m
//  MXImagePicker
//
//  Created by MX on 16/2/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "MXAssetCollectionViewCell.h"
#import "UIButton+TouchAreaInsets.h"
#import "MXConstantsTool.h"

@interface MXAssetCollectionViewCell ()

//@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton    *photoButton;
@property (nonatomic, strong) UIButton    *checkButton;

@end

@implementation MXAssetCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        [self imageView];
        [self photoButton];
        self.checkButton.right = self.imageView.right-6;
        self.checkButton.top = self.imageView.top+6;
    }
    return self;
}

#pragma mark - setter/getter

- (void)setAsset:(ALAsset *)asset
{
    if (asset == nil) {
        _asset = asset;
        self.photoButton.hidden = NO;
        self.imageView.hidden = YES;
        return;
    }
    
    self.imageView.hidden = NO;
    self.photoButton.hidden = YES;
    
    if (_asset != asset) {
        _asset = asset;
        
        CGImageRef thumbnailImageRef = [asset aspectRatioThumbnail];
        
        if (thumbnailImageRef) {
            self.imageView.image = [UIImage imageWithCGImage:thumbnailImageRef scale:1.0 orientation:UIImageOrientationUp];
        } else {
            self.imageView.image = [UIImage imageNamed:@"assets_placeholder_picture"];
        }
    }
    
}

- (void)setShowBadgeIcon:(BOOL)showBadgeIcon
{
    _showBadgeIcon = showBadgeIcon;
    
    _checkButton.hidden = !_showBadgeIcon;
}

- (void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    
    self.checkButton.selected = isSelected;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UIButton *)checkButton{
    if (!_checkButton) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage  *img = [UIImage imageNamed:@"photo_check_default"];
        UIImage  *imgH = [UIImage imageNamed:@"photo_check_selected"];
        _checkButton.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        [_checkButton setBackgroundImage:img forState:UIControlStateNormal];
        [_checkButton setBackgroundImage:imgH forState:UIControlStateSelected];
        [_checkButton addTarget:self action:@selector(photoDidChecked) forControlEvents:UIControlEventTouchUpInside];
        _checkButton.touchAreaInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        _checkButton.exclusiveTouch = YES;
        [self.imageView addSubview:_checkButton];
    }
    return _checkButton;
}

- (UIButton *)photoButton{
    if (!_photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoButton.frame = self.contentView.bounds;
        [_photoButton setBackgroundImage:[MXConstantsTool createImageWithColor:UIColorFromRGB(0xf5f5f5)] forState:UIControlStateNormal];
        [_photoButton setBackgroundImage:[MXConstantsTool createImageWithColor:UIColorFromRGB(0x61cbf5)] forState:UIControlStateHighlighted];
        
        UIImage  *img = [UIImage imageNamed:@"compose_photograph"];
        [_photoButton setImage:img forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(photo) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_photoButton];
        
    }
    return _photoButton;
}

- (void)photo
{
    if (self.delegate && [_delegate respondsToSelector:@selector(startPhotoAssetsViewCell:)]) {
        [_delegate startPhotoAssetsViewCell:self];
    }
}

- (void)photoDidChecked
{
    if (self.checkButton.selected) {
        if (self.delegate && [_delegate respondsToSelector:@selector(didDeselectItemAssetsViewCell:)]) {
            [_delegate didDeselectItemAssetsViewCell:self];
        }
    }else{
        if (self.delegate && [_delegate respondsToSelector:@selector(didSelectItemAssetsViewCell:)]) {
            [_delegate didSelectItemAssetsViewCell:self];
        }
    }
}

@end
