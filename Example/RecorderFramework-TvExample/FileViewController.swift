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

    @IBOutlet weak var txtReccuranceDate: UITextField!
    @IBOutlet weak var txtReccuranceDays: UITextField!
    @IBOutlet weak var txtNotes: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnTags: UIButton!
    @IBOutlet weak var btnStar: UIButton!
    
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
                let folder = RecorderFrameworkManager.sharedInstance.folderForItem(file.id)
                RecorderFrameworkManager.sharedInstance.downloadAudioFile(file, toFolder: folder.id, completionHandler: { (success) in
                    self.play()
                })
            }
            else {
                self.play()
            }
        }
        fillView()
        self.btnTags.isEnabled = false
        Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(FileViewController.enableTags), userInfo: nil, repeats: true)
    }
    
    @objc func enableTags(){
        self.btnTags.isEnabled = true
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
        txtReccuranceDate.text = file.remindDate
        txtReccuranceDays.text = file.remindDays
        txtNotes.text = file.notes
        txtEmail.text = file.email
        txtPhoneNumber.text = file.phoneNumber
        txtLastName.text = file.lastName
        txtFirstName.text = file.firstName
        txtName.text = file.text
        btnStar.setTitle(file.isStar ? "Unstar":"Star", for: .normal)
    }
    
    @IBAction func onRename(_ sender: Any) {
        titleType = 0
        placeholder = "new name id"
        self.performSegue(withIdentifier: "titleFromFile", sender: self)
    }
    
    @IBAction func onClone(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.cloneFile(entityId: file.id, completionHandler: { (success, data) -> Void in
            if success {
                self.navigationController?.popToRootViewController(animated: true)
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
        file.remindDays = txtReccuranceDays.text ?? ""
        file.remindDate = txtReccuranceDate.text ?? ""
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
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        let dict = RecorderFrameworkManager.sharedInstance.createDictFromRecordItem(file)
        RecorderFrameworkManager.sharedInstance.updateRecordingInfo(file, fileInfo: NSMutableDictionary(dictionary: dict))
        self.navigationController?.popToRootViewController(animated: true)
        self.alert(message: "Request sent")
    }
    
    @IBAction func onDelete(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.deleteRecording(file, forever: true)
        self.navigationController?.popToRootViewController(animated: true)
        self.alert(message: "Request sent")
    }
    
    @IBAction func onStar(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.star(true, entityId: file.id, isFile: true, completionHandler: { (success, data) -> Void in
            if success {
                self.navigationController?.popToRootViewController(animated: true)
                self.alert(message: "Request sent")
            }
            else {
                self.alert(message: (data as AnyObject).description)
            }
        })
    }
    
    @IBAction func onTags(_ sender: Any) {
//        self.performSegue(withIdentifier: "showTagsFromFile", sender: self)
    }
    
    func selectedTitle(_ title: String){
        if titleType == 0{
            file.text = title
            RecorderFrameworkManager.sharedInstance.renameRecording(file)
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(message: "Request sent")
        }else if titleType == 1{
            RecorderFrameworkManager.sharedInstance.moveRecording(file, folderId: title)
            self.navigationController?.popToRootViewController(animated: true)
            self.alert(message: "Request sent")
        }else{
            RecorderFrameworkManager.sharedInstance.recoverRecording(file, folderId: title)
            self.navigationController?.popToRootViewController(animated: true)
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
