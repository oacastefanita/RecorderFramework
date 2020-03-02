//
//  TagViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 21/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework
import MapKit

protocol TagViewControllerDelegate {
    func editedTag(_ tag: AudioTag)
}

class TagViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, DatePickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LocationViewControllerDelegate{
    
    var tag: AudioTag!
    var delegate: TagViewControllerDelegate!
    var data = Array<TagType>()
    var filePath: String!
    var maxImages = 0
    var fileId: String!
    var imageType = 0
    
    @IBOutlet weak var txtTime: UITextField!
    @IBOutlet weak var txtDureation: UITextField!
    @IBOutlet weak var txtArg1: UITextField!
    @IBOutlet weak var txtArg2: UITextField!
    @IBOutlet weak var pkrType: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        data = Array(iterateEnum(TagType.self))
        pkrType.reloadAllComponents()
        fillView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDone(_ sender: Any) {
        if !fillObject(){
            return
        }
        if delegate != nil{
            delegate.editedTag(tag)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtTime || textField == txtDureation{
            return
        }
        switch tag.type {
        case .date:
            if textField == txtArg1{
                self.performSegue(withIdentifier: "showDatePickerFromTag", sender: self)
            }
            self.view.endEditing(true)
            break
        case .images:
            imageType = 0
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            self.view.endEditing(true)
            break
        case .beforeAfter:
            imageType = 1
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            self.view.endEditing(true)
            break
        case .panorama:
            imageType = 2
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            self.view.endEditing(true)
            break
        case .location:
            self.performSegue(withIdentifier: "showLocationFromTag", sender: self)
            self.view.endEditing(true)
            break
        default:
            
            break
        }
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.tag = AudioTag()
        tag.type = data[row]
        fillView(false)
    }
    
    func fillObject() -> Bool{
        if Double(txtTime.text!) == nil{
            return false
        }else if Double(txtDureation.text!) == nil{
            return false
        }
        tag.timeStamp = TimeInterval(Double(txtTime.text!)!)
        tag.duration = TimeInterval(Double(txtDureation.text!)!)
        tag.arg = txtArg1.text as AnyObject
        tag.arg2 = txtArg2.text as AnyObject
        
        return true
    }
    
    func fillView(_ picker:Bool = true){
        if tag.timeStamp != nil{
            txtTime.text = "\(tag.timeStamp!)"
        }else{
            txtTime.text = ""
        }
        
        if tag.duration != nil{
            txtDureation.text = "\(tag.duration!)"
        }else{
            txtDureation.text = ""
        }
        
        if tag.arg != nil{
            txtArg1.text = "\(tag.arg!)"
        }else{
            txtArg1.text = ""
        }
        
        if tag.arg2 != nil{
            txtArg2.text = "\(tag.arg2!)"
        }else{
            txtArg2.text = ""
        }
        
        if picker {
            for type in data{
                if type.rawValue == tag.type.rawValue{
                    pkrType.selectRow(data.indexOf(type)!, inComponent: 0, animated: true)
                }
            }
        }
        
        updatePlaceholders()
    }
    
    func updatePlaceholders(){
        txtArg1.isHidden = false
        txtArg2.isHidden = false
        switch tag.type {
        case .alert:
            txtArg1.placeholder = "Alert text"
            txtArg2.placeholder = "Priority"
            break
        case .note:
            txtArg1.placeholder = "Note text"
            txtArg2.isHidden = true
            break
        case .todo:
            txtArg1.placeholder = "Todo text"
            txtArg2.isHidden = true
            break
        case .date:
            txtArg1.placeholder = "Date"
            txtArg2.isHidden = true
            break
        case .images:
            txtArg1.placeholder = "Select images"
            txtArg2.isHidden = true
            break
        case .audio:
            txtArg1.placeholder = "Audio file URL"
            txtArg2.isHidden = true
            break
        case .video:
            txtArg1.placeholder = "Video file URL"
            txtArg2.isHidden = true
            break
        case .tags:
            txtArg1.placeholder = "Tag name"
            txtArg2.isHidden = true
            break
        case .beforeAfter:
            txtArg1.placeholder = "Select before image"
            txtArg2.placeholder = "Select after image"
            break
        case .panorama:
            txtArg1.placeholder = "Select panorama image"
            txtArg2.isHidden = true
            break
        case .productViewer:
            txtArg1.placeholder = ".obj file URL"
            txtArg2.isHidden = true
            break
        case .pageFlip:
            txtArg1.placeholder = ".pdf file URL"
            txtArg2.isHidden = true
            break
        case .location:
            txtArg1.placeholder = "Select location"
            txtArg2.isHidden = true
            break
        case .phoneNumber:
            txtArg1.placeholder = "Enter phone number"
            txtArg2.isHidden = true
            break
        case .socialMedia:
            txtArg1.placeholder = "Social media URL"
            txtArg2.isHidden = true
            break
        case .imageURL:
            txtArg1.placeholder = "Image URL"
            txtArg2.isHidden = true
            break
        case .htmlEmbed:
            txtArg1.placeholder = "html URL"
            txtArg2.isHidden = true
            break
        case .noiztube:
            txtArg1.placeholder = "NoizTube"
            txtArg2.isHidden = true
            break
        }
    }
    
    func selectedDate(_ date: Date) {
        tag.arg = "\(date)" as AnyObject
        txtArg1.text = "\(date)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.view.endEditing(true)
        if segue.identifier == "showDatePickerFromTag"{
            (segue.destination as! DatePickerViewController).delegate = self
        }else if segue.identifier == "showLocationFromTag"{
            (segue.destination as! LocationViewController).delegate = self
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if imageType == 0{
                maxImages = 0
                selectedNewImage(pickedImage)
            }else if imageType == 1{
                maxImages = 2
                selectedNewImage(pickedImage)
            }else if imageType == 2{
                maxImages = 1
                selectedNewImage(pickedImage)
            }
        }
        picker.dismiss(animated: true, completion: nil)
        fillView()
    }
    
    func selectedNewImage(_ image: UIImage){
        var index = 0
        if self.tag.arg != nil{
            index = (self.tag.arg as! String).components(separatedBy: ",").count - 1
        }
        if index > maxImages - 1 && maxImages != 0{
            return
        }
        if Double(txtTime.text!) == nil{
            txtTime.text = "1.0"
        }
        if self.tag.arg == nil{
            self.tag.arg = "" as AnyObject
        }
        
        if self.tag.arg2 == nil{
            self.tag.arg2 = "" as AnyObject
        }
        let photoPath = RecorderFrameworkManager.sharedInstance.getPhotoFilePath(filePath, time: TimeInterval(Double(txtTime.text!)!), index:index)
        do {
            try UIImageJPEGRepresentation(image, 0.5)!.write(to: URL(fileURLWithPath: photoPath), options: .atomic)
        } catch {
            print(error)
        }
        
        RecorderFrameworkManager.sharedInstance.uploadMetadataImageFile(photoPath, fileId: fileId, completionHandler: { (success, data) -> Void in
            if success {
                if !FileManager.default.fileExists(atPath: self.filePath.components(separatedBy: ".").first! + "/") {
                    do {
                        try FileManager.default.createDirectory(atPath: self.filePath.components(separatedBy: ".").first! + "/", withIntermediateDirectories: true, attributes: nil)
                    } catch _ {
                    }
                }
                var url = self.filePath.components(separatedBy: ".").first! + "/" + "\(data!)" + "." + photoPath.components(separatedBy: ".").last!
                do {
                    try UIImageJPEGRepresentation(image, 0.5)!.write(to: URL(fileURLWithPath: url), options: .atomic)
                } catch {
                    print(error)
                }
                if self.maxImages == 2 && index == 0 && (self.tag.arg as! String).count > 0{
                    self.tag.arg2 = ("\(data!)" + "." + photoPath.components(separatedBy: ".").last!) as AnyObject
                    self.txtArg2.text = "\(data!)" + "." + photoPath.components(separatedBy: ".").last!
                }else{
                    self.txtArg1.text = (self.txtArg1.text ?? "") + ","
                    if self.txtArg1.text?.characters.count == 1{
                        self.txtArg1.text = ""
                    }
                    self.txtArg1.text = self.txtArg1.text! + "\(data!)" + "." + photoPath.components(separatedBy: ".").last!
                    self.tag.arg = self.txtArg1.text as AnyObject
                }
            }
            else {
                self.alert(message: (data as! AnyObject).description)
            }
        })
    }
    
    func selectedLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.txtArg1.text = "\(latitude),\(longitude)"
    }
}
