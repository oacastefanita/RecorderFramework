//
//  RecordInterfaceController.swift
//  RecorderFramework-WatchExample Extension
//
//  Created by Stefanita Oaca on 01/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import RecorderFramework
import Foundation

class RecordInterfaceController: WKInterfaceController {
    @IBOutlet var btnRecord: WKInterfaceButton!
    var recItem: RecordItem!
    var recording = false
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func onRecord(_ sender: Any) {
        var p = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let recordFilePath = p + "/Recording1.caf"
        if recording{
            dismissAudioRecorderController()
            recording = false
            self.btnRecord.setTitle("Record")
        }else{
            presentAudioRecorderController(withOutputURL: URL(string: recordFilePath)!,
                                           preset: .narrowBandSpeech,
                                           options: nil,
                                           completion: { saved, error in
                                            
                                            if let err = error {
                                                print(err.localizedDescription)
                                            }
            })
            recording = true
            self.btnRecord.setTitle("Stop")
        }
    }
}
