//
//  ContactUsViewController.swift
//  lockDown
//
//  Created by Aymen HECHMI on 04/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit

class ContactUsViewController: BaseController, UITextViewDelegate {
    
    @IBOutlet var firstImageView: UIImageView!
    @IBOutlet var secondImageView: UIImageView!
    @IBOutlet var thirdImageView: UIImageView!
    @IBOutlet var firstdelete: UIButton!
    @IBOutlet var seconddelete: UIButton!
    @IBOutlet var thirddelete: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var textView:UITextView!
    @IBOutlet var textfield:UITextField!
    
    var imagePicker: ImagePicker!
    
    var pickedImagesArray: NSMutableArray = []
    var attachementDict: NSMutableDictionary = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "tecSupport_txt".localiz()
        // Do any additional setup after loading the view.
        
        textView.text = "Write your message"
        textView.textColor = UIColor.lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.contentSize = CGSize(width:firstImageView.frame.size.width * 3 + 100, height: scrollView.frame.size.height)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bg_navBar")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - UItextView and UITextField Delegates
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write your message"
            textView.textColor = UIColor.lightGray
        }
    }
    
    // MARK: - Actions
    
    @IBAction func imagePickerButtonTouched(_ sender: UIButton) {
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.present(from: sender)
    }
    
    @IBAction func sendDataButtonTouched(_ sender: UIButton) {
        startLoading()
        if pickedImagesArray.count > 0 {
            for index in 0...pickedImagesArray.count - 1 {
                
                let image = pickedImagesArray[index]  as! UIImage
                if let imageData = image.jpeg(.medium) {
                    let image64 : String = imageData.base64EncodedString(options: .lineLength64Characters)
                    let imageNSData:NSData = imageData as NSData
                    attachementDict.setValue(image64, forKey: "image\(index).\(imageNSData.imageFormat)")
                }
            }
        }
    // MARK: - APIs call
        
        let dataBody = ["phoneNumber":UserDefaults.standard.value(forKey: "UserNameSignUp") as! String ,"subject":textfield.text as Any,"message":textView.text as
            Any,"attachement":attachementDict as Any] as [String : Any]
        
        if !textView.text.isEmpty && textView.textColor != UIColor.lightGray {
            APIClient.sendContactUSForm(data: dataBody, onSuccess: { (success) in
                self.finishLoading()
                print(success)
                let alert = UIAlertController(title: "".localiz(), message: "support_successMsg_txt".localiz(), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok_text".localiz() , style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }) { (error) in
                self.finishLoading()
                print(error)
            }
        }else{
            self.finishLoading()
            let alert = UIAlertController(title: "Warning_txt".localiz(), message: "support_invalidMsg_txt".localiz(), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok_text".localiz() , style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func deletePhotoButtonTouched(_ sender: UIButton) {
        
        let pressedButton = sender
        pickedImagesArray.removeObject(at: pressedButton.tag)
        reorgonizePictureView()

    }
    
    // MARK: - Helpers
    
    func reorgonizePictureView() {
        
        firstImageView.image = nil
        secondImageView.image = nil
        thirdImageView.image = nil
        
        firstdelete.isHidden = true
        seconddelete.isHidden = true
        thirddelete.isHidden = true
        
        switch pickedImagesArray.count {
        
        case 1:
            firstImageView.image = pickedImagesArray[0] as? UIImage
            firstdelete.isHidden = false

        case 2:
            firstImageView.image = pickedImagesArray[0] as? UIImage
            firstdelete.isHidden = false
            
            secondImageView.image = pickedImagesArray[1] as? UIImage
            seconddelete.isHidden = false
            
        default:
            break
        }
    }
}

// MARK: - ImagePickerDelegate

extension ContactUsViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {

        guard let image = image else {
            return
        }
        switch pickedImagesArray.count {
        case 0:
            firstImageView.image = image
            firstdelete.isHidden = false
            pickedImagesArray.add(image)
        case 1:
            secondImageView.image = image
            seconddelete.isHidden = false
            pickedImagesArray.add(image)
        case 2:
            thirdImageView.image = image
            thirddelete.isHidden = false
            pickedImagesArray.add(image)
        default:
            thirdImageView.image = image
            pickedImagesArray.replaceObject(at: 2, with: image)
        }
    }
}
