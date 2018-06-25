//
//  SearchViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 06/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import RecorderFramework

class SearchViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var objects = [RecordItem]()
    var selectedFile: RecordItem!
    @IBOutlet weak var txtSearch: UITextField!
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
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        let recordItem = objects[indexPath.row]
        if recordItem.text != nil && !recordItem.text.isEmpty {
            cell.textLabel?.text = recordItem.text
        }
        else if recordItem.accessNumber != nil && !recordItem.accessNumber.isEmpty {
            cell.textLabel?.text = recordItem.accessNumber
        }
        else {
            cell.textLabel?.text = "Untitled".localized
        }
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedFile = objects[indexPath.row]
        self.performSegue(withIdentifier: "showFileDetailsFromSearch", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        RecorderFrameworkManager.sharedInstance.searchRecordings(query: textField.text!, completionHandler:  ({ (success, data) -> Void in
            if success && data != nil{
                self.objects = data as! [RecordItem]
                self.tableView.reloadData()
            }
        }))
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFileDetailsFromSearch"{
            (segue.destination as! FileViewController).file = selectedFile
        }
    }
}
