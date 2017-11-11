//
//  DisplayViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 11/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import RecorderFramework
import Cocoa

class DisplayViewController: NSViewController{
    
    @IBOutlet weak var textView: NSTextView!
    
    var object: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.string = object.description
    }
}

