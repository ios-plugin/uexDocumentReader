
//
//  EUExDocumentReader.m
//  EUExDOCReader
//
//  Created by AppCan on 13-4-1.
//  Copyright (c) 2013年 AppCan. All rights reserved.
//

#import "EUExDocumentReader.h"
#import "EUtility.h"
@interface EUExDocumentReader()
@property(nonatomic,assign)UIStatusBarStyle style;
@property BOOL isBarHidden;
@end
@implementation EUExDocumentReader {
    NSFileManager *fmanager;
    NSString *txtTmpPath;
}

- (id)initWithBrwView:(EBrowserView *)eInBrwView{
    
    if (self=[super initWithBrwView:eInBrwView]) {
        self.docPath = @"";
        _isBarHidden = [UIApplication sharedApplication].isStatusBarHidden;
        if (!_isBarHidden) {
            _style = [UIApplication sharedApplication].statusBarStyle;
        }
       
        
    }
    return self;
}

#pragma mark - QLPreviewController DataSource 

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller 
{
    return 1; 
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    
    NSString *path = @"";
    if (self.docPath) {
        path = self.docPath;
    }
    //txt文档,wgt://和wgts://协议路径
    if ([path hasSuffix:@"txt"]) {
        NSData *fileData = [NSData dataWithContentsOfFile:path];
        
        NSError *error;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        //判断是UNICODE编码
        NSString *isUNICODE = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        
        //还是ANSI编码
        NSString *isANSI = [[NSString alloc] initWithData:fileData encoding:-2147482062];
        
        if (isUNICODE) {
            NSString *retStr = [[NSString alloc]initWithCString:[isUNICODE UTF8String] encoding:NSUTF8StringEncoding];
            NSData *data = [retStr dataUsingEncoding:NSUTF16StringEncoding];
            [fileManager removeItemAtPath:path error:&error];
            [data writeToFile:path atomically:YES];
        }
        else if(isANSI){
            NSData *data = [isANSI dataUsingEncoding:NSUTF16StringEncoding];
            [fileManager removeItemAtPath:path error:&error];
            [data writeToFile:path atomically:YES];
        }
    }
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    return pathURL;
}

#pragma mark - QLPreviewController Delegate

-(void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    [[UIApplication sharedApplication] setStatusBarHidden:_isBarHidden withAnimation:UIStatusBarAnimationNone];
    if (!_isBarHidden) {
         [[UIApplication sharedApplication] setStatusBarStyle:_style];
    }
    [self close:nil];
}

#pragma mark - openDocumentReader

- (void)openDocumentReader:(NSMutableArray *)inArguments
{
    NSString *filePath = @"";
    if (inArguments != nil && [inArguments count] == 1) {
        filePath = [self absPath:[inArguments objectAtIndex:0]];
    }else {
        return;
    }
    self.docPath = filePath;
    if (!qlPreViewController) {
        qlPreViewController = [[QLPreviewController alloc] init];
    }
    qlPreViewController.view.bounds = CGRectMake(0, 0, qlPreViewController.view.frame.size.width, qlPreViewController.view.frame.size.height);
    qlPreViewController.dataSource = self;
    qlPreViewController.delegate = self;
    [EUtility brwView:meBrwView navigationPresentModalViewController:qlPreViewController animated:YES];
}

#pragma mark - 进入插件界面退出后，点击“关闭”会调

- (void)close:(NSMutableArray *)inArguments
{
    if (qlPreViewController) {
        [qlPreViewController release];
        qlPreViewController = nil;
    }
    if (self.docPath) {
        self.docPath = nil;
    }
    qlPreViewController.delegate = nil;
    qlPreViewController.dataSource = nil;
}

#pragma mark - 进入插件界面退出后，点击“返回”会调

- (void)clean
{
    [self close:nil];
    [super clean];
}

- (void)dealloc
{
    [self close:nil];
    [super dealloc];
}

@end

