//
//  FileViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 26/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class FileViewController: UIViewController, TitleViewControllerDelegater{
    @IBOutlet weak var txtTags: UITextField!
    @IBOutlet weak var txtNotes: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var btnUpdate: UIButton!
    var file: RecordItem!
    var titleType = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if file == nil{
            btnUpdate.setTitle("Done", for: .normal)
            file = RecordItem()
            if let audioFilePath = Bundle.main.path(forResource: "sample", ofType: "wav") {
                print(audioFilePath)
                let fileManager = FileManager.default
                var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                do {
                    try fileManager.moveItem(atPath: audioFilePath, toPath: path + "sample.wav")
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
                file.localFile =  "sample.wav"
            }
            RecorderFrameworkManager.sharedInstance.syncRecordingItem(file, folder: RecorderFrameworkManager.sharedInstance.getFolders().first!)
        }
        fillView()
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
        self.performSegue(withIdentifier: "titleFromFile", sender: self)
    }
    
    @IBAction func onMove(_ sender: Any) {
        titleType = 1
        self.performSegue(withIdentifier: "titleFromFile", sender: self)
    }
    
    @IBAction func onUpdate(_ sender: Any) {
        file.tags = txtTags.text!
        file.notes = txtNotes.text!
        file.email = txtEmail.text!
        file.phoneNumber = txtPhoneNumber.text!
        file.lastName = txtLastName.text!
        file.firstName = txtFirstName.text!
        file.text = txtName.text!
        
        if btnUpdate.titleLabel?.text == "Done"{
            RecorderFrameworkManager.sharedInstance.uploadRecording(file)
            self.alert(message: "Request sent")
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let dict = NSMutableDictionary(dictionary: ["id":file.id, "f_name":file.firstName, "l_name":file.lastName, "email":file.email, "notes":file.notes, "phone":file.phoneNumber, "tags":file.tags])
        RecorderFrameworkManager.sharedInstance.updateRecordingInfo(file, fileInfo: dict)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.deleteRecording(file, forever: true)
    }
    
    @IBAction func onStar(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.star(true, entityId: file.id, isFile: true, completionHandler: { (success, data) -> Void in
            if success {
                self.alert(message: "Request sent")
                self.navigationController?.popViewController(animated: true)
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "titleFromFile"{
            (segue.destination as! TitleViewController).delegate = self
        }
    }
}
