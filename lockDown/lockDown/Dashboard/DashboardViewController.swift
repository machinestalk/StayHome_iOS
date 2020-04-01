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
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var recenterButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.transparentNavigationBar()
        self.mapView.bringSubviewToFront(recenterButton)
        setuprequestLocationVC()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.rightBarButtonItem = nil;
        //Location Manager code to fetch current location
        let image = UIImage(named: "ic_sattelite")?.withRenderingMode(.alwaysOriginal)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(changeMapStatus))
        self.navigationItem.rightBarButtonItem  = button
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            locValue = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
            self.locationManager.delegate = self
            self.locationManager.startUpdatingLocation()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            
        }
        else {
            locValue = CLLocationCoordinate2D(latitude :0.0,longitude : 0.0)
            checkUsersLocationServicesAuthorization()
        }
        
        
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
    @objc func changeMapStatus() {
        if self.mapView.mapType == .normal {self.mapView.mapType = .hybrid}
        else {self.mapView.mapType = .normal}
        
    }
    
    //Location Manager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        if let lastLocation = locations.last {
            currentLocation = lastLocation.coordinate
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 1.0)
        //let camera = GMSCameraPosition.camera(withLatitude: 10.197235, longitude: 36.850652, zoom: 1.0)
        //  self.mapView?.animate(to: camera)
        //self.locationManager.stopUpdatingLocation()
        
        
        
        locValue = currentLocation
        
        
        
        
        
        
        
        //  let distanceInMeters = coordinateVeh.distance(from: coordinateUser)
        
        
        
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            // manager.requestLocation()
            break
        case .authorizedAlways, .authorizedWhenInUse:
            
            self.mapView.delegate = self
            self.mapView?.isMyLocationEnabled = true
            self.mapView.bringSubviewToFront(recenterButton)
            
            
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
            alert.addAction(UIAlertAction(title: "Ok_text".localiz(), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable features that require location services here.
            print("Full Access")
            break
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        recenterButton.setImage(UIImage(named: "userLocation"), for: .normal)

        let camera = GMSCameraPosition.camera(withLatitude: marker.position.latitude, longitude: marker.position.longitude, zoom: 16.0)
        return true
    }
    
    
    
    func mapView(_ mapView: GMSMapView, idleAt cameraPosition: GMSCameraPosition) {
        if !navigatedToMyLocation {
            self.recenterButton.setImage(UIImage(named: "userLocation"), for: .normal)
        }
        navigatedToMyLocation = !navigatedToMyLocation
        
        
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
    
}
// MARK: RequestLocation delagates methods

extension DashboardViewController: RequestLocationProtocol {
    func requestlocation() {
        requestLocationVC.view.removeFromSuperview()
    }
    
}
