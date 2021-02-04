//
//  PicksStore.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 7/10/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import Foundation
import FirebaseAuth

class Picks {
    
    static let store = Picks()
    
    var allPicks: [Int] = []
    var currentPick: Int? = nil
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private init() {
        self.allPicks = self.retrieveAll()
        self.currentPick = self.setCurrentPick()
    }
    
    public func retrieveAll() -> [Int] {
        if let allPicks = appDelegate.currentUser?.picks {
            return allPicks
        } else {
            return []
        }
    }
    
    public func setCurrentPick() -> Int? {
        if let currentPick = appDelegate.currentUser?.currentPick {
            return currentPick
        } else {
            return nil
        }
    }
    
    func removeAll() {
        self.allPicks.removeAll()
        //Defaults.add(value: allPicks, for: Defaults.picksKey)
        FirebaseClient.updatePicks(picks: allPicks)
    }
    
    func removeCurrentPick() {
        //Defaults.removeObject(key: Defaults.currentPickKey)
        self.currentPick = nil
        FirebaseClient.removeCurrentPick()
    }
    
    func addPick(id: Int) {
        self.allPicks.append(id)
        self.currentPick = id
        //Defaults.add(value: allPicks, for: Defaults.picksKey)
        //Defaults.add(value: id, for: Defaults.currentPickKey)
        FirebaseClient.updatePicks(picks: self.allPicks)
        FirebaseClient.updateCurrentPick(currentPick: id)
    }
    
    func removePick(id: Int) {
        for (index, pickID) in allPicks.enumerated() {
            if pickID == id {
                self.allPicks.remove(at: index)
                FirebaseClient.removePick(pick: id)
            }
        }
        //Defaults.add(value: allPicks, for: Defaults.picksKey)
        
    }
    
}
