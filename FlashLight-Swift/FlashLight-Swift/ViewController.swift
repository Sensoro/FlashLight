//
//  ViewController.swift
//  FlashLight-Swift
//
//  Created by skyming on 15/4/14.
//  Copyright (c) 2015年 Sensoro. All rights reserved.
//

import UIKit
import SensoroBeaconKit

class ViewController: UIViewController ,SBKBeaconManagerDelegate{

    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var stateText: UILabel!

    
    var UUIDs:NSArray! = NSArray();
    var beacons:NSMutableArray! = NSMutableArray();
    var _beacon:SBKBeacon? = SBKBeacon();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = .None;
        
        UUIDs = ["23A01AF0-232A-4518-9C0E-323FB773F5EF",
        "63EA09C2-5345-4E6D-9776-26B9C6FC126C",
        "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0",
        "B9407F30-F5F8-466E-AFF9-25556B57FE6D",
        "FDA50693-A4E2-4FB1-AFCF-C6EB07647825"];
        
        SBKBeaconManager.sharedInstance().requestAlwaysAuthorization();
        SBKBeaconManager.sharedInstance().delegate = self;
        
        for  str in UUIDs{
            var beaconID:SBKBeaconID? = SBKBeaconID(string: str as! String);
            SBKBeaconManager.sharedInstance().startRangingBeaconsWithID(beaconID!, wakeUpApplication: false);
            
        }
        
        flashButton.enabled = false;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func scanAYunzi(sender: UIButton) {
        var qrvc:SENQRCodeViewController? = SENQRCodeViewController();
        qrvc?.completion = { ( var value) in
            
            var comps:NSArray? = value.componentsSeparatedByString("|");
            if  (comps!.count < 4){
                self.navigationController?.popViewControllerAnimated(true);
                return ;
            }
            
            var beacon:SBKBeacon? = nil;
            var sn:NSString? = comps?.objectAtIndex(0) as? NSString;
            
            for iter in self.beacons{
                if (sn!.isEqualToString(iter.serialNumber as String)){
                    beacon = iter as? SBKBeacon;
                    break;
                }
            }
            
            if ( beacon == nil){
                var tip:String = "没有扫描到此Beacon，请稍候重试，或者确认此Beacon是否工作";
                
                var av:KDXAlertView? = KDXAlertView(title: "提示", message:tip, cancelButtonTitle:"好的", cancelAction: { (av:KDXAlertView!) -> Void in
                    qrvc?.restartScan();
                });
                av?.show();

            }else{
                
                if let hardwareModeName : NSString = beacon?.hardwareModelName {
                    if (!(hardwareModeName.isEqualToString("C0") && beacon!.firmwareVersion.compare("3.1", options: .NumericSearch) != .OrderedAscending) ){
                     
                        var tip:String? = "只有云盒，且固件版本在3.1以上才支持此功能。";
                        var av:KDXAlertView? = KDXAlertView(title: "提示", message:tip, cancelButtonTitle:"好的", cancelAction: { (av:KDXAlertView!) -> Void in
                            qrvc?.restartScan();
                        });
                        av?.show();
                        return ;
                    }
                    self.stateText.text = "点击\"闪灯\"，来闪烁Beacon的LED灯";
                    self._beacon = beacon;
                    self.flashButton.enabled = true;
                }
            }
        }
        self.navigationController!.pushViewController(qrvc!, animated: true);
    }
    
    
    @IBAction func flashLight(sender: UIButton) {
        if (_beacon == nil){
            return ;
        }
        
        if (_beacon!.connectionStatus() == .Disconnected){
            stateText.text = "连接中...";
    
            _beacon?.connectWithCompletion({ (error:NSError?) -> Void in
                
                if (error != nil){
            
                    self.stateText.text = "连接失败";
                    self._beacon!.disconnect();
                }else{
                    self.stateText.text = "已连接，闪灯中...";
                    
                    let option = SBKCommonLigthFlashCommand.FlashLightCommand_22.rawValue;
                    self._beacon?.flashLightWithCommand(option, repeat: 2, completion: { (error:NSError?) -> Void in
                        if (error == nil){
                            self.stateText.text = "连接已断开";
                        }else{
                            NSLog("XXXXXXXXXXXXXXX----%@", error!.localizedDescription);
                            self.stateText.text = "闪灯失败";
                        }
                        self._beacon?.disconnect();
                    })
                }
            });
        }
    }
    
    func beaconManager(beaconManager: SBKBeaconManager!, didRangeNewBeacon beacon: SBKBeacon!) {
        beacons.addObject(beacon);
    }
    
    func beaconManager(beaconManager: SBKBeaconManager!, beaconDidGone beacon: SBKBeacon!) {
        beacons.removeObject(beacon);
    }
    
    func beaconManager(beaconManager: SBKBeaconManager!, scanDidFinishWithBeacons beacons: [AnyObject]!) {
    }
    
}

