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
        previousPickImageView.layer.cornerRadius = 20
        previousPickImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        previousPickImageView.image = nil
        previousPickImageView.layer.borderWidth = 0
    }

}
