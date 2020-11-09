//
//  BNIAUser.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 7/28/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import Foundation

struct BNIAUser {
    let id: String
    let name: String
    let currentPick: Int?
    let picks: [Int]
    let isAdmin: Bool
    let status: SurvivorStatus
}
