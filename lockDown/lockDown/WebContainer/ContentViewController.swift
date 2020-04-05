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
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "aboutAs_txt".localiz()
        let url = URL(string: "https://www.machinestalk.com")!
        startLoading()
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func webView(_ webView: WKWebView,didFinish navigation: WKNavigation!) {
        
        finishLoading()
        
    }

    
    func startLoading() {
        // Show your loader
        MBProgressHUD .showAdded(to: self.view, animated: true)
        
    }
    
    func finishLoading() {
        // Dismiss your loader
        let delay = DispatchTime.now()
        DispatchQueue.main.asyncAfter(deadline: delay) {
            MBProgressHUD .hide(for: self.view, animated: true)
            
        }
        
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
