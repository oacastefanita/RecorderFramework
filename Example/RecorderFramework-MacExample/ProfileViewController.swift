//
//  ProfileViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 11/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class ProfileViewController: NSViewController {
    var selectedObject: AnyObject!
    
    @IBOutlet weak var txtFirstName: NSTextField!
    @IBOutlet weak var txtLastName: NSTextField!
    @IBOutlet weak var txtEmail: NSTextField!
    @IBOutlet weak var txtPic: NSTextField!
    @IBOutlet weak var txtTimezone: NSTextField!
    @IBOutlet weak var btnPlayBell: NSButton!
    @IBOutlet weak var btnPublic: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillView()
    }
    
    @IBAction func onDone(_ sender: Any) {
        let params = NSMutableDictionary()
        params["data[play_beep]"] = btnPlayBell.state == NSControl.StateValue(rawValue: 1)
        params["data[f_name]"] = txtFirstName.stringValue ?? ""
        params["data[l_name]"] = txtLastName.stringValue ?? ""
        params["data[is_public]"] = btnPublic.state == NSControl.StateValue(rawValue: 1)
        params["data[time_zone]"] = txtTimezone.stringValue ?? ""
        params["data[email]"] = txtEmail.stringValue ?? ""
        RecorderFrameworkManager.sharedInstance.updateUserProfile(userInfo: params)
        self.view.window?.close()
    }
    
    func fillView(){
        txtFirstName.stringValue = RecorderFrameworkManager.sharedInstance.getUser().firstName
        txtLastName.stringValue = RecorderFrameworkManager.sharedInstance.getUser().lastName
        txtEmail.stringValue = RecorderFrameworkManager.sharedInstance.getUser().email
        txtTimezone.stringValue = RecorderFrameworkManager.sharedInstance.getUser().timeZone
        btnPlayBell.state = NSControl.StateValue(rawValue: RecorderFrameworkManager.sharedInstance.getUser().playBeep == true ? 1 : 0)
        btnPublic.state = NSControl.StateValue(rawValue: RecorderFrameworkManager.sharedInstance.getUser().isPublic == true ? 1 : 0)
    }
}
