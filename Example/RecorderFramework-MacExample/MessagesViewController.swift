//
//  MessagesViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 04/07/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class MessagesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var tableView: NSTableView!
    var messages = [ServerMessage]()
    var selectedObject: AnyObject!
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
        return messages.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "resultCell"), owner: self) as! NSTableCellView
        cell.textField?.stringValue = messages[row].title + "\n" + messages[row].body
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRowIndexes.first!
        selectedObject = messages[row].description as AnyObject
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showMessageDetails"), sender: self)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier != nil{
            if segue.identifier!.rawValue == "showMessageDetails"{
                (segue.destinationController as! DisplayViewController).object = selectedObject
            }
        }
    }
}
