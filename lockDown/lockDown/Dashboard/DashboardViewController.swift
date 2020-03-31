//
//  DashboardViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 30/03/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import GoogleMaps

class DashboardViewController: UIViewController ,GMSMapViewDelegate{
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
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.transparentNavigationBar()
        setuprequestLocationVC()
        // Do any additional setup after loading the view.
    }
    
    
    
    // MARK: - Bottom Views Methods
    func setuprequestLocationVC() {
        //requestLocationVC.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        requestLocationVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(requestLocationVC)
        self.view.addSubview(requestLocationVC.view)
        requestLocationVC.didMove(toParent: self)
    }
}

