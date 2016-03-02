//
//  MXAssetsThumbnailView.m
//  MXImagePicker
//
//  Created by MX on 16/2/16.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "MXAssetsThumbnailView.h"

@interface MXAssetsThumbnailView ()

@property (nonatomic, strong) NSArray *thumbnailImages;
@property (nonatomic, strong) UIImage *blankImage;

@end

@implementation MXAssetsThumbnailView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(40.f, 40.f);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 1.f, 1.f, 1.f, 1.f);
    
    if (self.thumbnailImages.count >= 1) {
        UIImage *thubnailImage = self.thumbnailImages[0];
        
        CGRect thumbnailImageRect = CGRectMake(0, 0, 40.f, 40.f);
        CGContextFillRect(context, thumbnailImageRect);
        [thubnailImage drawInRect:CGRectInset(thumbnailImageRect, 0.5, 0.5)];
    }
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    if (_assetsGroup != assetsGroup) {
        _assetsGroup = assetsGroup;
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, MIN(1, assetsGroup.numberOfAssets))];
        NSMutableArray *thumbnailImages = [NSMutableArray array];
        [assetsGroup enumerateAssetsAtIndexes:indexes options:0 usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                CGImageRef thumbailImageRef = [result thumbnail];
                if (thumbailImageRef) {
                    [thumbnailImages addObject:[UIImage imageWithCGImage:thumbailImageRef]];
                } else {
                    [thumbnailImages addObject:[self blankImage]];
                }
            }
        }];
        //
        if (thumbnailImages.count > 0) {
            self.thumbnailImages = thumbnailImages;
        } else {
            [thumbnailImages addObject:self.blankImage];
            self.thumbnailImages = thumbnailImages;
        }
        [self setNeedsDisplay];
    }
}
// 占位图
- (UIImage *)blankImage
{
    if (_blankImage == nil) {
        _blankImage = [UIImage imageNamed:@"assets_placeholder_picture"];
    }
    return _blankImage;
}

@end
