//
//  FilesViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 12/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class FilesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, TitleViewControllerDelegater {
    
    var selectedFolder:Int = 0
    var selectedFile: RecordItem!
    var titleType = 0
    
    var placeholder = ""
    let dragDropTypeId = "public.data"
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.registerForDraggedTypes( [NSPasteboard.PasteboardType(rawValue: dragDropTypeId)])
        RecorderFrameworkManager.sharedInstance.deleteRecordingItem("Delete")
        tableView.reloadData()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "resultCell"), owner: self) as! NSTableCellView
        let recordItem = RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems[row]
        if recordItem.text != nil && !recordItem.text.isEmpty {
            cell.textField?.stringValue = recordItem.text
        }
        else if recordItem.accessNumber != nil && !recordItem.accessNumber.isEmpty {
            cell.textField?.stringValue = recordItem.accessNumber
        }
        else {
            cell.textField?.stringValue = "Untitled".localized
        }
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRowIndexes.first!
        selectedFile = RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems[row]
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showFileFromFiles"), sender: self)
        self.view.window?.close()
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: NSPasteboard.PasteboardType(rawValue: dragDropTypeId))
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        var oldIndexes = [Int]()
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) {(draggingItem: NSDraggingItem!, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            if let str = (draggingItem.item as! NSPasteboardItem).string(forType: NSPasteboard.PasteboardType(rawValue: "public.data")), let index = Int(str) {
                oldIndexes.append(index)
            }
        }
        
        
        var oldIndexOffset = 0
        var newIndexOffset = 0
        
        // For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
        // You may want to move rows in your content array and then call `tableView.reloadData()` instead.
        tableView.beginUpdates()
        for oldIndex in oldIndexes {
            if oldIndex < row {
                var files = RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems
                let item = RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems[oldIndex + oldIndexOffset]
                files.remove(at: oldIndex + oldIndexOffset)
                files.insert(item, at: row - 1)
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
                tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                oldIndexOffset -= 1
            } else {
                var files = RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems
                let item = RecordingsManager.sharedInstance.recordFolders[selectedFolder].recordedItems[oldIndex]
                files.remove(at: oldIndex)
                files.insert(item, at: row + newIndexOffset)
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
                tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                newIndexOffset += 1
            }
        }
        tableView.endUpdates()
        
        return true
    }
    
    @IBAction func onNewRecording(_ sender: Any) {
        selectedFile = nil
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showFileFromFiles"), sender: self)
        self.view.window?.close()
    }
    
    @IBAction func onCheckPassword(_ sender: Any) {
        titleType = 0
        placeholder = "enter pass"
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "titleFromFiles"), sender: self)
    }
    
    @IBAction func onAddPassword(_ sender: Any) {
        titleType = 1
        placeholder = "enter new pass"
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "titleFromFiles"), sender: self)
    }
    
    @IBAction func onRename(_ sender: Any) {
        titleType = 2
        placeholder = "new name"
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "titleFromFiles"), sender: self)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.deleteFolder(RecordingsManager.sharedInstance.recordFolders[selectedFolder], moveToFolder: "")
        RecorderFrameworkManager.sharedInstance.getRecordingsManager().recordFolders.remove(at: selectedFolder)
        self.view.window?.close()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier != nil{
            if segue.identifier!.rawValue == "titleFromFiles"{
                (segue.destinationController as! TitleViewController).delegate = self
                (segue.destinationController as! TitleViewController).placeholder = placeholder
            } else if segue.identifier!.rawValue == "showFileFromFiles"{
                (segue.destinationController as! FileViewController).file = selectedFile
                (segue.destinationController as! FileViewController).folder = RecordingsManager.sharedInstance.recordFolders[selectedFolder]
            }
        }
    }
    
    func selectedTitle(_ title: String){
        if titleType == 0{
            if(RecordingsManager.sharedInstance.recordFolders[selectedFolder].password != nil){
                if RecordingsManager.sharedInstance.recordFolders[selectedFolder].password == title{
                    //                self.alert(message: "Password is correct")
                }else{
                    //                self.alert(message: "Password is incorrect")
                }
            }
        }else if titleType == 1{
            RecordingsManager.sharedInstance.recordFolders[selectedFolder].password = title
            RecorderFrameworkManager.sharedInstance.addPasswordToFolder(RecordingsManager.sharedInstance.recordFolders[selectedFolder])
            self.view.window?.close()
//            self.alert(message: "Request sent")
        }else{
            RecordingsManager.sharedInstance.recordFolders[selectedFolder].title = title
            RecorderFrameworkManager.sharedInstance.renameFolder(RecordingsManager.sharedInstance.recordFolders[selectedFolder])
            self.view.window?.close()
//            self.alert(message: "Request sent")
        }
    }
}
