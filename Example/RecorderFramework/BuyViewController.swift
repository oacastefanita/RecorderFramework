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
        NotificationCenter.default.addObserver(self, selector: #selector(BuyViewController.purchaseSucessful), name: NSNotification.Name.mkStoreKitProductPurchased, object: nil)
    }
    
    @IBAction func buy100(){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.Recorder100")
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitProductPurchased, object: nil, queue: OperationQueue()) {note in
            RecorderFrameworkManager.sharedInstance.buy100(reciept: "com.werockapps.Recorder100")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitRestoringPurchasesFailed, object: nil, queue: OperationQueue()) {note in
            
        }
    }
    
    @IBAction func buy300(){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.Recorder300")
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitProductPurchased, object: nil, queue: OperationQueue()) {note in
            RecorderFrameworkManager.sharedInstance.buy100(reciept: "com.werockapps.Recorder300")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitRestoringPurchasesFailed, object: nil, queue: OperationQueue()) {note in
            
        }
    }
    
    @IBAction func buy1000(){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.Recorder1000")
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitProductPurchased, object: nil, queue: OperationQueue()) {note in
            RecorderFrameworkManager.sharedInstance.buy100(reciept: "com.werockapps.Recorder1000")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.mkStoreKitRestoringPurchasesFailed, object: nil, queue: OperationQueue()) {note in
            
        }
    }
    
    @IBAction func buyPremium(){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.CallRecorderPremium")
    }
    
    @IBAction func buyPro(){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.CallRecorderPro")
    }
    
    @objc func purchaseSucessful(){
        if let receipt = self.getReceipt() {
            RecorderFrameworkManager.sharedInstance.buyCredits(0, reciept: receipt)
        }
    }
    
    func getReceipt() -> String? {
        let receiptURL = Bundle.main.appStoreReceiptURL
        
        var receiptError:NSError?
        if let isPresent = (receiptURL as NSURL?)?.checkResourceIsReachableAndReturnError(&receiptError) {
            if !isPresent {
                return nil
            }
        }
        
        if let receiptData = try? Data(contentsOf: receiptURL!) {
            return NSString.init(data: receiptData.base64EncodedData(options: NSData.Base64EncodingOptions(rawValue: 0)), encoding: String.Encoding.utf8.rawValue) as? String
        }
        else {
            return nil
        }
    }
}
