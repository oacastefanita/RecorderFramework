//
//  FileViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 12/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework
import AVFoundation
import AVKit

class FileViewController: NSViewController, TitleViewControllerDelegater, AVAudioRecorderDelegate, NSTextFieldDelegate{
    
    @IBOutlet weak var waveViewHolder: NSView!
    @IBOutlet weak var datePicker: NSDatePicker!
    @IBOutlet weak var txtReccurenceDays: NSTextField!
    @IBOutlet weak var txtNotes: NSTextField!
    @IBOutlet weak var txtEmail: NSTextField!
    @IBOutlet weak var txtPhoneNumber: NSTextField!
    @IBOutlet weak var txtLastName: NSTextField!
    @IBOutlet weak var txtFirstName: NSTextField!
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var btnUpdate: NSButton!
    
    @IBOutlet weak var btnRecord: NSButton!
    @IBOutlet weak var btnStar: NSButton!
    @IBOutlet weak var btnTags: NSButton!
    @IBOutlet weak var btnTrim: NSButton!
    @IBOutlet weak var btnRecover: NSButton!
    @IBOutlet weak var recordingTimeLabel: NSTextField!
    
    var file: RecordItem!
    var folder: RecordFolder!
    var titleType = 0
    var player:AVAudioPlayer!
    var recording = false
    var fileCreated = false
    
    var waveView: JHAudioPreviewView!
    //Variables
    var audioRecorder: AVAudioRecorder!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    
    var placeholder = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if file == nil{
            btnUpdate.title = "Done"
            file = RecordItem()
            file.id = "Delete"
            folder.recordedItems.append(file)
            fileCreated = true
            btnTags.isEnabled = false
            btnTrim.isEnabled = false
        }else{
            btnRecord.isEnabled = false
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
                self.recordingTimeLabel.stringValue = "Downloading"
                if folder == nil{
                    folder = RecorderFrameworkManager.sharedInstance.folderForItem(file.id)
                }
                RecorderFrameworkManager.sharedInstance.downloadAudioFile(file, toFolder: folder.id, completionHandler: { (success) in
                    self.recordingTimeLabel.stringValue = "Downloaded"
                    self.play()
                })
            }
            else {
                self.recordingTimeLabel.stringValue = "Downloaded"
                self.play()
            }
        }
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(FileViewController.enableTags), userInfo: nil, repeats: true)
        fillView()
    }
    
    override func viewDidDisappear() {
        super.viewWillDisappear()
        if player != nil && player.isPlaying{
            player.stop()
        }
    }
    
    @objc func enableTags(){
        if file.id != "Delete"{
            self.btnTags.isEnabled = true
            self.btnTrim.isEnabled = true
        }
    }
    
    func play() {
        let fileManager = FileManager.default
        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
        path += file.localFile
        
        if !FileManager.default.fileExists(atPath: path) {
            return
        }
        do {
            let url = URL(fileURLWithPath: path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        catch {
            
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
//        waveView.player = player
    }
    
    func fillView(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        datePicker.dateValue = (dateFormatter.date(from: file.remindDate) != nil) ? dateFormatter.date(from: file.remindDate)! : Date()
        txtReccurenceDays.stringValue = file.remindDays
        txtNotes.stringValue = file.notes
        txtEmail.stringValue = file.email
        txtPhoneNumber.stringValue = file.phoneNumber
        txtLastName.stringValue = file.lastName
        txtFirstName.stringValue = file.firstName
        txtName.stringValue = file.text
        if folder != nil{
            btnRecover.isHidden = (folder.id! != "trash")
        }
        btnStar.title = (file.isStar ? "Unstar":"Star")
        txtReccurenceDays.isEnabled = file.id != "Delete"
        datePicker.isEnabled = file.id != "Delete"
        
        renderAudio()
    }
    
    @IBAction func onRename(_ sender: Any) {
        titleType = 0
        placeholder = "new name id"
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "titleFromFile"), sender: self)
    }
    
    @IBAction func onClone(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.cloneFile(entityId: file.id, completionHandler: { (success, data) -> Void in
            if success {
                self.view.window?.close()
            }
            else {
                
            }
        })
    }
    
    @IBAction func onRecover(_ sender: Any) {
        titleType = 2
        placeholder = "item id"
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "titleFromFile"), sender: self)
    }
    
    @IBAction func onMove(_ sender: Any) {
        titleType = 1
        placeholder = "Folder id"
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "titleFromFile"), sender: self)
    }
    
    @IBAction func onUpdate(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        file.remindDays = txtReccurenceDays.stringValue
        file.remindDate = dateFormatter.string(from: datePicker.dateValue)
        file.notes = txtNotes.stringValue
        file.email = txtEmail.stringValue
        file.phoneNumber = txtPhoneNumber.stringValue
        file.lastName = txtLastName.stringValue
        file.firstName = txtFirstName.stringValue
        file.text = txtName.stringValue
        file.folderId = Int(folder.id) ?? 0 > 0 ? folder.id : nil
    
        if btnUpdate.title == "Done"{
            file.id = UUID().uuidString
            doSaveCurrentRecording()
            self.view.window?.close()
            return
        }
        
        let dict = RecorderFrameworkManager.sharedInstance.createDictFromRecordItem(file)
        RecorderFrameworkManager.sharedInstance.updateRecordingInfo(file, fileInfo: NSMutableDictionary(dictionary: dict))
        self.view.window?.close()
    }
    
    @IBAction func onDelete(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.deleteRecording(file, forever: true)
        self.view.window?.close()
    }
    
    @IBAction func onStar(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.star(!file.isStar, entityId: file.id, isFile: true, completionHandler: { (success, data) -> Void in
            if success {
                self.view.window?.close()
            }
            else {
                
            }
        })
    }
    
    func selectedTitle(_ title: String){
        if titleType == 0{
            file.text = title
            RecorderFrameworkManager.sharedInstance.renameRecording(file)
            self.view.window?.close()
        }else if titleType == 1{
            RecorderFrameworkManager.sharedInstance.moveRecording(file, folderId: title)
            self.view.window?.close()
        }else{
            RecorderFrameworkManager.sharedInstance.recoverRecording(file, folderId: title)
            self.view.window?.close()
        }
        RecorderFrameworkManager.sharedInstance.startProcessingActions()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier!.rawValue == "titleFromFile"{
            (segue.destinationController as! TitleViewController).delegate = self
            (segue.destinationController as! TitleViewController).placeholder = placeholder
        }else if segue.identifier!.rawValue == "showTagsFromFile"{
            let fileManager = FileManager.default
            var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
            path += file.localFile
            self.file.setupWithFile(path)
            (segue.destinationController as! FileTagsViewController).file = self.file
        }
        else if segue.identifier!.rawValue == "showTrimFromFile"{
            let fileManager = FileManager.default
            var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
            path += file.localFile
            self.file.setupWithFile(path)
            (segue.destinationController as! TrimViewController).file = self.file
        }else if segue.identifier!.rawValue == "showFolderSelectionFromFile"{
            (segue.destinationController as! SelectFolderViewController).file = self.file
        }
    }
    
    @IBAction func audioRecorderAction(_ sender: Any) {
        if recording{
            btnRecord.title = "Record"
            finishAudioRecording(success: true)
        }else{
//            if isAudioRecordingGranted {
                btnRecord.title = "Stop"
                do {
                    let settings = [
                        AVFormatIDKey:Int(kAudioFormatLinearPCM),
                        AVSampleRateKey:44100.0,
                        AVNumberOfChannelsKey:1,
                        AVLinearPCMBitDepthKey:8,
                        AVLinearPCMIsFloatKey:false,
                        AVLinearPCMIsBigEndianKey:false,
                        AVEncoderAudioQualityKey:AVAudioQuality.max.rawValue
                        ] as [String : Any]
                    //Create audio file name URL
                    let fileManager = FileManager.default
                    let sharedContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)
                    let path = sharedContainer?.appendingPathComponent("Recording1.wav")
                    //Create the audio recording, and assign ourselves as the delegate
                    audioRecorder = try AVAudioRecorder(url: path!, settings: settings)
                    audioRecorder.delegate = self
                    audioRecorder.isMeteringEnabled = true
                    audioRecorder.record()
                    meterTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
                }
                catch let error {
                    print("Error for start audio recording: \(error.localizedDescription)")
                }
//            }
        }
        recording = !recording
    }
    
    func finishAudioRecording(success: Bool) {
        
        audioRecorder.stop()
        audioRecorder = nil
        meterTimer.invalidate()
        
        if success {
            print("Recording finished successfully.")
        } else {
            print("Recording failed :(")
        }
    }
    
    @objc func updateAudioMeter(timer: Timer) {
        
        if audioRecorder.isRecording {
            let hr = Int((audioRecorder.currentTime / 60) / 60)
            let min = Int(audioRecorder.currentTime / 60)
            let sec = Int(audioRecorder.currentTime.truncatingRemainder(dividingBy: 60))
            let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
            recordingTimeLabel.stringValue = totalTimeString
            audioRecorder.updateMeters()
        }
    }
    
    //MARK:- Audio recoder delegate methods
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if !flag {
            finishAudioRecording(success: false)
        }
    }
    
    func doSaveCurrentRecording() {
        file.fileDownloaded = true
        
        let fileManager = FileManager.default
        let sharedContainer = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)
        let oldPath = sharedContainer?.appendingPathComponent("Recording1.wav")
        
        var newPath = "/" + (RecordingsManager.sharedInstance.recordFolders.first?.title)! + "/" + file.id
        if !FileManager.default.fileExists(atPath: (sharedContainer?.path)! + newPath) {
            do {
                try FileManager.default.createDirectory(atPath: (sharedContainer?.path)! + newPath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {
            }
        }
        newPath = newPath + "/" + file.id + ".wav"
        
        do {
            try fileManager.moveItem(atPath: (oldPath?.path)!, toPath: (sharedContainer?.path)! + newPath)
            file.localFile = newPath
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        RecorderFrameworkManager.sharedInstance.uploadRecording(file)
        RecorderFrameworkManager.sharedInstance.saveData()
    }
}

