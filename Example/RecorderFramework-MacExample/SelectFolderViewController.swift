//
//  SelectFolderViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 08/07/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class SelectFolderViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var tableView: NSTableView!
    var file: RecordItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        RecorderFrameworkManager.sharedInstance.moveRecording(file, folderId: RecorderFrameworkManager.sharedInstance.getFolders()[row].id)
        RecorderFrameworkManager.sharedInstance.startProcessingActions()
        self.view.window?.close()
    }
    
}
