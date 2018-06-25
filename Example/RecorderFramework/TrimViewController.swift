//
//  TrimViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 24/06/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework
import FDWaveformView
import CoreAudio
import AVKit
import AVFoundation

class TrimViewController: UIViewController {
    var file: RecordItem!
    @IBOutlet weak var waveView: FDWaveformView!
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initAudio()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initAudio(){
        let url = URL(fileURLWithPath: RecorderFrameworkManager.sharedInstance.getPath() + file.localFile)
        self.waveView.audioURL = url
        self.waveView.doesAllowScrubbing = true
        self.waveView.doesAllowStretch = true
        self.waveView.doesAllowScroll = true
        self.waveView.wavesColor = UIColor.black
        self.waveView.progressColor = UIColor.black
    }
    
    @IBAction func trim(_ sender: Any) {
        if Int64(txtFrom.text!) == nil || Int64(txtTo.text!) == nil {
            return
        }
        
        let url = URL(fileURLWithPath: RecorderFrameworkManager.sharedInstance.getPath() + file.localFile)
        let asset = AVAsset(url: url)
        exportAsset(asset)
    }
    
    func exportAsset(_ asset: AVAsset) {
        print("\(#function)")
        
        let oldPath = RecorderFrameworkManager.sharedInstance.getPath() + file.localFile
        var newPath = oldPath.components(separatedBy: ".").first
        newPath = newPath! + "Cropped." + oldPath.components(separatedBy: ".").last!
        let trimmedSoundFileURL = URL(fileURLWithPath:newPath!)
        print("saving to \(trimmedSoundFileURL.absoluteString)")
        
        deleteFileAtPath(trimmedSoundFileURL.path)
        
        print("creating export session for \(asset)")
        
        if let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) {
            exporter.outputFileType = AVFileType.m4a
            exporter.outputURL = trimmedSoundFileURL
            
            let duration = CMTimeGetSeconds(asset.duration)
            if duration < Float64(txtFrom.text!)! {
                print("sound is not long enough")
                return
            }
            if duration < Float64(txtTo.text!)! +  Float64(txtFrom.text!)!{
                print("sound is not long enough")
                return
            }
            // e.g. the first 5 seconds
            let startTime = CMTimeMake(Int64(txtFrom.text!)!, 1)
            let stopTime = CMTimeMake(Int64(duration) - Int64(txtTo.text!)!, 1)
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
}
