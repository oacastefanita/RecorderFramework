//
//  LocationManager.swift
//  TimeAtack
//
//  Created by Stefanita Oaca on 21/06/2017.
//  Copyright © 2017 Stefanita Oaca. All rights reserved.
//

import MapKit

protocol LocationManagerDelegate {
    func updatedLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var updatingLocation = false
    var delegate : LocationManagerDelegate!
    static let sharedInstance = LocationManager()
    
    var locationManager: CLLocationManager = CLLocationManager()
    
    override init(){
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    func startUpdatingLocation(){
        updatingLocation = true
        if CLLocationManager.authorizationStatus() == .authorizedAlways{
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    func stopUpdatingLocation(){
        updatingLocation = false
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let latestLocation: CLLocation = locations[locations.count - 1]
        if delegate != nil{
            delegate.updatedLocation(latitude: latestLocation.coordinate.latitude, longitude: latestLocation.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        } else if status == .denied || status == .restricted {
            // app should not work
        } else {
            if updatingLocation{
                locationManager.startUpdatingLocation()
            }
        }
    }
}
