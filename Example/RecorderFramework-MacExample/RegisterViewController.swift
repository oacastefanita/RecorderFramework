//
//  RegisterViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 09/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class RegisterViewController: NSViewController {

    @IBOutlet weak var txtPhone: NSTextField!
    @IBOutlet weak var btnDone: NSButton!
    
    @IBAction func onDone(_ sender:Any){
        RecorderFrameworkManager.sharedInstance.register(self.txtPhone!.stringValue, completionHandler: { (success, data) -> Void in
//            if success {
                self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showEnterCodeFromRegister"), sender: self)
//            }
//            else {
//                self.alert(message: (data as! AnyObject).description)
//            }
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

