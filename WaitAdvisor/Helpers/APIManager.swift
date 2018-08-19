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
    private let NetworkQueue = OperationQueue()
    private let reachability = Reachability()
    
    func post(apiObject: APIObject) {
        //if no connection, save to user defaults
//        if reachability?.connection == .none {
//            print("No connection")
//        } else {
//            print("With connection")
//        }
        
        
        let operation = PostOperation(apiObject: apiObject)
        NetworkQueue.addOperation(operation)
        
//        UserDefaultsManager.shared.saveAPIObject(userId: apiObject.userID)
    }
}
