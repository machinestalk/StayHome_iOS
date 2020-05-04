//
//  ScanListViewController.swift
//  lockDown
//
//  Created by Ahmed Mh on 01/05/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class ScanListViewController: BaseController, UITableViewDataSource, UITableViewDelegate  {
    
    
 
    @IBOutlet weak var tableView: UITableView!
    
    var beaconNameListArray = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "scanBraceletTitle".localiz()
        let nib = UINib(nibName: "ScanTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "ScanTableViewCell")
        self.tableView.separatorColor = .clear
        beaconNameListArray.append("aa:aa:aa:aa")
        beaconNameListArray.append("aa:aa:aa:aa")
        beaconNameListArray.append("aa:aa:aa:aa")
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
