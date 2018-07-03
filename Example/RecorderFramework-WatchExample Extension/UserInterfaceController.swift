//
//  UserInterfaceController.swift
//  RecorderFramework-WatchExample Extension
//
//  Created by Stefanita Oaca on 02/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import Foundation
import RecorderFramework

class UserInterfaceController: WKInterfaceController {
    
    @IBOutlet var lblFirstName: WKInterfaceLabel!
    @IBOutlet var lblLastName: WKInterfaceLabel!
    @IBOutlet var lblEmail: WKInterfaceLabel!
    @IBOutlet var lblTimezone: WKInterfaceLabel!
    @IBOutlet var lblPlayBeep: WKInterfaceLabel!
    @IBOutlet var lblIsPublic: WKInterfaceLabel!
    @IBOutlet var lblPin: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        fillView()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func fillView(){
        lblFirstName.setText(RecorderFrameworkManager.sharedInstance.getUser().firstName)
        lblLastName.setText(RecorderFrameworkManager.sharedInstance.getUser().lastName)
        lblEmail.setText(RecorderFrameworkManager.sharedInstance.getUser().email)
        lblPlayBeep.setText("Play Beep: " + RecorderFrameworkManager.sharedInstance.getUser().playBeep.description)
        lblIsPublic.setText("Public: " + RecorderFrameworkManager.sharedInstance.getUser().isPublic.description)
        lblTimezone.setText("UTC +" + RecorderFrameworkManager.sharedInstance.getUser().timeZone)
        lblPin.setText("Pin: " + RecorderFrameworkManager.sharedInstance.getUser().pin)
    }
}
