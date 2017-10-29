//
//  FilesViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 26/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class FilesViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, TitleViewControllerDelegater {
    
    var selectedFolder:Int = 0
    var titleType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        let recordItem = RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems[indexPath.row]
        if recordItem.text != nil && !recordItem.text.isEmpty {
            cell.textLabel?.text = recordItem.text
        }
        else if recordItem.accessNumber != nil && !recordItem.accessNumber.isEmpty {
            cell.textLabel?.text = recordItem.accessNumber
        }
        else {
            cell.textLabel?.text = "Untitled".localized
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: "showFileFromFiles", sender: self)
    }
    
    @IBAction func onNewRecording(_ sender: Any) {
        
    }
    
    @IBAction func onCheckPassword(_ sender: Any) {
        titleType = 0
        self.performSegue(withIdentifier: "titleFromFiles", sender: self)
    }
    
    @IBAction func onAddPassword(_ sender: Any) {
        titleType = 1
        self.performSegue(withIdentifier: "titleFromFiles", sender: self)
    }
    
    @IBAction func onRename(_ sender: Any) {
        titleType = 2
        self.performSegue(withIdentifier: "titleFromFiles", sender: self)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.deleteFolder(RecordingsManager.sharedInstance.recordFolders[selectedFolder], moveToFolder: "")
        RecorderFrameworkManager.sharedInstance.getRecordingsManager().recordFolders.remove(at: selectedFolder)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "titleFromFiles"{
            (segue.destination as! TitleViewController).delegate = self
        }
    }
    
    func selectedTitle(_ title: String){
        if titleType == 0{
            if RecordingsManager.sharedInstance.recordFolders[selectedFolder].password == title{
                self.alert(message: "Password is correct")
            }else{
                self.alert(message: "Password is incorrect")
            }
        }else if titleType == 1{
            RecordingsManager.sharedInstance.recordFolders[selectedFolder].password = title
            RecorderFrameworkManager.sharedInstance.addPasswordToFolder(RecordingsManager.sharedInstance.recordFolders[selectedFolder])
            self.alert(message: "Request sent")
        }else{
            RecordingsManager.sharedInstance.recordFolders[selectedFolder].title = title
            RecorderFrameworkManager.sharedInstance.renameFolder(RecordingsManager.sharedInstance.recordFolders[selectedFolder])
            self.alert(message: "Request sent")
        }
    }
}
