//
//  MXAssetsGroupCell.m
//  MXImagePicker
//
//  Created by MX on 16/2/16.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "MXAssetsGroupCell.h"
#import "MXAssetsThumbnailView.h"

@interface MXAssetsGroupCell ()

@property (nonatomic, strong) MXAssetsThumbnailView *thumbnailView;
@property (nonatomic, strong) UILabel *assetsNameLabel;
@property (nonatomic, strong) UILabel *assetsCountLabel;
@property (nonatomic, strong) UIImageView *checkImageView;

@end

@implementation MXAssetsGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.accessoryType = UITableViewCellAccessoryNone;
        [self thumbnailView];
    }
    return self;
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    if (_assetsGroup != assetsGroup) {
        _assetsGroup = assetsGroup;
        
        self.thumbnailView.assetsGroup = _assetsGroup;

//      extern NSString *const ALAssetsGroupPropertyName 相册名字
        self.assetsNameLabel.text = [_assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        [self.assetsNameLabel sizeToFit];
        
        CGFloat assetsNameWidth = self.assetsNameLabel.width;
        if (self.assetsNameLabel.width > (Width - 85)) {
            assetsNameWidth = Width - 85;
        }
        self.assetsNameLabel.frame = CGRectMake(self.thumbnailView.right + 15, self.thumbnailView.centerY - self.assetsNameLabel.height - 2, assetsNameWidth, self.assetsNameLabel.height);
        
        self.assetsCountLabel.text = [NSString stringWithFormat:@"%@", @([_assetsGroup numberOfAssets])];
        [self.assetsCountLabel sizeToFit];
        self.assetsCountLabel.left = self.assetsNameLabel.left;
        self.assetsCountLabel.top = self.assetsNameLabel.bottom+4;
    }
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    self.checkImageView.hidden = !isSelected;
}

#pragma mark --- getter

- (MXAssetsThumbnailView *)thumbnailView{
    if (!_thumbnailView) {
        _thumbnailView = [[MXAssetsThumbnailView alloc] initWithFrame:CGRectMake(15, 9, 40, 40)];
        _thumbnailView.backgroundColor = [UIColor clearColor];
        _thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview:_thumbnailView];
    }
    return _thumbnailView;
}

- (UIImageView *)checkImageView{
    if (!_checkImageView) {
        _checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picker_photo_filter_checked"]];
        _checkImageView.backgroundColor = [UIColor clearColor];
        _checkImageView.right = self.thumbnailView.width-3;
        _checkImageView.bottom = self.thumbnailView.height-3;
        [self.thumbnailView addSubview:_checkImageView];
    }
    return _checkImageView;
}

- (UILabel *)assetsNameLabel{
    if (!_assetsNameLabel) {
        _assetsNameLabel = [[UILabel alloc] init];
        _assetsNameLabel.backgroundColor = [UIColor clearColor];
        _assetsNameLabel.textColor = UIColorFromRGB(0x333333);
        _assetsNameLabel.font = [UIFont systemFontOfSize:15.0f];
        [self.contentView addSubview:_assetsNameLabel];
    }
    return _assetsNameLabel;
}

- (UILabel *)assetsCountLabel{
    if (!_assetsCountLabel) {
        _assetsCountLabel = [[UILabel alloc] init];
        _assetsCountLabel.backgroundColor = [UIColor clearColor];
        _assetsCountLabel.textColor = UIColorFromRGB(0x333333);
        _assetsCountLabel.font = [UIFont systemFontOfSize:12.0f];
        [self.contentView addSubview:_assetsCountLabel];
    }
    return _assetsCountLabel;
}

@end
