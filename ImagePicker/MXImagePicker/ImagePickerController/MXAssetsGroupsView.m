//
//  MXAssetsGroupsView.m
//  MXImagePicker
//
//  Created by MX on 16/2/16.
//  Copyright © 2016年 MX. All rights reserved.
//

#import "MXAssetsGroupsView.h"
#import "MXAssets.h"
#import "MXAssetsGroupCell.h"

@interface MXAssetsGroupsView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIButton *touchButton;

@end

static CGFloat kMXAssetsGroupCellHeight = 58.f;

@implementation MXAssetsGroupsView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self tableView];
    }
    return self;
}

#pragma mark --- MXAssetsGroupsViewDelegate

- (void)cancelAssetsGroupSelect
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsGroupsViewDidCancel:)]) {
        [self.delegate assetsGroupsViewDidCancel:self];
    }
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.assetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MXAssetsGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MXAssetsGroupCell class])];
    
    ALAssetsGroup *assetsGroup = self.assetsGroups[indexPath.row];
    cell.assetsGroup = assetsGroup;
    cell.isSelected = [self selectAssetsGroup:assetsGroup];
    if (_selectedIndexPath.row == indexPath.row) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark --- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kMXAssetsGroupCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedIndexPath = indexPath;
    [self.tableView reloadData];
    
    ALAssetsGroup *assetsGroup = self.assetsGroups[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsGroupsView:didSelectAssetsGroup:)]) {
        [self.delegate assetsGroupsView:self didSelectAssetsGroup:assetsGroup];
    }
}

#pragma mark --- 设置分割线
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 70, 0, 0);
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:edgeInsets];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:edgeInsets];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (BOOL)selectAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    // ALAssetsGroupPropertyPersistentID 查看相册的存储id
    NSString *groupID = [assetsGroup valueForProperty:ALAssetsGroupPropertyPersistentID];
    NSInteger count = [[self.selectedAssetsCount objectForKey:groupID] integerValue];
    return count > 0;
}

- (void)removeAssetSelected:(MXAssets *)assets
{
    NSInteger count = [[self.selectedAssetsCount objectForKey:assets.groupPropertyID] integerValue];
    if (count <= 1) {
        [self.selectedAssetsCount removeObjectForKey:assets.groupPropertyID];
    } else {
        [self.selectedAssetsCount setObject:@(count-1) forKey:assets.groupPropertyID];
    }
    [self.tableView reloadData];
}

- (void)addAssetSelected:(MXAssets *)assets
{
    NSInteger count = [[self.selectedAssetsCount objectForKey:assets.groupPropertyID] integerValue];
    [self.selectedAssetsCount setObject:@(count+1) forKey:assets.groupPropertyID];
    [self.tableView reloadData];
}

#pragma mark --- setter

- (void)setSelectedAssetsCount:(NSMutableDictionary *)selectedAssetsCount
{
    if (_selectedAssetsCount != selectedAssetsCount) {
        _selectedAssetsCount = selectedAssetsCount;
        [self.tableView reloadData];
    }
}

- (void)setAssetsGroups:(NSArray *)assetsGroups
{
    if (_assetsGroups != assetsGroups) {
        _assetsGroups = assetsGroups;
        
        CGFloat rowCount = 0;
        if ([_assetsGroups count] > 5) {
            rowCount = 5.5;
        } else {
            rowCount = [_assetsGroups count];
        }
        
        _selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        self.tableView.height = rowCount * kMXAssetsGroupCellHeight;
        self.touchButton.top = self.tableView.bottom;
        self.touchButton.height = self.height - self.tableView.bottom;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

#pragma mark --- getter

- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Width, 5*kMXAssetsGroupCellHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self addSubview:_tableView];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:NSClassFromString(@"MXAssetsGroupCell") forCellReuseIdentifier:NSStringFromClass([MXAssetsGroupCell class])];
    }
    return _tableView;
}

// 作用： 列表展开时，点击取消的操作
- (UIButton *)touchButton
{
    if (_touchButton == nil) {
        _touchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _touchButton.frame = CGRectMake(0, _tableView.bottom, Width, self.height-_tableView.bottom);
        [_touchButton addTarget:self action:@selector(cancelAssetsGroupSelect) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_touchButton];
    }
    return _touchButton;
}

@end
