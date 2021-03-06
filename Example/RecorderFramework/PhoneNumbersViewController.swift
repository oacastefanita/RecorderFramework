//
//  PhoneNumbersViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 30/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class PhoneNumbersViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var selectedObject: AnyObject!
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
        return RecorderFrameworkManager.sharedInstance.getPhoneNumbers().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        cell.textLabel?.text = RecorderFrameworkManager.sharedInstance.getPhoneNumbers()[indexPath.row].phoneNumber
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        for phoneNumber in AppPersistentData.sharedInstance.phoneNumbers{
            if phoneNumber.isDefault{
                phoneNumber.isDefault = false
            }
        }
        selectedObject = AppPersistentData.sharedInstance.phoneNumbers[indexPath.row]
        (AppPersistentData.sharedInstance.phoneNumbers[indexPath.row] as PhoneNumber).isDefault = true
        self.performSegue(withIdentifier: "showNumberDetailsFromNumbers", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNumberDetailsFromNumbers"{
            (segue.destination as! DisplayViewController).object = selectedObject
            (segue.destination as! DisplayViewController).objectTitle = "Phone number details"
        }
    }
}
