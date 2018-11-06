//
//  PostOperation.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 19/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PostOperation: WaitAdvisorOperation {
    var responseObject: ServerResponse?
    var apiObjectAsJson: String
    private var dbRef: DatabaseReference
    
    init(apiObjectAsJson: String) {
        self.apiObjectAsJson = apiObjectAsJson
        dbRef = Database.database().reference().child("location-data")
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        
        var dictionary: [String: Any]
        do {
            guard let apiObjectData = apiObjectAsJson.data(using: .utf8) else {
                executing(false)
                finish(true)
                return
            }
            let apiObject = try JSONDecoder().decode(APIObject.self, from: apiObjectData)
            dictionary = [
                "latitude": apiObject.latitude,
                "longitude": apiObject.longitude,
                "time_start": apiObject.time_start,
                "time_end": apiObject.time_end,
                "userID": apiObject.userID
                ] as [String : Any]

            dbRef.childByAutoId().setValue(dictionary) {[weak self] (error, dbRef) in
                guard let weakSelf = self else {
                    self?.executing(false)
                    self?.finish(true)
                    return
                }
                if  error != nil {
                    print("Error = \(String(describing: error?.localizedDescription))")
                    weakSelf.executing(false)
                    weakSelf.finish(true)
                    return
                }
                if (!weakSelf.isCancelled) {
                    weakSelf.responseObject?.response = "Server Response"
                }
                weakSelf.executing(false)
                weakSelf.finish(true)
            }
        } catch {
            print("Error = \(error.localizedDescription)")
            executing(false)
            finish(true)
            return
        }
        
    }
}
