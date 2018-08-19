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
    
    func saveAPIObject(apiObjectAsJson: String) {
        if var pendingData = UserDefaults.standard.array(forKey: key) as? [String] {
            pendingData.append(apiObjectAsJson)
            commitChanges(data: pendingData, key: key)
        } else {
            var pendingData = [String]()
            pendingData.append(apiObjectAsJson)
            commitChanges(data: pendingData, key: key)
        }
    }
    
    private func commitChanges<T>(data: [T], key: String) {
        UserDefaults.standard.set(data, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    @discardableResult func getLastAndRemove() -> String? {
        if var pendingData = UserDefaults.standard.array(forKey: key) as? [String] {
            if pendingData.count > 0 {
                let returnValue = pendingData.removeLast()
                commitChanges(data: pendingData, key: key)
                return returnValue
            }
        }
        return nil
    }
    
    func getAllPendingData() -> [String] {
        return UserDefaults.standard.array(forKey: key) as? [String] ?? []
    }
    
    func clearOutPendingData() {
        if var pendingData = UserDefaults.standard.array(forKey: key) as? [String] {
            pendingData.removeAll()
            commitChanges(data: pendingData, key: key)
        }
    }
    
    func printContents() {
        if let contents = UserDefaults.standard.array(forKey: key) as? [String] {
            print(contents)
        }
    }
    
}
