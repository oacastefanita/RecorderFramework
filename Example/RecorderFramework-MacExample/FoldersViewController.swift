//
//  FoldersViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 12/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class FoldersViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, TitleViewControllerDelegater {
    
    var selectedIndex = 0
    let dragDropTypeId = "public.data"
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var btnReorder: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.registerForDraggedTypes( [NSPasteboard.PasteboardType(rawValue: dragDropTypeId)])
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return RecorderFrameworkManager.sharedInstance.getFolders().count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "resultCell"), owner: self) as! NSTableCellView
        cell.textField?.stringValue = RecorderFrameworkManager.sharedInstance.getFolders()[row].title
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRowIndexes.first!
        selectedIndex = row
        RecorderFrameworkManager.sharedInstance.getRecordings(RecorderFrameworkManager.sharedInstance.getFolders()[row].id, completionHandler: ({ (success, data) -> Void in
            
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showFilesFromFolders"), sender: self)
            self.view.window?.close()
        }))
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
                var folders = RecorderFrameworkManager.sharedInstance.getFolders()
                let item = RecorderFrameworkManager.sharedInstance.getFolders()[oldIndex + oldIndexOffset]
                folders.remove(at: oldIndex + oldIndexOffset)
                folders.insert(item, at: row - 1)
                let parameters = ["type":"folder","id":item.id!,"top_id": folders[folders.indexOf(item)! + 1].id!] as [String : Any]
                RecorderFrameworkManager.sharedInstance.reorderItems(parameters, completionHandler: ({(success, response) -> Void in
                    
                }))
                tableView.moveRow(at: oldIndex + oldIndexOffset, to: row - 1)
                oldIndexOffset -= 1
            } else {
                var folders = RecorderFrameworkManager.sharedInstance.getFolders()
                let item = RecorderFrameworkManager.sharedInstance.getFolders()[oldIndex]
                folders.remove(at: oldIndex)
                folders.insert(item, at: row + newIndexOffset)
                let parameters = ["type":"folder","id":item.id!,"top_id": folders[folders.indexOf(item)! + 1].id!] as [String : Any]
                RecorderFrameworkManager.sharedInstance.reorderItems(parameters, completionHandler: ({(success, response) -> Void in
                    
                }))
                tableView.moveRow(at: oldIndex, to: row + newIndexOffset)
                newIndexOffset += 1
            }
        }
        tableView.endUpdates()
         
        return true
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier != nil{
            if segue.identifier!.rawValue == "showFilesFromFolders"{
                (segue.destinationController as! FilesViewController).selectedFolder = selectedIndex
            } else if segue.identifier!.rawValue == "createFolderFromFolders"{
                (segue.destinationController as! TitleViewController).delegate = self
                (segue.destinationController as! TitleViewController).placeholder = "Folder title"
            }
        }
    }
    
    @IBAction func onCreate(_ sender: Any) {
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "createFolderFromFolders"), sender: self)
    }
    
    @IBAction func onReorder(_ sender: Any) {
        self.tableView.allowsColumnReordering = !self.tableView.allowsColumnReordering
        if tableView.allowsColumnReordering{
            self.btnReorder.stringValue = "Done"
        }else{
            self.btnReorder.stringValue = "Reorder Folders"
            self.view.window?.close()
        }
    }
    
    func selectedTitle(_ title: String){
        RecorderFrameworkManager.sharedInstance.createFolder(title, localID: "", completionHandler: { (success, data) -> Void in
            if success {
                self.view.window?.close()
            }
            else {
                
            }
        })
    }
}
