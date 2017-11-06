//
//  BuyViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 06/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//
import Foundation
import UIKit
import RecorderFramework

class BuyViewController: UIViewController{

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func buy100(){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.CallRecorder100")
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitProductPurchased, object: nil, queue: OperationQueue()) {note in
            RecorderFrameworkManager.sharedInstance.buy100(reciept: "com.werockapps.CallRecorder100")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitRestoringPurchasesFailed, object: nil, queue: OperationQueue()) {note in
            
        }
    }
    
    @IBAction func buy300(){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.CallRecorder300")
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitProductPurchased, object: nil, queue: OperationQueue()) {note in
            RecorderFrameworkManager.sharedInstance.buy100(reciept: "com.werockapps.CallRecorder300")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitRestoringPurchasesFailed, object: nil, queue: OperationQueue()) {note in
            
        }
    }
    
    @IBAction func buy1000(){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.CallRecorder1000")
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitProductPurchased, object: nil, queue: OperationQueue()) {note in
            RecorderFrameworkManager.sharedInstance.buy100(reciept: "com.werockapps.CallRecorder1000")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitRestoringPurchasesFailed, object: nil, queue: OperationQueue()) {note in
            
        }
    }
}
