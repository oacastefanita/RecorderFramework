//
//  HomeViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 09/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class HomeViewController: NSViewController {
    var selectedObject: AnyObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func onGetFolders(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getFolders({ (success, data) -> Void in
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showFoldersFromHome"), sender: self)
        })
    }
    
    @IBAction func onGetSettings(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getSettings({ (success, data) -> Void in
            if success {
                self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showSettingsFromHome"), sender: self)
            }
            else {
                
            }
        })
    }
    
    @IBAction func onGetMessages(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getMessages({ (success, data) -> Void in
            if success && data != nil {
                self.selectedObject = data as AnyObject
                self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showMessagesFromHome"), sender: self)
                
            }
            else if data != nil{
                
            }else{
                
            }
        })
    }
    
    @IBAction func onGetLanguages(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getLanguages({ (success, data) -> Void in
            if success {
                self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showLanguagesFromHome"), sender: self)
            }
            else {
                
            }
        })
    }
    
    @IBAction func onGetPhoneNumbers(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getPhoneNumbers({ (success, data) -> Void in
            if success {
                self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showPhoneNumbersFromHome"), sender: self)
            }
            else {
                
            }
        })
    }
    
    @IBAction func onGetProfile(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.getProfile({ (success, data) -> Void in
            if success {
                self.selectedObject = data as AnyObject
                self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showProfileFromHome"), sender: self)
            }
            else {
                
            }
        })
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier != nil{
            if segue.identifier!.rawValue == "showTranslationsFromLanguages"{
                //            (segue.destination as! DisplayViewController).object = selectedObject
            }else{
                if segue.identifier!.rawValue == "showMessagesFromHome"{
                    (segue.destinationController as! MessagesViewController).messages = selectedObject as! [ServerMessage]
                }
            }
        }
    }
}
