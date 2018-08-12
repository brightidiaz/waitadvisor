//
//  StateModel.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 12/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

import Foundation

enum State {
    case started
    case stopped
    case responseNeeded
}

class StateModel {
    static let stateDidChange = Notification.Name("stateDidChange")
    static let stateKey = "state"
    
    var value: State {
        didSet {
            NotificationCenter.default.post(name: StateModel.stateDidChange, object: self, userInfo: [StateModel.stateKey: value])
        }
    }
    
    init(value: State) {
        self.value = value
    }
}
