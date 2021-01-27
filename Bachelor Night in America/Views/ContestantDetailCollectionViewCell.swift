//
//  ContestantDetailCollectionViewCell.swift
//  Bachelor Night in America
//
//  Created by TJ Carney on 1/26/21.
//  Copyright © 2021 TJ Carney. All rights reserved.
//

import UIKit

class ContestantDetailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contestantImageView: UIImageView!
    @IBOutlet weak var nameAgeLabel: UILabel!
    @IBOutlet weak var occupationLabel: UILabel!
    @IBOutlet weak var hometownLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var funFactsTextView: UITextView!
    @IBOutlet weak var pickButton: UIButton!
    @IBOutlet weak var statusLabel: PaddingLabel!
    @IBOutlet weak var availabilityLabel: PaddingLabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bioTextView.textContainerInset = UIEdgeInsets.zero
        self.bioTextView.textContainer.lineFragmentPadding = 0
        self.statusLabel.layer.cornerRadius = 10
        self.statusLabel.layer.masksToBounds = true
        self.availabilityLabel.layer.cornerRadius = 10
        self.availabilityLabel.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        self.statusLabel.text = "Off Show"
        self.statusLabel.backgroundColor = AppColors.red
        self.availabilityLabel.text = "Unavailable"
        self.availabilityLabel.backgroundColor = AppColors.red
        self.pickButton.isEnabled = true
        self.pickButton.backgroundColor = AppColors.red
        self.pickButton.setTitle("", for: .normal)


    }
    
    func setUpIndicatorLabels(currentContestant: Contestant, hasBeenPicked: Bool, currentPick: Int?, isEliminated: Bool) {
        self.statusLabel.layer.cornerRadius = 10
        self.statusLabel.layer.masksToBounds = true
        self.availabilityLabel.layer.cornerRadius = 10
        self.availabilityLabel.layer.masksToBounds = true
        
        if currentContestant.status == .winner {
            self.statusLabel.backgroundColor = AppColors.yellow
            self.statusLabel.text = "Winner"
            self.availabilityLabel.backgroundColor = AppColors.red
            self.availabilityLabel.text = "Unavailable"
        } else if currentContestant.status == .onShow && !hasBeenPicked {
            self.statusLabel.backgroundColor = AppColors.green
            self.statusLabel.text = "On Show"
            self.availabilityLabel.backgroundColor = AppColors.green
            self.availabilityLabel.text = "Available"
        } else if currentContestant.status == .onShow && hasBeenPicked {
            self.statusLabel.backgroundColor = AppColors.green
            self.statusLabel.text = "On Show"
            if currentPick == currentContestant.id {
                self.availabilityLabel.backgroundColor = AppColors.green
                self.availabilityLabel.text = "Current Pick"
            } else {
                self.availabilityLabel.backgroundColor = AppColors.red
                self.availabilityLabel.text = "Previously Picked"
            }
        } else if currentContestant.status == .offShow {
            self.statusLabel.backgroundColor = AppColors.red
            self.statusLabel.text = "Eliminated"
            self.availabilityLabel.backgroundColor = AppColors.red
            self.availabilityLabel.text = "Unavailable"
        }
        
        if isEliminated {
            self.availabilityLabel.backgroundColor = AppColors.red
            self.availabilityLabel.text = "Unavailable"
        }
    }
    
    func setUpPickButton(currentContestant: Contestant, currentPick: Int?, pickSubmitted: Bool, isEliminated: Bool) {
        self.pickButton.layer.cornerRadius = 15
        
        if isEliminated {
            self.pickButton.setTitle("You Are Eliminated", for: .disabled)
            self.pickButton.backgroundColor = .darkGray
            self.pickButton.isEnabled = false
        } else if currentContestant.status == .winner {
            self.pickButton.isHidden = true
        }  else {
            if pickSubmitted {
                if currentPick == currentContestant.id {
                    self.pickButton.setTitle("Remove Pick", for: .normal)
                } else {
                    self.pickButton.setTitle("Change Pick", for: .normal)
                }
                
            } else {
                self.pickButton.setTitle("Pick", for: .normal)
            }
            
            if Picks.store.allPicks.contains(currentContestant.id) {
                if currentPick == currentContestant.id {
                    self.pickButton.isEnabled = true
                    self.pickButton.isHidden = false
                } else {
                    self.pickButton.isEnabled = false
                    self.pickButton.isHidden = true
                }
            } else if currentContestant.status == .offShow {
                self.pickButton.isEnabled = false
                self.pickButton.isHidden = true
            } else {
                self.pickButton.isEnabled = true
                self.pickButton.isHidden = false
            }
        }
    }
}
