//
//  APIManager.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 19/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

//This will also take care of caching

import Foundation
import CoreLocation

struct APIObject {
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var time1: Date
    var time2: Date
    var userID: String
}

class APIManager {
    static let shared = APIManager()
    
    func post(apiObject: APIObject) {
        //if no connection, save to user defaults
        UserDefaultsManager.shared.saveAPIObject(userId: apiObject.userID)
    }
}
