//
//  BraceletViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 30/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import MTBeaconPlus

class BraceletViewController: BaseController {

    var addBraceletVC = AddBraceletBottomViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

       self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bg_navBar")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
        title = "addBraceletTitle".localiz()
        setupAddBeaconVC()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)


    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - AddBeacon View
    func setupAddBeaconVC() {
        //requestLocationVC.view.removeFromSuperview()
        addBraceletVC.delegate = self
        let height = view.frame.height
        let width  = view.frame.width
        addBraceletVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
        self.addChild(addBraceletVC)
        self.view.addSubview(addBraceletVC.view)
        addBraceletVC.didMove(toParent: self)
    }
}
extension BraceletViewController : AddBraceletProtocol {
    func scanForBracelet() {
        print("scanForBracelet")
        let scanListVC = ScanListViewController(nibName: "ScanListViewController", bundle: nil)
        self.navigationController!.pushViewController(scanListVC, animated: true)
    }
    
    func addBraceletManually() {
        print("addBraceletManually")
        let AddBraceletVC = AddBraceletManuallyViewController(nibName: "AddBraceletManuallyViewController", bundle: nil)
              self.navigationController!.pushViewController(AddBraceletVC, animated: true)
    }
    
    
}
