//
//  TitleViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 12/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

protocol TitleViewControllerDelegater {
    func selectedTitle(_ title: String)
}

class TitleViewController: NSViewController, NSTextFieldDelegate {

    @IBOutlet weak var txtTitle: NSTextField!
    var delegate: TitleViewControllerDelegater!
    var placeholder = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        
    }
    
    @IBAction func onDone(_ sender: Any) {
        if delegate != nil{
            delegate.selectedTitle(txtTitle.stringValue)
        }
        self.view.window?.close()
    }
}

