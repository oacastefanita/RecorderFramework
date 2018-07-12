//
//  MessagesViewController.swift
//  RecorderFramework-TVExample
//
//  Created by Stefanita Oaca on 12/07/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class MessagesViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var selectedObject: AnyObject!
    @IBOutlet weak var tableView: UITableView!
    var messages = [ServerMessage]()
    
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
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row].title
        cell.detailTextLabel?.text = messages[indexPath.row].body
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        selectedObject = messages[indexPath.row].description as AnyObject
        self.performSegue(withIdentifier: "showMessageDetailsFromMessages", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMessageDetailsFromMessages"{
            (segue.destination as! DisplayViewController).object = selectedObject
            (segue.destination as! DisplayViewController).objectTitle = "Message details"
        }
    }
}

