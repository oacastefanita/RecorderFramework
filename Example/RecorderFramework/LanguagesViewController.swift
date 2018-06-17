//
//  LanguagesViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 30/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class LanguagesViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var selectedObject: AnyObject!
    var selectedLanguage:Language!
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
        return RecorderFrameworkManager.sharedInstance.getLanguages().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        cell.textLabel?.text = RecorderFrameworkManager.sharedInstance.getLanguages()[indexPath.row].name
        cell.detailTextLabel?.text = ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       selectedLanguage = RecorderFrameworkManager.sharedInstance.getLanguages()[indexPath.row]
        RecorderFrameworkManager.sharedInstance.getTranslations(RecorderFrameworkManager.sharedInstance.getLanguages()[indexPath.row].code, completionHandler: { (success, data) -> Void in
            if success {
                self.selectedObject = data as AnyObject
                self.performSegue(withIdentifier: "showTranslationsFromLanguages", sender: self)
            }
            else {
                self.alert(message: (data as! AnyObject).description)
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTranslationsFromLanguages"{
            (segue.destination as! DisplayViewController).object = selectedObject
            (segue.destination as! DisplayViewController).objectTitle = selectedLanguage.name
        }
    }

}
