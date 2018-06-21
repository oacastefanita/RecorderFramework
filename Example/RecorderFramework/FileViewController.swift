//
//  FileViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 26/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework
import AVFoundation

class FileViewController: UIViewController, TitleViewControllerDelegater, AVAudioRecorderDelegate, UITextFieldDelegate, DatePickerViewControllerDelegate{
    
    @IBOutlet weak var txtReccuranceDate: UITextField!
    @IBOutlet weak var txtReccuranceDays: UITextField!
    @IBOutlet weak var txtNotes: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnTags: UIButton!
    @IBOutlet weak var btnStar: UIButton!
    @IBOutlet weak var btnRecover: UIButton!
    
    var file: RecordItem!
    var folder: RecordFolder!
    var titleType = 0
    var player:AVAudioPlayer!
    var recording = false
    
    var fileCreated = false
    
    //Variables
    var audioRecorder: AVAudioRecorder!
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    
    var placeholder = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.btnTags.isEnabled = false
        if file == nil{
            btnUpdate.setTitle("Done", for: .normal)
            file = RecordItem()
            file.id = "Delete"
            checkPermission()
            folder.recordedItems.append(file)
            fileCreated = true
        }else{
            if !file.fileDownloaded || file.localFile == nil {
                let folder = RecorderFrameworkManager.sharedInstance.folderForItem(file.id)
                self.recordingTimeLabel.text = "Downloading"
                RecorderFrameworkManager.sharedInstance.downloadAudioFile(file, toFolder: folder.id, completionHandler: { (success) in
                    self.recordingTimeLabel.text = "Downloaded"
                    self.play()
                })
            }
            else {
                self.recordingTimeLabel.text = "Downloaded"
                self.play()
            }
        }
        fillView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(noti:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(FileViewController.enableTags), userInfo: nil, repeats: true)
    }
    
    @objc func enableTags(){
        self.btnTags.isEnabled = true
    }
    
    func checkPermission(){
        switch AVAudioSession.sharedInstance().recordPermission() {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.isAudioRecordingGranted = true
                    } else {
                        self.isAudioRecordingGranted = false
                    }
                }
            }
            break
        default:
            break
        }
    }
    
    func play() {
        var path = RecorderFrameworkManager.sharedInstance.getPath()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillView(){
        txtReccuranceDate.text = file.remindDate
        txtReccuranceDays.text = file.remindDays
        txtNotes.text = file.notes
        txtEmail.text = file.email
        txtPhoneNumber.text = file.phoneNumber
        txtLastName.text = file.lastName
        txtFirstName.text = file.firstName
        txtName.text = file.text
        btnStar.setTitle(file.isStar ? "Unstar":"Star", for: .normal)
        btnRecover.isHidden = (folder.id! != "trash")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtReccuranceDate{
            self.performSegue(withIdentifier: "showDateFromFile", sender: self)
            textField.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    @IBAction func onRename(_ sender: Any) {
        titleType = 0
        placeholder = "new name id"
        self.performSegue(withIdentifier: "titleFromFile", sender: self)
    }
    
    @IBAction func onClone(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.cloneFile(entityId: file.id, completionHandler: { (success, data) -> Void in
            if success {
                self.navigationController?.popViewController(animated: true)
                self.alert(message: "Request sent")
            }
            else {
                self.alert(message: (data as AnyObject).description)
            }
        })
    }
    
    @IBAction func onRecover(_ sender: Any) {
        titleType = 2
        placeholder = "item id"
        self.performSegue(withIdentifier: "titleFromFile", sender: self)
    }
    
    @IBAction func onMove(_ sender: Any) {
        self.performSegue(withIdentifier: "showMoveToFromFile", sender: self)
    }
    
    @IBAction func onUpdate(_ sender: Any) {
        self.view.endEditing(true)
        file.remindDays = txtReccuranceDays.text ?? ""
        file.remindDate = txtReccuranceDate.text ?? ""
        file.notes = txtNotes.text ?? ""
        file.email = txtEmail.text ?? ""
        file.phoneNumber = txtPhoneNumber.text ?? ""
        file.lastName = txtLastName.text ?? ""
        file.firstName = txtFirstName.text ?? ""
        file.text = txtName.text ?? ""
        
        if btnUpdate.titleLabel?.text == "Done"{
            file.id = UUID().uuidString
            doSaveCurrentRecording()
            self.alert(message: "Request sent")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let dict = RecorderFrameworkManager.sharedInstance.createDictFromRecordItem(file)
        RecorderFrameworkManager.sharedInstance.updateRecordingInfo(file, fileInfo: NSMutableDictionary(dictionary: dict))
        self.navigationController?.popViewController(animated: true)
        self.alert(message: "Request sent")
    }
    
    @IBAction func onDelete(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.deleteRecording(file, forever: true)
        self.navigationController?.popViewController(animated: true)
        self.alert(message: "Request sent")
    }
    
    @IBAction func onStar(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.star(true, entityId: file.id, isFile: true, completionHandler: { (success, data) -> Void in
            if success {
                self.navigationController?.popViewController(animated: true)
                self.alert(message: "Request sent")
            }
            else {
                self.alert(message: (data as AnyObject).description)
            }
        })
    }
    
    func selectedTitle(_ title: String){
        if titleType == 0{
            file.text = title
            RecorderFrameworkManager.sharedInstance.renameRecording(file)
            self.navigationController?.popViewController(animated: true)
            self.alert(message: "Request sent")
        }else if titleType == 1{
            RecorderFrameworkManager.sharedInstance.moveRecording(file, folderId: title)
            self.navigationController?.popViewController(animated: true)
            self.alert(message: "Request sent")
        }else{
            RecorderFrameworkManager.sharedInstance.recoverRecording(file, folderId: title)
            self.navigationController?.popViewController(animated: true)
            self.alert(message: "Request sent")
        }
        RecorderFrameworkManager.sharedInstance.startProcessingActions()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "titleFromFile"{
            (segue.destination as! TitleViewController).delegate = self
            (segue.destination as! TitleViewController).placeholder = placeholder
        } else if segue.identifier == "tagsFromFile"{
            let fileManager = FileManager.default
            var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
            path += file.localFile
            self.file.setupWithFile(path)
            (segue.destination as! FileTagsViewController).file = self.file
        } else if segue.identifier == "showDateFromFile"{
            (segue.destination as! DatePickerViewController).delegate = self
            (segue.destination as! DatePickerViewController).showHours = true
        } else if segue.identifier == "showMoveToFromFile"{
            (segue.destination as! MoveToViewController).file = self.file
        }
    }
    
    @IBAction func audioRecorderAction(_ sender: UIButton) {
        if recording{
            btnRecord.setTitle("Record", for: .normal)
            finishAudioRecording(success: true)
        }else{
            if isAudioRecordingGranted {
                btnRecord.setTitle("Stop", for: .normal)
                //Create the session.
                let session = AVAudioSession.sharedInstance()
                
                do {
                    //Configure the session for recording and playback.
                    try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
                    try session.setActive(true)
                    //Set up a high-quality recording session.
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
            }
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
            recordingTimeLabel.text = totalTimeString
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
    
    @objc func keyboardWillHide(noti: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    
    @objc func keyboardWillShow(noti: Notification) {
        
        guard let userInfo = noti.userInfo else { return }
        guard var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    func selectedDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        txtReccuranceDate.text = dateFormatter.string(from: date)
    }
}
