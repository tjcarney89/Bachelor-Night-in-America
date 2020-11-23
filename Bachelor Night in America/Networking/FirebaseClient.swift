//
//  MasterAPIClient.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 6/27/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class FirebaseClient {
    
    static var ref = Database.database().reference()
    static var storage = Storage.storage().reference(forURL: "gs://bachelor-night-in-america.appspot.com")
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate

    
    class func fetchContestants(completion: @escaping ([Contestant]) -> ()) {
        var contestants: [Contestant] = []
        ref.child("contestants").observeSingleEvent(of: .value) { (snapshot) in
            if let value = snapshot.value as? [[String:Any]] {
                for (_, contestantDict) in value.enumerated() {
                    let id = contestantDict["id"] as? Int ?? 0
                    let name = contestantDict["name"] as? String ?? ""
                  
                    let age = contestantDict["age"] as? Int ?? 0
                    let hometown = contestantDict["hometown"] as? String ?? ""
                    let occupation = contestantDict["occupation"] as? String ?? ""
                    let statusString = contestantDict["status"] as? String ?? ""
                    let status = ContestantStatus.init(rawValue: statusString)
                    let imagePath = contestantDict["image_path"] as? String ?? ""
                    let bio = contestantDict["bio"] as? String ?? ""
                    let funFacts = contestantDict["fun_facts"] as? [String] ?? []
                    let newContestant = Contestant(id: id, name: name, age: age, hometown: hometown, occupation: occupation, status: status!, bio: bio, imagePath: imagePath, funFacts: funFacts)
                    contestants.append(newContestant)
                    print(contestants.count)
                    
                }
                completion(contestants)
            }
        }
    }
    
    class func fetchUser(id: String, completion: @escaping (BNIAUser) -> ()) {
        ref.child("users").child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String:Any] {
                let name = data["name"] as? String ?? ""
                let currentPick = data["currentPick"] as? Int ?? nil
                let isAdmin = data["isAdmin"] as? Bool ?? false
                let statusString = data["status"] as? String ?? "Active"
                let status = SurvivorStatus(rawValue: statusString)
                var picks: [Int] = []
                let picksDict = data["picks"] as? [String:Any] ?? [:]
                for (_, value) in picksDict.enumerated() {
                    let pick = Int(value.key) ?? 0
                    picks.append(pick)
                }
                let user = BNIAUser(id: id, name: name, currentPick: currentPick, picks: picks, isAdmin: isAdmin, status: status!)
                completion(user)
            }
        }
    }
    
    class func fetchUsers(completion: @escaping ([BNIAUser]) -> ()) {
        var users: [BNIAUser] = []
        ref.child("users").observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String:Any] {
                for userDict in data {
                    if let userInfo = userDict.value as? [String:Any] {
                        let id = userDict.key
                        let name = userInfo["name"] as? String ?? ""
                        let currentPick = userInfo["currentPick"] as? Int ?? nil
                        let isAdmin = userInfo["isAdmin"] as? Bool ?? false
                        let statusString = userInfo["status"] as? String ?? "Active"
                        let status = SurvivorStatus(rawValue: statusString)
                        var picks: [Int] = []
                        let picksDict = userInfo["picks"] as? [String:Any] ?? [:]
                        for (_, value) in picksDict.enumerated() {
                            let pick = Int(value.key) ?? 0
                            picks.append(pick)
                        }
                        let user = BNIAUser(id: id, name: name, currentPick: currentPick, picks: picks, isAdmin: isAdmin, status: status!)
                        users.append(user)
                    }
                }
                completion(users)
            }
        }
    }
    
    class func setIsAdmin(userID: String, completion: @escaping () -> ()) {
        ref.child("users").child(userID).observeSingleEvent(of: .value) { (snapshot) in
            if let data = snapshot.value as? [String:Any] {
                let name = data["name"] as? String ?? ""
                let currentPick = data["currentPick"] as? Int ?? nil
                let isAdmin = data["isAdmin"] as? Bool ?? false
                let statusString = data["status"] as? String ?? "Active"
                let status = SurvivorStatus(rawValue: statusString)
                var picks: [Int] = []
                let picksDict = data["picks"] as? [String:Any] ?? [:]
                for (key, _) in picksDict.enumerated() {
                    picks.append(key)
                }
                let user = BNIAUser(id: userID, name: name, currentPick: currentPick, picks: picks, isAdmin: isAdmin, status: status!)
                Defaults.add(value: user.isAdmin, for: Defaults.isAdminKey)
                completion()
            }
        }
    }
    
    class func updateStatus(id: Int, status: String) {
        ref.child("contestants/\(id)/status").setValue(status)
    }
    
    class func createUser(user: User) {
        guard let name = user.displayName else {return}
        ref.child("users").child(user.uid).setValue(["name": name, "isAdmin": false, "status": "Active"])
        //ref.child("users").child(user.uid).setValue(["isAdmin": false])
    }
    
    class func updatePicks(picks: [Int]) {
        for pick in picks {
            let selectedPick = String(pick)
            ref.child("users").child(self.appDelegate.currentUser!.id).child("picks").child(selectedPick).setValue(true)
            
        }
    }
    
    class func updateCurrentPick(currentPick: Int) {
        ref.child("users").child(self.appDelegate.currentUser!.id).child("currentPick").setValue(currentPick)
    }
    
    class func removeCurrentPick() {
        ref.child("users").child(self.appDelegate.currentUser!.id).child("currentPick").setValue(nil)
    }
    
    class func removePick(pick: Int) {
        let selectedPick = String(pick)
        ref.child("users").child(self.appDelegate.currentUser!.id).child("picks").child(selectedPick).removeValue()
    }
    
    class func resetAllPicks(users: [BNIAUser], completion: () -> ()) {
        for user in users {
            ref.child("users").child(user.id).child("currentPick").setValue(nil)
        }
        completion()
    }
    
    class func updateSurvivorStatus(user: BNIAUser, status: String) {
        ref.child("users").child(user.id).child("status").setValue(status)
    }
    
    
}
