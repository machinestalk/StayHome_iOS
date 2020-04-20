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

class HomeViewController: BaseController, CLLocationManagerDelegate{
    
    enum CardState {
        case expanded
        case collapsed
    }
    var requestLocationVC = RequestLocationViewController()
    var ChangeLocationVC = ChangeLocationViewController()
    var biometricsBottomVc = BiometricsBottomViewController()
    var attentionAlertViewControllerOutZone = AttentionOutZoneAlertViewController()
    var attentionAlertViewControllerBluetooth : AttentionAlertViewController!
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
    //Bluetooth
    
    private lazy var bluetoothManager = CoreBluetoothManager()
    
    var peripherals = Array<CBPeripheral>()
    
    var alertBluetoothIsOpen = false
    var alertBatteryIsOpen = false
    var alertInternetIsOpen = false
    
    var carrier = CTCarrier()
    
    var userMotionActivity: CMMotionActivity!
    var userMotionManager: CMMotionManager!
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid

    func getTelephonyInfo() -> Dictionary<String, CTCarrier>{
        
        let networkInfo = CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            let serviceSubscriberCellularProviders = networkInfo.serviceSubscriberCellularProviders
            return serviceSubscriberCellularProviders!
        }
        return ["Not found":CTCarrier()]
    }
    
    
    
    var alertComeBackIsOpen = false
    
    //show Alert Bluetooth
    func showAlertComeBack(){
        if !alertComeBackIsOpen{
            let height = view.frame.height
            let width  = view.frame.width
            attentionAlertViewControllerOutZone.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
            attentionAlertViewControllerOutZone.delegate = self
            self.addChild(attentionAlertViewControllerOutZone)
            self.view.addSubview(attentionAlertViewControllerOutZone.view)
            attentionAlertViewControllerOutZone.didMove(toParent: self)
        }
    }
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
      manager.allowsBackgroundLocationUpdates = true
      return manager
    }()
    var currentLocation: CLLocationCoordinate2D!

    var countdownTimer: Timer!
    var totalTime : Int!
    var fileURL : URL?
    var Colons = [String]()
    
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusImgTop: NSLayoutConstraint!
    @IBOutlet weak var searchtxt: TextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var satBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    
    var activityManager = ActivityManager()
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        locationManager.startUpdatingLocation()

        //is Battery Monitoring Enabled
        UIDevice.current.isBatteryMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        startCustomTimer()
        
        // wifi changed
        do{
            Network.reachability = try CustomReachability(hostname: "www.google.com")
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: .flagsChanged, object: Network.reachability)
            
            do {
                try Network.reachability?.start()
            } catch let error as Network.Error {
                print(error)
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        if(!isInternetAvailable()){
            showAlertInternet()
        }
        let userPhoneNumber = UserDefaults.standard.value(forKey: "UserNameSignUp") as! String
        bluetoothManager.delegate = self
        bluetoothManager.startAdvertising(with: "BT:\(userPhoneNumber)")
        
        self.perform(#selector(self.startScanningBTDevices), with: nil, afterDelay: 2.0)
        
        //getSpeed
        // Do any additional setup after loading the view, typically from a nib.
        
        activityManager.delegate = self
        activityManager.startActivityScan()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getNotificationNoneLocation(notification:)), name: Notification.Name("NotificationNoneLocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationLocation"), object: nil)
        self.navigationItem.rightBarButtonItem = nil

        let dateString = Date().toString(dateFormat: "yyyyMMdd")
        let logFileName = "\(dateString).csv"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            fileURL = dir.appendingPathComponent(logFileName)
        }
        setLocation()
        let deviceId = UserDefaults.standard.string(forKey: "deviceId")
        let firebaseToken = UserDefaults.standard.string(forKey: "firebaseToken")
        APIClient.sendFirebaseToken(deviceId: deviceId!, firebase_token: firebaseToken!, onSuccess: { (Msg) in
            print(Msg)
        } ,onFailure : { (error) in
            print(error)
        }
        )
        //show Alert Internet when is Internet not Available
        if(!isInternetAvailable()){
            showAlertInternet()
        }
        //
        
        //Create log file if not yet created
        
        carrier = getTelephonyInfo().first!.value
    }
    @objc func batteryLevelDidChange(_ notification: Notification) {
        print( "batteryLevel = \(batteryLevel)" )
        if(batteryLevel<20 && batteryLevel>0){
            showAlertBattery()
             
        }
    }
    // MARK: Show Alerts

    func showAlertBluetooth(){
        NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"bluetooth"])
        self.appDelegate.scheduleNotification(notificationType: "Alert_bluetooth_msg_txt")
    }

    func showAlertBattery(){
        NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"battery"])
        self.appDelegate.scheduleNotification(notificationType: "Alert_battery_msg_txt")
    }

    func showAlertInternet(){
        NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"internet"])
    }
    func showAlertZone(){
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"zone"])
            
        }
        self.appDelegate.scheduleNotification(notificationType: "Alert_out_zone_msg_txt")
    }
    
    func checkAllServicesActivityFromBackground()  {

         batteryLevel = Int(UIDevice.current.batteryLevel)
        
        let userPhoneNumber = UserDefaults.standard.value(forKey: "UserNameSignUp") as! String
        bluetoothManager.delegate = self
        bluetoothManager.startAdvertising(with: "BT:\(userPhoneNumber)")
        
        self.perform(#selector(self.startScanningBTDevices), with: nil, afterDelay: 2.0)
        
        activityManager.delegate = self
        activityManager.startActivityScan()
        
        getUserstatus()
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
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }

    @IBAction func menuDidTap(_ sender: Any) {
        if(LanguageManger.shared.isRightToLeft==true){
            
            self.sideMenuController?.toggleRightViewAnimated()
            
        }
        else {
            self.sideMenuController?.toggleLeftViewAnimated()
        }
    }
    
    //Location Manager delegates
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
    let motionManager = CMMotionManager()

    func showAlertSpeed(){
//        if(bluetoothEnabled == false){
//            let alert = UIAlertController(title: "speed", message: "Please your speed > 10K/H", preferredStyle: .alert)
//
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//
//            self.present(alert, animated: true)
//        }
    }
    @objc func getSpeed(){
        
        
//        let speed = Double((locationManager.location?.speed)!)
//
//        print(String(format: "%.0f km/h", speed * 3.6)) //Current speed in km/h
//
//        //If speed is over 10 km/h
//        if(speed * 3.6 > 10 ){
//            showAlertSpeed()
//            //Getting the accelerometer data
//            if motionManager.isAccelerometerAvailable{
//                let queue = OperationQueue()
//                motionManager.startAccelerometerUpdates(to: queue, withHandler:
//                    {data, error in
//
//                        guard let data = data else{
//                            return
//                        }
//
//                        print("X = \(data.acceleration.x)")
//                        print("Y = \(data.acceleration.y)")
//                        print("Z = \(data.acceleration.z)")
//
//                }
//                )
//            } else {
//                print("Accelerometer is not available")
//            }
//
//        }
    }
    
   
    //internet state change
    
    @objc func reachabilityChanged(_ note: NSNotification) {
        //V1
        guard let status = Network.reachability?.status else { return }
        switch status {
        case .unreachable:
            isInternetOK = false
            print("Not reachable")
            showAlertInternet()
        case .wifi:
            isInternetOK = true
            print("wifi reachable")
        case .wwan:
            isInternetOK = true
            print("wwan reachable")
        }
        
    }

    
    func writeDataToLogFile() {
        
        createLogFile()
        if userMotionActivity != nil &&  locValue != nil {
            if  UserDefaults.standard.bool(forKey: "isSignedUp")  {
                logToFile(value: "\(Date()) ; \(userMotionActivity ?? CMMotionActivity()) ; user in zone ;  \(locValue.latitude) ; \(locValue.longitude) ; \(Array(Set(peripherals))) ; \(currentNetworkInfos?.first?.ssid ??  "nil") ; \(batteryLevel) ; \(checkIfLocationEnabled()) ; \(bluetoothEnabled) ; \(isInternetAvailable()) ; \(locationManager.location?.horizontalAccuracy ?? 0) ; \(userMotionManager.accelerometerData) ; \(userMotionManager.gyroData) ; \(userMotionManager.magnetometerData) ; \(userMotionManager.deviceMotion)\n")
                peripherals.removeAll()
            }
        }
    }

    
    // MARK : Set counter for Check In
    
    //MARK : Add Timer
    
    func startCustomTimer() {
        
        customTimer.eventHandler = {
            if self.locationManager.location != nil && self.locValue != nil {
                self.getUserstatus()
            }
            self.registerBackgroundTask()
        }
        customTimer.resume()
    }
    
    // MARK : Desactivate Timer
    func desactivateTimer()  {
        if(countdownTimer != nil ){
            countdownTimer.invalidate()
            countdownTimer = nil
        }
    }
    //MARK : Check User out of zone
    func getUserstatus(){
        let deviceToken = UserDefaults.standard.string(forKey: "DeviceToken")
        let myhomeLocation = UserDefaults.standard.location(forKey:"myhomeLocation")
        let Circleloc : CLLocation =  CLLocation(latitude: myhomeLocation?.latitude ?? 0.0, longitude: myhomeLocation?.longitude ?? 0.0)
        locValue = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
        let myLocation : CLLocation =  CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        let distance = Circleloc.distance(from: myLocation)
        if(distance >= 100)
        {
            showAlertZone()
            APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 0, raison: "user out of zone", onSuccess: { (Msg) in
                print(Msg)
            } ,onFailure : { (error) in
                print(error)
            })
        }
        else {
            APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 1, raison: "user in zone", onSuccess: { (Msg) in
                print(Msg)
            } ,onFailure : { (error) in
                print(error)
            })
            
        }
        writeDataToLogFile()
    }
    
    // MARK : Log in File
    
    //create file
    func createLogFile(){
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let dateString = Date().toString(dateFormat:"yyyyMMdd")
        let logFileName = "\(dateString).csv"
        let filePath = url.appendingPathComponent(logFileName).path
        let fileManager = FileManager.default
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
    //add data to log file
    func logToFile(value : String)  {
        
        //writing
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL!)
            fileHandle.seekToEndOfFile()
            fileHandle.write(value.data(using: .utf8)!)
            fileHandle.closeFile()
        } catch {
            print("Error writing to file \(error)")
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
    
    func peripheralsDidUpdate() {
        peripherals = Array(bluetoothManager.peripherals.values)
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

