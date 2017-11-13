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

    @IBOutlet var btnSegmentBeep : UISegmentedControl!
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
        btnSegmentBeep.selectedSegmentIndex = RecorderFrameworkManager.sharedInstance.getUser().playBeep ? 1:0
        
        lblFilePermission.text = lblFilePermission.text! + RecorderFrameworkManager.sharedInstance.getFilePermission()!
        lblApp.text = lblApp.text! + RecorderFrameworkManager.sharedInstance.getApp()!
        lblCredits.text = lblCredits.text! + "\(RecorderFrameworkManager.sharedInstance.getCredits())"
    }
    
    @IBAction func onUpdate(_ sender: Any) {
        updateSettings()
    }
    func updateSettings(){
        RecorderFrameworkManager.sharedInstance.updateSettings(btnSegmentBeep.selectedSegmentIndex == 1, completionHandler: { (success, data) -> Void in
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
