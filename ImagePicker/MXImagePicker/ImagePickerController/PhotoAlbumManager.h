//
//  PhotoAlbumManager.h
//  MXImagePicker
//
//  Created by MX on 16/2/17.
//  Copyright © 2016年 MX. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SaveImageCompletion)(ALAsset *asset, NSError *error);

@interface PhotoAlbumManager : NSObject

+ (PhotoAlbumManager *)sharedManager;

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName completionBlock:(SaveImageCompletion)completionBlock;
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName completionBlock:(SaveImageCompletion)completionBlock;

@end
