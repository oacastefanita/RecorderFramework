//
//  DisplayViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 30/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class DisplayViewController: UIViewController{
    
    @IBOutlet weak var textView: UITextView!
    
    var object: AnyObject!
    var objectTitle:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = object.description
        if let number = object as? PhoneNumber{
            textView.text = ""
            textView.text = "Phone number: " + number.phoneNumber + "\n"
            textView.text = textView.text + "Number: " + number.number + "\n"
            textView.text = textView.text + "Prefix: " + number.prefix + "\n"
            textView.text = textView.text + "Friendly Name: " + number.friendlyNumber + "\n"
            textView.text = textView.text + "City: " + number.city + "\n"
            textView.text = textView.text + "Country: " + number.country + "\n"
        }
        self.title = objectTitle ?? ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
