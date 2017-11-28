//
//  DatePickerViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 24/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//
import UIKit

protocol DatePickerViewControllerDelegate {
    func selectedDate(_ date: Date)
}

class DatePickerViewController: UIViewController, UIPickerViewDelegate{
    
    @IBOutlet weak var pkrDate: UIDatePicker!
    var delegate: DatePickerViewControllerDelegate!
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pkrDate.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dateChanged(sender: UIDatePicker) {
        date = sender.date
    }
    
    @IBAction func onDone(_ sender: Any) {
        if delegate != nil{
            delegate.selectedDate(self.date)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
