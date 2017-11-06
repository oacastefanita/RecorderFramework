//
//  TitleViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 28/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework

protocol TitleViewControllerDelegater {
    func selectedTitle(_ title: String)
}

class TitleViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var txtTitle: UITextField!
    var delegate: TitleViewControllerDelegater!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtTitle.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDone(_ sender: Any) {
        txtTitle.endEditing(true)
        if delegate != nil{
            delegate.selectedTitle(txtTitle.text!)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
