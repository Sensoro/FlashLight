//
//  SENQRCodeViewController.h
//  Sensoro Beacon Utility
//
//  Created by Zihua Li on 8/6/14.
//  Copyright (c) 2014 Sensoro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SENQRCodeViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
@property (nonatomic, copy) void (^completion)(NSString *);
@property BOOL keepShow;//是否在扫描结束后返回。
@property (strong, nonatomic) NSArray * allowedBarcodeTypes;// 支持的扫描码类型

- (void) restartScan;
@end
