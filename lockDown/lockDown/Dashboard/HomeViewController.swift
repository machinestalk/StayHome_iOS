//
//  HomeViewController.swift
//  lockDown
//
//  Created by Aymen HECHMI on 14/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import GoogleMaps
import SystemConfiguration.CaptiveNetwork
import CoreBluetooth
import SystemConfiguration.CaptiveNetwork
import CoreMotion
import CoreLocation
import CoreTelephony
import MTBeaconPlus

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

class HomeViewController: BaseController, CLLocationManagerDelegate, ReachabilityObserverDelegate{

    enum EventType: String {
        case onEntry = "On Entry"
        case onExit = "On Exit"
    }
    
    enum CardState {
        case expanded
        case collapsed
    }
    var requestLocationVC = RequestLocationViewController()
    var ChangeLocationVC = ChangeLocationViewController()
    var biometricsBottomVc = BiometricsBottomViewController()
    var attentionAlertViewControllerOutZone = AttentionAlertViewController(nibName: "AttentionAlertViewController", bundle: nil)
    var attentionAlertViewControllerBluetooth = AttentionAlertViewController(nibName: "AttentionAlertViewController", bundle: nil)
    var attentionAlertViewControllerInternet = AttentionAlertViewController(nibName: "AttentionAlertViewController", bundle: nil)
    var attentionAlertViewControllerBattery = AttentionAlertViewController(nibName: "AttentionAlertViewController", bundle: nil)
    let customTimer = CustomTimer(timeInterval: 60)
    let cardHeight:CGFloat = 300
    let cardHandleAreaHeight:CGFloat = 65
    var cardVisible = false
    var isfirstTime = false
    var isNextBtnTapped = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    private lazy var bluetoothManager = CoreBluetoothManager()
    var peripherals = Array<[String:Any]>()
    var braceletArray = Array<MTPeripheral>()
    var alertBluetoothIsOpen = false
    var alertBatteryIsOpen = false
    var alertInternetIsOpen = false
    var isInternetOK = true
    var bluetoothEnabled = true
    var carrier = CTCarrier()
    var userMotionActivity: CMMotionActivity!
    var userMotionManager: CMMotionManager!
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    var dayQuarantine : Int = 0
    var alertComeBackIsOpen = false
    var outOfZoneCounter : Int = 0
    var zoneRadius : Int = 100
    var currentNetworkInfos: Array<NetworkInfo>? {
        get {
            return  SSID.fetchNetworkInfo()
        }
    }
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    var locValue: CLLocationCoordinate2D!
    var navigatedToMyLocation : Bool! = false
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        manager.allowsBackgroundLocationUpdates = true
        return manager
    }()
    var currentLocation: CLLocationCoordinate2D!
    var countdownTimer: Timer!
    var totalTime : Int!
    var fileURL : URL?
    var fileBLEURL : URL?
    var Colons = [String]()
    var activityManager = ActivityManager()
    var batteryLevel: Float { UIDevice.current.batteryLevel }
    var window: UIWindow?
    var manager : MTCentralManager!
    var scannerDevices : Array<MTPeripheral>!
    var currentPeripheral:MTPeripheral?
    
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusImgTop: NSLayoutConstraint!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var homeImg: UIImageView!
    @IBOutlet weak var homeTip: UILabel!
    @IBOutlet weak var homeTitle: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.window = UIWindow(frame:UIScreen.main.bounds)
        createLogFile()
        createBLELogFile()
        manager = MTCentralManager.sharedInstance()
        manager?.stateBlock = { (state) in
            
            if state != .poweredOn {
                print("the iphone bluetooth state error")
            }
        }
        DispatchQueue.main.async {
            self.startScan()
        }
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        startCustomTimer()
        let deviceId = UserDefaults.standard.value(forKey: "deviceId") as! String
        let start = deviceId.index(deviceId.endIndex, offsetBy: -26)
        let range = start..<deviceId.endIndex
        let miniID = String(deviceId[range])
        bluetoothManager.delegate = self
        bluetoothManager.startAdvertising(with:miniID)
        bluetoothManager.initLocalBeacon()
        self.perform(#selector(self.startScanningBTDevices), with: nil, afterDelay: 2.0)
        activityManager.delegate = self
        activityManager.startActivityScan()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        try? addReachabilityObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(self.getNotificationNoneLocation(notification:)), name: Notification.Name("NotificationNoneLocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationLocation"), object: nil)
        self.navigationItem.rightBarButtonItem = nil
        setLocation()
        let deviceId = UserDefaults.standard.string(forKey: "deviceId")
        let firebaseToken = UserDefaults.standard.string(forKey: "firebaseToken")
        APIClient.sendFirebaseToken(deviceId: deviceId!, firebase_token: firebaseToken!, onSuccess: { (Msg) in
            print(Msg)
        } ,onFailure : { (error) in
            print(error)
        })
        self.startLoading()
        getUserstatus()
        getBracelet()
        getCustomerData()
    }
    
    func reachabilityChanged(_ isReachable: Bool, status: String) {
        
        if isReachable {
            if status == "cellular" {
                isInternetOK = false
                showAlertInternet()
            } else {
                isInternetOK = true
            }
        } else {
            isInternetOK = false
            showAlertInternet()
        }
    }
    
    func getHomeTips(){
        let tenantId = UserDefaults.standard.string(forKey: "tenantId")
        let homeDataFuture = APIClient.getTipsHome(tenantId: tenantId!)
        homeDataFuture.execute(onSuccess: { homeDataArray in
            self.finishLoading()
            if self.dayQuarantine > 0 {
                print("homeDataArray == > \(homeDataArray)")
                let homeData = homeDataArray.filter{ $0.key == "Day \(self.dayQuarantine)" }
                let stringJson = homeData[0].value as? String
                let dicHome = stringJson?.convertToDictionary()
                if let body = dicHome!["body"] as? String {
                    self.homeTip.text = body
                }
                if let title = dicHome!["title"] as? String {
                    self.homeTitle.text = title
                }
                self.dayNumber.text = "\(self.dayQuarantine)"
            }
            let version = homeDataArray.filter{ $0.key == "lastVersionIOS"}
            if let versionValue = version.first?.value as? String {
                print("versionValue ==> \(versionValue)")
                let urlobject = homeDataArray.filter{ $0.key == "url-app-ios"}
                if let url = urlobject.first?.value as? String {
                    print("versionValue ==> \(url)")
                    self.checkAppVersion(version: versionValue , urlStr: url)
                }
            }
            self.checkAllServicesActivityFromBackground()
            
        }, onFailure: {error in
            self.finishLoading()
            let errorr = error as NSError
            let errorDict = errorr.userInfo
            self.checkAllServicesActivityFromBackground()
        })
    }
    
    
    func getCustomerData(){
        let customerId = UserDefaults.standard.string(forKey: "customerId")
        let CustomerDataFuture = APIClient.getCustomerData(customerId: customerId! )
        CustomerDataFuture.execute(onSuccess: { customerData in
            print("customerData == > \(customerData)")
            if let lastDay = (customerData.lastDay?.first?.value as? String) {
                let date = Date(timeIntervalSince1970: Double(lastDay) as! TimeInterval)
                self.dayQuarantine = date.interval(ofComponent: .day, fromDate: Date())
                print("diff == > \(self.dayQuarantine)")
                UserDefaults.standard.set(self.dayQuarantine, forKey: "dayQuarantine")
            }
            if let lat = customerData.latitude?.first!.value {
                if let long = customerData.longitude?.first!.value {
                    let locValue:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: Double((lat as! NSString).doubleValue), longitude: Double((long as! NSString).doubleValue))
                    UserDefaults.standard.set(location:locValue, forKey:"myhomeLocation")
                    UserDefaults.standard.set(true, forKey: "isLocationSetted")
                    UserDefaults.standard.set(true, forKey: "isSignedUp")
                }
            }
            if let radious = customerData.radius?.first?.value {
                print("radious == > \(radious)")
                self.zoneRadius = Int(radious) ?? 100
                UserDefaults.standard.set(self.zoneRadius, forKey: "zoneRadius")
            }
            self.getHomeTips()
            
        }, onFailure: {error in
            let errorr = error as NSError
            let errorDict = errorr.userInfo
            self.finishLoading()
        })
    }
    
    func getBracelet(){
        let customerId = UserDefaults.standard.string(forKey: "customerId")
        APIClient.getBracelet(customerId: customerId!,onSuccess: { (responseObject) in
            self.finishLoading()
            if let objectDict = responseObject.convertToDictionary(){
                if let data =  objectDict["data"] as? NSArray{
                    if let braceletDict = data.firstObject as? [String : Any] {
                        if let macAddress =  braceletDict["name"] as? String {
                            if UserDefaults.standard.valueExists(forKey: "connected_bracelet"){
                                UserDefaults.standard.removeObject(forKey: "connected_bracelet")
                            }
                            UserDefaults.standard.set(macAddress, forKey:"connected_bracelet")
                            
                        }
                    }
                }}
        } ,onFailure : { (error) in
            print(error)
        })
    }
    
    func checkAppVersion(version : String , urlStr :String  ){
        if let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if  version == versionNumber  {
                print("Version is Supported")
            }
            else {
                let alert = UIAlertController(title: "", message: "versionUpdate_txt".localiz(), preferredStyle: UIAlertController.Style.alert)
                
                // Button to Open Settings
                alert.addAction(UIAlertAction(title: "Ok_text".localiz(), style: UIAlertAction.Style.default, handler: { action in
                    
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
                        
                    } else {
                        UIApplication.shared.openURL(URL(string: urlStr)!)
                    }
                }))
                var rootViewController = UIApplication.shared.keyWindow?.rootViewController
                if let navigationController = rootViewController as? UINavigationController {
                    rootViewController = navigationController.viewControllers.first
                }
                rootViewController?.present(alert, animated: true, completion: nil)
                
                
            }
        }
    }
    
    @objc func batteryLevelDidChange(_ notification: Notification) {
        
    }
    
    // MARK: Beacons
    
    func startScan() -> Void {
        manager.startScan { (devices) in
        }
        scannerDevices = manager.scannedPeris
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
    
    
    // MARK: Show Alerts
    
    func showAlertBluetooth(){
        
        if !UserDefaults.standard.bool(forKey: "didShowAlertBluetooth") {
            
            self.appDelegate.scheduleNotification(notificationType: "Alert_bluetooth_msg_txt")
            UserDefaults.standard.set(true, forKey: "didShowAlertBluetooth")
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"bluetooth"])
        }
    }
    
    func showAlertBracelet(){
        
        if !UserDefaults.standard.bool(forKey: "didShowAlertBracelet") {
            self.appDelegate.scheduleNotification(notificationType: "errorMsgConnection")
            UserDefaults.standard.set(true, forKey: "didShowAlertBracelet")
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"bracelet"])
        }
    }
    
    func showAlertBattery(){
        
        if !UserDefaults.standard.bool(forKey: "didShowAlertBattery") {
            
            self.appDelegate.scheduleNotification(notificationType: "Alert_battery_msg_txt")
            UserDefaults.standard.set(true, forKey: "didShowAlertBattery")
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"battery"])
        }
    }
    
    func showAlertInternet(){
        
        if !UserDefaults.standard.bool(forKey: "didShowAlertInternet") {
            self.appDelegate.scheduleNotification(notificationType: "Alert_wifi_msg_txt")
            UserDefaults.standard.set(true, forKey: "didShowAlertInternet")
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"internet"])
            
        }
    }
    
    func showAlertZoneWithEvent(eventType : EventType){
        
        switch eventType {
        case .onEntry:
            if !UserDefaults.standard.bool(forKey: "didEnterZone") {
                //                DispatchQueue.main.async {
                //                    NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"zone_entry"])
                //                }
                self.appDelegate.scheduleNotification(notificationType: "Alert_in_zone_msg_txt")
                UserDefaults.standard.set(true, forKey: "didEnterZone")
                UserDefaults.standard.set(false, forKey: "didExitZone")
            }
        case .onExit:
            
            if !UserDefaults.standard.bool(forKey: "didExitZone") {
                self.appDelegate.scheduleNotification(notificationType: "Alert_out_zone_msg_txt")
                UserDefaults.standard.set(true, forKey: "didExitZone")
                UserDefaults.standard.set(false, forKey: "didEnterZone")
            }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"zone_exit"])
            }
        }
    }
    
    // MARK: Check All Services
    
    func checkAllServicesActivityFromBackground()  {
        
        getUserstatus()
        
        if (batteryLevel  < 0.2 && batteryLevel > 0.0 ) {
            showAlertBattery()
        }
        
        let myMacAdress = UserDefaults.standard.string(forKey:"connected_bracelet")
        
        if manager != nil {
            
            var braceletVisible = false
            for key in manager.scannedPeris {
                var bleName = "Unknown"
                var mac = "Unknown"
                if key.framer.name != nil {
                    bleName = key.framer.name
                }
                
                if key.framer.mac != nil {
                    mac = key.framer.mac
                    if mac.uppercased().inserting(separator: ":", every: 2) == myMacAdress {
                        braceletVisible = true
                        break
                    }
                }
                
            }
            if !braceletVisible && myMacAdress != nil {
                showAlertBracelet()
            }else{
                UserDefaults.standard.set(false, forKey: "didShowAlertBracelet")
            }
        }
        
        if !bluetoothEnabled{
            showAlertBluetooth()
        }
        
        
        activityManager.delegate = self
        activityManager.startActivityScan()
        
    }
    
    
    // MARK: getAllWiFiNameList
    
    func getAllWiFiNameList() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }
    
    // MARK: Check if location services are enabledlog
    
    func checkIfLocationEnabled() -> String{
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                print("notDetermined")
                self.appDelegate.scheduleNotification(notificationType: "Alert_gps_msg_txt")
                return "notDetermined"
                
            case .restricted :
                print("restricted")
                self.appDelegate.scheduleNotification(notificationType: "Alert_gps_msg_txt")
                return "restricted"
            case .denied:
                print("denied")
                self.appDelegate.scheduleNotification(notificationType: "Alert_gps_msg_txt")
                return "denied"
            case .authorizedAlways:
                print("authorizedAlways")
                return "authorizedAlways"
            case .authorizedWhenInUse:
                print("authorizedWhenInUse")
                return "authorizedWhenInUse"
            @unknown default:
                print("default")
                return "no one"
            }
        } else {
            print("Location services are not enabled")
            self.appDelegate.scheduleNotification(notificationType: "Alert_gps_msg_txt")
            return "notEnabled"
            
        }
    }
    
    @objc func startScanningBTDevices(){
        
        bluetoothManager.startScanning()
    }
    
    // MARK: setLocations
    func setLocation() {
        //Location Manager code to fetch current location
        if  !UserDefaults.standard.bool(forKey: "isSignedUp")  {
            if CLLocationManager.authorizationStatus() == .authorizedAlways {
                
                locValue = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
                
                // scheduledTimerWithTimeInterval()
            }
            else {
                locValue = CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
                checkUsersLocationServicesAuthorization()
            }
        }
        else {
            if CLLocationManager.authorizationStatus() == .authorizedAlways {
                
                locValue = UserDefaults.standard.location(forKey:"myhomeLocation")
                
            }
            else {
                locValue = CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
                checkUsersLocationServicesAuthorization()
            }
        }
    }
    
    
    
    func checkUsersLocationServicesAuthorization(){
        /// Check if user has authorized Total Plus to use Location Services
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            // Request when-in-use authorization initially
            // This is the first and the ONLY time you will be able to ask the user for permission
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied,.authorizedWhenInUse:
            // Disable location features
            // switchAutoTaxDetection.isOn = false
            let alert = UIAlertController(title: "", message: "locationAlert_txt".localiz(), preferredStyle: UIAlertController.Style.alert)
            
            // Button to Open Settings
            alert.addAction(UIAlertAction(title: "Settings_txt".localiz(), style: UIAlertAction.Style.default, handler: { action in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }))
            self.present(alert, animated: true, completion: nil)
            
            break
            
        case  .authorizedAlways:
            // Enable features that require location services here.
            
            locValue = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
            
            break
        }
        
    }
    @objc func getNotificationNoneLocation(notification: Notification) {
        setLocation()
    }
    @objc func methodOfReceivedNotification(notification: Notification) {
        setLocation()
        
    }
    @IBAction func menuDidTap(_ sender: Any) {
        if(LanguageManger.shared.isRightToLeft==true){
            
            self.sideMenuController?.toggleRightViewAnimated()
            
        }
        else {
            self.sideMenuController?.toggleLeftViewAnimated()
        }
    }
    
    //MARK: Location Manager delegates
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let lastLocation = locations.last {
            currentLocation = lastLocation.coordinate
        }
        locValue = currentLocation
        print("horizontalAccuracy : \( manager.location!.horizontalAccuracy)")
        print("desiredAccuracy : \(manager.desiredAccuracy)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // manager.requestLocation()
            break
        case .restricted, .denied, .authorizedWhenInUse:
            self.appDelegate.scheduleNotification(notificationType: "Alert_gps_msg_txt")
            let alert = UIAlertController(title: "", message: "locationAlert_txt".localiz(), preferredStyle: UIAlertController.Style.alert)
            // Button to Open Settings
            alert.addAction(UIAlertAction(title: "Settings_txt".localiz(), style: UIAlertAction.Style.default, handler: { action in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }))
            self.present(alert, animated: true, completion: nil)
            break
        case .authorizedAlways :
            
            locValue = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
            
            
            break
        default: break
            // Permission denied, do something else
        }
    }
    
    func writeDataToLogFile() {
        
        let deviceToken = UserDefaults.standard.string(forKey: "DeviceToken")
        createBLELogFile()
        if  UserDefaults.standard.bool(forKey: "isSignedUp")  {
            if peripherals.count > 0{
                for index in 0...peripherals.count - 1 {
                    let infoDict = peripherals[index]
                    var bleName = "Unknown"
                    if infoDict["Name"] != nil {
                        bleName = infoDict["Name"] as! String
                    }
                    //let bleUID = infoDict["UID"]
                    let bleRSSI = infoDict["RSSI"]
                    let data = infoDict["Data"] as! String
                    
                    let uid = String(format:"%@, %@",bleName ,bleRSSI as! NSNumber)
                    let info = String(format:"StayHomeApp_%@",data)
                    
                    let dataDictToSend = ["info":info,"iBeacon":Constants.SERVICE_UUID.rawValue,"UID":uid,"URL":"","Acc":"","TLM":batteryLevel] as [String : Any]
                    logToBLEFile(value: String(format:" %@ ; StayHomeApp_%@ ; %@ ; %@ ; %@ ; %@ ; %f ; \n", Date() as NSDate, data, Constants.SERVICE_UUID.rawValue, uid,"","",batteryLevel))
                    
                    /*APIClient.sendBLEScannedTelimetry(deviceToken:deviceToken! , data: dataDictToSend, onSuccess: { (Msg) in
                     print(Msg)
                     } ,onFailure : { (error) in
                     print(error)
                     })*/
                }
            }
            
            if manager != nil {
                stopScan()
                braceletArray = manager.scannedPeris
                for key in braceletArray {
                    var bleName = "Unknown"
                    var mac = "Unknown"
                    if key.framer.name != nil {
                        bleName = key.framer.name
                    }
                    if key.framer.mac != nil {
                        mac = key.framer.mac
                    }
                    sendScannedDataFrames(frames: key.framer.advFrames,deviceName: bleName,deviceMac:mac)
                    
                }
                braceletArray.removeAll()
                DispatchQueue.main.async {
                    self.startScan()
                }
            }
            
            
            createLogFile()
            if userMotionActivity != nil  {
                logToFile(value: "\(Date()) ; \(userMotionActivity ?? CMMotionActivity()) ; user in zone ;  \(locValue.latitude) ; \(locValue.longitude) ; \(peripherals)) ; \(currentNetworkInfos?.first?.ssid ??  "nil") ; \(batteryLevel) ; \(checkIfLocationEnabled()) ; \(bluetoothEnabled) ; \(isInternetOK) ; \(locationManager.location?.horizontalAccuracy ?? 0) ; \(userMotionManager.accelerometerData) ; \(userMotionManager.gyroData) ; \(userMotionManager.magnetometerData) ; \(userMotionManager.deviceMotion)\n")
            }
            peripherals.removeAll()
            startScanningBTDevices()
        }
    }
    
    // MARK : Send Data to the Server
    
    func sendScannedDataFrames(frames: [MinewFrame] ,deviceName: String,deviceMac: String){
        
        let deviceToken = UserDefaults.standard.string(forKey: "DeviceToken")
        let dictParams: NSMutableDictionary? = ["info":"","iBeacon":"","UID":"","URL":"","Acc":"","TLM":""]
        
        for i in 0..<frames.count {
            let frame = frames[i]
            
            switch frame.frameType {
            case .FrameiBeacon:
                let bea = frame as? MinewiBeacon
                if let uuid = bea?.uuid, let major = bea?.major, let minor = bea?.minor {
                    print(String(format: "iBeacon:%@, %ld, %ld", uuid, major, minor))
                    dictParams!["iBeacon"] = String(format:"%@, %ld, %ld", uuid, major, minor)
                }
            case .FrameUID:
                let uid = frame as? MinewUID
                if let namespaceId = uid?.namespaceId, let instanceId = uid?.instanceId, let txPower = uid?.txPower {
                    print(String(format: "UID:%@, %@, %ld", namespaceId, instanceId, txPower))
                    dictParams!["UID"] = String(format:"%@, %@, %ld", namespaceId, instanceId, txPower)
                }
            case .FrameDeviceInfo:
                let info = frame as? MinewDeviceInfo
                if let mac = info?.mac, let name = info?.name {
                    print(String(format: "DeviceInfo: %ld, %@, %@", Int(info?.battery ?? 0), mac, name))
                    //dictParams!["info"] = String(format:"%ld, %@, %@", Int(info?.battery ?? 0), mac, name)
                }
                
            case .FrameTLM:
                
                let tlm = frame as? MinewTLM
                if let batteryVol = tlm?.batteryVol, let temperature = tlm?.temperature, let advCount = tlm?.advCount, let secCount = tlm?.secCount {
                    print(String(format:"TLM: %ld, %f, %ld, %ld",batteryVol, temperature, advCount, secCount))
                    dictParams!["TLM"] = String(format:"%ld, %f, %ld, %ld",batteryVol, temperature, advCount, secCount)
                }
                
            case .FrameURL:
                
                let url = frame as? MinewURL
                if let txPower = url?.txPower, let urlString = url?.urlString {
                    print(String(format:"URL: %ld, %@", txPower, urlString))
                    dictParams!["URL"] = String(format:"%@", urlString)
                }
                
                
            case .FrameAccSensor:
                
                let acc = frame as? MinewAccSensor
                if let xAxis = acc?.xAxis, let yAxis = acc?.yAxis, let zAxis = acc?.zAxis {
                    print(String(format:"ACC: %f, %f, %f", xAxis, yAxis, zAxis))
                    dictParams!["Acc"] = String(format:"%f, %f, %f", xAxis, yAxis, zAxis)
                }
                
            case .FrameNone:
                break
            case .FrameConnectable:
                break
            case .FrameUnknown:
                break
            case .FrameHTSensor:
                break
            case .FrameLightSensor:
                break
            case .FrameQlock:
                break
            case .FrameDFU:
                break
            case .FrameRoambee:
                break
            case .FrameForceSensor:
                break
            case .FramePIRSensor:
                break
            case .FrameTVOCSensor:
                break
            case .FrameSingleTempSensor:
                break
            case .FrameLineBeacon:
                break
            @unknown default:
                break
            }
            
        }
        dictParams!["info"] = String(format:"%@, %@", deviceName, deviceMac)
        logToBLEFile(value: String(format:"%@ ; %@ ; %@ ; %@ ; %@ ; %@ ; %@ ; \n", Date() as NSDate, dictParams!["info"] as! String, dictParams!["iBeacon"] as! String,dictParams!["UID"] as! String,dictParams!["URL"] as! String,dictParams!["Acc"] as! String,dictParams!["TLM"] as! String))
        
        /*APIClient.sendBLEScannedTelimetry(deviceToken:deviceToken! , data: dictParams as! [String : Any], onSuccess: { (Msg) in
         print(Msg)
         } ,onFailure : { (error) in
         print(error)
         })*/
    }
    
    //MARK : Add Timer
    
    func startCustomTimer() {
        
        customTimer.eventHandler = {
            if self.locationManager.location != nil && self.locValue != nil {
                self.checkAllServicesActivityFromBackground()
            }
            self.registerBackgroundTask()
        }
        customTimer.resume()
    }

    //MARK : Check User out of zone
    
    func getUserstatus(){
        
        let deviceToken = UserDefaults.standard.string(forKey: "DeviceToken")
        let myhomeLocation = UserDefaults.standard.location(forKey:"myhomeLocation")
        let Circleloc : CLLocation =  CLLocation(latitude: myhomeLocation?.latitude ?? 0.0, longitude: myhomeLocation?.longitude ?? 0.0)
        locValue = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
        let myLocation : CLLocation =  CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        let distance = Circleloc.distance(from: myLocation)
        if(Int(distance) >= self.zoneRadius)
        {
            outOfZoneCounter += 1
            
            if UserDefaults.standard.object(forKey: "didExitZone") == nil {
                UserDefaults.standard.set(false, forKey: "didExitZone")
            }
            showAlertZoneWithEvent(eventType: .onExit)
            
            if outOfZoneCounter == 3 {
                outOfZoneCounter = 0
                APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 0, raison: "user out of zone",zoneStatus:0, onSuccess: { (Msg) in
                    print(Msg)
                } ,onFailure : { (error) in
                    print(error)
                })
            }
        }else {
            outOfZoneCounter = 0
            if UserDefaults.standard.object(forKey: "didEnterZone") == nil {
                UserDefaults.standard.set(false, forKey: "didEnterZone")
            }
            showAlertZoneWithEvent(eventType: .onEntry)
            APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 1, raison: "user in zone",zoneStatus:1, onSuccess: { (Msg) in
                print(Msg)
            } ,onFailure : { (error) in
                print(error)
            })
            
        }
        writeDataToLogFile()
    }
    
    // MARK : Log in File
    
    func createLogFile(){
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let dateString = Date().toString(dateFormat:"yyyyMMdd")
        let logFileName = "\(dateString).csv"
        let filePath = url.appendingPathComponent(logFileName).path
        let fileManager = FileManager.default
        
        if fileURL == nil {
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                fileURL = dir.appendingPathComponent(logFileName)
            }
        }
        
        
        if fileManager.fileExists(atPath: filePath) {
            print("FILE AVAILABLE")
        } else {
            print("FILE NOT AVAILABLE")
            let titleString = "DateTime ; UserActivity ; Status ; latitude ; longitude ; bluetooth ; wifi ; batteryLevel ; locationState ; bluetoothEnabled ; isInternetAvailable ; Accuracy ; accelerometerData ; gyroData ; magnetometerData ; deviceMotion ; "
            
            do {
                try "\(titleString)\n".write(to: fileURL!, atomically: false, encoding: String.Encoding.utf8)
            } catch {
                print(error)
            }
        }
    }
    
    func createBLELogFile(){
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let dateString = Date().toString(dateFormat:"yyyyMMdd")
        let logFileName = "BLE_SCAN_\(dateString).csv"
        let filePath = url.appendingPathComponent(logFileName).path
        let fileManager = FileManager.default
        
        if fileBLEURL == nil {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                fileBLEURL = dir.appendingPathComponent(logFileName)
            }
        }
        
        if fileManager.fileExists(atPath: filePath) {
            print("FILE AVAILABLE")
        } else {
            print("FILE NOT AVAILABLE")
            
            let titleString = " DateTime ; info ; iBeacon ; UID ; URL ; Acc ; TLM ;"
            
            do {
                try "\(titleString)\n".write(to: fileBLEURL!, atomically: false, encoding: String.Encoding.utf8)
            } catch {
                print(error)
            }
        }
    }
    
    func logToFile(value : String)  {

        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL!)
            fileHandle.seekToEndOfFile()
            fileHandle.write(value.data(using: .utf8)!)
            fileHandle.closeFile()
        } catch {
            print("Error writing to file \(error)")
        }
    }
    
    func logToBLEFile(value : String)  {
        
        if fileBLEURL != nil {
            do {
                let fileHandle = try FileHandle(forWritingTo: fileBLEURL!)
                fileHandle.seekToEndOfFile()
                fileHandle.write(value.data(using: .utf8)!)
                fileHandle.closeFile()
            } catch {
                print("Error writing to file \(error)")
            }
        }
        
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            [unowned self] in
            self.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskIdentifier.invalid)
    }
    
    func endBackgroundTask() {
        NSLog("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskIdentifier.invalid
    }
}

extension HomeViewController : BiometricsAuthProtocol{
    func requestRecognition(){
        UserDefaults.standard.set(true, forKey: "isLocationSetted")
        UserDefaults.standard.set(location:locValue, forKey:"myhomeLocation")
        let customerId = UserDefaults.standard.string(forKey: "customerId")
        
        APIClient.sendLocationTelimetry(deviceid: customerId!, latitude: String(locValue!.latitude), longitude: String(locValue!.longitude), radius: "100", onSuccess: { (Msg) in
            print(Msg)
            self.biometricsBottomVc.view.removeFromSuperview()
        } ,onFailure : { (error) in
            print(error)
        })
        let biometricsAuthVC = BiometricsAuthViewController(nibName: "BiometricsAuthViewController", bundle: nil)
        self.navigationController!.pushViewController(biometricsAuthVC, animated: true)
    }
    
}

public class SSID {
    class func fetchNetworkInfo() -> [NetworkInfo]? {
        if let interfaces: NSArray = CNCopySupportedInterfaces() {
            var networkInfos = [NetworkInfo]()
            for interface in interfaces {
                let interfaceName = interface as! String
                var networkInfo = NetworkInfo(interface: interfaceName,
                                              success: false,
                                              ssid: nil,
                                              bssid: nil)
                if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary? {
                    networkInfo.success = true
                    networkInfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
                    networkInfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
                }
                networkInfos.append(networkInfo)
            }
            return networkInfos
        }
        return nil
    }
    class func getAllWiFiNameList() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                }
            }
        }
        return ssid
    }
    class func fetchSSIDInfo() -> String {
        var currentSSID = ""
        if let interfaces = CNCopySupportedInterfaces() {
            for i in 0..<CFArrayGetCount(interfaces) {
                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
                if let interfaceData = unsafeInterfaceData as? [String: AnyObject] {
                    currentSSID = interfaceData["SSID"] as! String
                }
            }
        }
        return currentSSID
    }
    
}

struct NetworkInfo {
    var interface: String
    var success: Bool = false
    var ssid: String?
    var bssid: String?
}
extension HomeViewController: responceProtocol {
    func oKClick() {
        alertComeBackIsOpen = false
        self.attentionAlertViewControllerOutZone.view.removeFromSuperview()
    }
    
    func emergencyClick() {
        alertComeBackIsOpen = false
        self.attentionAlertViewControllerOutZone.view.removeFromSuperview()
    }
    
    
}

extension HomeViewController: BluetoothManagerDelegate {
    
    func peripheralsDidUpdate(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        var bleName = "Unknoun"
        if advertisementData["kCBAdvDataLocalName"] != nil{
            bleName = advertisementData["kCBAdvDataLocalName"] as! String
            peripherals.append(["UID":peripheral.identifier,"Name":bleName as Any,"RSSI":RSSI,"Data":peripheral.name as Any])
        }else if peripheral.name != nil {
            bleName = peripheral.name!
        }
        
    }
    
    func centralStateOn() {
        bluetoothEnabled = true
    }
    
    func centralStateOff() {
        bluetoothEnabled = false
        showAlertBluetooth()
    }
}

extension HomeViewController: ActivityManagerDelegate {
    
    func activityDidUpdate(data: CMMotionActivity, motionManager: CMMotionManager) {
        userMotionActivity = data
        userMotionManager = motionManager
    }
}


