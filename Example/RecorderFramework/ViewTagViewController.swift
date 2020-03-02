//
//  ViewTagViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 26/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import RecorderFramework
import AVFoundation
import AVKit
import MapKit
import ModelIO
import SceneKit
import SceneKit.ModelIO
import FDWaveformView

class ViewTagViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UIDocumentInteractionControllerDelegate{
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var file: RecordItem!
    var tag: AudioTag!
    
    var documentInteractionController: UIDocumentInteractionController!
    
    @IBOutlet weak var waveView: FDWaveformView!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblArg1: UILabel!
    @IBOutlet weak var lblArg2: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sceneView: SCNView!
    var images = [UIImage]()
    var firstAppearance = true
    override func viewDidLoad() {
        super.viewDidLoad()
        initAudio()
        
        self.lblType.text = "Type: \(tag.type)"
    }
    
    func initAudio(){
        let url = URL(fileURLWithPath: RecorderFrameworkManager.sharedInstance.getPath() + file.localFile)
        self.waveView.audioURL = url
        self.waveView.doesAllowScrubbing = true
        self.waveView.doesAllowStretch = true
        self.waveView.doesAllowScroll = true
        self.waveView.wavesColor = UIColor.black
        self.waveView.progressColor = UIColor.black
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstAppearance{
            prepareView()
            firstAppearance = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDone(_ sender: Any) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath)
        cell.imageView?.image = images[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func prepareView(){
        self.title = self.tag.type.rawValue
        self.lblArg1.isHidden = false
        self.lblArg2.isHidden = false
        self.tableView.isHidden = true
        self.mapView.isHidden = true
        self.sceneView.isHidden = true
        switch tag.type {
        case .alert:
            if self.tag.arg != nil{
                self.lblArg1.text = "Alert: " + (self.tag.arg as! String)
            }else{
                self.lblArg1.text = "missing argument"
            }
            
            if self.tag.arg2 != nil{
                self.lblArg2.text = self.tag.arg2 as! String
            }else{
                self.lblArg2.text = "missing argument"
            }
            
            break
        case .note:
            if self.tag.arg != nil{
                self.lblArg1.text = "Note: " + (self.tag.arg as! String)
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .todo:
            if self.tag.arg != nil{
                self.lblArg1.text = "Todo: " + (self.tag.arg as! String)
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .date:
            if self.tag.arg != nil{
                self.lblArg1.text = "Date: " + (self.tag.arg as! String)
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .images:
            self.lblArg1.isHidden = true
            self.lblArg2.isHidden = true
            for id in (tag.arg as! String).components(separatedBy: ","){
                var url = RecorderFrameworkManager.sharedInstance.getPath() + file.localFile.components(separatedBy: ".").first! + "/" + id
                if let image = UIImage(contentsOfFile:url){
                    images.append(image)
                }
            }
            self.tableView.isHidden = false
            tableView.reloadData()
            break
        case .audio:
        
            if self.tag.arg != nil{
                self.lblArg1.isHidden = true
                self.lblArg2.isHidden = true
                let videoURL = URL(string: self.tag.arg as! String)
                player = AVPlayer(url: videoURL! as URL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.addChildViewController(playerController)
                
                // Add your view Frame
                playerController.view.frame = self.tableView.frame
                
                
                // Add sub view in your view
                self.view.addSubview(playerController.view)
                
                player.play()
            }else{
                self.lblArg1.text = "missing argument"
            }
        
            break
        case .video:
            if self.tag.arg != nil{
                self.lblArg1.isHidden = true
                self.lblArg2.isHidden = true
                
                let videoURL = URL(string: self.tag.arg as! String)
                player = AVPlayer(url: videoURL! as URL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.addChildViewController(playerController)
                
                // Add your view Frame
                playerController.view.frame = self.tableView.frame
                
                // Add sub view in your view
                self.view.addSubview(playerController.view)
                
                player.play()
            }else{
                self.lblArg1.text = "missing argument"
            }
            break
        case .tags:
            if self.tag.arg != nil{
                self.lblArg1.text = "Tag: " + (self.tag.arg as! String)
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .beforeAfter:
            self.lblArg1.isHidden = true
            self.lblArg2.isHidden = true
            self.tableView.isHidden = false
            var url1 = RecorderFrameworkManager.sharedInstance.getPath() + file.localFile.components(separatedBy: ".").first! + "/" + (tag.arg as? String)!
            var url2 = RecorderFrameworkManager.sharedInstance.getPath() + file.localFile.components(separatedBy: ".").first! + "/" + (tag.arg2 as? String)!
            if let image = UIImage(contentsOfFile:url1){
                images.append(image)
            }
            if let image = UIImage(contentsOfFile:url2){
                images.append(image)
            }
            tableView.reloadData()
            break
        case .panorama:
            self.lblArg1.isHidden = true
            self.lblArg2.isHidden = true
            self.performSegue(withIdentifier: "showPanoramaViewFromTag", sender: self)
            break
        case .productViewer:
            if self.tag.arg != nil{
                self.lblArg1.text = self.tag.arg as! String
                RecorderFrameworkManager.sharedInstance.downloadFile(self.tag.arg as! String, atPath: RecorderFrameworkManager.sharedInstance.getPath() + "/3d.obj", completionHandler: { (success, data) -> Void in
                    if success {
                        let url = URL(string: RecorderFrameworkManager.sharedInstance.getPath() + "/3d.obj")
                        let asset = MDLAsset(url:url!)
                        guard let object = asset.object(at: 0) as? MDLMesh else {
//                            fatalError("Failed to get mesh from asset.")
                            return
                        }
                        let scene = SCNScene()
                        let node = SCNNode(mdlObject: object)
                        scene.rootNode.addChildNode(node)
                        self.sceneView.autoenablesDefaultLighting = true
                        self.sceneView.allowsCameraControl = true
                        self.sceneView.scene = scene
                        self.sceneView.backgroundColor = UIColor.yellow
                        self.sceneView.isHidden = false
                    }
                    else {
                        self.alert(message: (data as! AnyObject).description)
                    }
                })
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            
            break
        case .pageFlip:
            if self.tag.arg != nil{
                self.lblArg1.text = self.tag.arg as! String
                RecorderFrameworkManager.sharedInstance.downloadFile(self.tag.arg as! String, atPath: RecorderFrameworkManager.sharedInstance.getPath() + "/file.pdf", completionHandler: { (success, data) -> Void in
                    if success {
                        let url = URL(fileURLWithPath: RecorderFrameworkManager.sharedInstance.getPath() + "/file.pdf")
                        
                        self.documentInteractionController = UIDocumentInteractionController(url: url)
                        self.documentInteractionController?.delegate = self
                        self.documentInteractionController?.presentPreview(animated: true)
                    }
                    else {
                        self.alert(message: (data as! AnyObject).description)
                    }
                })
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .location:
            if let string = self.tag.arg as? String{
                self.mapView.isHidden = false
                self.lblArg1.isHidden = true
                self.lblArg2.isHidden = true
                let latitude = CLLocationDegrees(Float(string.components(separatedBy: ",").first!)!)
                let longitude = CLLocationDegrees(Float(string.components(separatedBy: ",").last!)!)
                let CLLCoordType = CLLocationCoordinate2D(latitude: latitude, longitude: longitude);
                let anno = MKPointAnnotation();
                anno.coordinate = CLLCoordType;
                mapView.addAnnotation(anno);
                
                let newLocation = CLLocation(latitude: latitude, longitude: longitude)
                let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.mapView.setRegion(region, animated: true)
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .phoneNumber:
            if self.tag.arg != nil{
                self.lblArg1.text = "Number" + (self.tag.arg as! String)
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .socialMedia:
            if self.tag.arg != nil{
                self.lblArg1.text = self.tag.arg as! String
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .imageURL:
            if self.tag.arg != nil{
                let webV:UIWebView = UIWebView(frame: self.tableView.frame)
                webV.loadRequest(URLRequest(url: URL(string: self.tag.arg as! String)!))
                self.view.addSubview(webV)
                self.lblArg1.isHidden = true
            }
            else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .htmlEmbed:
            if self.tag.arg != nil{
                let webV:UIWebView = UIWebView(frame: self.tableView.frame)
                webV.loadRequest(URLRequest(url: URL(string: self.tag.arg as! String)!))
                self.view.addSubview(webV)
                self.lblArg1.isHidden = true
            }
            else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .noiztube:
            if self.tag.arg != nil{
                self.lblArg1.text = "Note: " + (self.tag.arg as! String)
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
