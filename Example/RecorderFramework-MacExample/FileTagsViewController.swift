//
//  FileTagsViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 08/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class FileTagsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource,FileTagViewControllerDelegate {
    
    var file: RecordItem!
    var selectedTag: AudioTag!
    
    var selectedIndex: Int!
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return file.audioFileTags.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "resultCell"), owner: self) as! NSTableCellView
        cell.textField?.stringValue = "\((file.audioFileTags[row] as! AudioTag).type)" + "  " + "\((file.audioFileTags[row] as! AudioTag).timeStamp!)"
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRowIndexes.first!
        selectedTag = (file.audioFileTags[row] as! AudioTag)
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showViewTagFromTags"), sender: self)
        self.view.window?.close()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier != nil{
            if segue.identifier!.rawValue == "showTagFromTags"{
                (segue.destinationController as! FileTagViewController).tag = selectedTag
                (segue.destinationController as! FileTagViewController).delegate = self
                let path = RecorderFrameworkManager.sharedInstance.getPath()
                (segue.destinationController as! FileTagViewController).filePath = path + file.localFile
                (segue.destinationController as! FileTagViewController).fileId = file.id
            }  else if segue.identifier!.rawValue == "showViewTagFromTags"{
                (segue.destinationController as! ViewTagViewController).file = file
                (segue.destinationController as! ViewTagViewController).tag = selectedTag
            }
        }
    }
    
    @IBAction func onNewTag(_ sender: Any) {
        selectedTag = AudioTag()
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showTagFromTags"), sender: self)
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
//                    self.alert(message: (data as! AnyObject).description)
                }
                RecorderFrameworkManager.sharedInstance.updateRecordingMetadata(self.file)
                RecorderFrameworkManager.sharedInstance.startProcessingActions()
                let folder = RecorderFrameworkManager.sharedInstance.folderForItem(self.file.id)
                RecorderFrameworkManager.sharedInstance.downloadAudioFile(self.file, toFolder: folder.id, completionHandler: { (success) in
                    
                })
                self.view.window?.close()
            })
        }else{
            RecorderFrameworkManager.sharedInstance.updateRecordingMetadata(self.file)
            RecorderFrameworkManager.sharedInstance.startProcessingActions()
        }
    }
}
