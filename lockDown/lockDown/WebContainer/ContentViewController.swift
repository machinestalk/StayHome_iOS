//
//  ContentViewController.swift
//  lockDown
//
//  Created by Aymen HECHMI on 05/04/2020.
//  Copyright © 2020 Ahmed Mh. All rights reserved.
//

import UIKit
import WebKit
import MBProgressHUD

class ContentViewController: BaseController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
//    override func loadView() {
//        webView = WKWebView()
//        webView.navigationDelegate = self
//        view = webView
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "aboutAs_txt".localiz()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Bg_navBar")!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0 ,right: 0), resizingMode: .stretch), for: .default)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func webView(_ webView: WKWebView,didFinish navigation: WKNavigation!) {
        
        finishLoading()
        
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
