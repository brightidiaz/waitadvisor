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
    var apiObjecAsJson: String
    private var dbRef: DatabaseReference
    
    init(apiObjecAsJson: String) {
        self.apiObjecAsJson = apiObjecAsJson
        dbRef = Database.database().reference().child("user-locations")
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        
        print("POSTING  DATA = \(self.apiObjecAsJson)")
        
        dbRef.setValue(apiObjecAsJson) {[weak self] (error, dbRef) in
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
    }
}
