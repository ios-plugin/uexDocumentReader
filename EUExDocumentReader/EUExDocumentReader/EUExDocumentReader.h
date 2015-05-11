//
//  EUExDocumentReader.h
//  EUExDOCReader
//
//  Created by AppCan on 13-4-1.
//  Copyright (c) 2013年 AppCan. All rights reserved.
//

#import "EUExBase.h"
#import "EUExBase.h"
#import "EUExBaseDefine.h"
#import <QuickLook/QuickLook.h>

@interface EUExDocumentReader : EUExBase <QLPreviewControllerDataSource,QLPreviewControllerDelegate>
{
    QLPreviewController *qlPreViewController;
}

@property (nonatomic,copy)NSString *docPath;

- (void)openDocumentReader:(NSMutableArray *)inArguments;
- (void)close:(NSMutableArray *)inArguments;

@end
