//
//  MenuViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 30/03/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import LGSideMenuController


class MenuViewController: BaseController {
    fileprivate var menuItems = ["home_txt","MyZone_txt" , "checkIn_txt","emergency_txt","","", "tecSupport_txt", "aboutAs_txt","logout_txt"]
    let menuIconsArray = ["home_black","zones_black","check_black","emergency_black","","","support_black","about_black","logout_black"]
    let menuSelectedIconsArray = ["home_green","zones_green","check_green","emergency_green","","","support_green","about_green","logout_green"]
    var selectedItem = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var VersionLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenu(menuItems: self.menuItems as NSArray)
        let nib = UINib(nibName: "MenuTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "menuCell")
        self.tableView.backgroundColor = UIColor.clear
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: UIScreen.main.bounds.size.height)
        self.tableView.separatorColor = .clear
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func switchToEnglish(_ sender: Any) {
        /* let modalViewController = LanguageSettingsViewController()
         modalViewController.modalPresentationStyle = .overCurrentContext
         present(modalViewController, animated: false, completion: nil)*/
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setMenu(menuItems:NSArray)  {
        self.menuItems = menuItems as! [String]
        
        self.tableView .reloadData()
    }
    //Hide Menu
    func hideMenu() {
        
        self.sideMenuController?.hideLeftView()
        
        self.sideMenuController?.hideRightView()
    }
}

// extensions related to UItableView

extension MenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 55.0;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier:"menuCell", for: indexPath as IndexPath) as! MenuTableViewCell
        //cell.backgroundColor = UIColorFromHex(hex: "#4ED689")
        switch indexPath.row {
            case 0:
            do {
                if !((self.sideMenuController?.rootViewController as! UINavigationController).visibleViewController!.isKind(of: HomeViewController.self)) {
                    
                    let vc = HomeViewController(nibName: "HomeViewController", bundle: nil)
                    let navC = self.sideMenuController?.rootViewController as! UINavigationController
                    navC.setViewControllers([vc], animated: true)
                    selectedItem = 1
                }
                hideMenu()
                break
            }
        case 1:
            do {
                if !((self.sideMenuController?.rootViewController as! UINavigationController).visibleViewController!.isKind(of: DashboardViewController.self)) {
                    
                    let vc = DashboardViewController(nibName: "DashboardViewController", bundle: nil)
                    let navC = self.sideMenuController?.rootViewController as! UINavigationController
                    navC.setViewControllers([vc], animated: true)
                    selectedItem = 1
                }
                hideMenu()
                break
            }
        case 2:
            do {
                if !((self.sideMenuController?.rootViewController as! UINavigationController).visibleViewController!.isKind(of: CheckInViewController.self)) {
                    
                    
                    let vc = CheckInViewController(nibName: "CheckInViewController", bundle: nil)
                    let navC = self.sideMenuController?.rootViewController as! UINavigationController
                    navC.setViewControllers([vc], animated: true)
                    selectedItem = 2
                }
                hideMenu()
                break
            }
        case 3:
            do {
                if !((self.sideMenuController?.rootViewController as! UINavigationController).visibleViewController!.isKind(of: EmergencyViewController.self)) {
                    
                    
                    let vc = EmergencyViewController(nibName: "EmergencyViewController", bundle: nil)
                    let navC = self.sideMenuController?.rootViewController as! UINavigationController
                    navC.setViewControllers([vc], animated: true)
                    selectedItem = 3
                }
                hideMenu()
                break
            }
        case 4:
            do {
                
            }
            
            break
            case 5:
                       do {
                           
                       }
                       
                       break
            
        case 6:
            do {
                if !((self.sideMenuController?.rootViewController as! UINavigationController).visibleViewController!.isKind(of: ContactUsViewController.self)) {
                    
                    
                    let vc = ContactUsViewController(nibName: "ContactUsViewController", bundle: nil)
                    let navC = self.sideMenuController?.rootViewController as! UINavigationController
                    navC.setViewControllers([vc], animated: true)
                    selectedItem = 6
                }
                hideMenu()
                break
                
            }
        case 7:
            do {
                if !((self.sideMenuController?.rootViewController as! UINavigationController).visibleViewController!.isKind(of: ContentViewController.self)) {
                    
                    
                    let vc = ContentViewController(nibName: "ContentViewController", bundle: nil)
                    let navC = self.sideMenuController?.rootViewController as! UINavigationController
                    navC.setViewControllers([vc], animated: true)
                    selectedItem = 7
                }
                
                hideMenu()
                break
                
            }
        default:
            print("Default")
        }
        self.tableView.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
}

extension MenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return menuItems.count ;
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"menuCell", for: indexPath as IndexPath) as! MenuTableViewCell
        cell.menuLabel.text = self.menuItems[(indexPath as NSIndexPath).row].localiz()
        if selectedItem == indexPath.row {
            cell.menuLabel.textColor = UIColorFromHex(hex: "#26B7A0")
            cell.menuIcon.image = UIImage(named:menuSelectedIconsArray[indexPath.row])
            cell.selectedView.isHidden = false
        }
        else {
            cell.menuLabel.textColor  = .black
            cell.menuIcon.image = UIImage(named:menuIconsArray[indexPath.row])
            cell.selectedView.isHidden = true
        }
        cell.topLbl.isHidden = (indexPath.row != 5)
        return cell
    }
}
