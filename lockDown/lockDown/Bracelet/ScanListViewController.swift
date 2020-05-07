//
//  ScanListViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 01/05/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import MTBeaconPlus

class ScanListViewController: BaseController, UITableViewDataSource, UITableViewDelegate  {
    
    
 
    @IBOutlet weak var tableView: UITableView!
    
    var beaconNameListArray = [String]()
    var manager : MTCentralManager!
    var scannerDevices : Array<MTPeripheral>!
    var currentPeripheral:MTPeripheral?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "scanBraceletTitle".localiz()
        let nib = UINib(nibName: "ScanTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ScanTableViewCell")
        self.tableView.separatorColor = .clear
        
        manager = MTCentralManager.sharedInstance()
        
        manager?.stateBlock = { (state) in
            
            if state != .poweredOn {
                print("the iphone bluetooth state error")
            }
        }
        
        self.startScan()
        
        
//        beaconNameListArray.append("aa:aa:aa:aa")
//        beaconNameListArray.append("aa:aa:aa:aa")
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bg_navBar")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
    }
    // MARK - UITableView Delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return beaconNameListArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier:"ScanTableViewCell", for: indexPath as IndexPath) as! ScanTableViewCell
       
        cell.braceletname.text = self.beaconNameListArray[indexPath.row]
        cell.addBtn.tag = indexPath.row
        cell.addBtn.addTarget(self, action: #selector(addBtnDidTap), for: .touchUpInside)
        cell.selectionStyle = .none
    
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

    
        return 40
    }

    
    @objc func addBtnDidTap(sender : UIButton){
        let braceletStatusVC = BraceletStatusViewController(nibName: "BraceletStatusViewController", bundle: nil)
        braceletStatusVC.macAddress = self.beaconNameListArray[sender.tag]
        self.navigationController!.pushViewController(braceletStatusVC, animated: true)
        //checkMacAdress(macAdress: self.beaconNameListArray[sender.tag])
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Beacons
    
    func startScan() -> Void {
        
        self.startLoading()
        
//        manager.startScan { (devices) in
//            
//            self.startConnect()
//        }
//        scannerDevices = manager.scannedPeris
//        //stopScan()
        
        manager.startScan({ peris in

            self.beaconNameListArray.removeAll()
            // Traverse the array，get instance of every device.
            // ** you can also display them on views.
            for i in 0..<(peris?.count ?? 0) {
                let peri = peris?[i]

                // get FrameHandler of a device.
                // **some properties maybe nil
                let framer = peri?.framer
                let name = framer?.name // name of device, may nil
                let rssi = framer?.rssi ?? 0 // rssi
                let battery = framer?.battery ?? 0 // battery,may nil
                if let mac = framer?.mac{
                    self.beaconNameListArray.append(mac.uppercased().inserting(separator: ":", every: 2))
                }else{
                    //self.beaconNameListArray.append("00:00:00:00:00:00")
                }// mac address,may nil
                
                let frames = framer?.advFrames // all data frames of device（such as:iBeacon，UID，URL...）
            }
            self.tableView.reloadData()
            self.finishLoading()
        })
        
    }
    
    func stopScan() -> Void {
        manager.stopScan()
    }
    
    func connectDevice(peripheral : MTPeripheral) -> Void {
         
         currentPeripheral = peripheral
         
         peripheral.connector.statusChangedHandler = { (status, error) in
             
             if error != nil {
                 print(error as Any)
             }
          
             switch status {
             case .StatusCompleted:
                 self.writeFrame(peripheral: peripheral)
                 DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                     self.getAllSlot()
                     self.getTrigger()
                     self.setLineBeacon()
                     self.writeTrigger(peripheral: peripheral)
                 })
                 
                 self.stopScan()
                 
                 break

             case .StatusDisconnected:
                 
                 print("disconnected")
                 break
                 
             case .StatusConnectFailed:
                 
                 print("connect failed")
                 break
                 
             case .StatusUndifined:
                 break
                 
             default:
                 break
             }
         }
         
         manager.connect(toPeriperal:peripheral, passwordRequire: { (pass) in
             
             pass!("minew123")
         })
     }
     
     func disconnect(peripheral : MTPeripheral) -> Void {
         manager.disconnect(fromPeriperal: peripheral)
     }
     
     func getAllSlot() -> Void {
         for frame in (currentPeripheral?.connector.allFrames)! {
             self.getBroadcastContent(frame: frame)
         }
     }
     

     
     func getBroadcastContent(frame:MinewFrame) -> Void {
                 
         switch frame.frameType {
         case .FrameiBeacon:
             let iBeacon = frame as! MinewiBeacon
             print("iBeacon:\(iBeacon.major)--\(String(describing: iBeacon.uuid))--\( iBeacon.minor)")
             break
         // Same thing with MTSensorPIRData/MTSensorHTData
         case .FrameLineBeacon:
             let lineBeaconLotKey:MTLineBeaconData = currentPeripheral?.connector?.sensorHandler.lineBeaconLotKeyDataDic["lineBeaconLotKeyDataDic"] as! MTLineBeaconData
             let lineBeaconHwidAndVendorKey:MTLineBeaconData = currentPeripheral?.connector?.sensorHandler.lineBeaconDataDic["lineBeaconDataDic"] as! MTLineBeaconData
         print("LineBeacon:\(lineBeaconLotKey.lotKey)--\(lineBeaconHwidAndVendorKey.hwId)--\(lineBeaconHwidAndVendorKey.vendorKey)")
             
             break
         case .FrameURL:
             let url = frame as! MinewURL
             print("URL:\(url.urlString ?? "nil")")
             break
         case .FrameUID:
             let uid = frame as! MinewUID
             print("UID:\(uid.namespaceId ?? "nil")--\(uid.instanceId ?? "nil")")
             break
         case .FrameTLM:
             print("TLM")
             break
         case .FrameDeviceInfo:
             print("DeviceInfo")
             break
         default:
             print("Unauthenticated Frame")
             break
         }
     }
     
     func writeFrame(peripheral : MTPeripheral) -> Void {
         let ib = MinewiBeacon.init()
         ib.slotNumber = 0;
         ib.uuid = "47410a54-99dd-49f9-a2f4-e1a7efe03c13";
         ib.major = 300;
         ib.minor = 30;
         ib.slotAdvInterval = 400;
         ib.slotAdvTxpower = -62;
         ib.slotRadioTxpower = -4;
         
         peripheral.connector.write(ib, completion: { (success, error) in
             if success {
                 print("write success,%d",ib.slotRadioTxpower)
             }
             else {
                 print(error as Any)
             }
         })
         
     }
     
     func setLineBeacon() -> Void {
    
         currentPeripheral?.connector.setLineBeaconLotkey("0011223344556600", completion: { (success, error) in
             if error == nil {
                 print("Set LineBeacon's lotKey success")
             } else {
                 print("Set LineBeacon's lotKey fail")
             }
         })
         
         currentPeripheral?.connector.setLineBeaconHWID("0011223300", vendorKey: "00112200", completion: { (success, error) in
             if error == nil {
                 if error == nil {
                     print("Set LineBeacon's hwid and vendorKey success")
                 } else {
                     print("Set LineBeacon's hwid and vendorKey fail")
                 }
             }
         })
     }
     
     func getTrigger() -> Void {
         let triggerData:MTTriggerData =  currentPeripheral?.connector.triggers[1] ?? MTTriggerData()
         
         print("TriggerData \n type:\(triggerData.type)--advertisingSecond:\(String(describing: triggerData.value))--alwaysAdvertise:\( triggerData.always)--advInterval:\(triggerData.advInterval)--radioTxpower:\(triggerData.radioTxpower)")

     }
     
     func writeTrigger(peripheral : MTPeripheral) -> Void {
         // Tips:Use the correct initialization method for MTTriggerData
         let triggerData = MTTriggerData.init(slot: 1, paramSupport: true, triggerType: TriggerType.btnDtapLater, value: 30)
         triggerData?.always = true;
         triggerData?.advInterval = 100;
         triggerData?.radioTxpower = -20;
         
         peripheral.connector.writeTrigger(triggerData) { (success) in
             if success {
                 print("write triggerData success")
             }
             else {
                 print("write triggerData failed")
             }
         }
     }

}
