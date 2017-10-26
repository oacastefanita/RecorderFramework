//
//  HomeViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 25/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class HomeViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onGetFolders(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getFolders({ (success, data) -> Void in
            self.performSegue(withIdentifier: "showFoldersFromHome", sender: self)
        })
    }
    
    @IBAction func onGetSettings(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getSettings({ (success, data) -> Void in
            if success {
                
            }
            else {
                
            }
        })
    }
    
    @IBAction func onGetMessages(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getMessages({ (success, data) -> Void in
            if success {
                
            }
            else {
                
            }
        })
    }
    
    @IBAction func onGetLanguages(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getLanguages({ (success, data) -> Void in
            if success {

            }
            else {

            }
        })
    }
    
    @IBAction func onGetPhoneNumbers(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getPhoneNumbers({ (success, data) -> Void in
            if success {
                
            }
            else {
                
            }
        })
    }
    
    @IBAction func onGetProfile(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getProfile({ (success, data) -> Void in
            if success {
                
            }
            else {
                
            }
        })
    }
}

