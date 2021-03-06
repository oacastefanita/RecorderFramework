//
//  FileTagsViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 20/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class FileTagsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var file: RecordItem!
    var selectedTag: AudioTag!
    
    var selectedIndex: Int!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if file.audioFileTags == nil{
            file.audioFileTags = NSMutableArray()
        }

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedIndex = nil
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
        return file.audioFileTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
        cell.textLabel?.text = "\((file.audioFileTags[indexPath.row] as! AudioTag).type)"
        cell.detailTextLabel?.text = "\((file.audioFileTags[indexPath.row] as! AudioTag).timeStamp!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedTag = (file.audioFileTags[indexPath.row] as! AudioTag)
        selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "showViewTagFromTags", sender: self)
    }
    
    @IBAction func onNewTag(_ sender: Any) {
        selectedTag = AudioTag()
        self.performSegue(withIdentifier: "showTagFromTags", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showViewTagFromTags"{
            (segue.destination as! ViewTagViewController).file = file
            (segue.destination as! ViewTagViewController).tag = selectedTag
        }
    }
}
