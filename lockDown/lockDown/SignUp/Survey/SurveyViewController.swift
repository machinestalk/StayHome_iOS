//
//  SurveyViewController.swift
//  lockDown
//
//  Created by Aymen HECHMI on 04/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class SurveyViewController: BaseController {
    
    let surveyIconsArray  = ["Scough","Sheadache","Sfever","Sbreath","Sno_sympthoms"]
    let surveyLabelsKeyArray = ["survey_cough_txt","survey_headache_txt","survey_fever_txt","survey_breath_txt","survey_no_symtoms_txt"]
    var statusArray : NSMutableArray = [0,0,0,0,1]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "SurveyCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.navigationBar.isHidden = false
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named:"Bg_navBar"),for: .default)
        self.title = "SignUpTitle".localiz()
    }
    
    @objc func switchButtonTapped(_ sender: Any) {
        let switcher : UISwitch = sender as! UISwitch
        if switcher.tag == 4{
            if switcher.isOn {
                statusArray = [0,0,0,0,1]
            }else{
                statusArray.replaceObject(at: switcher.tag, with: switcher.isOn)
                statusArray.replaceObject(at: 4, with: 0)
            }
        }else{
            statusArray.replaceObject(at: switcher.tag, with: switcher.isOn)
            statusArray.replaceObject(at: 4, with: 0)
        }
        self.tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextBtnDidTap(_ sender: Any) {
        
        if isValidateSurvey() {
            let customerId = UserDefaults.standard.string(forKey: "customerId")
            let data = ["cough":statusArray[0], "headache":statusArray[1], "fever":statusArray[2], "shortBreath": statusArray[3], "noSuffer": statusArray[4]]
            APIClient.sendSurveyTelimetry(deviceid:customerId! , data: data, onSuccess: { (Msg) in
                print(Msg)
            } ,onFailure : { (error) in
                print(error)
            })
            let DashboardVC = DashboardViewController(nibName: "DashboardViewController", bundle: nil)
            self.navigationController!.pushViewController(DashboardVC, animated: true)
        } else {
            let alert = UIAlertController(title: "Warning_txt".localiz(), message: "survey_invalidSurvey_txt".localiz(), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok_text".localiz() , style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func isValidateSurvey() -> Bool {
        var isValidateSurvey = false
        for status in statusArray {
            let boolStatus = status as! Bool
            if boolStatus{
                isValidateSurvey = true
                break
            }
        }
        return isValidateSurvey
    }
    
    // extensions related to UItableView
}

extension SurveyViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return surveyIconsArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath as IndexPath) as! SurveyCell
        cell.selectionStyle = .none
        cell.surveyImageView.image = UIImage(named:surveyIconsArray[indexPath.row])
        cell.switchButton.tag = indexPath.row
        cell.switchButton.isOn = statusArray[indexPath.row] as! Bool
        cell.switchButton.addTarget(self, action:#selector(switchButtonTapped(_ :)), for: .valueChanged)
        cell.textCellLabel.text = surveyLabelsKeyArray[indexPath.row].localiz()
        return cell
    }
}
