//
//  LocationManager.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 18/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    var coreLocationManager: CLLocationManager!
    override init() {
        super.init()
        coreLocationManager = CLLocationManager()
        coreLocationManager.delegate = self
        coreLocationManager.requestWhenInUseAuthorization()
    }
    
    private func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse {
            //Not authorized
            print("Not Authorized")
            return
        }
        
        if !CLLocationManager.locationServicesEnabled() {
            return
        }
        
        //Configure the service
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        coreLocationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            startReceivingLocationChanges()
        } else {
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        print("Last Location = \(lastLocation)")
        coreLocationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            print("Did Fail - Not Authorized")
            manager.stopUpdatingLocation()
            return
        }
        print("Did Fail")
    }

}
