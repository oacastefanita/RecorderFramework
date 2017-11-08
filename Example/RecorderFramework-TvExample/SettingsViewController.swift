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

//    @IBOutlet weak var swcBeep: UISwitch!
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
//        swcBeep.isOn = AppPersistentData.sharedInstance.user.playBeep
        lblFilePermission.text = lblFilePermission.text! + AppPersistentData.sharedInstance.filePermission
        lblApp.text = lblApp.text! + AppPersistentData.sharedInstance.app
        lblCredits.text = lblCredits.text! + "\(AppPersistentData.sharedInstance.credits!)"
    }
    
    @IBAction func onUpdate(_ sender: Any) {
        updateSettings()
    }
    func updateSettings(){
//        RecorderFrameworkManager.sharedInstance.updateSettings(swcBeep.isOn, completionHandler: { (success, data) -> Void in
//            if success {
//                self.navigationController?.popViewController(animated: true)
//                self.alert(message: "Request sent")
//            }
//            else {
//                self.alert(message: (data as! AnyObject).description)
//            }
//        })
    }
}
