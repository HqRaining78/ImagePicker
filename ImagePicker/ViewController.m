//
//  ViewController.m
//  ImagePicker
//
//  Created by MX on 16/3/2.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#import "MXAssets.h"
#import "MXImagePickerController.h"
#import "MXAssetCollectionViewCell.h"
#import "MXPromptView.h"

@interface ViewController () <MXImagePickerControllerDelegate>

@property (nonatomic, strong) NSMutableArray *assetsArray;

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.assetsArray = [NSMutableArray array];
    
    [self scrollView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 120, 30);
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"多选相册" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(150, 0, 120, 30);
    btn2.backgroundColor = [UIColor greenColor];
    [btn2 setTitle:@"单选相册" forState:UIControlStateNormal];
    [self.view addSubview:btn2];
    [btn2 addTarget:self action:@selector(btnClick2) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick2
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
        [[[UIAlertView alloc] initWithTitle:@"无法使用相册" message:@"请在“设置-隐私-照片”选项中允许访问你的照片" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    MXImagePickerController *imagePickerController = [MXImagePickerController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    imagePickerController.allowsMultipleSelection = NO;
    imagePickerController.maximumNumberOfSelection = 1;
    
    imagePickerController.delegate = self;
    imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePickerController.modalPresentationStyle = UIModalPresentationNone;
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)btnClick
{
    if (self.assetsArray.count >= 9) {
        [MXPromptView showWithImageName:@"picker_alert_sigh" message:@"最多上传九张图片"];
        return;
        
    }
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
        [[[UIAlertView alloc] initWithTitle:@"无法使用相册" message:@"请在“设置-隐私-照片”选项中允许访问你的照片" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    MXImagePickerController *imagePickerController = [MXImagePickerController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    
    // 多选
    imagePickerController.maximumNumberOfSelection = 9 - self.assetsArray.count;
    imagePickerController.allowsMultipleSelection = YES;
    
    // 单选
    //            imagePickerController.allowsMultipleSelection = NO;
    //            imagePickerController.maximumNumberOfSelection = 1;
    
    imagePickerController.delegate = self;
    imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    imagePickerController.modalPresentationStyle = UIModalPresentationNone;
    [self presentViewController:nav animated:YES completion:NULL];
    
}

#pragma mark --- MXImagePickerControllerDelegate
// 单选
- (void)imagePickerController:(MXImagePickerController *)imagePicker selectFromCameraWithInfo:(NSDictionary *)info
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 80, 80)];
    imageView.image = [info objectForKey: UIImagePickerControllerOriginalImage];
    [self.scrollView addSubview:imageView];
    self.scrollView.contentSize = CGSizeMake(Width, 0);
    
    
    UIImage *img = [info objectForKey: UIImagePickerControllerOriginalImage];
    
    NSData *imgData = UIImageJPEGRepresentation(img, 0.1);
    NSLog(@"压缩Size of Image(bytes):%.2f",[imgData length]/1024.0/1024.0);
    [imagePicker dismissViewControllerAnimated:NO completion:^{
    }];
}

- (void)imagePickerController:(MXImagePickerController *)imagePicker didSelectAssetWithInfo:(UIImage *)singleImage
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 80, 80)];
    imageView.image = singleImage;
    [self.scrollView addSubview:imageView];
    self.scrollView.contentSize = CGSizeMake(Width, 0);
    [imagePicker dismissViewControllerAnimated:NO completion:^{
    }];
}

// 压缩图片，任意大小的图片压缩到100K以内
// 压缩图像
+(NSData *)imageData:(UIImage *)myimage
{
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    if (data.length>100*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.1);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(myimage, 0.5);
        }else if (data.length>200*1024) {//0.25M-0.5M
            data=UIImageJPEGRepresentation(myimage, 0.9);
        }
    }
    return data;
}

// 多选
- (void)imagePickerController:(MXImagePickerController *)imagePicker didSelectAssetsWithInfo:(NSArray *)info
{
    self.assetsArray = [NSMutableArray arrayWithArray:info];
    
    for (NSInteger i=0; i<self.assetsArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5+(80+10)*(i%self.assetsArray.count), 0, 80, 80)];
        imageView.image = self.assetsArray[i];
        [self.scrollView addSubview:imageView];
        self.scrollView.contentSize = CGSizeMake(self.assetsArray.count*90, 0);
    }
    
    [imagePicker dismissViewControllerAnimated:NO completion:^{
    }];
}

- (void)imagePickerControllerDidCancel:(MXImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 120, Width, 80)];
        [self.view addSubview:_scrollView];
        _scrollView.contentSize = CGSizeMake(2*Width, 0);
    }
    return _scrollView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
