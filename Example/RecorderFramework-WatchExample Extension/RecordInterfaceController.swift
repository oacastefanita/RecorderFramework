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
        let fileManager = FileManager.default
        let sharedContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)
        let recordFilePath = sharedContainer?.appendingPathComponent("Recording1.wav")
        if recording{
            self.btnRecord.setTitle("Record")
            recording = !recording
        }else{
            recording = !recording
            self.btnRecord.setTitle("Stop")
            let preset = WKAudioRecorderPreset.narrowBandSpeech
            presentAudioRecorderController(
                withOutputURL: recordFilePath!,
                preset: preset,
                options: nil) { [weak self] (didSave: Bool, error: Error?) in
                    print("Did save? \(didSave) - Error: \(String(describing: error))")
                    guard didSave else { return }
                    self?.btnRecord.setTitle("Record")
                    self?.recording = !(self?.recording)!
            }
        }
    }
}
