//
//  FileTagsViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 20/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class FileTagsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, TagViewControllerDelegate {
    
    var file: RecordItem!
    var selectedTag: AudioTag!
    
    var selectedIndex: Int!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if file.audioFileTags == nil{
            file.audioFileTags = NSMutableArray()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedIndex = nil
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
        return file.audioFileTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        cell.textLabel?.text = "\((file.audioFileTags[indexPath.row] as! AudioTag).type)"
        cell.detailTextLabel?.text = "\((file.audioFileTags[indexPath.row] as! AudioTag).timeStamp!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedTag = (file.audioFileTags[indexPath.row] as! AudioTag)
        selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "showViewTagFromTags", sender: self)
    }
    
    @IBAction func onNewTag(_ sender: Any) {
        selectedTag = AudioTag()
        self.performSegue(withIdentifier: "showTagFromTags", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTagFromTags"{
            (segue.destination as! TagViewController).tag = selectedTag
            (segue.destination as! TagViewController).delegate = self
            let path = RecorderFrameworkManager.sharedInstance.getPath()
            (segue.destination as! TagViewController).filePath = path + file.localFile
            (segue.destination as! TagViewController).fileId = file.id
        } else if segue.identifier == "showViewTagFromTags"{
            (segue.destination as! ViewTagViewController).file = file
            (segue.destination as! ViewTagViewController).tag = selectedTag
        }
    }
    
    func editedTag(_ tag: AudioTag) {
        if selectedIndex != nil{
            file.audioFileTags[selectedIndex] = tag
        }else{
            file.audioFileTags.add(tag)
        }
        file.saveToFile()
        tableView.reloadData()
        if let id = self.file.metaFileId{
            RecorderFrameworkManager.sharedInstance.deleteMetadataFile(self.file.metaFileId, completionHandler: { (success, data) -> Void in
                if success {
                    
                }
                else {
                    self.alert(message: (data as! AnyObject).description)
                }
                RecorderFrameworkManager.sharedInstance.updateRecordingMetadata(self.file)
                RecorderFrameworkManager.sharedInstance.startProcessingActions()
                let folder = RecorderFrameworkManager.sharedInstance.folderForItem(self.file.id)
                RecorderFrameworkManager.sharedInstance.downloadAudioFile(self.file, toFolder: folder.id, completionHandler: { (success) in
                    
                })
                self.navigationController?.popToRootViewController(animated: true)
            })
        }else{
            RecorderFrameworkManager.sharedInstance.updateRecordingMetadata(self.file)
            RecorderFrameworkManager.sharedInstance.startProcessingActions()
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
}
