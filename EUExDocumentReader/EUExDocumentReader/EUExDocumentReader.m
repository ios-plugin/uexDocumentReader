
//
//  EUExDocumentReader.m
//  EUExDOCReader
//
//  Created by AppCan on 13-4-1.
//  Copyright (c) 2013年 AppCan. All rights reserved.
//

#import "EUExDocumentReader.h"
#import "EUtility.h"

@implementation EUExDocumentReader {
    NSFileManager *fmanager;
    NSString *txtTmpPath;
}

@synthesize docPath;


- (id)initWithBrwView:(EBrowserView *)eInBrwView{
    
    if (self=[super initWithBrwView:eInBrwView]) {
    
    }
    return self;
}

#pragma mark - QLPreviewController DataSource 

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller 
{
    return 1; 
}

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSString *path = self.docPath;
    NSURL *pathURL = [NSURL fileURLWithPath:path];
    txtTmpPath = @"";
    
    if([path hasSuffix:@"txt"]) {
        NSStringEncoding enc;
        NSString* contentStr = [NSString stringWithContentsOfFile:path usedEncoding:&enc error:nil];
        
        if (enc == NSUTF16StringEncoding) {
            
        }else{
            
            fmanager = [NSFileManager defaultManager];
            NSString *homeDirectory = NSHomeDirectory();
            NSString *tempPath = [homeDirectory stringByAppendingPathComponent:@"Documents/apps"];
            NSString *curAppId = [EUtility brwViewWidgetId:self.meBrwView];
            NSString *wgtTempPath = [tempPath stringByAppendingPathComponent:curAppId];
            if (![fmanager fileExistsAtPath:wgtTempPath]) {
                [fmanager createDirectoryAtPath:wgtTempPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            //txt name
            NSString *txtTime = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSinceReferenceDate]];
            NSString *txtName = [NSString stringWithFormat:@"%@.txt",[txtTime substringFromIndex:([txtTime length]-6)]];
            
            txtTmpPath = [wgtTempPath stringByAppendingPathComponent:txtName];
            if ([fmanager fileExistsAtPath:txtTmpPath]) {
                [fmanager removeItemAtPath:txtTmpPath error:nil];
            }
            NSData *data = [contentStr dataUsingEncoding:NSUTF16StringEncoding];
            [data writeToFile:txtTmpPath atomically:YES];
            pathURL = [NSURL URLWithString:txtTmpPath];
        }
    }
    
    return pathURL;
}

#pragma mark - QLPreviewController Delegate

-(void)previewControllerDidDismiss:(QLPreviewController *)controller
{
    if (qlPreViewController) {
        [qlPreViewController release];
        qlPreViewController = nil;
    }
    if (self.docPath) {
        self.docPath = nil;
    }
    if ([fmanager fileExistsAtPath:txtTmpPath]) {
        
       [fmanager removeItemAtPath:txtTmpPath error:nil];
    }
}

#pragma mark - openDocumentReader

- (void)openDocumentReader:(NSMutableArray *)inArguments
{
    NSString *filePath = nil;
    if (inArguments != nil && [inArguments count] == 1) {
        filePath = [self absPath:[inArguments objectAtIndex:0]];
    }else {
        return;
    }
    self.docPath = filePath;
    if (!qlPreViewController) {
        qlPreViewController = [[QLPreviewController alloc] init];
    }
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
}

#pragma mark - 进入插件界面退出后，点击“返回”会调

- (void)clean
{
    if (qlPreViewController) {
        [qlPreViewController release];
        qlPreViewController = nil;
    }
    if (self.docPath) {
        self.docPath = nil;
    }
    [super clean];
}

- (void)dealloc
{
    if (qlPreViewController) {
        [qlPreViewController release];
        qlPreViewController = nil;
    }
    if (self.docPath) {
        self.docPath = nil;
    }
    [super dealloc];
}


@end

