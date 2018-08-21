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

struct APIObject: Codable {
    var location: GeoPoint
    var time1: Date
    var time2: Date
    var userID: String
}

struct GeoPoint: Codable {
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
}

class APIManager {
    static let shared = APIManager()
    private let NetworkQueue = OperationQueue()
    private let reachability = Reachability()
    
    func post(apiObject: APIObject) {
        //convert to json
        
        do {
            let jsonData = try JSONEncoder().encode(apiObject)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            let _ = try JSONDecoder().decode(APIObject.self, from: jsonData)
            
            if reachability?.connection == .none {
                print("No connection - Saving")
                UserDefaultsManager.shared.saveAPIObject(apiObjectAsJson: jsonString)
            } else {
                print("With connection - Sending out")
                postToServer(json: jsonString)
            }
        } catch {
            print(error)
        }
    }
    
    func postAllIfNetworkAvailable() {
        print("Post All")
        if reachability?.connection != .none {
            let allPending = UserDefaultsManager.shared.getAllPendingData()
            allPending.forEach { (jsonString) in
                postToServer(json: jsonString)
            }
            UserDefaultsManager.shared.clearOutPendingData()
        }
    }
    
    private func postToServer(json: String) {
        let operation = PostOperation(apiObjecAsJson: json)
        NetworkQueue.addOperation(operation)
    }
}
