//
//  DashboardViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 30/03/2020.
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

class DashboardViewController: BaseController ,GMSMapViewDelegate , CLLocationManagerDelegate{
    
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
    let customTimer = CustomTimer(timeInterval: 300)
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
    var isInternetOK = false
    
    var carrier = CTCarrier()
    var batteryLevel = Int(UIDevice.current.batteryLevel)
    var userMotionActivity: CMMotionActivity!
    var userMotionManager: CMMotionManager!
        
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
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D!
    var cameraa : GMSCameraPosition!
    var circle = GMSCircle()
    var marker = GMSMarker()
    var markerPosition : CGPoint!
    var countdownTimer: Timer!
    var totalTime : Int!
    var fileURL : URL?
    var Colons = [String]()
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var recenterButton: Button!
    @IBOutlet weak var searchViewTop: NSLayoutConstraint!
    
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusImgTop: NSLayoutConstraint!
    @IBOutlet weak var searchtxt: TextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var satBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    
    var activityManager = ActivityManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.mapView.bringSubviewToFront(recenterButton)
        self.mapView.bringSubviewToFront(satBtn)
        self.mapView.bringSubviewToFront(searchView)
        self.mapView.bringSubviewToFront(addressLbl)
        if isItIPhoneX(){
            searchViewTop.constant = 110
        }
        //is Battery Monitoring Enabled
        UIDevice.current.isBatteryMonitoringEnabled = true
        
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
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bg_navBar")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
        self.navigationController?.navigationBar.isHidden = false
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
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
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        //Create log file if not yet created
        createLogFile()
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
    }

    func showAlertBattery(){
        NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"battery"])
    }

    func showAlertInternet(){
        NotificationCenter.default.post(name: Notification.Name("Alerts"), object: nil, userInfo:["type":"internet"])
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
                return "notDetermined"
            case .restricted :
                print("restricted")
                return "restricted"
            case .denied:
                print("denied")
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
            setLocationView()
            self.title = "SignUpTitle".localiz()
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                
                locValue = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
                self.locationManager.delegate = self
                self.locationManager.startUpdatingLocation()
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 16.0)
                cameraa = camera
                self.mapView?.animate(to: camera)
                marker.icon = UIImage(named: "red_marker")
                marker.position = locValue
                marker.map = self.mapView
                getAddressFromLatLon(pdblLatitude: locValue!.latitude, withLongitude: locValue!.longitude)
               // scheduledTimerWithTimeInterval()
            }
            else {
                locValue = CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
                checkUsersLocationServicesAuthorization()
            }
        }
        else {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                setupChangeLocationVC()
                self.title = "MyZone_txt".localiz()
                locValue = UserDefaults.standard.location(forKey:"myhomeLocation")
                self.locationManager.delegate = self
                self.locationManager.startUpdatingLocation()
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 16.0)
                cameraa = camera
                self.mapView?.animate(to: camera)
                marker.icon = UIImage(named: "red_marker")
                marker.position = locValue
                marker.map = self.mapView
                getAddressFromLatLon(pdblLatitude: locValue!.latitude, withLongitude: locValue!.longitude)
                circle = GMSCircle()
                circle.radius = 100 // Meters
                circle.position = marker.position // user  position
                circle.fillColor = UIColorFromHex(hex: "#FBBBBC").withAlphaComponent(0.8)
                circle.strokeColor = .clear
                circle.map = mapView;
                //scheduledTimerWithTimeInterval()
            }
            else {
                locValue = CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
                checkUsersLocationServicesAuthorization()
            }
        }
    }
    
    
    
    @objc func getNotificationNoneLocation(notification: Notification) {
        setLocation()
        
    }
    @objc func methodOfReceivedNotification(notification: Notification) {
        
        
        
    }
    @IBAction func navigateToMyLocation(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            if  let userLocation = locValue{
                //let camera = GMSCameraPosition.camera(withLatitude: 10.197235, longitude: 36.850652, zoom: 16.0)
                
                let camera = GMSCameraPosition.camera(withLatitude: userLocation.latitude, longitude: userLocation.longitude, zoom: 16.0)
                cameraa = camera
                self.mapView?.animate(to: camera)
                
                
                recenterButton.setImage(UIImage(named: "ic_localisation_blue"), for: .normal)
                navigatedToMyLocation = true
            }
        }
        else {
            checkUsersLocationServicesAuthorization()
        }
    }
    //is Internet Available
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

    func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = pdblLatitude
        center.longitude = pdblLongitude
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                if let pm = placemarks {
                    
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        var addressString : String = ""
                        if pm.subLocality != nil {
                            addressString = addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            addressString = addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            addressString = addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            addressString = addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            addressString = addressString + pm.postalCode! + " "
                        }
                        
                        self.addressLbl.text = addressString
                        print(addressString)
                    }
                }
        })
        
    }
    
    
    @IBAction  func changeMapStatus() {
        if self.mapView.mapType == .normal {self.mapView.mapType = .hybrid}
        else {self.mapView.mapType = .normal}
        
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
        let circleLocation : CLLocation =  CLLocation(latitude: circle.position.latitude, longitude: circle.position.longitude)
        let myLocation : CLLocation =  CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        let distance = circleLocation.distance(from: myLocation)
        
        let deviceToken = UserDefaults.standard.string(forKey: "DeviceToken")
        if manager.location!.horizontalAccuracy < 300 {
            if(distance >= circle.radius)
            {
                print("user out of zone")
                if  UserDefaults.standard.bool(forKey: "isSignedUp")  {
                    if  UserDefaults.standard.bool(forKey: "isLocationSetted")  {
                        //Alert please come back
                        let alert = UIAlertController(title: "zone", message: "you are out of zone, please come back", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: {action in self.showAlertInternet()}))
                        
                        self.present(alert, animated: true)
                        
                        
                        APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 0, raison: " out of zone ", onSuccess: { (Msg) in
                            print(Msg)
                        } ,onFailure : { (error) in
                            print(error)
                        }
                        )
                    }
                }
            }
        }
    }
    
    //
    // acceleration
    
    
    var timer = Timer()
    let motionManager = CMMotionManager()
    
//    func scheduledTimerWithTimeInterval(){
//        // Scheduling timer to Call the function **getSpeed** with the interval of 1 seconds
//        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(getSpeed), userInfo: nil, repeats: true)
//    }
    func showAlertSpeed(){
        if(bluetoothEnabled == false){
            let alert = UIAlertController(title: "speed", message: "Please your speed > 10K/H", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    @objc func getSpeed(){
        
        
        let speed = Double((locationManager.location?.speed)!)
        
        print(String(format: "%.0f km/h", speed * 3.6)) //Current speed in km/h
        
        //If speed is over 10 km/h
        if(speed * 3.6 > 10 ){
            showAlertSpeed()
            //Getting the accelerometer data
            if motionManager.isAccelerometerAvailable{
                let queue = OperationQueue()
                motionManager.startAccelerometerUpdates(to: queue, withHandler:
                    {data, error in
                        
                        guard let data = data else{
                            return
                        }
                        
                        print("X = \(data.acceleration.x)")
                        print("Y = \(data.acceleration.y)")
                        print("Z = \(data.acceleration.z)")
                        
                }
                )
            } else {
                print("Accelerometer is not available")
            }
            
        }
    }
    
    //
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
        case .authorizedAlways:
            if  !UserDefaults.standard.bool(forKey: "isLocationSetted")  {
                self.mapView.delegate = self
                self.mapView?.isMyLocationEnabled = true
                self.mapView.bringSubviewToFront(recenterButton)
                locValue = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
                self.locationManager.delegate = self
                self.locationManager.startUpdatingLocation()
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 16.0)
                cameraa = camera
                self.mapView?.animate(to: camera)
                marker.icon = UIImage(named: "red_marker")
                marker.map = self.mapView
                getAddressFromLatLon(pdblLatitude: locValue!.latitude, withLongitude: locValue!.longitude)
                marker.position = locValue
                
            }
            else {
                locValue = UserDefaults.standard.location(forKey:"myhomeLocation")
                self.locationManager.delegate = self
                self.locationManager.startUpdatingLocation()
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 16.0)
                cameraa = camera
                self.mapView?.animate(to: camera)
                marker.icon = UIImage(named: "red_marker")
                marker.map = self.mapView
                getAddressFromLatLon(pdblLatitude: locValue!.latitude, withLongitude: locValue!.longitude)
                marker.position = locValue
                
                
            }
            
            break
        default: break
            // Permission denied, do something else
        }
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
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
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
            
        case .restricted, .denied:
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
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable features that require location services here.
            
            locValue = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
            self.locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 16.0)
            cameraa = camera
            self.mapView?.animate(to: camera)
            
            marker.icon = UIImage(named: "red_marker")
            marker.position = locValue
            marker.map = self.mapView
            getAddressFromLatLon(pdblLatitude: locValue!.latitude, withLongitude: locValue!.longitude)
            
            break
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        recenterButton.setImage(UIImage(named: "userLocation"), for: .normal)
        _ = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 16.0)
        return true
    }
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("didDrag")
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if !isNextBtnTapped {
            if self.markerPosition == nil {
                //To set pin into the center of mapview
                marker.position = position.target
                getAddressFromLatLon(pdblLatitude: marker.position.latitude, withLongitude: marker.position.longitude)
            }else{
                //To set pin into the any particular point of the screen on mapview
                
                let coordinate = self.mapView.projection.coordinate(for: self.markerPosition)
                marker.position = coordinate
                getAddressFromLatLon(pdblLatitude: marker.position.latitude, withLongitude: marker.position.longitude)
            }
        }
    }
    
    
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        if !navigatedToMyLocation {
            self.recenterButton.setImage(UIImage(named: "userLocation"), for: .normal)
        }
        navigatedToMyLocation = !navigatedToMyLocation
        
        
    }
    // MARK: - set LocationForFirst Time
    func setLocationView() {
        setuprequestLocationVC()
        statusImg.isHidden = false
        mapView.bringSubviewToFront(statusImg)
        if isItIPhoneX() {
            statusImgTop.constant = 110
            searchViewTop.constant = 140
        }
        else {
            statusImgTop.constant = 70
            searchViewTop.constant = 100
        }
        
        
    }
    
    // MARK: - Bottom Views Methods
    func setuprequestLocationVC() {
        requestLocationVC.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        requestLocationVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(requestLocationVC)
        self.view.addSubview(requestLocationVC.view)
        requestLocationVC.didMove(toParent: self)
    }
    
    // MARK: - changeLocation View
    func setupChangeLocationVC() {
        ChangeLocationVC.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        ChangeLocationVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(ChangeLocationVC)
        self.view.addSubview(ChangeLocationVC.view)
        ChangeLocationVC.didMove(toParent: self)
    }
    // MARK: Send data with counter
    
    func sendData() {
        let circleLocation : CLLocation =  CLLocation(latitude: circle.position.latitude, longitude: circle.position.longitude)
        let myLocation : CLLocation =  CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        let distance = circleLocation.distance(from: myLocation)
        
        let deviceToken = UserDefaults.standard.string(forKey: "DeviceToken")
        batteryLevel = Int(UIDevice.current.batteryLevel)
        let locationState = checkIfLocationEnabled()
        if Double(locationManager.location!.horizontalAccuracy) < 300 {
            if(distance >= circle.radius)
            {
                logToFile(value: "\(Date()) ; \(userMotionActivity ?? CMMotionActivity()) ; user out of zone ;  \(locValue.latitude) ; \(locValue.longitude) ; \(Array(Set(peripherals))) ; \(currentNetworkInfos?.first?.ssid ??  "nil") ; \(batteryLevel) ; \(locationState) ; \(bluetoothEnabled) ; \(isInternetAvailable()) ; \(locationManager.location?.horizontalAccuracy ?? 0) ; \(userMotionManager.accelerometerData) ; \(userMotionManager.gyroData) ; \(userMotionManager.magnetometerData) ; \(userMotionManager.deviceMotion)\n")
                peripherals.removeAll()
                if  UserDefaults.standard.bool(forKey: "isLocationSetted")  {
                    APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 0, raison: "user out of zone", onSuccess: { (Msg) in
                        print(Msg)
                    } ,onFailure : { (error) in
                        print(error)
                    })
                }
            }
            else
            {
                logToFile(value: "\(Date()) ; \(userMotionActivity ?? CMMotionActivity()) ; user in zone ;  \(locValue.latitude) ; \(locValue.longitude) ; \(Array(Set(peripherals))) ; \(currentNetworkInfos?.first?.ssid ??  "nil") ; \(batteryLevel) ; \(locationState) ; \(bluetoothEnabled) ; \(isInternetAvailable()) ; \(locationManager.location?.horizontalAccuracy ?? 0) ; \(userMotionManager.accelerometerData) ; \(userMotionManager.gyroData) ; \(userMotionManager.magnetometerData) ; \(userMotionManager.deviceMotion)\n")
                peripherals.removeAll()
                if  UserDefaults.standard.bool(forKey: "isLocationSetted")  {
                    APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 1, raison: "user in zone", onSuccess: { (Msg) in
                        print(Msg)
                    } ,onFailure : { (error) in
                        print(error)
                    })
                }
            }
        }
    }
    
    // MARK : Set counter for Check In
    
    //MARK : Add Timer
    
    func startCustomTimer() {
        
        customTimer.eventHandler = {
            self.getSpeed()
            self.sendData()
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
    
    
    // MARK : Log in File
    
    //create file
    func createLogFile(){
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = URL(fileURLWithPath: path)
        let dateString = Date().toString(dateFormat: "yyyyMMdd")
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
}
// MARK: RequestLocation delagates methods

extension DashboardViewController: RequestLocationProtocol {
    func noBtnDidTap() {
        circle.map = nil
        isNextBtnTapped = false
    }
    
    func nextBtnDidTap() {
        isNextBtnTapped = true
        self.markerPosition = self.mapView.projection.point(for: CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude))
        getAddressFromLatLon(pdblLatitude: marker.position.latitude, withLongitude: marker.position.longitude)
        locValue = self.mapView.projection.coordinate(for: self.markerPosition)
        UserDefaults.standard.set(location:locValue, forKey:"myhomeLocation")
        circle = GMSCircle()
        circle.radius = 100 // Meters
        circle.position = marker.position // user  position
        circle.fillColor = UIColorFromHex(hex: "#FBBBBC").withAlphaComponent(0.8)
        circle.strokeColor = .clear
        circle.map = mapView;
        
    }
    
    
    func requestlocation() {
        requestLocationVC.view.removeFromSuperview()
        biometricsBottomVc.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        biometricsBottomVc.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(biometricsBottomVc)
        self.view.addSubview(biometricsBottomVc.view)
        biometricsBottomVc.msgLbl.text = "locationStoredTxt".localiz()
        biometricsBottomVc.titleLbl.isHidden = true
        biometricsBottomVc.successImage.isHidden = false 
        biometricsBottomVc.didMove(toParent: self)
    }
    
    
}

extension DashboardViewController : ChangeLocationProtocol {
    func ContactUs() {
        let contactUsVC = ContactUsViewController(nibName: "ContactUsViewController", bundle: nil)
        
        self.navigationController!.pushViewController(contactUsVC, animated: true)
    }
}


extension DashboardViewController : BiometricsAuthProtocol{
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

//public class SSID {
//    class func fetchNetworkInfo() -> [NetworkInfo]? {
//        if let interfaces: NSArray = CNCopySupportedInterfaces() {
//            var networkInfos = [NetworkInfo]()
//            for interface in interfaces {
//                let interfaceName = interface as! String
//                var networkInfo = NetworkInfo(interface: interfaceName,
//                                              success: false,
//                                              ssid: nil,
//                                              bssid: nil)
//                if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary? {
//                    networkInfo.success = true
//                    networkInfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
//                    networkInfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
//                }
//                networkInfos.append(networkInfo)
//            }
//            return networkInfos
//        }
//        return nil
//    }
//    class func getAllWiFiNameList() -> String? {
//        var ssid: String?
//        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
//            for interface in interfaces {
//                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
//                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
//                }
//            }
//        }
//        return ssid
//    }
//    class func fetchSSIDInfo() -> String {
//        var currentSSID = ""
//        if let interfaces = CNCopySupportedInterfaces() {
//            for i in 0..<CFArrayGetCount(interfaces) {
//                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interfaces, i)
//                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
//                let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString)
//                if let interfaceData = unsafeInterfaceData as? [String: AnyObject] {
//                    currentSSID = interfaceData["SSID"] as! String
//                }
//            }
//        }
//        return currentSSID
//    }
//    
//}

//struct NetworkInfo {
//    var interface: String
//    var success: Bool = false
//    var ssid: String?
//    var bssid: String?
//}
extension DashboardViewController: responceProtocol {
    func oKClick() {
        alertComeBackIsOpen = false
        self.attentionAlertViewControllerOutZone.view.removeFromSuperview()
    }
    
    func emergencyClick() {
        alertComeBackIsOpen = false
        self.attentionAlertViewControllerOutZone.view.removeFromSuperview()
    }
    
    
}

extension DashboardViewController: BluetoothManagerDelegate {
    
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

extension DashboardViewController: ActivityManagerDelegate {
    
    func activityDidUpdate(data: CMMotionActivity, motionManager: CMMotionManager) {
        userMotionActivity = data
        userMotionManager = motionManager
    }
}
