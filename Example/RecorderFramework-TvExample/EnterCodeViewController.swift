//
//  EnterCodeViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 24/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

class EnterCodeViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtToken: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtToken.text = AppPersistentData.sharedInstance.notificationToken
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDone(_ sender: Any) {
        RecorderFrameworkManager.sharedInstance.sendVerificationCode(self.txtCode.text!, completionHandler: { (success, data) -> Void in
            if success {
                RecorderFrameworkManager.sharedInstance.mainSync { (success) -> Void in
                    if success {
                        self.performSegue(withIdentifier: "showHomeFromEnterCode", sender: self)
                    }
                }
                
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
