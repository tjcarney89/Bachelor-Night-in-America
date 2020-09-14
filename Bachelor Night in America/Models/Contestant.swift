//
//  Contestant.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 6/23/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import Foundation
import UIKit

struct Contestant {
    let id: Int
    let name: String
    let age: Int
    let hometown: String
    let occupation: String
    let status: ContestantStatus
    let bio: String = "This is placeholder text for the evental contestant bios. The hope is that they will be released pretty soon but until then I am going to write a very long string in order to try and test the limits of the TextView. I hope this is long enough but who the hell knows."
    let imagePath: String
    
}
