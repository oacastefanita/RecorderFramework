//
//  TrimViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 07/07/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class TrimViewController: NSViewController{

    var waveView: JHAudioPreviewView!
    @IBOutlet weak var waveViewHolder: NSView!
    
    @IBOutlet weak var txtFrom: NSTextField!
    @IBOutlet weak var txtTo: NSTextField!
    
    var file: RecordItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        renderAudio()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier != nil{
            if segue.identifier!.rawValue == ""{
                
            } else if segue.identifier!.rawValue == ""{
                
            }
        }
    }
    
    @IBAction func trim(_ sender: Any) {
        if Int64(txtFrom.stringValue) == nil || Int64(txtTo.stringValue) == nil {
            return
        }
        
        let url = URL(fileURLWithPath: RecorderFrameworkManager.sharedInstance.getPath() + file.localFile)
        let asset = AVAsset(url: url)
        exportAsset(asset)
    }
    
    func exportAsset(_ asset: AVAsset) {
        print("\(#function)")
        
        let oldPath = RecorderFrameworkManager.sharedInstance.getPath() + file.localFile
        var newPath = oldPath.replacingOccurrences(of: oldPath.components(separatedBy: ".").last!, with: "")
        newPath.dropLast()
        newPath = newPath + "Cropped." + oldPath.components(separatedBy: ".").last!
        let trimmedSoundFileURL = URL(fileURLWithPath:newPath)
        print("saving to \(trimmedSoundFileURL.absoluteString)")
        
        deleteFileAtPath(trimmedSoundFileURL.path)
        
        print("creating export session for \(asset)")
        
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
            exporter.outputFileType = AVFileType.m4a
            exporter.outputURL = trimmedSoundFileURL
            
            let duration = CMTimeGetSeconds(asset.duration)
            if duration < Float64(txtFrom.stringValue)! {
                print("sound is not long enough")
                self.showAlert(title: "Error", body: "Sound is not long enough")
                return
            }
            if duration < Float64(txtTo.stringValue)! +  Float64(txtFrom.stringValue)!{
                self.showAlert(title: "Error", body: "Sound is not long enough")
                return
            }
            // e.g. the first 5 seconds
            let startTime = CMTimeMake(Int64(txtFrom.stringValue)!, 1)
            let stopTime = CMTimeMake(Int64(duration) - Int64(txtTo.stringValue)!, 1)
            exporter.timeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            
            // do it
            exporter.exportAsynchronously(completionHandler: {
                print("export complete \(exporter.status)")
                
                switch exporter.status {
                case  AVAssetExportSessionStatus.failed:
                    
                    if let e = exporter.error {
                        print("export failed \(e)")
                    }
                    
                case AVAssetExportSessionStatus.cancelled:
                    print("export cancelled \(String(describing: exporter.error))")
                default:
                    print("export complete")
                    
                    self.file.fileDownloaded = false
                    self.file.localFile = trimmedSoundFileURL.path.components(separatedBy: RecorderFrameworkManager.sharedInstance.getPath()).last
                    self.deleteFileAtPath(oldPath)
                    RecorderFrameworkManager.sharedInstance.uploadRecording(self.file)
                    RecorderFrameworkManager.sharedInstance.saveData()
                    DispatchQueue.main.async {
                        self.view.window?.close()
                    }
                }
            })
        } else {
            print("cannot create AVAssetExportSession for asset \(asset)")
        }
        
    }
    
    
    func deleteFileAtPath(_ path: String){
        if FileManager.default.fileExists(atPath: path) {
            print("sound exists, removing \(path)")
            do {
                
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print("could not remove \(path)")
                print(error.localizedDescription)
            }
        }
    }
    
    func renderAudio() {
        waveView = JHAudioPreviewView()
        waveView.frame = waveViewHolder.bounds
        waveViewHolder.addSubview(waveView)
        
        let fileManager = FileManager.default
        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
        path += file.localFile
        
        if !FileManager.default.fileExists(atPath: path) {
            return
        }
        let url = URL(fileURLWithPath: path)
        let player = AVPlayer(url: url)
        waveView.player = player
    }
}
