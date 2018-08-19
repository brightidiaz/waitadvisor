//
//  PostOperation.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 19/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

import Foundation

class PostOperation: WaitAdvisorOperation {
    var responseObject: ServerResponse?
    var apiObject: APIObject
    
    init(apiObject: APIObject) {
        self.apiObject = apiObject
    }
    
    override func main() {
        guard isCancelled == false else {
            finish(true)
            return
        }
        
        executing(true)
        
        print("POST DATA = \(self.apiObject)")
        if (!isCancelled) {
            responseObject?.response = "Server Response"
        }
        self.executing(false)
        self.finish(true)
    }
}
