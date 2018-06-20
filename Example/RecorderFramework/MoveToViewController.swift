//
//  MoveToViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 20/06/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class MoveToViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var file: RecordItem!
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
        RecorderFrameworkManager.sharedInstance.moveRecording(file, folderId: RecorderFrameworkManager.sharedInstance.getFolders()[indexPath.row].id)
        RecorderFrameworkManager.sharedInstance.startProcessingActions()
        self.navigationController?.popViewController(animated: true)
        self.alert(message: "Request sent")
    }
}
