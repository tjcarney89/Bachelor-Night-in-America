//
//  ContestantCollectionViewCell.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 6/27/20.
//  Copyright © 2020 TJ Carney. All rights reserved.
//

import UIKit

class ContestantCollectionViewCell: UICollectionViewCell {
        
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var xImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.contentMode = .scaleAspectFill
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOpacity = 0.75
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowRadius = 2.0
        
        cardView.layer.cornerRadius = 20
        cardView.layer.masksToBounds = true
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.overlayView.alpha = 0
        self.xImageView.isHidden = true
        self.cardView.layer.borderWidth = 0
        
    }
}
