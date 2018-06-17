//
//  ProfileViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 30/10/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework
import Photos

class ProfileViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate {
    var selectedObject: AnyObject!
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var imgPic: UIImageView!
    @IBOutlet weak var txtPin: UITextField!
    @IBOutlet weak var txtTimezone: UITextField!
    @IBOutlet weak var swtPlayBell: UISwitch!
    @IBOutlet weak var swtPublic: UISwitch!
    
    var imgPicker : UIImagePickerController!
    var path = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        fillView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imgPic.isUserInteractionEnabled = true
        imgPic.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(ProfileViewController.showCamera)))
        imgPic.backgroundColor = .red
        imgPic.contentMode = .scaleAspectFill
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func onDone(_ sender: Any) {
        let params = NSMutableDictionary()
        params["data[play_beep]"] = swtPlayBell.isOn ? "1":"0"
        params["data[f_name]"] = txtFirstName.text ?? ""
        params["data[l_name]"] = txtLastName.text ?? ""
        params["data[is_public]"] = swtPublic.isOn ? "1":"0"
        params["data[time_zone]"] = txtTimezone.text ?? ""
        params["data[email]"] = txtEmail.text ?? ""
        params["data[pin]"] = txtPin.text ?? ""
        
        RecorderFrameworkManager.sharedInstance.updateUserProfile(userInfo: params)
        self.navigationController?.popViewController(animated: true)
        self.alert(message: "Request sent")
    }
    
    func fillView(){
        txtFirstName.text = RecorderFrameworkManager.sharedInstance.getUser().firstName
        txtLastName.text = RecorderFrameworkManager.sharedInstance.getUser().lastName
        txtEmail.text = RecorderFrameworkManager.sharedInstance.getUser().email
        txtTimezone.text = RecorderFrameworkManager.sharedInstance.getUser().timeZone
        txtPin.text = RecorderFrameworkManager.sharedInstance.getUser().pin
        swtPlayBell.isOn = RecorderFrameworkManager.sharedInstance.getUser().playBeep
        swtPublic.isOn = RecorderFrameworkManager.sharedInstance.getUser().isPublic
        
        path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        path = (path as String) + "/profile.jpeg"
        RecorderFrameworkManager.sharedInstance.downloadFile(RecorderFrameworkManager.sharedInstance.getUser().imagePath!, atPath: path, completionHandler: ({ (success,response) -> Void in
            if success{
                self.imgPic.image = UIImage(contentsOfFile: self.path)
            }else{
                
            }
        }))
    }
    
    @objc func showCamera(){
        let alert = UIAlertController()
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
                self.imgPicker = UIImagePickerController()
                self.imgPicker.delegate = self
                self.imgPicker.allowsEditing = true
                self.imgPicker.sourceType = .camera
                self.imgPicker.cameraCaptureMode = .photo
                self.present(self.imgPicker, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Albums", style: .default , handler:{ (UIAlertAction)in
            PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
                switch status{
                case .authorized:
                    self.imgPicker = UIImagePickerController()
                    self.imgPicker.delegate = self
                    self.imgPicker.allowsEditing = true
                    self.imgPicker.sourceType = .photoLibrary
                    self.present(self.imgPicker, animated: true, completion: nil)
                    break
                case .denied:
                    
                    break
                default:
                    
                    break
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler:{ (UIAlertAction)in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imgPic.image = chosenImage
            
            do {
                try UIImageJPEGRepresentation(chosenImage, 0.5)!.write(to: URL(fileURLWithPath: path), options: .atomic)
            } catch {
                print(error)
            }
            
            RecorderFrameworkManager.sharedInstance.uploadProfilePicture(path: path, completionHandler: ({ (success,response) -> Void in
                if success{
                    
                }else{
                    
                }
            }))
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
