//
//  ProfileViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 30/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class ProfileViewController: UIViewController {
    var selectedObject: AnyObject!
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPic: UITextField!
    @IBOutlet weak var txtTimezone: UITextField!
    @IBOutlet var btnSegmentPlayBeep : UISegmentedControl!
    @IBOutlet var btnSegmentPublic : UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onDone(_ sender: Any) {
        let params = NSMutableDictionary()
        params["data[play_beep]"] = btnSegmentPlayBeep.selectedSegmentIndex == 1 ? "1":"0"
        params["data[f_name]"] = txtFirstName.text ?? ""
        params["data[l_name]"] = txtLastName.text ?? ""
        params["data[is_public]"] = btnSegmentPublic.selectedSegmentIndex == 1 ? "1":"0"
        params["data[time_zone]"] = txtTimezone.text ?? ""
        params["data[email]"] = txtEmail.text ?? ""
        
        RecorderFrameworkManager.sharedInstance.updateUserProfile(RecorderFrameworkManager.sharedInstance.getUser(), userInfo: params)
        self.navigationController?.popViewController(animated: true)
        self.alert(message: "Request sent")
    }
    
    func fillView(){
        txtFirstName.text = RecorderFrameworkManager.sharedInstance.getUser().firstName
        txtLastName.text = RecorderFrameworkManager.sharedInstance.getUser().lastName
        txtEmail.text = RecorderFrameworkManager.sharedInstance.getUser().email
        txtTimezone.text = "\(RecorderFrameworkManager.sharedInstance.getUser().timeZone!)"
        btnSegmentPlayBeep.selectedSegmentIndex = RecorderFrameworkManager.sharedInstance.getUser().playBeep ? 1:0
        btnSegmentPublic.selectedSegmentIndex = RecorderFrameworkManager.sharedInstance.getUser().isPublic ? 1:0
    }
    
    
}
