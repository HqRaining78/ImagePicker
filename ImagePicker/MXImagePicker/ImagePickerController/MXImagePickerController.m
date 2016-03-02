//
//  MXImagePickerController.m
//  MXImagePicker
//
//  Created by MX on 16/2/16.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "MXImagePickerController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#import "MXAssets.h"
#import "MXAssetsGroupsView.h"
#import "MXAssetCollectionViewCell.h"
#import "MXPromptView.h"
#import "PhotoAlbumManager.h"
#import "DNPhotoBrowser.h"
#import "EMAlertView.h"
#import "MXConstantsTool.h"

ALAssetsFilter * ALAssetsFilterFromMXImagePickerControllerFilterType(MXImagePickerControllerFilterType type) {
    switch (type) {
        case MXImagePickerControllerFilterTypeNone:
            return [ALAssetsFilter allAssets];
            break;
            
        case MXImagePickerControllerFilterTypePhotos:
            return [ALAssetsFilter allPhotos];
            break;
            
        case MXImagePickerControllerFilterTypeVideos:
            return [ALAssetsFilter allVideos];
            break;
    }
}

@interface MXImagePickerController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MXAssetsGroupsViewDelegate, MXAssetCollectionViewCellDelegate, DNPhotoBrowserDelegate>

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary; //ALAssetsLibrary类可以实现查看相册列表，增加相册，保存图片到相册等功能。
@property (nonatomic, strong) NSArray *groupTypes; // 相册可选类型

@property (nonatomic, assign) BOOL showsAssetsGroupSelection; // 标记是否展开相册列表

@property (nonatomic, strong) UILabel      *titleLabel; // 相册名：注意名字长度
@property (nonatomic, strong) UIButton     *titleButton; // navigationBar的titleView可点击
@property (nonatomic, strong) UIImageView  *arrowImageView; // 标示： 列表是否展开

@property (nonatomic, strong) MXAssetsGroupsView *assetsGroupsView; // 导航栏 titleView 下拉相册列表
@property (nonatomic, strong) UIButton              *touchButton; // 遮盖导航栏，作用：点击隐藏列表
@property (nonatomic, strong) UIView                *overlayView; // 遮罩图

@property (nonatomic, strong) ALAssetsGroup *selectAssetsGroup; // 相册列表数据源
@property (nonatomic, strong) NSMutableArray *assetsArray; // 相册全部资源
@property (nonatomic, assign) NSUInteger numberOfAssets;
@property (nonatomic, assign) NSUInteger numberOfPhotos;
@property (nonatomic, assign) NSUInteger numberOfVideos;

@property (nonatomic, strong) NSMutableArray     *selectedAssetArray; // 已经选择

@property (nonatomic, strong) UIButton      *finishButton;
@property (nonatomic, strong) UILabel       *finishLabel;
@property (nonatomic, strong) UIToolbar     *toolbar;
@property (nonatomic, strong) UIButton *previewButton; // 预览

@property (nonatomic, strong) UICollectionView   *collectionView;

@property (nonatomic, assign) BOOL isSelected; //是否选择

@end

@implementation MXImagePickerController

- (instancetype)init
{
    if (self = [super init]) {
        self.filterType = MXImagePickerControllerFilterTypeNone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self collectionView];
    
    if (_allowsMultipleSelection) {
        [self toolbar];
    }
    
    [self loadAssetsGroupsCompletion:^{
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preparePhotos) name:ALAssetsLibraryChangedNotification object:nil];

}

#pragma mark -- 当系统相册发生变化时

- (void)preparePhotos
{
    [self loadAssetsGroupsCompletion:^{

        for (int i=0; i<self.selectedAssetArray.count; i++) {
            MXAssets *mxAsset = self.selectedAssetArray[i];
            __weak typeof(self) weakSelf = self;
//
            [self.assetsLibrary assetForURL:mxAsset.assetPropertyURL resultBlock:^(ALAsset *asset) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!asset) {
                    [strongSelf dismissViewControllerAnimated:YES completion:NULL];
                }
            } failureBlock:^(NSError *error) {
            }];
        }
    }];
}

// 对视图页面进行初始化
- (void)initUI
{
    self.groupTypes = @[@(ALAssetsGroupLibrary),
                        @(ALAssetsGroupSavedPhotos),
                        @(ALAssetsGroupPhotoStream),
                        @(ALAssetsGroupAlbum)];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.navigationItem.titleView = self.titleButton;

    // 取消
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, 50, 30);
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [cancelBtn setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelEventDidTouched) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancelBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -10;
    [self.navigationItem setLeftBarButtonItems:@[negativeSpacer, cancelItem] animated:NO];
    
    // 确定
    _finishLabel = [[UILabel alloc] init];
    _finishLabel.backgroundColor = [UIColor clearColor];
    _finishLabel.textColor = UIColorFromRGB(0x999999);
    _finishLabel.font = [UIFont systemFontOfSize:15];
    _finishLabel.text = @"确认";
    _finishLabel.textAlignment = NSTextAlignmentRight;
    [_finishLabel sizeToFit];
    
    _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _finishButton.frame = CGRectMake(0, 0, _finishLabel.width+10, 30);
    [_finishButton addTarget:self action:@selector(finishPhotoDidSelected) forControlEvents:UIControlEventTouchUpInside];
    
    _finishLabel.centerY = _finishButton.height/2;
    _finishLabel.centerX = _finishButton.width/2;
    [_finishButton addSubview:_finishLabel];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:_finishButton];
    UIBarButtonItem *negativeSpacerRight = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacerRight.width = -6;
    [self.navigationItem setRightBarButtonItems:@[negativeSpacerRight, doneItem] animated:NO];
    
    if (!_allowsMultipleSelection) {
        [self.navigationItem setRightBarButtonItems:nil animated:NO];
    }
}

#pragma mark --- 获取相册列表

- (void)loadAssetsGroupsCompletion: (void (^)(void))completion
{
    // Load assets groups
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadAssetsGroupsWithTypes:self.groupTypes
                             completion:^(NSArray *assetsGroups) {
                                 if ([assetsGroups count]>0) {
                                     weakSelf.titleButton.enabled = YES;
                                     
                                     // 有遮挡
                                     [weakSelf performSelectorOnMainThread:@selector(assetsGroupsDidDeselected) withObject:nil waitUntilDone:YES];
                                     
                                     if (!weakSelf.selectAssetsGroup) {
                                         weakSelf.selectAssetsGroup = [assetsGroups objectAtIndex:0];
                                     } else {
                                         [weakSelf loadAllAssetsForGroups];
                                     }
                                     
                                     weakSelf.assetsGroupsView.assetsGroups = assetsGroups;
                                     
                                     NSMutableDictionary  *dic = [NSMutableDictionary dictionaryWithCapacity:0];
                                     for (MXAssets  *asset in weakSelf.selectedAssetArray) {
                                         if (asset.groupPropertyID) {
                                             NSInteger  count = [[dic objectForKey:asset.groupPropertyID] integerValue];
                                             [dic setObject:[NSNumber numberWithInteger:count+1] forKey:asset.groupPropertyID];
                                         }
                                     }
                                     weakSelf.assetsGroupsView.selectedAssetsCount = dic;
                                     [weakSelf resetFinishFrame];
                                     
                                 }else{
                                     weakSelf.titleButton.enabled = NO;
                                 }
                                 
                                 if(completion){
                                     completion();
                                 }
                             }];
    });
    
}

- (void)loadAssetsGroupsWithTypes:(NSArray *)types completion:(void (^)(NSArray *assetsGroups))completion
{
    __block NSMutableArray *assetsGroups = [NSMutableArray array];
    __block NSUInteger numberOfFinishedTypes = 0;
    
    for (NSNumber *type in types) {
        __weak typeof(self) weakSelf = self;
        [self.assetsLibrary enumerateGroupsWithTypes:[type unsignedIntegerValue]
                                          usingBlock:^(ALAssetsGroup *assetsGroup, BOOL *stop) {
                                              if (assetsGroup) {
                                                  // Filter the assets group
                                                  [assetsGroup setAssetsFilter:ALAssetsFilterFromMXImagePickerControllerFilterType(weakSelf.filterType)];
                                                  
                                                  // Add assets group
                                                  if (assetsGroup.numberOfAssets > 0) {
                                                      // Add assets group
                                                      [assetsGroups addObject:assetsGroup];
                                                  }
                                              } else {
                                                  numberOfFinishedTypes++;
                                              }
                                              
                                              // Check if the loading finished
                                              if (numberOfFinishedTypes == types.count) {
                                                  // Sort assets groups
                                                  NSArray *sortedAssetsGroups = [self sortAssetsGroups:(NSArray *)assetsGroups typesOrder:types];
                                                  
                                                  // Call completion block
                                                  if (completion) {
                                                      completion(sortedAssetsGroups);
                                                  }
                                              }
                                          } failureBlock:^(NSError *error) {
                                              
                                              if (error) {
                                                  [MXPromptView showWithImageName:@"picker_alert_sigh" message:@"请在“设置-隐私-照片”中允许访问"];
                                              }
                                              
                                          }];
    }
    
}

- (NSArray *)sortAssetsGroups:(NSArray *)assetsGroups typesOrder:(NSArray *)typesOrder
{
    NSMutableArray *sortedAssetsGroups = [NSMutableArray array];
    
    for (ALAssetsGroup *assetsGroup in assetsGroups) {
        if (sortedAssetsGroups.count == 0) {
            [sortedAssetsGroups addObject:assetsGroup];
            continue;
        }
        
        ALAssetsGroupType assetsGroupType = [[assetsGroup valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
        NSUInteger indexOfAssetsGroupType = [typesOrder indexOfObject:@(assetsGroupType)];
        
        for (NSInteger i = 0; i <= sortedAssetsGroups.count; i++) {
            if (i == sortedAssetsGroups.count) {
                [sortedAssetsGroups addObject:assetsGroup];
                break;
            }
            
            ALAssetsGroup *sortedAssetsGroup = sortedAssetsGroups[i];
            ALAssetsGroupType sortedAssetsGroupType = [[sortedAssetsGroup valueForProperty:ALAssetsGroupPropertyType] unsignedIntegerValue];
            NSUInteger indexOfSortedAssetsGroupType = [typesOrder indexOfObject:@(sortedAssetsGroupType)];
            
            if (indexOfAssetsGroupType < indexOfSortedAssetsGroupType) {
                [sortedAssetsGroups insertObject:assetsGroup atIndex:i];
                break;
            }
        }
    }
    
    return sortedAssetsGroups;
}

- (void)loadAllAssetsForGroups
{
    
    [self.selectAssetsGroup setAssetsFilter:ALAssetsFilterFromMXImagePickerControllerFilterType(self.filterType)];
    
    // Load assets
    NSMutableArray *assets = [NSMutableArray array];
    __block NSUInteger numberOfAssets = 0;
    __block NSUInteger numberOfPhotos = 0;
    __block NSUInteger numberOfVideos = 0;
    
    [self.selectAssetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            numberOfAssets++;
            NSString *type = [result valueForProperty:ALAssetPropertyType];
            if ([type isEqualToString:ALAssetTypePhoto]){
                numberOfPhotos++;
            }else if ([type isEqualToString:ALAssetTypeVideo]){
                numberOfVideos++;
            }
            [assets addObject:result];
        }
    }];
    
    self.assetsArray = assets;
    self.numberOfAssets = numberOfAssets;
    self.numberOfPhotos = numberOfPhotos;
    self.numberOfVideos = numberOfVideos;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
    
}

- (BOOL)validateMaximumNumberOfSelections:(NSUInteger)numberOfSelections
{
    
    if (1 <= self.maximumNumberOfSelection) {
        return (numberOfSelections <= self.maximumNumberOfSelection);
    }
    return YES;
}

#pragma mark - MXAssetCollectionViewCellDelegate
- (void)startPhotoAssetsViewCell:(MXAssetCollectionViewCell *)assetsCell
{
    if (self.selectedAssetArray.count>=self.maximumNumberOfSelection) {
        NSString  *str = [NSString stringWithFormat:@"最多选择%@张照片", @(self.maximumNumberOfSelection)];
        [MXPromptView showWithImageName:@"picker_alert_sigh" message:str];
        return;
    }

    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){
        
        [[[UIAlertView alloc] initWithTitle:@"无法使用相机" message:@"请在“设置-隐私-相机”选项中允许访问你的相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
        pickerController.allowsEditing = YES;
        pickerController.delegate = self;
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
#pragma mark --- Snapshotting a view that has not been rendered results in an empty snapshot 系统8.0问题
        // http://stackoverflow.com/questions/25884801/ios-8-snapshotting-a-view-that-has-not-been-rendered-results-in-an-empty-snapsho

        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:pickerController animated:YES completion:^{
            }];
        });
    } else {
        [MXPromptView showWithImageName:@"picker_alert_sigh" message:@"相机功能暂不可用"];
    }
}

- (void)didSelectItemAssetsViewCell:(MXAssetCollectionViewCell *)assetsCell
{
    
    if (self.selectedAssetArray.count>=self.maximumNumberOfSelection) {
        NSString  *str = [NSString stringWithFormat:@"最多选择%@张照片", @(self.maximumNumberOfSelection)];
        [MXPromptView showWithImageName:@"picker_alert_sigh" message:str];
    }
    
    BOOL  validate = [self validateMaximumNumberOfSelections:(self.selectedAssetArray.count + 1)];
    if (validate) {
        // Add asset URL
        [self addAssetsObject:assetsCell.asset];
        [self resetFinishFrame];
        assetsCell.isSelected = YES;
    }
    
}

- (void)didDeselectItemAssetsViewCell:(MXAssetCollectionViewCell *)assetsCell
{
    [self removeAssetsObject:assetsCell.asset];
    [self resetFinishFrame];
    assetsCell.isSelected = NO;
}

- (void)removeAssetsObject:(ALAsset *)asset
{
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    for (MXAssets *mxAsset in self.selectedAssetArray) {
        if ([assetURL isEqual:mxAsset.assetPropertyURL]) {
            [self.assetsGroupsView removeAssetSelected:mxAsset];
            [self.selectedAssetArray removeObject:mxAsset];
            break;
        }
    }
}

- (void)addAssetsObject:(ALAsset *)asset
{
    NSURL *groupURL = [self.selectAssetsGroup valueForProperty:ALAssetsGroupPropertyURL];
    NSString *groupID = [self.selectAssetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    MXAssets  *mxAsset = [[MXAssets alloc] init];
    mxAsset.groupPropertyID = groupID;
    mxAsset.groupPropertyURL = groupURL;
    mxAsset.assetPropertyURL = assetURL;
    mxAsset.asset = asset;
    [self.selectedAssetArray addObject:mxAsset];
    [self.assetsGroupsView addAssetSelected:mxAsset];
}

#pragma mark --- UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
   
    
    if (_allowsMultipleSelection) {
        
        __weak typeof(self) weakSelf = self;

        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        NSString  *assetsName = [self.selectAssetsGroup valueForProperty:ALAssetsGroupPropertyName];

        [[PhotoAlbumManager sharedManager] saveImage:image
                                             toAlbum:assetsName
                                     completionBlock:^(ALAsset *asset, NSError *error) {
                                         if (error == nil && asset) {
                                             if (_allowsMultipleSelection) {
                                                 [weakSelf addAssetsObject:asset];
                                                 [weakSelf finishPhotoDidSelected];
                                             } else {
                                                 
                                             }
                                         }
                                     }];
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:selectFromCameraWithInfo:)]) {
            [self.delegate imagePickerController:self selectFromCameraWithInfo:info];
            [self dismissViewControllerAnimated:NO completion:^{
            }];
        }
    }
    [picker dismissViewControllerAnimated:NO completion:^{}];
}

#pragma mark --- MXImagePickerControllerDelegate

- (void)finishPhotoDidSelected
{
    if (self.selectedAssetArray.count > 0) {
        if ([_delegate respondsToSelector:@selector(imagePickerController:didSelectAssetsWithInfo:)]) {
            
            NSMutableArray *imgArray = [NSMutableArray array];
            for (NSInteger i=0; i<self.selectedAssetArray.count; i++) {
                MXAssets *mxAsset = self.selectedAssetArray[i];
                ALAsset *asset = mxAsset.asset;
                ALAssetRepresentation *representation = [asset defaultRepresentation];
                // 获取资源图片的 fullScreenImage
                UIImage *image = [UIImage imageWithCGImage:[representation fullScreenImage]];
                [imgArray addObject:image];
            }
            [self.delegate imagePickerController:self
                               didSelectAssetsWithInfo:imgArray];
        }
    }
}

- (void)cancelEventDidTouched
{
    if (self.delegate && [_delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
        [self.delegate imagePickerControllerDidCancel:self];
    }
}

#pragma mark --- 相册列表弹出操作

- (void)assetsGroupDidSelected
{
    self.showsAssetsGroupSelection = YES;
    if (self.showsAssetsGroupSelection) {
        [self showAssetsGroupView];
    }
}

- (void)assetsGroupsDidDeselected
{
    self.showsAssetsGroupSelection = NO;
    [self hideAssetsGroupView];
}

- (void)showAssetsGroupView
{
    [[UIApplication sharedApplication].keyWindow addSubview:self.touchButton];
    
    self.overlayView.alpha = 0.0f;
    self.overlayView.hidden = NO;
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.assetsGroupsView.top = 0;
                         self.overlayView.alpha = 0.85f;
                     }completion:^(BOOL finished) {
                         
                     }];
}

- (void)hideAssetsGroupView
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.assetsGroupsView.top = -self.assetsGroupsView.height;
                         self.overlayView.alpha = 0.0f;
                     }completion:^(BOOL finished) {
                         [_touchButton removeFromSuperview];
                         _touchButton = nil;
                         
                         [_overlayView removeFromSuperview];
                         _overlayView = nil;
                         
                         [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
                     }];
}

#pragma mark --- 更新数据

- (void)resetFinishFrame
{
    if (self.selectedAssetArray.count <= 0) {
        self.finishLabel.text = @"确认";
        self.finishLabel.textColor = UIColorFromRGB(0x999999);
        self.previewButton.enabled = NO;
    } else {
        self.finishLabel.text = [NSString stringWithFormat:@"确认(%@)", @(self.selectedAssetArray.count)];
        self.finishLabel.textColor = UIColorFromRGB(0x61cbf5);
        self.previewButton.enabled = YES;
    }
    [self.finishLabel sizeToFit];
    
    self.finishButton.width = _finishLabel.width+10;
    self.finishLabel.centerX = self.finishButton.width/2;
    self.finishLabel.centerY = self.finishButton.height/2;
    
    self.navigationItem.rightBarButtonItem.enabled = (self.selectedAssetArray.count>0);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.assetsArray count]+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MXAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MXAssetCollectionViewCell class]) forIndexPath:indexPath];
//
    cell.delegate = self;
    if ([indexPath row]<=0) {
        cell.asset = nil;
    }else{
        ALAsset *asset = self.assetsArray[indexPath.row-1];
        cell.asset = asset;
       
        if (!_allowsMultipleSelection) {
            cell.showBadgeIcon = NO;
        } else {
            NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
            cell.isSelected = [self assetIsSelected:assetURL];
            cell.showBadgeIcon = YES;
        }
    }

    return cell;
}

- (BOOL)assetIsSelected:(NSURL *)assetURL
{
    for (MXAssets *asset in self.selectedAssetArray) {
        if ([assetURL isEqual:asset.assetPropertyURL]) {
            return YES;
        }
    }
    return NO;
}

#define kSizeThumbnailCollectionView  (Width-6)/3

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kSizeThumbnailCollectionView, kSizeThumbnailCollectionView);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(3, 0, 3, 0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_allowsMultipleSelection) {
        [self browserPhotoAsstes:self.assetsArray pageIndex:indexPath.row-1];
    } else {
        [EMAlertView showAlertWithTitle:@"提示" message:@"是否选择该头像？" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            if (buttonIndex == 1) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerController:didSelectAssetWithInfo:)]) {
                    ALAsset *asset = self.assetsArray[indexPath.row-1];
                    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
                    UIImage *image = [UIImage imageWithCGImage:[assetRep fullScreenImage]];
                    [self.delegate imagePickerController:self didSelectAssetWithInfo:image];
                }
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    }
}

#pragma mark --- 预览

- (void)browserPhotoAsstes:(NSArray *)assets pageIndex:(NSInteger)page
{
    DNPhotoBrowser *browser = [[DNPhotoBrowser alloc] initWithPhotos:assets
                                                        currentIndex:page
                                                           fullImage:NO];
    browser.delegate = self;
    browser.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:browser animated:YES];
}

- (void)previewPhotoesSelected
{
    if (self.selectedAssetArray.count > 0) {
        NSMutableArray *assets = [NSMutableArray array];
        for (MXAssets *perAsset in self.selectedAssetArray) {
            ALAsset *pAsset = perAsset.asset;
            [assets addObject:pAsset];
        }
        [self browserPhotoAsstes:assets pageIndex:0];
    }
}

#pragma mark - DNPhotoBrowserDelegate

- (void)sendImagesFromPhotobrowser:(DNPhotoBrowser *)photoBrowser currentAsset:(ALAsset *)asset
{
    if (self.selectedAssetArray.count <= 0) {
        [self seletedAssets:asset];
        [self.collectionView reloadData];
    }
    [self finishPhotoDidSelected];
}

- (NSUInteger)seletedPhotosNumberInPhotoBrowser:(DNPhotoBrowser *)photoBrowser
{
    return self.selectedAssetArray.count;
}

- (BOOL)photoBrowser:(DNPhotoBrowser *)photoBrowser currentPhotoAssetIsSeleted:(ALAsset *)asset{
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    return [self assetIsSelected:assetURL];
}

- (BOOL)photoBrowser:(DNPhotoBrowser *)photoBrowser seletedAsset:(ALAsset *)asset
{
    BOOL seleted = [self seletedAssets:asset];
    [self.collectionView reloadData];
    return seleted;
}

- (void)photoBrowser:(DNPhotoBrowser *)photoBrowser deseletedAsset:(ALAsset *)asset
{
    [self removeAssetsObject:asset];
    [self resetFinishFrame];
    [self.collectionView reloadData];
}

- (BOOL)seletedAssets:(ALAsset *)asset
{
    NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    if ([self assetIsSelected:assetURL]) {
        return NO;
    }
    UIBarButtonItem *firstItem = self.toolbarItems.firstObject;
    firstItem.enabled = YES;
    if (self.selectedAssetArray.count >= self.maximumNumberOfSelection) {
        NSString  *str = [NSString stringWithFormat:@"最多选择%@张照片", @(self.maximumNumberOfSelection)];
        [MXPromptView showWithImageName:@"picker_alert_sigh" message:str];
        return NO;
    }else
    {
        [self addAssetsObject:asset];
        [self resetFinishFrame];
        return YES;
    }
}

#pragma mark --- MXAssetsGroupsViewDelegate

- (void)assetsGroupsViewDidCancel:(MXAssetsGroupsView *)groupsView
{
    [self assetsGroupsDidDeselected];
}

- (void)assetsGroupsView:(MXAssetsGroupsView *)groupsView didSelectAssetsGroup:(ALAssetsGroup *)assGroup
{
    [self assetsGroupsDidDeselected];
    self.selectAssetsGroup = assGroup;
}


#pragma mark --- setter

- (void)setSelectAssetsGroup:(ALAssetsGroup *)selectAssetsGroup{
    if (_selectAssetsGroup != selectAssetsGroup) {
        _selectAssetsGroup = selectAssetsGroup;
        
        NSString  *assetsName = [selectAssetsGroup valueForProperty:ALAssetsGroupPropertyName];
       
        self.titleLabel.text = assetsName;
        [self.titleLabel sizeToFit];
        
        if (self.titleLabel.width+self.arrowImageView.width+5 > 150) {
            self.titleLabel.width = 150-15-self.arrowImageView.width;
            self.titleLabel.left = 5;
        } else {
            self.titleLabel.left = (150-self.titleLabel.width-self.arrowImageView.width-5)/2;
        }
   
        self.titleLabel.top = (self.titleButton.height-self.titleLabel.height)/2;
        self.arrowImageView.left = self.titleLabel.right + 5;
        self.arrowImageView.centerY = self.titleLabel.centerY;
        
        [self loadAllAssetsForGroups];
    }
}

- (void)setShowsAssetsGroupSelection:(BOOL)showsAssetsGroupSelection{
    _showsAssetsGroupSelection = showsAssetsGroupSelection;
    
    if (_showsAssetsGroupSelection) {
        self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        self.arrowImageView.transform = CGAffineTransformIdentity;
    }
    
}

#pragma mark --- getter

- (NSMutableArray *)selectedAssetArray{
    if (!_selectedAssetArray) {
        _selectedAssetArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedAssetArray;
}

- (ALAssetsLibrary *)assetsLibrary{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (UIButton *)titleButton
{
    if (!_titleButton) {
        _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleButton.frame = CGRectMake(0, 0, 150, 30);
        [_titleButton setBackgroundImage:[MXConstantsTool createImageWithColor:[UIColor lightGrayColor]] forState:UIControlStateHighlighted];
        [_titleButton addTarget:self action:@selector(assetsGroupDidSelected) forControlEvents:UIControlEventTouchUpInside];
    }
    return _titleButton;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = LColor;
        _titleLabel.font = [UIFont systemFontOfSize:19];
        [_titleButton addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        UIImage *arrowDownImage = [UIImage imageNamed:@"nav-choce"];
        
        _arrowImageView = [UIImageView new];
        _arrowImageView.image = arrowDownImage;
        _arrowImageView.frame = CGRectMake(0, 0, arrowDownImage.size.width, arrowDownImage.size.height);
        [_titleButton addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (MXAssetsGroupsView *)assetsGroupsView
{
    if (!_assetsGroupsView) {
        _assetsGroupsView = [[MXAssetsGroupsView alloc] initWithFrame:CGRectMake(0, -self.view.height, Width, Height)];
        _assetsGroupsView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _assetsGroupsView.delegate = self;
        [self.view addSubview:_assetsGroupsView];
    }
    return _assetsGroupsView;
}

- (UIButton *)touchButton
{
    if (!_touchButton) {
        _touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _touchButton.frame = CGRectMake(0, 0, Width, 64);
        [_touchButton addTarget:self action:@selector(assetsGroupsDidDeselected) forControlEvents:UIControlEventTouchUpInside];
    }
    return _touchButton;
}

- (UIView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
        _overlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85f];
        _overlayView.hidden = YES;
        [self.view insertSubview:_overlayView belowSubview:self.assetsGroupsView];
    }
    return _overlayView;
}

- (UIToolbar *)toolbar{
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.height-45-64, self.view.width, 45)];
        _toolbar.tintColor = [UIColor colorWithWhite:1 alpha:0.96];
        if ([_toolbar respondsToSelector:@selector(barTintColor)]) {
            _toolbar.barTintColor = [UIColor colorWithWhite:1 alpha:0.96];
        }
        _toolbar.translucent = YES;
        _toolbar.userInteractionEnabled = YES;
        [_toolbar addSubview:self.previewButton];
        
        [self.view addSubview:_toolbar];
    }
    return _toolbar;
}

- (UIButton *)previewButton
{
    if (!_previewButton) {
        _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.frame = CGRectMake(Width-60, 7, 50, 30);
        [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
        _previewButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
        [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_previewButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateDisabled];
        [_previewButton addTarget:self action:@selector(previewPhotoesSelected) forControlEvents:UIControlEventTouchUpInside];
        _previewButton.enabled = NO;
    }
    return _previewButton;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 3.0;
        layout.minimumInteritemSpacing = 3.0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        if (_allowsMultipleSelection) {
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, Width, Height-64-44) collectionViewLayout:layout];
        } else {
            _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, Width, Height-64) collectionViewLayout:layout];
        }
        
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[MXAssetCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([MXAssetCollectionViewCell class])];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_collectionView];
        
    }
    return _collectionView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
