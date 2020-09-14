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
    
    private init() {
        self.allPicks = self.retrieveAll()
    }
    
    public func retrieveAll() -> [Int] {
        if let allPicks = Defaults.all().array(forKey: Defaults.picksKey) as? [Int] {
            return allPicks
        } else {
            return []
        }
    }
    
    func removeAll() {
        self.allPicks.removeAll()
        Defaults.add(value: allPicks, for: Defaults.picksKey)
        FirebaseClient.updatePicks(picks: allPicks)
    }
    
    func removeCurrentPick() {
        Defaults.removeObject(key: Defaults.currentPickKey)
        FirebaseClient.removeCurrentPick()
    }
    
    func addPick(id: Int) {
        self.allPicks.append(id)
        Defaults.add(value: allPicks, for: Defaults.picksKey)
        Defaults.add(value: id, for: Defaults.currentPickKey)
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
        Defaults.add(value: allPicks, for: Defaults.picksKey)
        
    }
    
}
