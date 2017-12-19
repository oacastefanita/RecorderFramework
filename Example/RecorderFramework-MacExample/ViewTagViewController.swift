//
//  ViewTagViewController.swift
//  RecorderFramework-MacExample
//
//  Created by Stefanita Oaca on 11/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Cocoa
import RecorderFramework
import AVFoundation
import AVKit
import WebKit
import SceneKit
import MapKit
import SceneKit.ModelIO
import Quartz

class ViewTagViewController: NSViewController,NSTableViewDelegate, NSTableViewDataSource{
    
    var file: RecordItem!
    var tag: AudioTag!
    
    @IBOutlet weak var waveViewHolder: NSView!
    @IBOutlet weak var lblType: NSTextField!
    @IBOutlet weak var lblArg1: NSTextField!
    @IBOutlet weak var lblArg2: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var tableViewHolder: NSScrollView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var playerView: AVPlayerView!
    @IBOutlet weak var pdfView: PDFView!
    
    var waveView: JHAudioPreviewView!
    var player:AVPlayer!
    var images = [NSImage]()
    var firstAppearance = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.renderAudio()
        self.lblType.stringValue = "\(tag.type)"
        if firstAppearance{
            prepareView()
            firstAppearance = false
        }
    }
    
    func renderAudio() {
        waveView = JHAudioPreviewView()
        waveView.frame = waveViewHolder.bounds
        waveViewHolder.addSubview(waveView)
        
        let fileManager = FileManager.default
        var path = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RecorderFrameworkManager.sharedInstance.containerName)!.path
        path += file.localFile
        
        if !FileManager.default.fileExists(atPath: path) {
            return
        }
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        waveView.player = player
    }
    
    func prepareView(){
        self.lblArg1.isHidden = false
        self.lblArg2.isHidden = false
        self.tableViewHolder.isHidden = true
        self.mapView.isHidden = true
        self.sceneView.isHidden = true
        self.playerView.isHidden = true
        self.webView.isHidden = true
        self.pdfView.isHidden = true
        switch tag.type {
        case .alert:
            if self.tag.arg != nil{
                self.lblArg1.stringValue = self.tag.arg as! String
            }else{
                self.lblArg1.stringValue = "missing argument"
            }
            
            if self.tag.arg2 != nil{
                self.lblArg2.stringValue = self.tag.arg2 as! String
            }else{
                self.lblArg2.stringValue = "missing argument"
            }
            
            break
        case .note:
            if self.tag.arg != nil{
                self.lblArg1.stringValue = self.tag.arg as! String
            }else{
                self.lblArg1.stringValue = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .todo:
            if self.tag.arg != nil{
                self.lblArg1.stringValue = self.tag.arg as! String
            }else{
                self.lblArg1.stringValue = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .date:
            if self.tag.arg != nil{
                self.lblArg1.stringValue = self.tag.arg as! String
            }else{
                self.lblArg1.stringValue = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .images:
            self.lblArg1.isHidden = true
            self.lblArg2.isHidden = true
            for id in (tag.arg as! String).components(separatedBy: ","){
                var url = RecorderFrameworkManager.sharedInstance.getPath() + file.localFile.components(separatedBy: ".").first! + "/" + id
                if let image = NSImage(contentsOfFile:url){
                    images.append(image)
                }
            }
            self.tableViewHolder.isHidden = false
            tableView.reloadData()
            break
        case .audio:
            
            if self.tag.arg != nil{
                self.lblArg1.isHidden = true
                self.lblArg2.isHidden = true
                playerView.isHidden = false
                let videoURL = URL(string: self.tag.arg as! String)
                player = AVPlayer(url: videoURL! as URL)
                playerView.player = player
                player.play()
            }else{
                self.lblArg1.stringValue = "missing argument"
            }
            
            break
        case .video:
            if self.tag.arg != nil{
                self.lblArg1.isHidden = true
                self.lblArg2.isHidden = true
                playerView.isHidden = false
                let videoURL = URL(string: self.tag.arg as! String)
                player = AVPlayer(url: videoURL! as URL)
                playerView.player = player
                player.play()
            }else{
                self.lblArg1.stringValue = "missing argument"
            }
            break
        case .tags:
            if self.tag.arg != nil{
                self.lblArg1.stringValue = self.tag.arg as! String
            }else{
                self.lblArg1.stringValue = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .beforeAfter:
            self.lblArg1.isHidden = true
            self.lblArg2.isHidden = true
            self.tableViewHolder.isHidden = false
            var url1 = RecorderFrameworkManager.sharedInstance.getPath() + file.localFile.components(separatedBy: ".").first! + "/" + (tag.arg as? String)!
            var url2 = RecorderFrameworkManager.sharedInstance.getPath() + file.localFile.components(separatedBy: ".").first! + "/" + (tag.arg2 as? String)!
            if let image = NSImage(contentsOfFile:url1){
                images.append(image)
            }
            if let image = NSImage(contentsOfFile:url2){
                images.append(image)
            }
            tableView.reloadData()
            break
        case .panorama:
            self.lblArg1.isHidden = true
            self.lblArg2.isHidden = true
            self.performSegue(withIdentifier: NSStoryboardSegue.Identifier(rawValue: "showPanoramaFromViewTag"), sender: self)
            break
        case .productViewer:
            if self.tag.arg != nil{
                self.lblArg1.stringValue = self.tag.arg as! String
                RecorderFrameworkManager.sharedInstance.downloadFile(self.tag.arg as! String, atPath: RecorderFrameworkManager.sharedInstance.getPath() + "/3d.obj", completionHandler: { (success, data) -> Void in
                    if success {
                        let url = URL(fileURLWithPath: RecorderFrameworkManager.sharedInstance.getPath() + "/3d.obj")
                        let asset = MDLAsset(url:url)
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
                        self.sceneView.backgroundColor = NSColor.yellow
                        self.sceneView.isHidden = false
                    }
                    else {
//                        self.alert(message: (data as! AnyObject).description)
                    }
                })
            }else{
                self.lblArg1.stringValue = "missing argument"
            }
            self.lblArg2.isHidden = true
            
            break
        case .pageFlip:
            if self.tag.arg != nil{
                self.lblArg1.stringValue = self.tag.arg as! String
                RecorderFrameworkManager.sharedInstance.downloadFile(self.tag.arg as! String, atPath: RecorderFrameworkManager.sharedInstance.getPath() + "/file.pdf", completionHandler: { (success, data) -> Void in
                    if success {
                        let url = URL(fileURLWithPath: RecorderFrameworkManager.sharedInstance.getPath() + "/file.pdf")
                        self.pdfView.isHidden = false
                        self.pdfView.document = PDFDocument(url:url)
                    }
                    else {
//                        self.alert(message: (data as! AnyObject).description)
                    }
                })
            }else{
                self.lblArg1.stringValue = "missing argument"
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
                self.lblArg1.stringValue = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .phoneNumber:
            if self.tag.arg != nil{
                self.lblArg1.stringValue = self.tag.arg as! String
            }else{
                self.lblArg1.stringValue = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .socialMedia:
            if self.tag.arg != nil{
                self.lblArg1.stringValue = self.tag.arg as! String
            }else{
                self.lblArg1.stringValue = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .imageURL:
            if self.tag.arg != nil{
                self.webView.isHidden = false
                webView.load(URLRequest(url: URL(string: self.tag.arg as! String)!))
                self.lblArg1.isHidden = true
            }
            else{
                self.lblArg1.stringValue = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        case .htmlEmbed:
            if self.tag.arg != nil{
                self.webView.isHidden = false
                webView.load(URLRequest(url: URL(string: self.tag.arg as! String)!))
                self.lblArg1.isHidden = true
            }
            else{
                self.lblArg1.stringValue = "missing argument"
            }
            self.lblArg2.isHidden = true
            break
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "imageCell"), owner: self) as! NSTableCellView
        cell.imageView?.image = images[row]
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
       
    }
}
