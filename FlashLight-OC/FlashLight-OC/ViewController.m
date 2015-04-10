//
//  ViewController.m
//  FlashLight-OC
//
//  Created by David Yang on 15/4/10.
//  Copyright (c) 2015年 Sensoro. All rights reserved.
//

#import "ViewController.h"
#import "SENQRCodeViewController.h"
#import "KDXAlertView.h"
#import <SensoroBeaconKit/SensoroBeaconKit.h>

@interface ViewController () <SBKBeaconManagerDelegate> {
    NSArray *_UUIDs;
    NSMutableArray *_beacons;
}

@property (nonatomic,strong) SBKBeacon * beacon;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UILabel *stateText;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _beacons = [NSMutableArray array];
    
    _UUIDs = @[@"23A01AF0-232A-4518-9C0E-323FB773F5EF",
               @"63EA09C2-5345-4E6D-9776-26B9C6FC126C",
               @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0",
               @"B9407F30-F5F8-466E-AFF9-25556B57FE6D",
               @"FDA50693-A4E2-4FB1-AFCF-C6EB07647825"];
    
    [[SBKBeaconManager sharedInstance] requestAlwaysAuthorization];
    
    [SBKBeaconManager sharedInstance].delegate = self;
    for (NSString *str in _UUIDs) {
        SBKBeaconID *beaconID = [SBKBeaconID beaconIDWithString:str];
        [[SBKBeaconManager sharedInstance] startRangingBeaconsWithID:beaconID wakeUpApplication:NO];
    }
    
    _flashButton.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanAYunzi:(id)sender {
    SENQRCodeViewController *qrvc = [[SENQRCodeViewController alloc] init];
    //qrvc.keepShow = YES;
    __weak SENQRCodeViewController * weakQrcode = qrvc;
    qrvc.completion = ^(NSString * value) {
        NSArray *comps = [value componentsSeparatedByString:@"|"];
        
        if (comps.count < 4) {
            [self.navigationController popToViewController:self animated:YES];
            return;
        };
        
        SBKBeacon *beacon = nil;
        
        for (SBKBeacon* iter in _beacons) {
            if ([iter.serialNumber isEqualToString:comps[0]]) {
                beacon = iter;
                break;
            }
        }
        
        if ( beacon == nil ) {//没有发现相应的beacon，说明用户拿到了没有扫描到的，此beacon可能没有在工作。
            NSString * tip = @"没有扫描到此Beacon，请稍候重试，或者确认此Beacon是否工作";
            KDXAlertView *av = [[KDXAlertView alloc] initWithTitle:@"提示"
                                                           message:tip
                                                 cancelButtonTitle:@"好的"
                                                      cancelAction:^(KDXAlertView *alertView) {
                                                          [weakQrcode restartScan];
                                                      }];
            [av show];
            
        }else{
            
            if (!(([beacon.hardwareModelName isEqualToString:@"C0"]) &&
                  [beacon.firmwareVersion compare:@"3.1"
                                           options:NSNumericSearch] != NSOrderedAscending)) {
                      NSString * tip = @"只有云盒，且固件版本在3.1以上才支持此功能。";
                      KDXAlertView *av = [[KDXAlertView alloc] initWithTitle:@"提示"
                                                                     message:tip
                                                           cancelButtonTitle:@"好的"
                                                                cancelAction:^(KDXAlertView *alertView) {
                                                                    [weakQrcode restartScan];
                                                                }];
                      [av show];
                      
                      return;
            }
            
            _stateText.text = @"点击\"闪灯\"，来闪烁Beacon的LED灯";
            _beacon = beacon;
            _flashButton.enabled = YES;
        }
    };
    
    [self.navigationController pushViewController:qrvc animated:YES];
}

- (IBAction)flashLight:(id)sender {
    if (_beacon == nil) {
        return;
    }
    
    if (_beacon.connectionStatus == SBKBeaconConnectionStatusDisconnected ) {
        _stateText.text = @"连接中...";
        [_beacon connectWithCompletion:^(NSError *error) {
            if (error != nil) {
                _stateText.text = @"连接失败";
                [_beacon disconnect];
            }else{
                _stateText.text = @"已连接，闪灯中...";
                [_beacon flashLightWithCommand:SBKCommonFlashLightCommand_22
                                                        repeat:2
                                                    completion:^(NSError *error) {
                                                        if (error == nil) {
                                                            _stateText.text = @"连接已断开";
                                                        }else{
                                                            _stateText.text = @"闪灯失败";
                                                        }
                                                        [_beacon disconnect];
                                                    }];
            }
        }];
    }
}

#pragma mark SBKBeaconManagerDelegate

- (void)beaconManager:(SBKBeaconManager *)beaconManager didRangeNewBeacon:(SBKBeacon *)beacon {
    [_beacons addObject:beacon];
}

- (void)beaconManager:(SBKBeaconManager *)beaconManager beaconDidGone:(SBKBeacon *)beacon {
    [_beacons removeObject:beacon];
}

- (void)beaconManager:(SBKBeaconManager *)beaconManager scanDidFinishWithBeacons:(NSArray *)beacons {
}

@end
