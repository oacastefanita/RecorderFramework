//
//  SettingsViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 30/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//
import UIKit
import RecorderFramework

class SettingsViewController: UIViewController{

    @IBOutlet weak var swcBeep: UISwitch!
    @IBOutlet weak var swcFilePermission: UISwitch!
    @IBOutlet weak var lblFilePermission: UILabel!
    @IBOutlet weak var lblApp: UILabel!
    @IBOutlet weak var lblCredits: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadViewData()
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
    
    func loadViewData(){
        swcBeep.isOn = RecorderFrameworkManager.sharedInstance.getUser().playBeep        
        swcFilePermission.isOn = RecorderFrameworkManager.sharedInstance.getFilePermission() == "public"
        lblApp.text = lblApp.text! + RecorderFrameworkManager.sharedInstance.getApp()!
        lblCredits.text = lblCredits.text! + "\(RecorderFrameworkManager.sharedInstance.getCredits())"
    }
    
    @IBAction func onUpdate(_ sender: Any) {
        updateSettings()
    }
    func updateSettings(){
        RecorderFrameworkManager.sharedInstance.updateSettings(swcBeep.isOn,filesPersmission: swcFilePermission.isOn, completionHandler: { (success, data) -> Void in
            if success {
                self.navigationController?.popViewController(animated: true)
                self.alert(message: "Request sent")
            }
            else {
                self.alert(message: (data as! AnyObject).description)
            }
        })
    }
}
