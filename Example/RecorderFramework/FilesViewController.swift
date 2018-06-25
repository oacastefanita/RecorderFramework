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
    var selectedFile: RecordItem!
    var titleType = 0
    
    var placeholder = ""
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnReorder: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = RecordingsManager.sharedInstance.recordFolders[selectedFolder].title
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        RecorderFrameworkManager.sharedInstance.deleteRecordingItem("Delete")
        tableView.reloadData()
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
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedFile = RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems[indexPath.row]
        self.performSegue(withIdentifier: "showFileFromFiles", sender: self)
    }
    
    @IBAction func onNewRecording(_ sender: Any) {
        selectedFile = nil
        self.performSegue(withIdentifier: "showFileFromFiles", sender: self)
    }
    
    @IBAction func onCheckPassword(_ sender: Any) {
        titleType = 0
        placeholder = "enter pass"
        self.performSegue(withIdentifier: "titleFromFiles", sender: self)
    }
    
    @IBAction func onAddPassword(_ sender: Any) {
        titleType = 1
        placeholder = "enter new pass"
        self.performSegue(withIdentifier: "titleFromFiles", sender: self)
    }
    
    @IBAction func onRename(_ sender: Any) {
        titleType = 2
        placeholder = "new name"
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
            (segue.destination as! TitleViewController).placeholder = placeholder
        } else if segue.identifier == "showFileFromFiles"{
            (segue.destination as! FileViewController).file = selectedFile
            (segue.destination as! FileViewController).folder = RecordingsManager.sharedInstance.recordFolders[selectedFolder]
        }
    }
    
    func selectedTitle(_ title: String){
        if titleType == 0{
            
            RecorderFrameworkManager.sharedInstance.verifyFolderPass(title, folderId: RecordingsManager.sharedInstance.recordFolders[selectedFolder].id, completionHandler: ({(success, response) -> Void in
                if success{
                    self.alert(message: "Password is correct")
                }else{
                    self.alert(message: "Password is incorrect")
                }
            }))
            
        }else if titleType == 1{
            RecordingsManager.sharedInstance.recordFolders[selectedFolder].password = title
            RecorderFrameworkManager.sharedInstance.addPasswordToFolder(RecordingsManager.sharedInstance.recordFolders[selectedFolder])
            self.navigationController?.popViewController(animated: true)
            self.alert(message: "Request sent")
        }else{
            RecordingsManager.sharedInstance.recordFolders[selectedFolder].title = title
            RecorderFrameworkManager.sharedInstance.renameFolder(RecordingsManager.sharedInstance.recordFolders[selectedFolder])
            self.navigationController?.popViewController(animated: true)
            self.alert(message: "Request sent")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var files = RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems
        let item = RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems[sourceIndexPath.row]
        files.remove(at: sourceIndexPath.row)
        files.insert(item, at: destinationIndexPath.row)
        var topItemIndex = files.indexOf(item)!
        var parameters = ["type":"file","id":item.id!] as [String : Any]
        if topItemIndex > 0{
            topItemIndex = topItemIndex - 1
            if topItemIndex == 0 {
                parameters["top_id"] = 0
            }else{
                parameters["top_id"] = files[topItemIndex].id!
            }
        }else{
            parameters["top_id"] = 0
        }
        parameters["folder_id"] = RecordingsManager.sharedInstance.recordFolders[selectedFolder].id!
        RecorderFrameworkManager.sharedInstance.reorderItems(parameters, completionHandler: ({(success, response) -> Void in
            
        }))
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @IBAction func onReorder(_ sender: Any) {
        self.tableView.isEditing = !self.tableView.isEditing
        if tableView.isEditing{
            self.btnReorder.setTitle("Done", for: .normal)
        }else{
            self.btnReorder.setTitle("Reorder", for: .normal)
        }
    }
}
