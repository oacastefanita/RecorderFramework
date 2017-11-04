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
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        if RecorderFrameworkManager.sharedInstance.getApiKey() == nil{
            self.btnNewRecording.setHidden(true)
            self.btnUser.setHidden(true)
            self.btnFolders.setHidden(true)
        }else{
            lblNoData.setHidden(true)
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
