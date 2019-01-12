//
//  ViewController.swift
//  RecorderFramework
//
//  Created by oacastefanita on 08/10/2017.
//  Copyright (c) 2017 oacastefanita. All rights reserved.
//

import UIKit
import RecorderFramework
import ShareFramework
import FacebookShare

class RegisterViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var btnDone: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onDone(_ sender: Any) {
        //ShareFacebook.sharedInstance.shareURL(URL(string:"https://www.marinetrade.com")!)

        RecorderFrameworkManager.sharedInstance.register(self.txtPhone.text!, completionHandler: { (success, data) -> Void in
            if success {
                self.performSegue(withIdentifier: "showEnterCodeFromRegister", sender: self)
            }
            else {
                self.alert(message: (data as! AnyObject).description)
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

