//
//  FoldersViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 26/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class FoldersViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, TitleViewControllerDelegater {
    var selectedIndex = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnReorder: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
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
        return RecorderFrameworkManager.sharedInstance.getFolders().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        
        let folder = RecorderFrameworkManager.sharedInstance.getFolders()[indexPath.row]
        if let lblTitle = cell.contentView.viewWithTag(2) as? UILabel {
            lblTitle.text = folder.title
        }
        
        if let btnStar = cell.contentView.viewWithTag(1) as? UIButton {
            cell.contentView.tag = indexPath.row
            btnStar.setTitle( folder.isStar ? "unstar" : "star" , for: .normal)
            btnStar.addTarget(self, action: #selector(FoldersViewController.onStar(_:)), for: .touchUpInside)
        }
//        cell.textLabel?.text = RecorderFrameworkManager.sharedInstance.getFolders()[indexPath.row].title
//        cell.detailTextLabel?.text = ""
        return cell
    }
    
    @objc func onStar(_ btn:UIButton) {
        let index = btn.superview!.tag
        let folder = RecorderFrameworkManager.sharedInstance.getFolders()[index]
        RecorderFrameworkManager.sharedInstance.star(!folder.isStar, entityId: folder.id, isFile: false) { (success, result) in
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        RecorderFrameworkManager.sharedInstance.getRecordings(RecorderFrameworkManager.sharedInstance.getFolders()[indexPath.row].id, completionHandler: ({ (success, data) -> Void in
            
            self.performSegue(withIdentifier: "showFilesFromFolders", sender: self)
        }))
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == RecorderFrameworkManager.sharedInstance.getFolders().count - 1{
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var folders = RecorderFrameworkManager.sharedInstance.getFolders()
        let item = RecorderFrameworkManager.sharedInstance.getFolders()[sourceIndexPath.row]
        folders.remove(at: sourceIndexPath.row)
        folders.insert(item, at: destinationIndexPath.row)
        
        RecorderFrameworkManager.sharedInstance.reorderItems(false, id: item.id!, topId: folders[folders.indexOf(item)! + 1].id!) { (success, response) in
            
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == RecorderFrameworkManager.sharedInstance.getFolders().count - 1{
            return false
        }
        return true
    }
    
    @IBAction func onCreate(_ sender: Any) {
        self.performSegue(withIdentifier: "createFolderFromFolders", sender: self)
    }
    
    @IBAction func onReorder(_ sender: Any) {
        self.tableView.isEditing = !self.tableView.isEditing
        if tableView.isEditing{
            self.btnReorder.setTitle("Done", for: .normal)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
            self.btnReorder.setTitle("Reorder Folders", for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilesFromFolders"{
            (segue.destination as! FilesViewController).selectedFolder = selectedIndex
        } else if segue.identifier == "createFolderFromFolders"{
            (segue.destination as! TitleViewController).delegate = self
            (segue.destination as! TitleViewController).placeholder = "Folder title"
        }
    }
    
    func selectedTitle(_ title: String){
        RecorderFrameworkManager.sharedInstance.createFolder(title, localID: "", completionHandler: { (success, data) -> Void in
            if success {
                self.navigationController?.popToRootViewController(animated: true)
            }
            else {
                self.alert(message: (data as AnyObject).description)
            }
        })
    }
}
