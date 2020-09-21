//
//  PreviousPickTableViewCell.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 9/20/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import UIKit

class PreviousPickTableViewCell: UITableViewCell {

    @IBOutlet weak var previousPickImageView: UIImageView!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var previousPickNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
