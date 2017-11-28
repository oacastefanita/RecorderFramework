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

class FileViewController: UIViewController, TitleViewControllerDelegater{
    @IBOutlet weak var txtTags: UITextField!
    @IBOutlet weak var txtNotes: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var file: RecordItem!
    var folder: RecordFolder!
    var titleType = 0
    var player:AVAudioPlayer!
    var recording = false
    
    var fileCreated = false
    
    //Variables
    var meterTimer:Timer!
    var isAudioRecordingGranted: Bool!
    
    var placeholder = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if file == nil{
            btnUpdate.setTitle("Done", for: .normal)
            file = RecordItem()
            file.id = "Delete"
            folder.recordedItems.append(file)
            fileCreated = true
        }else{
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
//                self.recordingTimeLabel.text = "Downloading"
                RecorderFrameworkManager.sharedInstance.downloadAudioFile(file, toFolder: folder.id, completionHandler: { (success) in
//                    self.recordingTimeLabel.text = "Downloaded"
                    self.play()
                })
            }
            else {
//                self.recordingTimeLabel.text = "Downloaded"
                self.play()
            }
        }
        fillView()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillView(){
        txtTags.text = file.tags
        txtNotes.text = file.notes
        txtEmail.text = file.email
        txtPhoneNumber.text = file.phoneNumber
        txtLastName.text = file.lastName
        txtFirstName.text = file.firstName
        txtName.text = file.text
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
        titleType = 1
        placeholder = "Folder id"
        self.performSegue(withIdentifier: "titleFromFile", sender: self)
    }
    
    @IBAction func onUpdate(_ sender: Any) {
        self.view.endEditing(true)
        file.tags = txtTags.text!
        file.notes = txtNotes.text!
        file.email = txtEmail.text!
        file.phoneNumber = txtPhoneNumber.text!
        file.lastName = txtLastName.text!
        file.firstName = txtFirstName.text!
        file.text = txtName.text
        
        if btnUpdate.titleLabel?.text == "Done"{
            file.id = UUID().uuidString
            doSaveCurrentRecording()
            self.alert(message: "Request sent")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let dict = NSMutableDictionary(dictionary: ["id":file.id, "f_name":file.firstName, "l_name":file.lastName, "email":file.email, "notes":file.notes, "phone":file.phoneNumber, "tags":file.tags])
        RecorderFrameworkManager.sharedInstance.updateRecordingInfo(file, fileInfo: dict)
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
