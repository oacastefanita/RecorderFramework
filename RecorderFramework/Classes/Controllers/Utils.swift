//
//  Utils.swift
//  Recorder
//
//  Created by Grif on 24/04/15.
//  Copyright (c) 2015 Grif. All rights reserved.
//

import UIKit
import AddressBook

public extension NSString {
    public var localized: String {
        if let value:String = TranslationManager.sharedInstance.translations.object(forKey: self) as? String {
            return value
        }
        
        return NSLocalizedString(self as String, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

public extension String {
    public var localized: String {
        if let value:String = TranslationManager.sharedInstance.translations.object(forKey: self) as? String {
            return value
        }
        
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }

    public func aesEncrypt() -> String {
        if (self.isEmpty){
            return ""
        }else{
            return AESCrypt.encrypt(self, password: "CALLRECORDER")
        }
    }
    
    public func aesDecrypt() -> String {
        if (self.isEmpty){
            return ""
        }else{
            return AESCrypt.decrypt(self, password: "CALLRECORDER")
        }
    }
}

//extension NSRange {
//    func toRange(string: String) -> Range<String.Index> {
//        let startIndex = advanceBy(string.startIndex, location)
//        let endIndex = advance(startIndex, length)
//        return startIndex..<endIndex
//    }
//}

public extension Array {
    public func contains<T>(_ obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

public extension Array {
    public func indexOf<T : Equatable>(_ x:T) -> Int? {
        for i in 0 ..< self.count {
            if self[i] as! T == x {
                return i
            }
        }
        return nil
    }
}

public class Utils:NSObject {
    
    public class func createContact(_ phone:String) {
        let addressBook = ABAddressBookCreateWithOptions(nil, nil)
        if addressBook == nil{
            return
        }
        let addressBookRef: ABAddressBook = addressBook!.takeRetainedValue()
        ABAddressBookRequestAccessWithCompletion(addressBookRef) {
            (granted: Bool, error: CFError!) in
            DispatchQueue.main.async {
                if !granted {
                    print("Just denied", terminator: "")
                    
                } else {
                    print("Just authorized", terminator: "")
                    var recordIDString = UserDefaults.standard.object(forKey: "contact") as? String
                    if recordIDString == nil{
                        recordIDString = "0"
                    } else{
                         print(recordIDString, terminator: "")
                    }
                    let recordID:Int32 = Int32(recordIDString!)!
                    var contact:ABRecord
                    
                    var found = false
                    let contactList: NSArray = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue()
                    for record in contactList {
                        let person: ABRecord = record as ABRecord
                        if ABRecordGetRecordID(person) == recordID{
                            ABAddressBookRemoveRecord(addressBookRef, person, nil)
                            found = true
                            self.saveAddressBookChanges(addressBookRef)
                        } else{
                            print("\(ABRecordGetRecordID(person))", terminator: "")
                            if let first = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as? String {
                                print(first, terminator: "")
                                if first == "Call Recorder"{
                                    ABAddressBookRemoveRecord(addressBookRef, person, nil)
                                    found = true
                                    self.saveAddressBookChanges(addressBookRef)
                                }
                            }
                            if let last  = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as? String {
                                print(last, terminator: "")
                            }
                        }
                    }
                    
                    contact = ABPersonCreate().takeRetainedValue()
                    ABRecordSetValue(contact, kABPersonFirstNameProperty, "Call Recorder" as CFTypeRef, nil)
                    ABPersonSetImageData(contact, NSData(data: UIImagePNGRepresentation(UIImage(named: "ContacsIcon")!)!) as Data as Data as CFData, nil)
                    let phoneNumbers: ABMutableMultiValue = ABMultiValueCreateMutable(ABPropertyType(kABMultiStringPropertyType)).takeRetainedValue()
                    let str = "to record"
                    let cfstr:CFString = str as NSString
                    ABMultiValueAddValueAndLabel(phoneNumbers, phone as CFTypeRef, cfstr, nil)
                    ABRecordSetValue(contact, kABPersonPhoneProperty, phoneNumbers,nil)
                    ABAddressBookAddRecord(addressBookRef, contact, nil)

                    self.saveAddressBookChanges(addressBookRef)
                    
                    UserDefaults.standard.set("\(ABRecordGetRecordID(contact))", forKey: "contact");
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    
    public class func saveAddressBookChanges(_ addressBookRef: ABAddressBook) {
        if ABAddressBookHasUnsavedChanges(addressBookRef){
            var err: Unmanaged<CFError>? = nil
            let savedToAddressBook = ABAddressBookSave(addressBookRef, &err)
            if savedToAddressBook {
                print("Successully saved changes.", terminator: "")
            } else {
                print("Couldn't save changes.", terminator: "")
            }
        } else {
            print("No changes occurred.", terminator: "")
        }
    }
}

public let kNotificationRecordingsUpdated = "RecordingsUpdated"
public let kNotificationCameFromBackground = "CameFromBackground"

public protocol AlertControllerDelegate{
    func alertAccepted(_ alertController:AlertController)
    func alertRejected(_ alertController:AlertController)
}


public class AlertController: NSObject, UIAlertViewDelegate {
    
    public var delegate:AlertControllerDelegate! {
        didSet {
            if (UIDevice.current.systemVersion as NSString).floatValue < 8.0 {
                alertView.delegate = self
            }
        }
    }
    public var alertView:UIAlertView!
    
    public var tag = 0
    
    public class func showAlert(_ sender:UIViewController, title:String, message:String, accept:String?, reject:String?) -> AlertController {
        let instance = AlertController()
        
        instance.showAlert(sender, title: title, message: message, accept: accept, reject:reject)

        return instance
    }
    
    class func showAlert(_ sender:UIViewController, title:String, message:String, accept:String?, reject:String?, cancel:String?) -> AlertController {
        let instance = AlertController()
        
        instance.showAlert(sender, title: title, message: message, accept: accept, reject:reject, cancel:cancel)
        
        return instance
    }
    
    public func showAlert (_ sender:UIViewController, title:String, message:String, accept:String?, reject:String?) {
        if (UIDevice.current.systemVersion as NSString).floatValue < 8.0 {
            alertView = UIAlertView()
            if let _accept = accept {
                alertView.addButton(withTitle: _accept)
            }
            if let _reject = reject {
                alertView.addButton(withTitle: _reject)
            }
            alertView.title = title
            alertView.message = message
            alertView.show()
        }
        else {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            if let _accept = accept {
                alert.addAction(UIAlertAction(title: _accept, style: .default, handler: { action in
                    alert.dismiss(animated: false, completion: nil)
                        if self.delegate != nil {
                            self.delegate.alertAccepted(self)
                        }
                }))
            }
            if let _reject = reject {
                alert.addAction(UIAlertAction(title: _reject, style: .default, handler: { action in
                    alert.dismiss(animated: false, completion: nil)
                        if self.delegate != nil {
                            self.delegate.alertRejected(self)
                        }
                }))
            }

            sender.present(alert, animated: true, completion: nil)
        }
    }
    
    public func showAlert (_ sender:UIViewController, title:String, message:String, accept:String?, reject:String?, cancel:String?) {
        if (UIDevice.current.systemVersion as NSString).floatValue < 8.0 {
            alertView = UIAlertView()
            if let _accept = accept {
                alertView.addButton(withTitle: _accept)
            }
            if let _reject = reject {
                alertView.addButton(withTitle: _reject)
            }
            if let _cancel = cancel {
                alertView.addButton(withTitle: _cancel)
            }
            alertView.title = title
            alertView.message = message
            alertView.show()
        }
        else {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            if let _accept = accept {
                alert.addAction(UIAlertAction(title: _accept, style: .default, handler: { action in
                    alert.dismiss(animated: false, completion: nil)
                    if self.delegate != nil {
                        self.delegate.alertAccepted(self)
                    }
                }))
            }
            if let _reject = reject {
                alert.addAction(UIAlertAction(title: _reject, style: .default, handler: { action in
                    alert.dismiss(animated: false, completion: nil)
                    if self.delegate != nil {
                        self.delegate.alertRejected(self)
                    }
                }))
            }
            
            if let _cancel = cancel {
                alert.addAction(UIAlertAction(title: _cancel, style: .default, handler: { action in
                    alert.dismiss(animated: false, completion: nil)

                }))
            }
            
            sender.present(alert, animated: true, completion: nil)
        }
    }
    
    public func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if delegate != nil {
            if buttonIndex == 0 {
                delegate.alertAccepted(self)
            }
            else if buttonIndex == 1{
                delegate.alertRejected(self)
            }
        }
    }
    
}
