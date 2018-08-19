//
//  UserDefaultsManager.swift
//  WaitAdvisor
//
//  Created by John Phillip Lee on 19/08/2018.
//  Copyright © 2018 John Phillip Lee. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let key = "com.jlee.WaitAdvisor.PendingData"
    
    func saveAPIObject(userId: String) {
        if var pendingData = UserDefaults.standard.array(forKey: key) as? [String] {
            pendingData.append(userId)
            commitChanges(data: pendingData, key: key)
        } else {
            var pendingData = [String]()
            pendingData.append(userId)
            commitChanges(data: pendingData, key: key)
        }
    }
    
    private func commitChanges<T>(data: [T], key: String) {
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
    func printContents() {
        if let contents = UserDefaults.standard.array(forKey: key) as? [String] {
            print(contents)
        }
    }
    
}
