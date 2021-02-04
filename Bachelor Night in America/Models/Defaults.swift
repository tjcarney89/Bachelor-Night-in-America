//
//  DefaultsStore.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 7/10/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import Foundation

class Defaults {
    
    static let signedInKey = "userSignedIn"
    static let picksKey = "picks"
    static let userIDKey = "userID"
    static let currentPickKey = "currentPick"
    static let isAdminKey = "isAdmin"
    static let canPickKey = "canPick"

    public class func add(value: Any, for key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public class func removeObject(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    public class func all() -> UserDefaults {
        return UserDefaults.standard
    }
    
    public class func removeAll() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
}
