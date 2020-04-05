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

class DashboardViewController: BaseController ,GMSMapViewDelegate , CLLocationManagerDelegate{
    enum CardState {
        case expanded
        case collapsed
    }
    var requestLocationVC = RequestLocationViewController()
    var ChangeLocationVC = ChangeLocationViewController()
    
    let cardHeight:CGFloat = 300
    let cardHandleAreaHeight:CGFloat = 65
    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
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
    var countdownTimer: Timer!
    var totalTime : Int!
    let file = "Log.csv" //this is the file. we will write to and read from it
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
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getNotificationNoneLocation(notification:)), name: Notification.Name("NotificationNoneLocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationLocation"), object: nil)
        self.navigationItem.rightBarButtonItem = nil
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named:"Bg_navBar"),for: .default)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            fileURL = dir.appendingPathComponent(file)
        }
        setLocation()
        startTimer()
        let deviceId = UserDefaults.standard.string(forKey: "deviceId")
        let firebaseToken = UserDefaults.standard.string(forKey: "firebaseToken")
        APIClient.sendFirebaseToken(deviceId: deviceId!, firebase_token: firebaseToken!, onSuccess: { (Msg) in
            print(Msg)
        } ,onFailure : { (error) in
            print(error)
        }
        )
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
                marker.isDraggable =  true
                marker.map = self.mapView
                getAddressFromLatLon(pdblLatitude: locValue!.latitude, withLongitude: locValue!.longitude)
                circle = GMSCircle()
                circle.radius = 100 // Meters
                circle.position = locValue // user  position
                circle.fillColor = UIColorFromHex(hex: "#FBBBBC")
                circle.strokeColor = .clear
                circle.map = mapView; // Add it to the map
                // Add it to the map
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
                circle.position = locValue // user  position
                circle.fillColor = UIColorFromHex(hex: "#FBBBBC")
                circle.strokeColor = .clear
                circle.map = mapView; // Add it to the map
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
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    print(pm.country)
                    print(pm.locality)
                    print(pm.subLocality)
                    print(pm.thoroughfare)
                    print(pm.postalCode)
                    print(pm.subThoroughfare)
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
        let location = locations.last
        if let lastLocation = locations.last {
            currentLocation = lastLocation.coordinate
        }
        locValue = currentLocation
        let circleLocation : CLLocation =  CLLocation(latitude: circle.position.latitude, longitude: circle.position.longitude)
        let myLocation : CLLocation =  CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        let distance = circleLocation.distance(from: myLocation)
        
        let deviceToken = UserDefaults.standard.string(forKey: "DeviceToken")
        
        if(distance >= circle.radius)
        {
            print("user out of zone")
            
            if  UserDefaults.standard.bool(forKey: "isLocationSetted")  {
                APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 0, onSuccess: { (Msg) in
                    print(Msg)
                } ,onFailure : { (error) in
                    print(error)
                }
                )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // manager.requestLocation()
            break
        case .restricted, .denied:
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
        case .authorizedAlways, .authorizedWhenInUse:
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
                marker.position = locValue
                marker.isDraggable =  true
                marker.map = self.mapView
                getAddressFromLatLon(pdblLatitude: locValue!.latitude, withLongitude: locValue!.longitude)
                circle = GMSCircle()
                circle.radius = 100 // Meters
                circle.position = locValue // user  position
                circle.fillColor = UIColorFromHex(hex: "#FBBBBC")
                circle.strokeColor = .clear
                circle.map = mapView; // Add it to the map
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
                marker.position = locValue
                marker.map = self.mapView
                getAddressFromLatLon(pdblLatitude: locValue!.latitude, withLongitude: locValue!.longitude)
                circle = GMSCircle()
                circle.radius = 100 // Meters
                circle.position = locValue // user  position
                circle.fillColor = UIColorFromHex(hex: "#FBBBBC")
                circle.strokeColor = .clear
                circle.map = mapView; // Add it to the map
                
            }
            
            break
        default: break
            // Permission denied, do something else
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
            circle = GMSCircle()
            circle.radius = 100 // Meters
            circle.position = locValue // user  position
            circle.fillColor = UIColorFromHex(hex: "#FBBBBC")
            circle.strokeColor = .clear
            circle.map = mapView; // Add it to the map
            break
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        recenterButton.setImage(UIImage(named: "userLocation"), for: .normal)
        
        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 16.0)
        return true
    }
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("didDrag")
    }
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        getAddressFromLatLon(pdblLatitude: marker.position.latitude, withLongitude: marker.position.longitude)
        locValue = marker.position
        circle.map = nil
        circle = GMSCircle()
        
        circle.radius = 100 // Meters
        circle.position = marker.position // user  position
        circle.fillColor = UIColorFromHex(hex: "#FBBBBC")
        circle.strokeColor = .clear
        circle.map = mapView;
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
        
        if(distance >= circle.radius)
        {
            print("user out of zone")
            logToFile(value: "user out of zone , \(locValue.latitude),\(locValue.longitude) \n")
            if  UserDefaults.standard.bool(forKey: "isLocationSetted")  {
                APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 0, onSuccess: { (Msg) in
                    print(Msg)
                } ,onFailure : { (error) in
                    print(error)
                }
                )
            }
        }
        else
        {
            print("user in zone")
           logToFile(value: "user in zone , \(locValue.latitude),\(locValue.longitude) \n")
            if  UserDefaults.standard.bool(forKey: "isLocationSetted")  {
                APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 1, onSuccess: { (Msg) in
                    print(Msg)
                } ,onFailure : { (error) in
                    print(error)
                }
                )
                
            }
        }
        
        
    }
    
    // MARK : Set counter for Check In
    
    //MARK : Add Timer
    
    func startTimer() {
        if(countdownTimer != nil ){
            countdownTimer.invalidate()
            countdownTimer = nil
        }
        totalTime = 60
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        if(countdownTimer != nil){
            let secondes = (totalTime % 60)
            let minutes : Int = Int(totalTime / 60)
            
            if totalTime != 0 {
                totalTime -= 1
                UserDefaults.standard.set(totalTime, forKey: "counter")
                print(String(format: "%02d:%02d", minutes, secondes))
                
            } else if secondes == 0 {
                
                sendData()
                desactivateTimer()
                startTimer()
            }
            else {
                
                //endTimer()
            }
            
        }
    }
    
    // MARK : Desactivate Timer
    func desactivateTimer()  {
        if(countdownTimer != nil ){
            countdownTimer.invalidate()
            countdownTimer = nil
        }
    }
    
   // MARK : Log in File
    func logToFile(value : String)  {
    let titleString = "Status, latitude, longitude"
               var dataString: String
               
        Colons.append(value)

               do {
                   try "\(titleString)\n".write(to: fileURL!, atomically: false, encoding: String.Encoding.utf8)
               } catch {
                   print(error)
               }
               //writing

        for i in 0...Colons.count-1 {
                
                   dataString =  String(Colons[i])
                   //Check if file exists
                   do {
                       let fileHandle = try FileHandle(forWritingTo: fileURL!)
                           fileHandle.seekToEndOfFile()
                           fileHandle.write(dataString.data(using: .utf8)!)
                           fileHandle.closeFile()
                   } catch {
                       print("Error writing to file \(error)")
                   }
                  // print(dataString)
               }
               print("Saving data in: \(fileURL!.path)")


               //reading
               do {
                   let text2 = try String(contentsOf: fileURL!, encoding: .utf8)
                   print(text2)
               }
               catch {/* error handling here */}
           
    }
}
// MARK: RequestLocation delagates methods

extension DashboardViewController: RequestLocationProtocol {
    
    func requestlocation() {
        requestLocationVC.view.removeFromSuperview()
        UserDefaults.standard.set(true, forKey: "isLocationSetted")
        UserDefaults.standard.set(location:locValue, forKey:"myhomeLocation")
        let customerId = UserDefaults.standard.string(forKey: "customerId")
        
        
        APIClient.sendLocationTelimetry(deviceid: customerId!, latitude: String(locValue!.latitude), longitude: String(locValue!.longitude), radius: "100", onSuccess: { (Msg) in
            print(Msg)
            self.startTimer()
        } ,onFailure : { (error) in
            print(error)
        }
        )
        let biometricsAuthVC = BiometricsAuthViewController(nibName: "BiometricsAuthViewController", bundle: nil)
        self.navigationController!.pushViewController(biometricsAuthVC, animated: true)
    }
    
}

extension DashboardViewController : ChangeLocationProtocol {
    func ContactUs() {
        let contactUsVC = ContactUsViewController(nibName: "ContactUsViewController", bundle: nil)
      
        self.navigationController!.pushViewController(contactUsVC, animated: true)
    }
}
