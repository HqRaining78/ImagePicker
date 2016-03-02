//
//  MXAssets.m
//  MXImagePicker
//
//  Created by MX on 16/2/16.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "MXAssets.h"

NSString *const MXKPickerGroupPropertyID    = @"MXKPickerGroupPropertyID";
NSString *const MXKPickerGroupPropertyURL   = @"MXKPickerGroupPropertyURL";
NSString *const MXKPickerAssetPropertyURL   = @"MXKPickerAssetPropertyURL";
NSString *const MXKPickerAssetInstance   =    @"MXKPickerAssetInstance";

@implementation MXAssets

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.groupPropertyID = [aDecoder decodeObjectForKey:MXKPickerGroupPropertyID];
        self.groupPropertyURL = [aDecoder decodeObjectForKey:MXKPickerGroupPropertyURL];
        self.assetPropertyURL = [aDecoder decodeObjectForKey:MXKPickerAssetPropertyURL];
        self.asset = [aDecoder decodeObjectForKey:MXKPickerAssetInstance];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_groupPropertyID forKey:MXKPickerGroupPropertyID];
    [aCoder encodeObject:_groupPropertyURL forKey:MXKPickerGroupPropertyURL];
    [aCoder encodeObject:_assetPropertyURL forKey:MXKPickerAssetPropertyURL];
    [aCoder encodeObject:_asset forKey:MXKPickerAssetInstance];
}

@end
