//
//  BuyViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 11/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework

class BuyViewController: NSViewController{
    
    @IBAction func buy100(_ sender: Any){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.Recorder100")
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitProductPurchased, object: nil, queue: OperationQueue()) {note in
            RecorderFrameworkManager.sharedInstance.buy100(reciept: "com.werockapps.Recorder100")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitRestoringPurchasesFailed, object: nil, queue: OperationQueue()) {note in
            
        }
    }
    
    @IBAction func buy300(_ sender: Any){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.Recorder300")
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitProductPurchased, object: nil, queue: OperationQueue()) {note in
            RecorderFrameworkManager.sharedInstance.buy100(reciept: "com.werockapps.Recorder300")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitRestoringPurchasesFailed, object: nil, queue: OperationQueue()) {note in
            
        }
    }
    
    @IBAction func buy1000(_ sender: Any){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.Recorder1000")
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitProductPurchased, object: nil, queue: OperationQueue()) {note in
            RecorderFrameworkManager.sharedInstance.buy100(reciept: "com.werockapps.Recorder1000")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitRestoringPurchasesFailed, object: nil, queue: OperationQueue()) {note in
            
        }
    }
}
