//
//  PanoramaViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 28/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class PanoramaViewController: GLKViewController{
    
    var panoramaView: PanoramaView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        panoramaView = PanoramaView()
        panoramaView.frame = self.view.frame
        panoramaView.setImage(UIImage(named:"360.jpeg"))
        panoramaView.orientToDevice = true
        panoramaView.touchToPan = true
        panoramaView.pinchToZoom = true
        panoramaView.showTouches = true
        panoramaView.vrMode = false
        self.view = panoramaView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        panoramaView.draw()
    }
    
}
