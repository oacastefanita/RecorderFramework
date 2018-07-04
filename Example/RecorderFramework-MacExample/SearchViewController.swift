//
//  SearchViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 11/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class SearchViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    var objects = [RecordItem]()
    var selectedFile: RecordItem!
    
    @IBOutlet weak var txtSearch: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "resultCell"), owner: self) as! NSTableCellView
        let recordItem = objects[row]
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
        selectedFile = objects[row]
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showFileDetailsFromSearch"), sender: self)
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        RecorderFrameworkManager.sharedInstance.searchRecordings(query: textField.stringValue, completionHandler:  ({ (success, data) -> Void in
            if success && data != nil{
                self.objects = data as! [RecordItem]
                self.tableView.reloadData()
            }
        }))
        tableView.reloadData()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier!.rawValue == "showFileDetailsFromSearch"{
            (segue.destinationController as! FileViewController).file = selectedFile
        }
    }
}
