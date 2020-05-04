//
//  MyZoneViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 15/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import GoogleMaps

class MyZoneViewController: BaseController , GMSMapViewDelegate , CLLocationManagerDelegate{
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var recenterButton: Button!
    @IBOutlet weak var searchViewTop: NSLayoutConstraint!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var statusImg: UIImageView!
    @IBOutlet weak var statusImgTop: NSLayoutConstraint!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var satBtn: UIButton!
    
    var locValue: CLLocationCoordinate2D!
    var navigatedToMyLocation : Bool! = false
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D!
    var cameraa : GMSCameraPosition!
    var circle = GMSCircle()
    var marker = GMSMarker()
    var markerPosition : CGPoint!
    var requestLocationVC = RequestLocationViewController()
    var ChangeLocationVC = ChangeLocationViewController()
    var biometricsBottomVc = BiometricsBottomViewController()
    var isNextBtnTapped = false

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
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.getNotificationNoneLocation(notification:)), name: Notification.Name("NotificationNoneLocation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("NotificationLocation"), object: nil)
        self.navigationItem.rightBarButtonItem = nil
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bg_navBar")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
        if  !UserDefaults.standard.bool(forKey: "isSignedUp")  {
            setLocationView()
        }
        else{
            setupChangeLocationVC()
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
       
    }
    @objc func getNotificationNoneLocation(notification: Notification) {
           setLocation()
           
       }
       @objc func methodOfReceivedNotification(notification: Notification) {
           
           setLocation()
           
       }
       @IBAction func navigateToMyLocation(_ sender: UIButton) {
           if CLLocationManager.authorizationStatus() ==  .authorizedAlways {
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
    // MARK: setLocations
    func setLocation() {
        //Location Manager code to fetch current location
        if  !UserDefaults.standard.bool(forKey: "isSignedUp")  {
            
            self.title = "SignUpTitle".localiz()
            if CLLocationManager.authorizationStatus() == .authorizedAlways {
                
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
            if CLLocationManager.authorizationStatus() == .authorizedAlways {
               
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
               
           case .restricted, .authorizedWhenInUse, .denied:
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
            if UserDefaults.standard.bool(forKey:  "isSignedUp" ){
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
            }
            else {
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
               break
           default: break
               // Permission denied, do something else
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
    private func mapView(_ mapView: GMSMapView, didEndDrag marker: GMSMarker) {
                
             }
       func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
           if !isNextBtnTapped {
               if self.markerPosition == nil {
                   //To set pin into the center of mapview
                   marker.position = position.target
                  self.markerPosition = self.mapView.projection.point(for: CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude))
                  // getAddressFromLatLon(pdblLatitude: marker.position.latitude, withLongitude: marker.position.longitude)
               }else{
                   //To set pin into the any particular point of the screen on mapview
                   
                   let coordinate = self.mapView.projection.coordinate(for: self.markerPosition)
                   marker.position = coordinate
                  self.markerPosition = self.mapView.projection.point(for: CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude))
                  // getAddressFromLatLon(pdblLatitude: marker.position.latitude, withLongitude: marker.position.longitude)
               }
           }
       }
       
       
       
       func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
           if !navigatedToMyLocation {
               self.recenterButton.setImage(UIImage(named: "userLocation"), for: .normal)
           }
           navigatedToMyLocation = !navigatedToMyLocation
        if self.markerPosition != nil {
       let coordinate = self.mapView.projection.coordinate(for: self.markerPosition)
    
        getAddressFromLatLon(pdblLatitude: coordinate.latitude, withLongitude: coordinate.longitude)
        }
            print("didEndDrag")
       }
    
    
    
    
    //
       func getAddressFromLatLon(pdblLatitude: Double, withLongitude pdblLongitude: Double) {
         DispatchQueue.main.async {
            var addressStr = " "
     let geoCoder = CLGeocoder()
           let location = CLLocation(latitude: pdblLatitude , longitude: pdblLongitude)
           geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in

               print("Response GeoLocation : \(placemarks)")
               var placeMark: CLPlacemark!
               placeMark = placemarks?[0]
            if (placeMark != nil) {
               // Country
               if let country = placeMark.addressDictionary!["Country"] as? String {
                   print("Country :- \(country)")
                addressStr = addressStr  + country
                   // City
                   if let city = placeMark.addressDictionary!["City"] as? String {
                       print("City :- \(city)")
                       // State
                    addressStr = addressStr + " , " + city
                       if let state = placeMark.addressDictionary!["State"] as? String{
                           print("State :- \(state)")
                           // Street
                           if let street = placeMark.addressDictionary!["Street"] as? String{
                               print("Street :- \(street)")
                            addressStr = addressStr + " , " + street
                               let str = street
                               if let streetNumber = str.components(
                                separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "") as? String {
                               print("streetNumber :- \(streetNumber)" as Any)
                            
                                if streetNumber != "" {
                                    addressStr = addressStr + " , " + streetNumber
                                }
                                
                                }
                               // ZIP
                               if let zip = placeMark.addressDictionary!["ZIP"] as? String{
                                   print("ZIP :- \(zip)")
                                   // Location name
                                   if let locationName = placeMark?.addressDictionary?["Name"] as? String {
                                       print("Location Name :- \(locationName)")
                                       // Street address
                                       if let thoroughfare = placeMark?.addressDictionary!["Thoroughfare"] as? NSString {
                                       print("Thoroughfare :- \(thoroughfare)")

                                       }
                                   }
                               }
                           }
                       }
                   }
               }
            }
            self.addressLbl.text = addressStr
           })
        }
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
//           print("horizontalAccuracy : \( manager.location!.horizontalAccuracy)")
//           print("desiredAccuracy : \(manager.desiredAccuracy)")
//           let circleLocation : CLLocation =  CLLocation(latitude: circle.position.latitude, longitude: circle.position.longitude)
//           let myLocation : CLLocation =  CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
//           let distance = circleLocation.distance(from: myLocation)
//
//           let deviceToken = UserDefaults.standard.string(forKey: "DeviceToken")
//           if manager.location!.horizontalAccuracy < 300 {
//               if(distance >= circle.radius)
//               {
//                   print("user out of zone")
//                   if  UserDefaults.standard.bool(forKey: "isSignedUp")  {
//                       if  UserDefaults.standard.bool(forKey: "isLocationSetted")  {
//                           //Alert please come back
//                         /*  let alert = UIAlertController(title: "zone", message: "you are out of zone, please come back", preferredStyle: .alert)
//
//                           alert.addAction(UIAlertAction(title: "Ok", style: .default,handler: {action in self.showAlertInternet()}))
//
//
//                           self.present(alert, animated: true)*/
//
//
//                           APIClient.sendTelimetry(deviceToken: deviceToken!, iscomplaint: 0, raison: " out of zone ", onSuccess: { (Msg) in
//                               print(Msg)
//                           } ,onFailure : { (error) in
//                               print(error)
//                           }
//                           )
//                       }
//                   }
//               }
//           }
       }
       
    
    
    
    
    
    
    
    // MARK: - set LocationForFirst Time
    func setLocationView() {
        DispatchQueue.main.async {
            self.requestLocationVC.delegate = self
            let height = self.view.frame.height
            let width  = self.view.frame.width
            self.requestLocationVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
            self.addChild(self.requestLocationVC)
            self.view.addSubview(self.requestLocationVC.view)
            self.requestLocationVC.didMove(toParent: self)
            self.statusImg.isHidden = false
            self.mapView.bringSubviewToFront(self.statusImg)
            if self.isItIPhoneX() {
                self.statusImgTop.constant = 110
                self.searchViewTop.constant = 140
            }
            else {
                self.statusImgTop.constant = 70
                self.searchViewTop.constant = 100
            }
        }
        
    }

    
    // MARK: - changeLocation View
    func setupChangeLocationVC() {
        //requestLocationVC.view.removeFromSuperview()
        ChangeLocationVC.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        ChangeLocationVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(ChangeLocationVC)
        self.view.addSubview(ChangeLocationVC.view)
        ChangeLocationVC.didMove(toParent: self)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
// MARK: RequestLocation delagates methods

extension MyZoneViewController: RequestLocationProtocol {
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
        UserDefaults.standard.set(true, forKey: "isLocationSetted")
        //UserDefaults.standard.set(location:locValue, forKey:"myhomeLocation")
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

extension MyZoneViewController : ChangeLocationProtocol {
    func ContactUs() {
        let contactUsVC = ContactUsViewController(nibName: "ContactUsViewController", bundle: nil)
        
        self.navigationController!.pushViewController(contactUsVC, animated: true)
    }
}


extension MyZoneViewController : BiometricsAuthProtocol{
    func requestRecognition(){
        UserDefaults.standard.set(true, forKey: "isLocationSetted")
        //UserDefaults.standard.set(location:locValue, forKey:"myhomeLocation")
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
