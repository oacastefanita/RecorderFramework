//
//  LocationViewController.swift
//  RecorderFramework_Example
//
//  Created by Stefanita Oaca on 28/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import MapKit

protocol LocationViewControllerDelegate {
    func selectedLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

class LocationViewController: UIViewController, LocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    var delegate: LocationViewControllerDelegate!
    var lastLocation: CLLocationCoordinate2D!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var center = MKAnnotationView()
        center.frame = CGRect(x:mapView.frame.width/2 - 32, y:mapView.frame.height/2 - 32, width:64, height: 64)
        self.mapView.addSubview(center)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onUseMyLocation(_ sender: Any) {
        let center = CLLocationCoordinate2D(latitude: lastLocation.latitude, longitude: lastLocation.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        self.selectedLocation(latitude: lastLocation.latitude, longitude:lastLocation.longitude)
    }
    
    @IBAction func onDone(_ sender: Any) {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        lastLocation = mapView.centerCoordinate
        
        // add annotation to map
        let CLLCoordType = CLLocationCoordinate2D(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude);
        let anno = MKPointAnnotation();
        anno.coordinate = CLLCoordType;
        mapView.addAnnotation(anno);
        self.selectedLocation(latitude: latitude, longitude:longitude)
    }
    
    func selectedLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        if delegate != nil{
            delegate.selectedLocation(latitude: latitude, longitude: longitude)
        }
        LocationManager.sharedInstance.stopUpdatingLocation()
        LocationManager.sharedInstance.delegate = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Location
    func setupLocationManager(){
        LocationManager.sharedInstance.delegate = self
        LocationManager.sharedInstance.startUpdatingLocation()
    }
    
    func updatedLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let newLocation = CLLocation(latitude: latitude, longitude: longitude)
        let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        self.mapView.setRegion(region, animated: true)
        lastLocation = newLocation.coordinate
    }
}
