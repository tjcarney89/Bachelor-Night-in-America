//
//  ResetPicksTableViewCell.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 10/24/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import UIKit

class ResetPicksTableViewCell: UITableViewCell {

    @IBOutlet weak var resetPicksButton: UIButton!
    var users: [BNIAUser] = []
    var callerVC: AdminViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.resetPicksButton.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
