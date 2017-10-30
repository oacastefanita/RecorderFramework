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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        cell.textLabel?.text = RecorderFrameworkManager.sharedInstance.getFolders()[indexPath.row].title
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "showFilesFromFolders", sender: self)
    }
    
    @IBAction func onCreate(_ sender: Any) {
        self.performSegue(withIdentifier: "createFolderFromFolders", sender: self)
    }
    
    @IBAction func onReorder(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilesFromFolders"{
            (segue.destination as! FilesViewController).selectedFolder = selectedIndex
        } else if segue.identifier == "createFolderFromFolders"{
            (segue.destination as! TitleViewController).delegate = self
        }
    }
    
    func selectedTitle(_ title: String){
        RecorderFrameworkManager.sharedInstance.createFolder(title, localID: "", completionHandler: { (success, data) -> Void in
            if success {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.alert(message: (data as AnyObject).description)
            }
        })
    }
}
