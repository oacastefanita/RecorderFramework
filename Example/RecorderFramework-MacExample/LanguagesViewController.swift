//
//  LanguagesViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 11/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class LanguagesViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var tableView: NSTableView!
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
        return RecorderFrameworkManager.sharedInstance.getLanguages().count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "resultCell"), owner: self) as! NSTableCellView
        cell.textField?.stringValue = RecorderFrameworkManager.sharedInstance.getLanguages()[row].name
        
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRowIndexes.first!
        RecorderFrameworkManager.sharedInstance.getTranslations(RecorderFrameworkManager.sharedInstance.getLanguages()[row].code, completionHandler: { (success, data) -> Void in
            if success {
                self.selectedObject = data as AnyObject
                self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showTranslationsFromLanguages"), sender: self)
            }
            else {
                
            }
        })
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier != nil{
            if segue.identifier!.rawValue == "showTranslationsFromLanguages"{
                (segue.destinationController as! DisplayViewController).object = selectedObject
            }
        }
    }
}
