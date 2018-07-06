//
//  SettingsViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 12/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class SettingsViewController: NSViewController{
    
    @IBOutlet weak var swcBeep: NSButton!
    @IBOutlet weak var swcFilePermission: NSButton!
    @IBOutlet weak var lblApp: NSTextField!
    @IBOutlet weak var lblCredits: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewData()
    }
    
    func loadViewData(){
        swcBeep.state = NSControl.StateValue(rawValue: RecorderFrameworkManager.sharedInstance.getUser().playBeep == true ? 1 : 0)
        swcFilePermission.state = NSControl.StateValue(rawValue: RecorderFrameworkManager.sharedInstance.getFilePermission() == "public" ? 1 : 0)
        lblApp.stringValue = lblApp.stringValue + RecorderFrameworkManager.sharedInstance.getApp()!
        lblCredits.stringValue = lblCredits.stringValue + "\(RecorderFrameworkManager.sharedInstance.getCredits())"
    }
    
    @IBAction func onUpdate(_ sender: Any) {
        updateSettings()
    }
    
    func updateSettings(){
        RecorderFrameworkManager.sharedInstance.updateSettings(swcBeep.state == NSControl.StateValue(rawValue: 1),filesPersmission: swcFilePermission.state == NSControl.StateValue(rawValue: 1), completionHandler: { (success, data) -> Void in
            if success {
                self.view.window?.close()
                
            }
            else {
                
            }
        })
    }
}
