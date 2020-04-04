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

    @IBOutlet weak var tableView: UITableView!

        override func viewDidLoad() {
            super.viewDidLoad()
            let nib = UINib(nibName: "SurveyCell", bundle: nil)
            self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        @IBAction func switchButtonTapped(_ sender: Any) {
           /* let modalViewController = LanguageSettingsViewController()
            modalViewController.modalPresentationStyle = .overCurrentContext
            present(modalViewController, animated: false, completion: nil)*/
        }
        
      
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
    // extensions related to UItableView
}

extension SurveyViewController: UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            return surveyIconsArray.count;
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier:"Cell", for: indexPath as IndexPath) as! SurveyCell
            cell.surveyImageView.image = UIImage(named:surveyIconsArray[indexPath.row])
            cell.textCellLabel.text = surveyLabelsKeyArray[indexPath.row].localiz()
            return cell
        }

}
