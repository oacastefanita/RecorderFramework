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


struct ReadFile {
    static var arrayFloatValues:[Float] = []
    static var points:[CGFloat] = []
}

class ViewTagViewController: UIViewController,WaveHolderViewDelegate, UITableViewDelegate, UITableViewDataSource,UIDocumentInteractionControllerDelegate{
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var file: RecordItem!
    var tag: AudioTag!
    
    var documentInteractionController: UIDocumentInteractionController!
    
    var inputOsciloscopLayer:TPOscilloscopeLayer!
    @IBOutlet weak var playerHolder: WaveHolderView!
    @IBOutlet var playerCursor:PlayerCursor!
    @IBOutlet weak var lblRecordItem: UILabel!
    @IBOutlet weak var waveView: UIView!
    @IBOutlet weak var waveScrollView: UIScrollView!
    @IBOutlet weak var cursor: UIImageView!
    
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblArg1: UILabel!
    @IBOutlet weak var lblArg2: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var sceneView: SCNView!
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerCursor = PlayerCursor(frame:CGRect(x: 131, y: -14, width: 42, height: 72))
        playerCursor.valueView.isHidden = true
        playerHolder.addSubview(playerCursor)

        playerHolder.cursor = self.cursor
        playerHolder.scrollView = self.waveScrollView
        playerHolder.delegate = self
        
        self.inputOsciloscopLayer = TPOscilloscopeLayer()
        inputOsciloscopLayer.frame = CGRect(x:0,y: 0,width: playerHolder.frame.size.width,height: playerHolder.frame.size.height)
        waveView.layer.addSublayer(inputOsciloscopLayer)
        
        initAudio()
        
        self.lblType.text = "\(tag.type)"
    }
    
    func initAudio(){
        let url = URL(string: RecorderFrameworkManager.sharedInstance.getPath() + self.file.localFile)
        let file = try! AVAudioFile(forReading: url!)//Read File into AVAudioFile
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false)//Format of the file
        
        let buf = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: UInt32(file.length))//Buffer
        try! file.read(into: buf!)//Read Floats
        //Store the array of floats in the struct
        let array = Array(UnsafeBufferPointer(start: buf?.floatChannelData?[0], count:Int("\(buf!.frameLength)")!))
        ReadFile.arrayFloatValues = Array()
        var max = Float(0.0)
        var newArray = Array<Float>()
        for item in array{
            var newItem = abs(item)
            if newItem == 0.0{
                newItem = 0.000001
            }
            if max < newItem{
                max = newItem
            }
            newArray.append(newItem)
        }
        for item in newArray{
            var newitem = 1 / (max / item)
            if newitem >= 1{
                newitem = 0.999999
            }
            ReadFile.arrayFloatValues.append(newitem * 10)
            print(newitem)
        }
        
        showWaves()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDone(_ sender: Any) {
        
    }
    
    func showWaves() {
        cursor.frame = CGRect(x: 0,y: cursor.frame.origin.y,width: cursor.frame.size.width,height: cursor.frame.size.height)
        waveScrollView.contentOffset = CGPoint(x: 0,y: 0)
        
        if ReadFile.arrayFloatValues != nil {
            self.inputOsciloscopLayer.renderVals = ReadFile.arrayFloatValues as! [Any]
            
            self.inputOsciloscopLayer.setNeedsDisplay()
            if inputOsciloscopLayer.renderVals != nil && inputOsciloscopLayer.renderVals.count > 0 {
                playerHolder.maxXPosition = Int(Float(inputOsciloscopLayer.renderVals.count) * 0.5)
            }
        }
    }
    
    func cursorMoved() {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func prepareView(){
        self.lblArg1.isHidden = false
        self.lblArg2.isHidden = false
        self.tableView.isHidden = true
        self.mapView.isHidden = true
        switch tag.type {
        case .alert:
            if self.tag.arg != nil{
                self.lblArg1.text = self.tag.arg as! String
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
                self.lblArg1.text = self.tag.arg as! String
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .todo:
            if self.tag.arg != nil{
                self.lblArg1.text = self.tag.arg as! String
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .date:
            if self.tag.arg != nil{
                self.lblArg1.text = self.tag.arg as! String
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .images:
            
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
                self.lblArg1.text = self.tag.arg as! String
            }else{
                self.lblArg1.text = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .beforeAfter:
            
            break
        case .panorama:
            self.performSegue(withIdentifier: "showPanoramaViewFromTag", sender: self)
            break
        case .productViewer:
            if self.tag.arg != nil{
                self.lblArg1.text = self.tag.arg as! String
                RecorderFrameworkManager.sharedInstance.downloadFile(self.tag.arg as! String, atPath: RecorderFrameworkManager.sharedInstance.getPath() + "3d.obj", completionHandler: { (success, data) -> Void in
                    if success {
                        let url = URL(string: RecorderFrameworkManager.sharedInstance.getPath() + "3d.obj")
                        
                        let asset = MDLAsset(url:url!)
                        guard let object = asset.object(at: 0) as? MDLMesh else {
                            fatalError("Failed to get mesh from asset.")
                        }
                        let scene = SCNScene()
                        let node = SCNNode(mdlObject: object)
                        scene.rootNode.addChildNode(node)
                        self.sceneView.autoenablesDefaultLighting = true
                        self.sceneView.allowsCameraControl = true
                        self.sceneView.scene = scene
                        self.sceneView.backgroundColor = UIColor.yellow
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
                RecorderFrameworkManager.sharedInstance.downloadFile(self.tag.arg as! String, atPath: RecorderFrameworkManager.sharedInstance.getPath() + "file.pdf", completionHandler: { (success, data) -> Void in
                    if success {
                        let url = URL(fileURLWithPath: RecorderFrameworkManager.sharedInstance.getPath() + "file.pdf")
                        
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
            
            break
        case .phoneNumber:
            if self.tag.arg != nil{
                self.lblArg1.text = self.tag.arg as! String
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
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}
