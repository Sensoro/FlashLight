//
//  SENQRCodeViewController.m
//  Sensoro Beacon Utility
//
//  Created by Zihua Li on 8/6/14.
//  Copyright (c) 2014 Sensoro. All rights reserved.
//

#import "SENQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
//#import "ZBarSDK.h"
//#import "BMMacroDefinition.h"

#define kScreen_Width ([UIScreen mainScreen].bounds.size.width)
#define kScreen_Height   ([UIScreen mainScreen].bounds.size.height)

@interface SENQRCodeViewController () <UINavigationControllerDelegate>{
    BOOL _finished;
    int num;
    BOOL upOrdown;
    NSTimer * timer;

}
@property (nonatomic, strong) UIView *previewView;
@property (strong, nonatomic)  UIActivityIndicatorView *loadingActivityIndicatorView;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, retain) UIImageView * line;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) UIButton *openFlashLightButton ;
@end

@implementation SENQRCodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _keepShow = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.title = @"扫描二维码";
    self.previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                self.view.frame.size.width,
                                                                self.view.frame.size.height)];
    [self.view addSubview:self.previewView];
    self.loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 150, 10, 10)];
    [self.view addSubview:self.loadingActivityIndicatorView];
    self.captureSession = nil;
    
    if(!self.allowedBarcodeTypes){
        self.allowedBarcodeTypes = @[@"org.iso.QRCode"];
    }
    
    [self setupMaskBackground];
    
    [self lineAnimation];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopReading];
    [timer invalidate];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];
    [self restartScan];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(autoMoveUpandDown) userInfo:nil repeats:YES];
}

- (void)autoMoveUpandDown{
    
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(50, 40+2*num, 270, 2);
        _line.center = CGPointMake(kScreen_Width/2.0, _line.center.y);
        if (2*num >= 265.0f) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(50, 40+2*num, 270, 2);
        _line.center = CGPointMake(kScreen_Width/2.0, _line.center.y);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
}

- (void)lineAnimation{
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(50, -15, 270, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [self.view addSubview:_line];
}
- (void)setupMaskBackground{
    
    CALayer *top = [[CALayer alloc]init];
    top.frame = CGRectMake(0, 0, kScreen_Width, 35);
    top.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.5].CGColor;
    [self.view.layer addSublayer:top];
    
    CALayer *bottom = [[CALayer alloc]init];
    bottom.frame = CGRectMake(0, 305, kScreen_Width, kScreen_Height-305);
    bottom.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.5].CGColor;
    [self.view.layer addSublayer:bottom];
    
    CALayer *left = [[CALayer alloc]init];
    left.frame = CGRectMake(0, 35, (kScreen_Width-270)/2.0, 270);
    left.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.5].CGColor;
    [self.view.layer addSublayer:left];
    
    CALayer *right = [[CALayer alloc]init];
    right.frame = CGRectMake((kScreen_Width + 270)/2.0, 35, (kScreen_Width-270)/2.0, 270);
    right.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.5].CGColor;
    [self.view.layer addSublayer:right];
    
    // 背景图片
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake((kScreen_Width - 280)/2.0, 30, 280, 280)];
    imageView.image = [[UIImage imageNamed:@"pick_bg"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    imageView.tintColor = [UIColor whiteColor];
    [self.view addSubview:imageView];
    
    
    // 说明文字
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake((kScreen_Width - 280)/2.0, imageView.bounds.size.width + 35, 280.0f, 44)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.font = [UIFont systemFontOfSize:14];
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.numberOfLines=2;
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text = @"二维码扫描提示";
    [self.view addSubview:labIntroudction];
    
    // 开灯
    _openFlashLightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _openFlashLightButton.frame = CGRectMake(0, 0, 50, 50);
    _openFlashLightButton.layer.borderWidth = 1.0;
    _openFlashLightButton.layer.cornerRadius = 25;
    _openFlashLightButton.layer.borderColor = [UIColor whiteColor].CGColor;
    _openFlashLightButton.center = CGPointMake(labIntroudction.center.x, labIntroudction.center.y + 54);
//    [_openFlashLightButton setTitle:@"开灯" forState:UIControlStateNormal];
    [_openFlashLightButton setImage:[UIImage imageNamed:@"fresh_on_iphone5"] forState:UIControlStateNormal];
    _openFlashLightButton.tintColor = [UIColor whiteColor];
    [_openFlashLightButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [_openFlashLightButton addTarget:self action:@selector(openFlashlight) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_openFlashLightButton];
    
}

-(void)openFlashlight
{
    if (_captureDevice.torchMode == AVCaptureTorchModeOff) {
        [_captureDevice lockForConfiguration:nil];
        [_captureDevice setTorchMode:AVCaptureTorchModeOn];
        [_captureDevice unlockForConfiguration];
//        [_openFlashLightButton setTitle:@"关灯" forState:UIControlStateNormal];
    }else{
        [_captureDevice lockForConfiguration:nil];
        [_captureDevice setTorchMode:AVCaptureTorchModeOff];
        [_captureDevice unlockForConfiguration];
//        [_openFlashLightButton setTitle:@"开灯" forState:UIControlStateNormal];
    }
}

- (void) restartScan{
    [self startReading];
    
    _finished = NO;
}

- (BOOL)startReading {
    NSError *error;
    
    _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:captureMetadataOutput.availableMetadataObjectTypes];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_previewView.layer.bounds];
//    CGRect viewPort = CGRectMake(50, 50, 100, 100);
//    [_videoPreviewLayer setFrame:viewPort];
    [_previewView.layer addSublayer:_videoPreviewLayer];
    [_captureSession startRunning];
    [_loadingActivityIndicatorView stopAnimating];
    
    //[_placeholderView setHidden:YES];
    
    return YES;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (_finished) return;
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([self.allowedBarcodeTypes containsObject:metadataObj.type]) {
            _finished = YES;
            NSString *value = [metadataObj stringValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_keepShow == NO) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [self stopReading];
                
                if (self.completion != nil) {
                    self.completion(value);
                }
                
            });
        }
    }
}

-(void)stopReading{
    [_captureSession stopRunning];
    _captureSession = nil;
    
    [_videoPreviewLayer removeFromSuperlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
