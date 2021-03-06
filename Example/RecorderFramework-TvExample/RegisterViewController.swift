//
//  ViewController.swift
//  RecorderFramework
//
//  Created by oacastefanita on 08/10/2017.
//  Copyright (c) 2017 oacastefanita. All rights reserved.
//

import UIKit
import RecorderFramework

class RegisterViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var btnDone: UIButton!
    var code = ""
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
        RecorderFrameworkManager.sharedInstance.register(self.txtPhone.text!, completionHandler: { (success, data) -> Void in
            if success {
                self.code = data as! String
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEnterCodeFromRegister"{
            (segue.destination as! EnterCodeViewController).code = self.code
        }
    }
}

