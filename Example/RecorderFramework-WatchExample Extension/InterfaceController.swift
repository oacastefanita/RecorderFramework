//
//  InterfaceController.swift
//  RecorderFramework-WatchExample Extension
//
//  Created by Stefanita Oaca on 31/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import Foundation
import RecorderFramework

class InterfaceController: WKInterfaceController {

    @IBOutlet var lblNoData: WKInterfaceLabel!
    @IBOutlet var btnNewRecording: WKInterfaceButton!
    @IBOutlet var btnUser: WKInterfaceButton!
    @IBOutlet var btnFolders: WKInterfaceButton!
    @IBOutlet var btnCall: WKInterfaceButton!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        refreshUI()
        // Configure interface objects here.
         NotificationCenter.default.addObserver(self, selector: #selector(InterfaceController.refreshUI), name: NSNotification.Name(rawValue: kNotificationContextUpdated), object: nil)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @objc func refreshUI(){
        if RecorderFrameworkManager.sharedInstance.getApiKey() == nil{
            self.btnNewRecording.setHidden(true)
            self.btnUser.setHidden(true)
            self.btnFolders.setHidden(true)
            lblNoData.setHidden(false)
        }else{
            lblNoData.setHidden(true)
            self.btnNewRecording.setHidden(false)
            self.btnUser.setHidden(false)
            self.btnFolders.setHidden(false)
        }
        self.btnCall.setHidden(AppPersistentData.sharedInstance.phone == nil)
    }
    
    @IBAction func onCall(_ sender: Any) {
        if AppPersistentData.sharedInstance.phone != nil{
            if let url = URL(string: "tel://\(AppPersistentData.sharedInstance.phone!)") {
                WKExtension.shared().openSystemURL(url)
            }
        }
    }
}
