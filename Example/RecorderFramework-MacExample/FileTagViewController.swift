//
//  FileTagViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 10/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//
import Cocoa
import RecorderFramework
import MapKit
import Quartz

protocol FileTagViewControllerDelegate {
    func editedTag(_ tag: AudioTag)
}

class FileTagViewController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var txtTime: NSTextField!
    @IBOutlet weak var txtDuration: NSTextField!
    @IBOutlet weak var txtArg1: NSTextField!
    @IBOutlet weak var txtArg2: NSTextField!
    @IBOutlet weak var btnType: NSPopUpButton!
    @IBOutlet weak var btnChoose: NSButton!
    @IBOutlet weak var pickerDate: NSDatePicker!
    
    var tag: AudioTag!
    var delegate: FileTagViewControllerDelegate!
    var data = Array<TagType>()
    var filePath: String!
    var maxImages = 0
    var fileId: String!
    var imageType = 0
    var pictureTK:IKPictureTaker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        data = Array(iterateEnum(TagType.self))
        btnType.removeAllItems()
        for tag in data{
            btnType.addItem(withTitle: tag.rawValue)
        }
        btnType.action = #selector(FileTagViewController.selectedType)
        fillView()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        return true
    }
    
    @objc func selectedType(){
        for tag in data{
            if tag.rawValue == btnType.titleOfSelectedItem{
                self.tag = AudioTag()
                self.tag.type = tag
                fillView(false)
                break
            }
        }
    }
    
    @IBAction func onChoose(_ sender: Any) {
        switch tag.type {
        case .date:
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showDatePickerFromTag"), sender: self)
            break
        case .images:
            imageType = 0
            showPictureTaker()
            break
        case .beforeAfter:
            imageType = 1
            showPictureTaker()
            break
        case .panorama:
            imageType = 2
            showPictureTaker()
            break
        case .location:
            
            break
        default:
            
            break
        }
    }
    
    @IBAction func onDone(_ sender: Any) {
        if !fillObject(){
            return
        }
        if delegate != nil{
            delegate.editedTag(tag)
            self.view.window?.close()
        }
        
    }
    
    func fillView(_ picker:Bool = true){
        if tag.timeStamp != nil{
            txtTime.stringValue = "\(tag.timeStamp!)"
        }else{
            txtTime.stringValue = ""
        }
        
        if tag.duration != nil{
            txtDuration.stringValue = "\(tag.duration!)"
        }else{
            txtDuration.stringValue = ""
        }
        
        if tag.arg != nil{
            txtArg1.stringValue = "\(tag.arg!)"
        }else{
            txtArg1.stringValue = ""
        }
        
        if tag.arg2 != nil{
            txtArg2.stringValue = "\(tag.arg2!)"
        }else{
            txtArg2.stringValue = ""
        }
        
        if picker {
            for type in data{
                if type.rawValue == tag.type.rawValue{
                    btnType.selectItem(at: data.indexOf(type)!)
                }
            }
        }
        
        updatePlaceholders()
    }
    
    func updatePlaceholders(){
        txtArg1.isHidden = false
        txtArg2.isHidden = false
        btnChoose.isHidden = true
        pickerDate.isHidden = true
        switch tag.type {
        case .alert:
            txtArg1.placeholderString = "Alert text"
            txtArg2.placeholderString = "Priority"
            break
        case .note:
            txtArg1.placeholderString = "Note text"
            txtArg2.isHidden = true
            break
        case .todo:
            txtArg1.placeholderString = "Todo text"
            txtArg2.isHidden = true
            break
        case .date:
            txtArg1.placeholderString = "Date"
            txtArg2.isHidden = true
            btnChoose.isHidden = false
            pickerDate.isHidden = false
            break
        case .images:
            txtArg1.placeholderString = "Select images"
            txtArg2.isHidden = true
            btnChoose.isHidden = false
            break
        case .audio:
            txtArg1.placeholderString = "Audio file URL"
            txtArg2.isHidden = true
            break
        case .video:
            txtArg1.placeholderString = "Video file URL"
            txtArg2.isHidden = true
            break
        case .tags:
            txtArg1.placeholderString = "Tag name"
            txtArg2.isHidden = true
            break
        case .beforeAfter:
            txtArg1.placeholderString = "Select before image"
            txtArg2.placeholderString = "Select after image"
            btnChoose.isHidden = false
            break
        case .panorama:
            txtArg1.placeholderString = "Select panorama image"
            txtArg2.isHidden = true
            btnChoose.isHidden = false
            break
        case .productViewer:
            txtArg1.placeholderString = ".obj file URL"
            txtArg2.isHidden = true
            break
        case .pageFlip:
            txtArg1.placeholderString = ".pdf file URL"
            txtArg2.isHidden = true
            break
        case .location:
            txtArg1.placeholderString = "Select location"
            txtArg2.isHidden = true
            btnChoose.isHidden = false
            break
        case .phoneNumber:
            txtArg1.placeholderString = "Enter phone number"
            txtArg2.isHidden = true
            break
        case .socialMedia:
            txtArg1.placeholderString = "Social media URL"
            txtArg2.isHidden = true
            break
        case .imageURL:
            txtArg1.placeholderString = "Image URL"
            txtArg2.isHidden = true
            break
        case .htmlEmbed:
            txtArg1.placeholderString = "html URL"
            txtArg2.isHidden = true
            break
        }
    }
    
    func fillObject() -> Bool{
        if Double(txtTime.stringValue) == nil{
            return false
        }else if Double(txtDuration.stringValue) == nil{
            return false
        }
        tag.timeStamp = TimeInterval(Double(txtTime.stringValue)!)
        tag.duration = TimeInterval(Double(txtDuration.stringValue)!)
        tag.arg = txtArg1.stringValue as AnyObject
        tag.arg2 = txtArg2.stringValue as AnyObject
        
        return true
    }
    
    func showPictureTaker(){
        pictureTK = IKPictureTaker()
        pictureTK.begin(withDelegate: self, didEnd: #selector(FileTagViewController.pictureSelected), contextInfo: nil)
        
    }
    
    @objc func pictureSelected(){
        if let img = pictureTK.outputImage(){
            if imageType == 0{
                maxImages = 0
                selectedNewImage(img)
            }else if imageType == 1{
                maxImages = 2
                selectedNewImage(img)
            }else if imageType == 2{
                maxImages = 1
                selectedNewImage(img)
            }
            
            fillView()
        }
    }
    
    func selectedNewImage(_ image: NSImage){
        var index = 0
        if self.tag.arg != nil{
            index = (self.tag.arg as! String).components(separatedBy: ",").count - 1
        }
        if index > maxImages - 1 && maxImages != 0{
            return
        }
        if Double(txtTime.stringValue) == nil{
            txtTime.stringValue = "1.0"
        }
        if self.tag.arg == nil{
            self.tag.arg = "" as AnyObject
        }
        
        if self.tag.arg2 == nil{
            self.tag.arg2 = "" as AnyObject
        }
        let photoPath = RecorderFrameworkManager.sharedInstance.getPhotoFilePath(filePath, time: TimeInterval(Double(txtTime.stringValue)!), index:index)
        image.saveAsPNG(url: URL(fileURLWithPath: photoPath))
        
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
                    image.saveAsPNG(url: URL(fileURLWithPath: url))
                } catch {
                    print(error)
                }
                if self.maxImages == 2 && index == 0 && (self.tag.arg as! String).count > 0{
                    self.tag.arg2 = ("\(data!)" + "." + photoPath.components(separatedBy: ".").last!) as AnyObject
                    self.txtArg2.stringValue = "\(data!)" + "." + photoPath.components(separatedBy: ".").last!
                }else{
                    self.txtArg1.stringValue = (self.txtArg1.stringValue ?? "") + ","
                    if self.txtArg1.stringValue.characters.count == 1{
                        self.txtArg1.stringValue = ""
                    }
                    self.txtArg1.stringValue = self.txtArg1.stringValue + "\(data!)" + "." + photoPath.components(separatedBy: ".").last!
                    self.tag.arg = self.txtArg1.stringValue as AnyObject
                }
            }
            else {
//                self.alert(message: (data as! AnyObject).description)
            }
        })
    }
    
    @IBAction func selectDate(_ sender:AnyObject){
        let date = self.pickerDate.dateValue
        tag.arg = "\(date)" as AnyObject
        txtArg1.stringValue = "\(date)"
    }
}
