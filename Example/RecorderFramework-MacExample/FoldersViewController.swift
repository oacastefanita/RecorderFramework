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
