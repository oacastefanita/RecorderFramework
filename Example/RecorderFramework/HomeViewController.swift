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
    var selectedObject: AnyObject!
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
                self.performSegue(withIdentifier: "showSettingsFromHome", sender: self)
            }
            else {
                self.alert(message: (data as! AnyObject).description)
            }
        })
    }
    
    @IBAction func onGetMessages(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getMessages({ (success, data) -> Void in
            if success && data != nil {
                
            }
            else if data != nil{
                self.alert(message: (data as! AnyObject).description)
            }else{
                self.alert(message: "No data")
            }
        })
    }
    
    @IBAction func onGetLanguages(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getLanguages({ (success, data) -> Void in
            if success {
                self.performSegue(withIdentifier: "showLanguagesFromHome", sender: self)
            }
            else {
                self.alert(message: (data as! AnyObject).description)
            }
        })
    }
    
    @IBAction func onGetPhoneNumbers(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getPhoneNumbers({ (success, data) -> Void in
            if success {
                self.performSegue(withIdentifier: "showPhoneNumbersFromHome", sender: self)
            }
            else {
                self.alert(message: (data as! AnyObject).description)
            }
        })
    }
    
    @IBAction func onGetProfile(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getProfile({ (success, data) -> Void in
            if success {
                self.selectedObject = data as AnyObject
                self.performSegue(withIdentifier: "showProfileFromHome", sender: self)
            }
            else {
                self.alert(message: (data as! AnyObject).description)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTranslationsFromLanguages"{
            (segue.destination as! DisplayViewController).object = selectedObject
        }
    }
}

