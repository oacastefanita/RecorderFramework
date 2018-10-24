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
    
    override func viewWillAppear() {
        super.viewWillAppear()
        NotificationCenter.default.addObserver(self, selector: #selector(BuyViewController.purchaseSucessful), name: NSNotification.Name.mkStoreKitProductPurchased, object: nil)
    }
    
    @IBAction func buyPro(_ sender: Any){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.RecorderMacPro")
    }
    
    @IBAction func buyPremium(_ sender: Any){
        MKStoreKit.shared().initiatePaymentRequestForProduct(withIdentifier: "com.werockapps.RecorderMacPremium")
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
