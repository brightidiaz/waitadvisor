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
    private var coreLocationManager: CLLocationManager!
    var errorCallback: ((String)->())?
    var successCallback: ((CLLocation)->())?
    
    private override init() {
        super.init()
        DispatchQueue.main.async {[unowned self] in
            self.coreLocationManager = CLLocationManager()
            self.coreLocationManager.delegate = self
            self.coreLocationManager.allowsBackgroundLocationUpdates = true
            self.coreLocationManager.requestAlwaysAuthorization()
        }
    }
    
    convenience init(successCallback: ((CLLocation)->())?, errorCallback: ((String)->())? = nil) {
        self.init()
        self.successCallback = successCallback
        self.errorCallback = errorCallback
    }
    
    func startReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways && authorizationStatus != .authorizedWhenInUse {
            errorCallback?("Not Authorized")
            return
        }
        
        if !CLLocationManager.locationServicesEnabled() {
            errorCallback?("Location Services not enabled")
            return
        }
        
        //Configure the service
        coreLocationManager.delegate = self
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        coreLocationManager.startUpdatingLocation()
    }
    
    func stopReceivingLocationChanges() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .notDetermined {
            coreLocationManager.delegate = nil
        }
        coreLocationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            startReceivingLocationChanges()
        } else {
            errorCallback?("Not Authorized")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        successCallback?(lastLocation)
//        coreLocationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
//            errorCallback?("Not Authorized - \(error.localizedDescription)")
            return
        }
//        errorCallback?("Failed - \(error.localizedDescription)")
    }

}
