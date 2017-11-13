//
//  FileInterfaceController.swift
//  RecorderFramework-WatchExample Extension
//
//  Created by Stefanita Oaca on 02/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import WatchKit
import Foundation
import RecorderFramework

class FileInterfaceController: WKInterfaceController {
    @IBOutlet var lblDownloading: WKInterfaceLabel!
    @IBOutlet var lblFirstName: WKInterfaceLabel!
    @IBOutlet var lblLastName: WKInterfaceLabel!
    @IBOutlet var lblPhoneNumber: WKInterfaceLabel!
    @IBOutlet var lblEmail: WKInterfaceLabel!
    @IBOutlet var lblNotes: WKInterfaceLabel!
    @IBOutlet var lblTags: WKInterfaceLabel!
    @IBOutlet var lblName: WKInterfaceLabel!
    
    var file: RecordItem!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        file = (context as! RecordItem)
        if !file.fileDownloaded || file.localFile == nil {
            var folder:RecordFolder! = nil
            
            for iterate in RecordingsManager.sharedInstance.recordFolders {
                if iterate.id == "-99" {
                    continue
                }
                for recItem in iterate.recordedItems {
                    if recItem == file {
                        folder = iterate
                        break
                    }
                }
                if folder != nil {
                    break
                }
            }
            if folder != nil{
                RecorderFrameworkManager.sharedInstance.downloadAudioFile(file, toFolder: folder.id, completionHandler: { (success) in
                    self.play()
                })
            }
        }
        else {
            lblDownloading.setText("Downloaded")
            self.play()
        }
        fillView()
    }
    func play(){
        let fileManager = FileManager.default
        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
        path += file.localFile
        
        if !FileManager.default.fileExists(atPath: path) {
            return
        }
        presentMediaPlayerController(with: URL(fileURLWithPath: path), options: nil, completion: { (success, time, error) in
            self.play()
        })
    }
    
    func fillView(){
        lblTags.setText(file.tags)
        lblNotes.setText(file.notes)
        lblEmail.setText(file.email)
        lblPhoneNumber.setText(file.phoneNumber)
        lblLastName.setText(file.lastName)
        lblFirstName.setText(file.firstName)
        lblName.setText(file.text)
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