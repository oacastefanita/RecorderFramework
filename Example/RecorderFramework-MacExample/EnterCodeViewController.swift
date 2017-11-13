//
//  EnterCodeViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 09/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class EnterCodeViewController: NSViewController {
    
    @IBOutlet weak var txtCode: NSTextField!
    @IBOutlet weak var btnDone: NSButton!
    
    @IBAction func onDone(_ sender:Any){
        RecorderFrameworkManager.sharedInstance.sendVerificationCode(self.txtCode.stringValue, completionHandler: { (success, data) -> Void in
            if success {
                RecorderFrameworkManager.sharedInstance.mainSync { (success) -> Void in
                    if success {
                        self.view.window?.close()
                        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showHomeFromEnterCode"), sender: self)
                    }
                }
            }
            else {
                //                self.alert(message: (data as! AnyObject).description)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}
